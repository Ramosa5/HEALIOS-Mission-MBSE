package MissionPackage {
    public import ScalarValues::*;
    private import Quantities::*;
    public import ISQ::*;
    public import StakeholdersDefinitionPackage::*;
    public import Environment::*;
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
    private import MissionControlCentrePackage::*;

    // PORTS
    
    port def TelecommandPort {
        out item TC : GroundCommand;
    }

    port def TelemetryPort {
        out item TM : TelemetryData;
    }


    // Obsolete port, used in the AOCS and COMMS.
    // --------------------TBA: Refactor to use the above TelecommandPort and TelemetryPort instead-------------------
    port def TmTcPort {
        out item Telecommand : GroundCommand;
        in item Telemetry : TelemetryData;
    }

    // Ground-to-Space Connection: Nominal Perspective

    // ITEMS
    item def OnBoardCommand {
        attribute Type : String;
    }

    item def OnBoardStatus {
        attribute Type : String;
    }

    item def GroundCommand {
        attribute Type : String;
    }

    item def OnBoardData {
        attribute Type : String;
    }
    item def ScienceData specializes OnBoardData {
        attribute Data_Product_Type : String; // e.g., "Radiation_Spectrum", "Irradiance_Profile", ...
    }

    item def HousekeepingData specializes OnBoardData {
        attribute Subsystem : String; // e.g., "EPS", "AOCS", "Thermal", ...
        attribute Parameter : String; // e.g., "Battery_Voltage", "Magnetometer_X", "Temperature_Sensor_1", ...
    }

    item def TelemetryData {
        attribute Type : String;

        item Science_Data : ScienceData;
        item Housekeeping_Data : HousekeepingData;
    }

    item def TimeTaggedStatus specializes OnBoardStatus {
        attribute Time_Tag : ISQ::TimeValue;
        attribute Source : String; // "EPS", "PL_RAD", "PL_SPEC", ...
        attribute Channel : String; // optional: "I2C0", "ADC1", ...
    }


    
    public part def SpaceSegment {
        // A. Attributes
        
        attribute Total_Mass : ISQ::MassValue;
        attribute CubeSat_Form_Factor : String;
        attribute Center_Of_Mass : String; // e.g., "X=0.1m, Y=0.2m, Z=0.3m"

        port Telecommand_Port : ~TelecommandPort;
        port Telemetry_Port : TelemetryPort;

        // B. Subsystems
        part <TCS> SS_Thermal_Control_System : ThermalControlSystem;
        part <COMMS> SS_Communication_System : CommunicationsSystem;
        part <EPS> SS_Electrical_Power_System : ElectricalPowerSystemPackage::ElectricalPowerSystem;
        part <OBDH> SS_On_Board_Data_Handling : OnBoardDataHandlingSystem;
        part <STR> SS_Structure_And_Mechanisms : StructureSystem;
        part <AOCS> SS_Attitude_And_Orbit_Control_System : AttitudeAndOrbitControlSystem;
        part <PL> SS_Satellite_Payload : Payload;

        in port satelliteSolarEnvironment : SolarEnvironment {
            in item Measured_Radiation : Real;
            in item Measured_Spectrum : Real;
            in item Measured_Beta_Angle : Real;
        }

        connect SS_Electrical_Power_System.EPS_I2C to SS_On_Board_Data_Handling.EPS_I2C;
        // connect SS_Attitude_And_Orbit_Control_System.Magnetorquer_Board_I2C to SS_On_Board_Data_Handling.Magnetorquer_Board_I2C;
        connect SS_Satellite_Payload.Env_Sensors_Block.Temperature_Sensor_At_Environment
                        .Temperature_Port to SS_On_Board_Data_Handling.Temperature_Sensor_I2C;
        // Payload Env Sensors -> OBDH I2C buses
        connect SS_Satellite_Payload.Env_Sensors_Block.Irradiance_Sensor_Block.Irradiance_Sensor_I2C
            to SS_On_Board_Data_Handling.Irradiance_Sensor_I2C;

        connect SS_Satellite_Payload.Env_Sensors_Block.Radiation_Dose_Sensor.Radiation_Sensor_I2C
            to SS_On_Board_Data_Handling.Radiation_Sensor_I2C;

        connect SS_Satellite_Payload.Env_Sensors_Block.Spectrometer.Spectrometer_Sensor_I2C
            to SS_On_Board_Data_Handling.Spectrometer_I2C;

        connect SS_Satellite_Payload.Iv_Sweep_And_Reverse_Bias_Block
                        .Current_And_Voltage_Sensing_Block.Voltage_Current_Sense_I2C
            to SS_On_Board_Data_Handling.Voltage_Current_Sense_I2C;

        connect SS_Attitude_And_Orbit_Control_System.Magnetorquer_Board.Magnetorquer_Board_I2C
            to SS_On_Board_Data_Handling.Magnetorquer_Board_I2C;

        // Power distribution
        connect SS_Electrical_Power_System.Power_Bus_5V
            to SS_Attitude_And_Orbit_Control_System.Magnetorquer_Board.Power_Bus_In_5V;
        connect SS_Electrical_Power_System.Power_Bus_5V to SS_Communication_System.EPS_Power_Port;
        connect SS_Electrical_Power_System.Power_Bus_3V3
            to SS_Attitude_And_Orbit_Control_System.Sun_Sensor.Power_Bus_In_3V3;

        // Telemetry
        connect Telecommand_Port to SS_On_Board_Data_Handling.Telecommand_In;
        connect Telemetry_Port to SS_On_Board_Data_Handling.Telemetry_Out;

        connect SS_Communication_System.DEC_AUTH_Action.Cmd_Out
            to SS_On_Board_Data_Handling.Telecommand_In;
        connect SS_On_Board_Data_Handling.Telemetry_Out to SS_Communication_System.OBDH_HK_Port.HK;

        // Commands
        connect SS_On_Board_Data_Handling.Out_Command_Port to SS_Thermal_Control_System.Command_IN;
        connect SS_On_Board_Data_Handling.Out_Command_Port
            to SS_Attitude_And_Orbit_Control_System.AOCS_Command_In;

        state Satellite_Mode;
    }
    // --- 4. Ground Segment Placeholder ---
    public part def GroundSegment {
        part <GST> Ground_Station : GroundStation;
        part <MCC> Mission_Control_Centre : MissionControlCentre;
        part <DT> Data_Centre : DataCentre;
        
        port Telecommand_Port : TelecommandPort;
        port Telemetry_Port : ~TelemetryPort;

        connect Mission_Control_Centre.Ground_Station_TC_Port
            to Ground_Station.Mission_Control_Centre_TC_Port;
        connect Mission_Control_Centre.Ground_Station_Pass_Plan_Port
            to Ground_Station.Mission_Control_Centre_Pass_Plan_Port;

        connect Ground_Station.Mission_Control_Centre_TM_Port
            to Mission_Control_Centre.Ground_Station_TM_Port;
        connect Ground_Station.Mission_Control_Centre_Tracking_Port
            to Mission_Control_Centre.Ground_Station_Tracking_Port;

        connect Ground_Station.Data_Centre_TM_Port to Data_Centre.Ground_Station_TM_Port;
        connect Ground_Station.Data_Centre_Archive_Port to Data_Centre.Ground_Station_Records_Port;

        connect Data_Centre.Mission_Control_Centre_TM_Products_Port
            to Mission_Control_Centre.Ground_Station_TM_Port;
    }

    // --- 5. The Complete System ---
    public part def MissionSegments {
        public part <SS> Space_Segment : SpaceSegment;
        public part <GS> Ground_Segment : GroundSegment;

        attribute missionName : String;
        attribute missionDuration : ScalarQuantityValue;
        attribute orbitType : String;

        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!TBA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        // perform action performScience : PerformScienceOperations;
        // perform action operateSystem : OperateSystem;
        // perform action maintainOperability : MaintainOperability;

        
        connect Sun_Entity.Sun_Solar_Environment to Space_Segment.satelliteSolarEnvironment;

        connection Uplink connect Ground_Segment.Telecommand_Port to Space_Segment.Telecommand_Port;
        connection Downlink connect Space_Segment.Telemetry_Port to Ground_Segment.Telemetry_Port;

    }
}
