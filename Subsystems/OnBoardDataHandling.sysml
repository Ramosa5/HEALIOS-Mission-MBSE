package OnBoardDataHandlingSystemPackage {
    private import MissionPackage::*;
    private import SpaceActionsPackage::*;
    private import ElectricalPowerSystemPackage::*;
    public import ScalarValues::*;
    private import ISQ::*;
    public import UnitTypesPackage::*;

    // ------------------------------------------------------------------------------------------------
    // Generic data/command plumbing (abstracted physical buses)
    // ------------------------------------------------------------------------------------------------
    port def I2CPort {
        in data : MissionPackage::OnBoardStatus;
        out cmd : MissionPackage::OnBoardCommand;
    }

    interface def I2CInterface {
        end rx : ~I2CPort;
        end tx : I2CPort;
    }

    // For DAQ analog lines connected to OBC ADC inputs (DAQ chapter interface concept)
    port def analogADCInput {
        in sample : MissionPackage::OnBoardStatus;
    }

    // ------------------------------------------------------------------------------------------------
    // Memory & state types (sized per Design Report budgets)
    // ------------------------------------------------------------------------------------------------

    // value def MemorySizeMB : Real;
    // value def MemorySizekB : Real;
    part def Memory {
        attribute totalMemory : Real; // later just go for: norFlashTotal = 256 [MB];
    }

    part def NonVolatileMemory specializes Memory;
    part def VolatileMemory specializes Memory;



    // ------------------------------------------------------------------------------------------------
    // OBC building blocks
    // ------------------------------------------------------------------------------------------------

    part def OnBoardComputerUnit {
        attribute name : String;
        attribute role : String; // "Primary" / "Secondary"
        attribute warmRedundant : Boolean;

        part nvm : NonVolatileMemory;
        part ram : VolatileMemory;
        part obcTemperatureSensor : TemperatureSensor;
        // Interfaces to spacecraft subsystems (centralised OBDH routing concept)
        port toDAQ_i2c : i2cBus;
        port fromDAQ_adc : analogADCInput [0..*];

        port toEPS_i2c : i2cBus;
        port toAOCS_can : canBus;
        port toTCS_i2c : i2cBus;

        // FDIR/event interface (logical)
        port fdirEventIn : uartLink;

        // Communications subsystem interface (for command ingest + downlink forwarding)
        port toCOMMS_uart : uartLink;

        // Ground command/telemetry logical ports
        port commandIn : MissionPackage::OnBoardCommand;
        port telemetryOut : MissionPackage::OnBoardStatus;

        // Redundancy synchronisation
        port syncTx : MissionPackage::OnBoardStatus;
        port syncRx : MissionPackage::OnBoardStatus;

        perform action readOBCTemperature : ReadTemperature;
    }

    part def OBCarrierBoard {
        attribute name : String; // NanoDock DMC-3 carrier concept
    }

    // ------------------------------------------------------------------------------------------------
    // OBDH System (top-level)
    // ------------------------------------------------------------------------------------------------

    part def OnBoardDataHandlingSystem {
        // Overall interfaces (space segment level)
        port gsTelecommandIn : MissionPackage::OnBoardCommand;
        port gsTelemetryOut : MissionPackage::OnBoardStatus;

        // Subsystem links (OBDH is the hub; no direct subsystem-to-subsystem exchange)
        port daqI2C : i2cBus;
        port daqADC : analogADCInput [0..*];

        port epsI2C : i2cBus;
        port aocsCAN : canBus;
        port tcsI2C : i2cBus;

        port commUart : uartLink;

        // Redundant computing hardware
        part carrier : OBCarrierBoard;
        part primaryOBC : OnBoardComputerUnit {
            :>> role = "Primary";
            :>> warmRedundant = true;
        }
        part secondaryOBC : OnBoardComputerUnit {
            :>> role = "Secondary";
            :>> warmRedundant = true;
        }

        // Persisted synchronised subset for takeover (stored in NVM per Design Report)
        part syncState : SynchronizedState;

        // Bind external ports to primary OBC (nominal authority)
        bind primaryOBC.commandIn = gsTelecommandIn;
        bind gsTelemetryOut = primaryOBC.telemetryOut;

        // Bind subsystem buses to OBDH ports (routing through the OBC)
        bind primaryOBC.toDAQ_i2c = daqI2C;
        bind primaryOBC.fromDAQ_adc = daqADC;

        bind primaryOBC.toEPS_i2c = epsI2C;
        bind primaryOBC.toAOCS_can = aocsCAN;
        bind primaryOBC.toTCS_i2c = tcsI2C;

        bind primaryOBC.toCOMMS_uart = commUart;

        // Secondary monitors primary via synchronisation & heartbeat concept
        bind primaryOBC.syncTx = secondaryOBC.syncRx;
        bind secondaryOBC.syncTx = primaryOBC.syncRx;

        // ------------------------------------------------------------------------------------------------
        // OBDH Actions (functional concept: cyclic acquisition, state, persistent storage, downlink support)
        // ------------------------------------------------------------------------------------------------

        perform action acquireAndTimeTag : AcquireAndTimestampSubsystemData;
        perform action managePersistentStore : ManagePersistentStorageAndBuffers;
        perform action prioritizeForDownlink : SelectAndPrioritizeDownlinkData;
        perform action routeDownlinkToComms : ForwardDownlinkFramesToComms;

        perform action decodeAndValidateCmds : DecodeValidateAndDispatchCommands;
        perform action executeTimeTaggedCmds : ExecuteTimeTaggedCommands;

        perform action monitorHealthAndFDIR : PerformOBDHHealthMonitoringAndFDIR;
        perform action manageModes : ManageSpacecraftModesAndAutonomy;

        perform action manageRedundancy : ManageWarmRedundantAuthorityAndTakeover;
        perform action syncAuthorityState : SynchronizeRedundantOBCState;

        perform action updateFlightSoftware : PerformDualBankSoftwareUpdateAndRollback;

        // Bind common command/telemetry channels into actions
        bind acquireAndTimeTag.obdhCommand = gsTelecommandIn;
        bind managePersistentStore.obdhCommand = gsTelecommandIn;
        bind prioritizeForDownlink.obdhCommand = gsTelecommandIn;
        bind routeDownlinkToComms.obdhCommand = gsTelecommandIn;
        bind decodeAndValidateCmds.obdhCommand = gsTelecommandIn;
        bind executeTimeTaggedCmds.obdhCommand = gsTelecommandIn;
        bind monitorHealthAndFDIR.obdhCommand = gsTelecommandIn;
        bind manageModes.obdhCommand = gsTelecommandIn;
        bind manageRedundancy.obdhCommand = gsTelecommandIn;
        bind syncAuthorityState.obdhCommand = gsTelecommandIn;
        bind updateFlightSoftware.obdhCommand = gsTelecommandIn;

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
