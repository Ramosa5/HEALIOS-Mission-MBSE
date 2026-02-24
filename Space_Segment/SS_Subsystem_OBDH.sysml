package OnBoardDataHandlingSystemPackage {
    private import MissionPackage::*;
    private import SpaceActionsPackage::*;
    private import ElectricalPowerSystemPackage::*;
    public import ScalarValues::*;
    private import ISQ::*;
    public import UnitTypesPackage::*;

    port def DataBus {
        attribute name : String;
        in data : MissionPackage::OnBoardStatus;
        out cmd : MissionPackage::OnBoardCommand;
    }

    interface def DataBusInterface {
        end rx : ~DataBus;
        end tx : DataBus;
    }

    connection def DataBusConnection {
        end part power_Source_Subsystem  : PowerSourceSubsystem crosses power_Sink_Subsystem.provided_Power_By;
        end part power_Sink_Subsystem: PowerSinkSubsystem   crosses power_Source_Subsystem.providing_Power_To;

        interface : DataBusInterface
            connect power_Source_Subsystem.power_Bus to power_Sink_Subsystem.power_Bus;
    }

    port def AnalogADCInput {
        in sample : MissionPackage::OnBoardStatus;
    }

    port def OutCommandPort {
        out cmd : MissionPackage::OnBoardCommand;
    }

    part def Memory {
        attribute total_Memory : Real;
    }

    part def NonVolatileMemory specializes Memory;
    part def VolatileMemory specializes Memory;

    part def Magnetometer :> GeneralElectricalComponent {
        attribute force : Real;
        attribute axes : Integer;
    }

    part def Gyroscope :> GeneralElectricalComponent {
        attribute axes : Integer;
    }

    part def OnBoardComputerUnit {
        attribute name : String;
        attribute role : String;
        attribute redundant : Redundancy;

        part ROM : NonVolatileMemory;
        part RAM : VolatileMemory;
        part OBC_Temperature_Sensor : TemperatureSensor;
        part OBC_Gyroscope : Gyroscope;
        part OBC_Magnetometer : Magnetometer;

        port analog_ADC_Input[0..*] : AnalogADCInput;

        port data_Bus[1] : DataBus;

        perform action read_OBC_Temperature : ReadTemperature;
    }

    part def OBCarrierBoard {
        attribute name : String;
    }

    part def OnBoardDataHandlingSystem :> PowerSinkSubsystem {
        port telecommand_In : MissionPackage::GroundCommand;
        port telemetry_Out : MissionPackage::OnBoardStatus;
        port out_Command_Port[0..*] : OutCommandPort;
        port power_Bus_3V3 : ~PowerBus;
        port power_Bus_5V : ~PowerBus;

        port data_Bus[1] : DataBus;

        port analog_ADC_Input[0..*] : AnalogADCInput;

        part carrier : OBCarrierBoard;

        part primary_OBC : OnBoardComputerUnit;
        part secondary_OBC : OnBoardComputerUnit;

        perform action prepare_Data : PrepareData;
        perform action manage_Persistent_Store : ManagePersistentStorageAndBuffers;
        perform action prioritize_For_Downlink : SelectAndPrioritizeDownlinkData;
        perform action route_Downlink_To_Comms : ForwardDownlinkFramesToComms;

        perform action decode_And_Validate_Cmds : DecodeValidateAndDispatchCommands;
        perform action execute_Time_Tagged_Cmds : ExecuteTimeTaggedCommands;

        perform action monitor_Health_And_FDIR : PerformOBDHHealthMonitoringAndFDIR;
        perform action manage_Modes : ManageSpacecraftModesAndAutonomy;

        perform action manage_Redundancy : ManageWarmRedundantAuthorityAndTakeover;
        perform action sync_Authority_State : SynchronizeRedundantOBCState;

        perform action update_Flight_Software : PerformDualBankSoftwareUpdateAndRollback;

        bind prepare_Data.Data_In = data_Bus.cmd;
        bind manage_Persistent_Store.Obdh_Command = telecommand_In;
        bind prioritize_For_Downlink.Obdh_Command = telecommand_In;
        bind route_Downlink_To_Comms.Obdh_Command = telecommand_In;
        bind decode_And_Validate_Cmds.Obdh_Command = telecommand_In;
        bind execute_Time_Tagged_Cmds.Obdh_Command = telecommand_In;
        bind monitor_Health_And_FDIR.Obdh_Command = telecommand_In;
        bind manage_Modes.Obdh_Command = telecommand_In;
        bind manage_Redundancy.Obdh_Command = telecommand_In;
        bind sync_Authority_State.Obdh_Command = telecommand_In;
        bind update_Flight_Software.Obdh_Command = telecommand_In;

        bind prepare_Data.Time_Tagged_Packed_Data = telemetry_Out;
        bind telemetry_Out = manage_Persistent_Store.Obdh_Telemetry;
        bind telemetry_Out = prioritize_For_Downlink.Obdh_Telemetry;
        bind telemetry_Out = route_Downlink_To_Comms.Obdh_Telemetry;
        bind telemetry_Out = decode_And_Validate_Cmds.Obdh_Telemetry;
        bind telemetry_Out = execute_Time_Tagged_Cmds.Obdh_Telemetry;
        bind telemetry_Out = monitor_Health_And_FDIR.Obdh_Telemetry;
        bind telemetry_Out = manage_Modes.Obdh_Telemetry;
        bind telemetry_Out = manage_Redundancy.Obdh_Telemetry;
        bind telemetry_Out = sync_Authority_State.Obdh_Telemetry;
        bind telemetry_Out = update_Flight_Software.Obdh_Telemetry;
    }
}
