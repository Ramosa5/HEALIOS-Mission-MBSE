package OnBoardDataHandlingSystemPackage {
    private import HEALIOS::*;
    private import HEALIOS_Space_Functions::*;
    private import ISQ::*;   
    private import ElectricalPowerSystemPackage::*;

    //------------------------------------------------------------------------------------------------
    // Generic data/command plumbing (abstracted physical buses)
    //------------------------------------------------------------------------------------------------

    port def i2cBus {
        in  rx : HEALIOS::OnBoardStatus;
        out tx : HEALIOS::OnBoardCommand;
    }

    port def canBus {
        in  rx : HEALIOS::OnBoardStatus;
        out tx : HEALIOS::OnBoardCommand;
    }

    port def uartLink {
        in  rx : HEALIOS::OnBoardStatus;
        out tx : HEALIOS::OnBoardCommand;
    }

    // For DAQ analog lines connected to OBC ADC inputs (DAQ chapter interface concept)
    port def analogADCInput {
        in sample : HEALIOS::OnBoardStatus;
    }

    //------------------------------------------------------------------------------------------------
    // Memory & state types (sized per Design Report budgets)
    //------------------------------------------------------------------------------------------------

    value def MemorySizeMB : Real;
    value def MemorySizekB : Real;

    part def NonVolatileMemory {
        attribute norFlashTotal : MemorySizeMB;

        // Budget elements from Design Report memory section:
        attribute downlinkBuffer : MemorySizeMB;
        attribute obsW_bankA     : MemorySizeMB;
        attribute obsW_bankB     : MemorySizeMB;
        attribute eventFdirLogs  : MemorySizeMB;
        attribute fsMetadata     : MemorySizeMB;
        attribute configData     : MemorySizeMB;
        attribute obcSyncData    : MemorySizeMB;
        attribute margin         : MemorySizeMB;
    }

    part def VolatileMemory {
        attribute ramTotal : MemorySizeMB;

        attribute inputsReadBuffer   : MemorySizeMB;
        attribute downlinkTxBuffer   : MemorySizeMB;
        attribute logsTelemetryBuf   : MemorySizeMB;
        attribute systemStateData    : MemorySizeMB;
        attribute rtosObswOverhead   : MemorySizeMB;
        attribute margin             : MemorySizeMB;
    }

    // Explicit “synchronised subset” for warm redundancy takeover
    part def SynchronizedState {
        attribute spacecraftMode : String;        // e.g., Deployment / Nominal / Safe
        attribute missionTimeTag : String;        // mission time / RTC snapshot identifier
        attribute powerClass     : String;        // power classification / load priority band
        attribute thermalClass   : String;        // thermal classification state
        attribute payloadState   : String;        // payload/DAQ enable & phase
        attribute dataHandlingState : String;     // buffer pointers / downlink selection state
        attribute execContextId  : String;        // current timeline/sequence identifier
        attribute authorityRole  : String;        // "Primary" or "Secondary"
    }

    //------------------------------------------------------------------------------------------------
    // OBC building blocks
    //------------------------------------------------------------------------------------------------

    part def OnBoardComputerUnit {
        attribute name : String;
        attribute role : String;          // "Primary" / "Secondary"
        attribute warmRedundant : Boolean;

        part nvm : NonVolatileMemory;
        part ram : VolatileMemory;
        part obcTemperatureSensor : TemperatureSensor;
        // Interfaces to spacecraft subsystems (centralised OBDH routing concept)
        port toDAQ_i2c      : i2cBus;
        port fromDAQ_adc[0..*] : analogADCInput;

        port toEPS_i2c      : i2cBus;
        port toAOCS_can     : canBus;
        port toTCS_i2c      : i2cBus;

        // FDIR/event interface (logical)
        port fdirEventIn    : uartLink;

        // Communications subsystem interface (for command ingest + downlink forwarding)
        port toCOMMS_uart   : uartLink;

        // Ground command/telemetry logical ports
        port commandIn      : HEALIOS::OnBoardCommand;
        port telemetryOut   : HEALIOS::OnBoardStatus;

        // Redundancy synchronisation
        port syncTx         : HEALIOS::OnBoardStatus;
        port syncRx         : HEALIOS::OnBoardStatus;
    }

    part def OBCarrierBoard {
        attribute name : String; // NanoDock DMC-3 carrier concept
    }

    //------------------------------------------------------------------------------------------------
    // OBDH System (top-level)
    //------------------------------------------------------------------------------------------------

    part def OnBoardDataHandlingSystem {

        // Overall interfaces (space segment level)
        port gsTelecommandIn  : HEALIOS::OnBoardCommand;
        port gsTelemetryOut   : HEALIOS::OnBoardStatus;

        // Subsystem links (OBDH is the hub; no direct subsystem-to-subsystem exchange)
        port daqI2C           : i2cBus;
        port daqADC[0..*]     : analogADCInput;

        port epsI2C           : i2cBus;
        port aocsCAN          : canBus;
        port tcsI2C           : i2cBus;

        port commUart         : uartLink;

        // Redundant computing hardware
        part carrier : OBCarrierBoard;
        part primaryOBC   : OnBoardComputerUnit { :>> role = "Primary";  :>> warmRedundant = true; }
        part secondaryOBC : OnBoardComputerUnit { :>> role = "Secondary";:>> warmRedundant = true; }

        // Persisted synchronised subset for takeover (stored in NVM per Design Report)
        part syncState : SynchronizedState;

        // Bind external ports to primary OBC (nominal authority)
        bind primaryOBC.commandIn    = gsTelecommandIn;
        bind gsTelemetryOut          = primaryOBC.telemetryOut;

        // Bind subsystem buses to OBDH ports (routing through the OBC)
        bind primaryOBC.toDAQ_i2c    = daqI2C;
        bind primaryOBC.fromDAQ_adc  = daqADC;

        bind primaryOBC.toEPS_i2c    = epsI2C;
        bind primaryOBC.toAOCS_can   = aocsCAN;
        bind primaryOBC.toTCS_i2c    = tcsI2C;

        bind primaryOBC.toCOMMS_uart = commUart;

        // Secondary monitors primary via synchronisation & heartbeat concept
        bind primaryOBC.syncTx       = secondaryOBC.syncRx;
        bind secondaryOBC.syncTx     = primaryOBC.syncRx;

        //------------------------------------------------------------------------------------------------
        // OBDH Actions (functional concept: cyclic acquisition, state, persistent storage, downlink support)
        //------------------------------------------------------------------------------------------------

        perform action acquireAndTimeTag      : AcquireAndTimestampSubsystemData;
        perform action managePersistentStore  : ManagePersistentStorageAndBuffers;
        perform action prioritizeForDownlink  : SelectAndPrioritizeDownlinkData;
        perform action routeDownlinkToComms   : ForwardDownlinkFramesToComms;

        perform action decodeAndValidateCmds  : DecodeValidateAndDispatchCommands;
        perform action executeTimeTaggedCmds  : ExecuteTimeTaggedCommands;

        perform action monitorHealthAndFDIR   : PerformOBDHHealthMonitoringAndFDIR;
        perform action manageModes            : ManageSpacecraftModesAndAutonomy;

        perform action manageRedundancy       : ManageWarmRedundantAuthorityAndTakeover;
        perform action syncAuthorityState     : SynchronizeRedundantOBCState;

        perform action updateFlightSoftware   : PerformDualBankSoftwareUpdateAndRollback;

        // Bind common command/telemetry channels into actions
        bind acquireAndTimeTag.obdhCommand        = gsTelecommandIn;
        bind managePersistentStore.obdhCommand    = gsTelecommandIn;
        bind prioritizeForDownlink.obdhCommand    = gsTelecommandIn;
        bind routeDownlinkToComms.obdhCommand     = gsTelecommandIn;
        bind decodeAndValidateCmds.obdhCommand    = gsTelecommandIn;
        bind executeTimeTaggedCmds.obdhCommand    = gsTelecommandIn;
        bind monitorHealthAndFDIR.obdhCommand     = gsTelecommandIn;
        bind manageModes.obdhCommand              = gsTelecommandIn;
        bind manageRedundancy.obdhCommand         = gsTelecommandIn;
        bind syncAuthorityState.obdhCommand       = gsTelecommandIn;
        bind updateFlightSoftware.obdhCommand     = gsTelecommandIn;

        bind gsTelemetryOut = acquireAndTimeTag.obdhTelemetry;
        bind gsTelemetryOut = managePersistentStore.obdhTelemetry;
        bind gsTelemetryOut = prioritizeForDownlink.obdhTelemetry;
        bind gsTelemetryOut = routeDownlinkToComms.obdhTelemetry;
        bind gsTelemetryOut = decodeAndValidateCmds.obdhTelemetry;
        bind gsTelemetryOut = executeTimeTaggedCmds.obdhTelemetry;
        bind gsTelemetryOut = monitorHealthAndFDIR.obdhTelemetry;
        bind gsTelemetryOut = manageModes.obdhTelemetry;
        bind gsTelemetryOut = manageRedundancy.obdhTelemetry;
        bind gsTelemetryOut = syncAuthorityState.obdhTelemetry;
        bind gsTelemetryOut = updateFlightSoftware.obdhTelemetry;
    }
}
