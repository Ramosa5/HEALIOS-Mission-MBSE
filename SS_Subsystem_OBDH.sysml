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
    port def DataBus {
        attribute name : String;
        in Data : MissionPackage::OnBoardStatus;
        out Cmd : MissionPackage::OnBoardCommand;
    }

    interface def I2CInterface {
        end Rx : ~DataBus;
        end Tx : DataBus;
    }

    port def AnalogADCInput {
        in Sample : MissionPackage::OnBoardStatus;
    }

    port def OutCommandPort {
        out Cmd : MissionPackage::OnBoardCommand;
    }

    // ------------------------------------------------------------------------------------------------
    // Memory & state types
    // ------------------------------------------------------------------------------------------------
    part def Memory {
        attribute Total_Memory : Real;
    }

    part def NonVolatileMemory specializes Memory;
    part def VolatileMemory specializes Memory;

    // ------------------------------------------------------------------------------------------------
    // OBC building blocks
    // ------------------------------------------------------------------------------------------------
    part def Magnetometer :> GeneralElectricalComponent {
        attribute Force : Real;
        attribute Axes : Integer;
    }

    part def Gyroscope :> GeneralElectricalComponent {
        attribute Axes : Integer;
    }

    part def OnBoardComputerUnit {
        attribute Name : String;
        attribute Role : String;
        attribute Warm_Redundant : Boolean;

        part NVM : NonVolatileMemory;
        part RAM : VolatileMemory;
        part OBC_Temperature_Sensor : TemperatureSensor;
        part OBC_Gyroscope : Gyroscope;
        part OBC_Magnetometer : Magnetometer;

        port Analog_ADC_Input[0..*] : AnalogADCInput;

        port Data_Bus[1] : DataBus;

        perform action Read_OBC_Temperature : ReadTemperature;
    }

    part def OBCarrierBoard {
        attribute Name : String;
    }

    // ------------------------------------------------------------------------------------------------
    // OBDH System (top-level)
    // ------------------------------------------------------------------------------------------------
    part def OnBoardDataHandlingSystem {
        port Telecommand_In : MissionPackage::GroundCommand;
        port Telemetry_Out : MissionPackage::OnBoardStatus;
        port Out_Command_Port[0..*] : OutCommandPort;
        port Power_Bus_3V3 : ~PowerBus;
        port Power_Bus_5V : ~PowerBus;

        port Data_Bus[1] : DataBus;

        port Analog_ADC_Input[0..*] : AnalogADCInput;

        part Carrier : OBCarrierBoard;

        part Primary_OBC : OnBoardComputerUnit;
        part Secondary_OBC : OnBoardComputerUnit;

        // ------------------------------------------------------------------------------------------------
        // OBDH Actions
        // ------------------------------------------------------------------------------------------------
        perform action Acquire_And_Time_Tag : AcquireAndTimestampSubsystemData;
        perform action Manage_Persistent_Store : ManagePersistentStorageAndBuffers;
        perform action Prioritize_For_Downlink : SelectAndPrioritizeDownlinkData;
        perform action Route_Downlink_To_Comms : ForwardDownlinkFramesToComms;

        perform action Decode_And_Validate_Cmds : DecodeValidateAndDispatchCommands;
        perform action Execute_Time_Tagged_Cmds : ExecuteTimeTaggedCommands;

        perform action Monitor_Health_And_FDIR : PerformOBDHHealthMonitoringAndFDIR;
        perform action Manage_Modes : ManageSpacecraftModesAndAutonomy;

        perform action Manage_Redundancy : ManageWarmRedundantAuthorityAndTakeover;
        perform action Sync_Authority_State : SynchronizeRedundantOBCState;

        perform action Update_Flight_Software : PerformDualBankSoftwareUpdateAndRollback;

        // Bind command distribution
        bind Acquire_And_Time_Tag.Obdh_Command = Telecommand_In;
        bind Manage_Persistent_Store.Obdh_Command = Telecommand_In;
        bind Prioritize_For_Downlink.Obdh_Command = Telecommand_In;
        bind Route_Downlink_To_Comms.Obdh_Command = Telecommand_In;
        bind Decode_And_Validate_Cmds.Obdh_Command = Telecommand_In;
        bind Execute_Time_Tagged_Cmds.Obdh_Command = Telecommand_In;
        bind Monitor_Health_And_FDIR.Obdh_Command = Telecommand_In;
        bind Manage_Modes.Obdh_Command = Telecommand_In;
        bind Manage_Redundancy.Obdh_Command = Telecommand_In;
        bind Sync_Authority_State.Obdh_Command = Telecommand_In;
        bind Update_Flight_Software.Obdh_Command = Telecommand_In;

        // Bind telemetry aggregation
        bind Telemetry_Out = Acquire_And_Time_Tag.Obdh_Telemetry;
        bind Telemetry_Out = Manage_Persistent_Store.Obdh_Telemetry;
        bind Telemetry_Out = Prioritize_For_Downlink.Obdh_Telemetry;
        bind Telemetry_Out = Route_Downlink_To_Comms.Obdh_Telemetry;
        bind Telemetry_Out = Decode_And_Validate_Cmds.Obdh_Telemetry;
        bind Telemetry_Out = Execute_Time_Tagged_Cmds.Obdh_Telemetry;
        bind Telemetry_Out = Monitor_Health_And_FDIR.Obdh_Telemetry;
        bind Telemetry_Out = Manage_Modes.Obdh_Telemetry;
        bind Telemetry_Out = Manage_Redundancy.Obdh_Telemetry;
        bind Telemetry_Out = Sync_Authority_State.Obdh_Telemetry;
        bind Telemetry_Out = Update_Flight_Software.Obdh_Telemetry;
    }
}
