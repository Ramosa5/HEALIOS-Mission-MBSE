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
        in Data : MissionPackage::OnBoardStatus;
        out Cmd : MissionPackage::OnBoardCommand;
    }

    interface def I2CInterface {
        end Rx : ~I2CPort;
        end Tx : I2CPort;
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
        port Command_In : MissionPackage::OnBoardCommand;
        port Telemetry_Out : MissionPackage::OnBoardStatus;

        port EPS_I2C : I2CPort;
        //port TCS_I2C : I2CPort;
        port Magnetorquer_Board_I2C : I2CPort;
        port Temperature_Sensor_I2C[0..*] : I2CPort;
        port Sun_Sensor_I2C[0..*] : I2CPort;
        port Irradiance_Sensor_I2C[0..*] : I2CPort;
        port Radiation_Sensor_I2C[0..*] : I2CPort;
        port Spectrometer_I2C[0..*] : I2CPort;
        port Voltage_Current_Sense_I2C[0..*] : I2CPort;
        port UHF_I2C[0..1] : I2CPort;

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
        port Power_Bus_In_3V3 : ~PowerBus;
        port Power_Bus_In_5V : ~PowerBus;

        port EPS_I2C[1] : I2CPort;
        port Magnetorquer_Board_I2C[0..2] : ~I2CPort;
        port Temperature_Sensor_I2C[0..*] : ~I2CPort;
        port Sun_Sensor_I2C[0..*] : ~I2CPort;
        port Irradiance_Sensor_I2C[0..*] : ~I2CPort;
        port Radiation_Sensor_I2C[0..*] : ~I2CPort;
        port Spectrometer_I2C[0..*] : ~I2CPort;
        port Voltage_Current_Sense_I2C[0..*] : ~I2CPort;
        port UHF_I2C[0..1] : ~I2CPort;

        port Analog_ADC_Input[0..*] : AnalogADCInput;

        part Carrier : OBCarrierBoard;

        part Primary_OBC : OnBoardComputerUnit;
        part Secondary_OBC : OnBoardComputerUnit;

        // Route primary OBC I2C controllers to system ports
        connect Primary_OBC.EPS_I2C to EPS_I2C;
        connect Primary_OBC.Temperature_Sensor_I2C to Temperature_Sensor_I2C;
        connect Primary_OBC.Magnetorquer_Board_I2C to Magnetorquer_Board_I2C;
        connect Primary_OBC.Sun_Sensor_I2C to Sun_Sensor_I2C;
        connect Primary_OBC.Irradiance_Sensor_I2C to Irradiance_Sensor_I2C;
        connect Primary_OBC.Radiation_Sensor_I2C to Radiation_Sensor_I2C;
        connect Primary_OBC.Spectrometer_I2C to Spectrometer_I2C;
        connect Primary_OBC.Voltage_Current_Sense_I2C to Voltage_Current_Sense_I2C;
        connect Primary_OBC.UHF_I2C to UHF_I2C;

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
