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

    part def Subsystem {
        doc /* High level part for a satellite subsystem */
    }
    
    public part def SpaceSegment {
        attribute total_Mass : ISQ::MassValue;
        attribute cubeSat_Form_Factor : String;
        attribute center_Of_Mass : String; // e.g., "X=0.1m, Y=0.2m, Z=0.3m"

        port telecommand_Port : ~TelecommandPort;
        port telemetry_Port : TelemetryPort;

        port deployment_Interface : ~LaunchEnvironment::DispenserContactInterface;

        part <tcs> ss_Thermal_Control_System : ThermalControlSystem;
        part <comms> ss_Communication_System : CommunicationsSystem;
        part <eps> ss_Electrical_Power_System : ElectricalPowerSystemPackage::ElectricalPowerSystem;
        part <obdh> ss_On_Board_Data_Handling : OnBoardDataHandlingSystem;
        part <str> ss_Structure_And_Mechanisms : StructureSystem;
        part <aocs> ss_Attitude_And_Orbit_Control_System : AttitudeAndOrbitControlSystem;
        part <pl> ss_Satellite_Payload : Payload;

        in port satellite_Solar_Environment : ~StellarEnvironment;

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

        connect mission_Control_Centre.ground_Station_TC_Port
            to ground_Station.mission_Control_Centre_TC_Port;
        connect mission_Control_Centre.ground_Station_Pass_Plan_Port
            to ground_Station.mission_Control_Centre_Pass_Plan_Port;

        connect ground_Station.mission_Control_Centre_TM_Port
            to mission_Control_Centre.ground_Station_TM_Port;
        connect ground_Station.mission_Control_Centre_Tracking_Port
            to mission_Control_Centre.ground_Station_Tracking_Port;

        connect ground_Station.Data_Centre_TM_Port to data_Centre.ground_Station_TM_Port;
        connect ground_Station.Data_Centre_Archive_Port to data_Centre.ground_Station_Records_Port;

        connect data_Centre.mission_Control_Centre_TM_Products_Port
            to mission_Control_Centre.ground_Station_TM_Port;
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
