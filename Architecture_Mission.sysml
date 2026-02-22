package MissionPackage {
    public import ScalarValues::*;
    private import Quantities::*;
    public import ISQ::*;
    public import StakeholdersDefinitionPackage::*;
    public import EnvironmentPackage::*;
    private import ElectricalPowerSystemPackage::*;
    private import PayloadPackage::*;
    private import ThermalControlSystemPackage::*;
    private import OnBoardDataHandlingSystemPackage::*;
    private import CommunicationsSystemPackage::*;
    private import StructureSystemPackage::*;
    private import AttitudeAndOrbitControlSystemPackage::*;
    public part def Software;
    private import GroundStationPackage::*;
    private import DataCentrePackage::*;
    private import ManagementEnvironment::*;
    private import MissionControlCentrePackage::*;

    port def TelecommandPort {
        out item tc : GroundCommand;
    }

    port def TelemetryPort {
        out item tm : TelemetryData;
    }

    port def TmTcPort {
        out item telecommand : GroundCommand;
        in item telemetry : TelemetryData;
    }

    item def OnBoardCommand {
        attribute type : String;
    }

    item def OnBoardStatus {
        attribute type : String;
    }

    item def GroundCommand {
        attribute type : String;
    }

    item def OnBoardData {
        attribute type : String;
    }
    item def ScienceData specializes OnBoardData {
        attribute data_Product_Type : String; // e.g., "Radiation_Spectrum", "Irradiance_Profile", ...
    }

    item def HousekeepingData specializes OnBoardData {
        attribute subsystem : String; // e.g., "EPS", "AOCS", "Thermal", ...
        attribute parameter : String; // e.g., "Battery_Voltage", "Magnetometer_X", "Temperature_Sensor_1", ...
    }

    item def TelemetryData {
        attribute type : String;

        item science_Data : ScienceData;
        item housekeeping_Data : HousekeepingData;
    }

    item def ProcessedScienceData specializes ScienceData {
        attribute processing_Level : String;
    }

    item def Dataset {
        item data_Products : ScienceData [0..*];
        item housekeeping_Records : HousekeepingData [0..*];
        item mission_Documentation : MissionDocumentation [0..*];
    }

    item def TimeTaggedStatus specializes OnBoardStatus {
        attribute time_Tag : ISQ::TimeValue;
        attribute source : String; // "EPS", "PL_RAD", "PL_SPEC", ...
        attribute channel : String; // optional: "I2C0", "ADC1", ...
    }

    part def <SS> Subsystem {
        doc
        /* High level part for a satellite subsystem */
    }

    public part def SpaceSegment {
        attribute total_Mass : ISQ::MassValue;
        attribute cubeSat_Form_Factor : String;
        attribute center_Of_Mass : String; // e.g., "X=0.1m, Y=0.2m, Z=0.3m"

        port telecommand_Port : ~TelecommandPort;
        port telemetry_Port : TelemetryPort;

        port deployment_Interface : ~LaunchEnvironment::DispenserContactInterface;

        part subsystems : Subsystem [2..*];
        part <tcs> ss_Thermal_Control_System : ThermalControlSystem subsets subsystems;
        part <comms> ss_Communication_System : CommunicationsSystem subsets subsystems;
        part <eps> ss_Electrical_Power_System
            : ElectricalPowerSystemPackage::ElectricalPowerSystem subsets subsystems;
        part <obdh> ss_On_Board_Data_Handling : OnBoardDataHandlingSystem subsets subsystems;
        part <str> ss_Structure_And_Mechanisms : StructureSystem subsets subsystems;
        part <aocs> ss_Attitude_And_Orbit_Control_System
            : AttitudeAndOrbitControlSystem subsets subsystems;
        part <pl> ss_Satellite_Payload : Payload subsets subsystems;

        in port satellite_Solar_Environment : ~StellarEnvironment;

        connection power_Bus_Connections_5V : PowerBusConnection5V
            connect [1] ss_Electrical_Power_System to [7] subsystems;
        connection power_Bus_Connections_3V3 : PowerBusConnection3V3
            connect [1] ss_Electrical_Power_System to [7] subsystems;

        connection subsets power_Bus_Connections_5V {
            end [1] part
                :>> ss_Electrical_Power_System references SpaceSegment::ss_Electrical_Power_System;
            end [1] part :>> ss_Satellite_Payload references SpaceSegment::ss_Satellite_Payload;
        }
        connection subsets power_Bus_Connections_5V {
            end [1] part
                :>> ss_Electrical_Power_System references SpaceSegment::ss_Electrical_Power_System;
            end [1] part
                :>> ss_On_Board_Data_Handling references SpaceSegment::ss_On_Board_Data_Handling;
        }

        connection subsets power_Bus_Connections_3V3 {
            end [1] part
                :>> ss_Electrical_Power_System references SpaceSegment::ss_Electrical_Power_System;
            end [1] part :>> ss_Satellite_Payload references SpaceSegment::ss_Satellite_Payload;
        }

        state satellite_Mode {
            in abstract port switch_Command : DataBus;
        }
    }

    public part def GroundSegment {
        part <gst> ground_Station : GroundStation;
        part <mcc> mission_Control_Centre : MissionControlCentre;
        part <dt> data_Centre : DataCentre;

        port telecommand_Port : TelecommandPort;
        port telemetry_Port : ~TelemetryPort;
    }

    public part def OperationalStructure {
        public part <ss> space_Segment : SpaceSegment;
        public part <gs> ground_Segment : GroundSegment;

        attribute mission_Name : String;
        attribute mission_Duration : Quantities::TensorQuantityValue;
        attribute orbit_Type : String;

        connection uplink connect ground_Segment.telecommand_Port to space_Segment.telecommand_Port;
        connection downlink connect space_Segment.telemetry_Port to ground_Segment.telemetry_Port;
    }
}
