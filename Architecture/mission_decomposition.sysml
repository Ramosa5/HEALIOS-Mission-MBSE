package MissionPackage {
    public import ScalarValues::*;
    public import ISQ::*;
    public import Stakeholders_and_Concerns::*;
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


    port def CommandPort {
        in Telecommand : OnBoardCommand;
        out Telemetry : OnBoardStatus;
    }

    
    // items that flow in the system
    item def OnBoardCommand {
        attribute type : String;
    }

    item def OnBoardStatus {
        attribute type : String;
    }

    item def GroundCommand {
        attribute type : String;
    }

    item def TelemetryData {
        attribute type : String;
    }

    item def TimeTaggedStatus specializes OnBoardStatus {
        attribute timeTag : ISQ::TimeValue;
        attribute source  : String;      // "EPS", "PL_RAD", "PL_SPEC", ...
        attribute channel : String;      // optional: "I2C0", "ADC1", ...
    }

    // --- 3. Define the Detailed Space Segment ---
    public part def SpaceSegment {
        // A. Attributes

        attribute totalMass : ISQ::MassValue;
        attribute CubeSatformFactor : String;
        attribute centerOfMass : String; // e.g., "X=0.1m, Y=0.2m, Z=0.3m"

        // B. Subsystems
        part <TCS> SS_Thermal_Control_System : ThermalControlSystem;
        part <COMMS> SS_Communication_System : CommunicationsSystem;
        part <EPS> SS_Electrical_Power_System
            : ElectricalPowerSystemPackage::ElectricalPowerSystem;
        part <OBDH> SS_On_Board_Data_Handling : OnBoardDataHandlingSystem;
        part <STR> SS_Structure_And_Mechanisms : StructureSystem;
        part <AOCS> SS_Attitude_And_Orbit_Control_System : AttitudeAndOrbitControlSystem;
        part <PL> SS_Satellite_Payload : Payload;

        in port satelliteSolarEnvironment : SolarEnvironment {
            in item measuredRadiation : Real;
            in item measuredSpectrum : Real;
            in item measuredAngleBeta : Real;
        }

        port Satellite_Command_Port : CommandPort;

        connect SS_Electrical_Power_System.EPS_I2C to SS_On_Board_Data_Handling.EPS_I2C;
        //connect SS_Attitude_And_Orbit_Control_System.Magnetorquer_Board_I2C to SS_On_Board_Data_Handling.Magnetorquer_Board_I2C;
        connect SS_Satellite_Payload.Env_Sensors_Block.Temperature_Sensor_At_Environment.Temperature_Port to SS_On_Board_Data_Handling.Temperature_Sensor_I2C;
        // Payload Env Sensors -> OBDH I2C buses
        connect SS_Satellite_Payload.Env_Sensors_Block.Irradiance_Sensor_Block.Irradiance_Sensor_I2C
            to SS_On_Board_Data_Handling.Irradiance_Sensor_I2C;

        connect SS_Satellite_Payload.Env_Sensors_Block.Radiation_Dose_Sensor.Radiation_Sensor_I2C
            to SS_On_Board_Data_Handling.Radiation_Sensor_I2C;

        connect SS_Satellite_Payload.Env_Sensors_Block.Spectrometer.Spectrometer_Sensor_I2C
            to SS_On_Board_Data_Handling.Spectrometer_I2C;

        connect SS_Satellite_Payload.Iv_Sweep_And_Reverse_Bias_Block.Current_And_Voltage_Sensing_Block.Voltage_Current_Sense_I2C
            to SS_On_Board_Data_Handling.Voltage_Current_Sense_I2C;

        connect SS_Attitude_And_Orbit_Control_System.Magnetorquer_Board.Magnetorquer_Board_I2C
            to SS_On_Board_Data_Handling.Magnetorquer_Board_I2C;

        // Power distribution
        connect SS_Electrical_Power_System.Power_Bus_5V to SS_Attitude_And_Orbit_Control_System.Magnetorquer_Board.Power_Bus_In_5V;
        connect SS_Electrical_Power_System.Power_Bus_5V to SS_Communication_System.commsPowerIn;

        

        connect Satellite_Command_Port.Telecommand to SS_On_Board_Data_Handling.Telecommand_In;
        connect Satellite_Command_Port.Telemetry to SS_On_Board_Data_Handling.Telemetry_Out;

        connect SS_Communication_System.tcToOBDH.cmdOut to SS_On_Board_Data_Handling.Telecommand_In;
        connect SS_On_Board_Data_Handling.Telemetry_Out to SS_Communication_System.hkFromOBDH.hkIn;


        state Satellite_Mode {
            entry;
            then Commissioning_Mode;

            state Commissioning_Mode {
                doc /* The satellite waits for ground command */
            }
            state Safe_Mode {
                doc /* The satellite charges battery and waits for commands */
            }
            state Nominal_Sun_Mode {
                doc /* The satellite performs nominal operations during sun exposure */
            }
            state Nominal_Eclipse_Mode {
                doc /* The satellite performs nominal operations during eclipse */
            }

            transition Commissioning_To_Nominal 
                first Commissioning_Mode
                accept Proceed_To_Nominal_Command : GroundCommand via Satellite_Command_Port
                then Nominal_Sun_Mode;          
            
            transition Sun_To_Eclipse
                first Nominal_Sun_Mode
                accept Proceed_To_Eclipse_Command : OnBoardCommand via Satellite_Command_Port
                then Nominal_Eclipse_Mode;    

            transition Eclipse_To_Sun
                first Nominal_Eclipse_Mode
                accept Proceed_To_Sun_Command : OnBoardCommand via Satellite_Command_Port
                then Nominal_Sun_Mode;

            transition Safe_To_Nominal
                first Safe_Mode
                accept Proceed_To_Nominal_Command : GroundCommand via Satellite_Command_Port
                then Nominal_Sun_Mode; 

            transition Nominal_To_Safe
                first Nominal_Sun_Mode
                accept Enter_Safe_Mode_Command : OnBoardCommand via Satellite_Command_Port
                do action Enter_Safe_Mode : Enter_Safe_Mode_Action;
                then Safe_Mode;       
        }
    }
    // --- 4. Ground Segment Placeholder ---
    public part def GroundSegment {
        part <GST> Ground_Station : GroundStation;
        part <MCC> Mission_Control_Centre : MissionControlCentre;
        part <DT> Data_Centre : DataCentre;

        connect Mission_Control_Centre.tcToGS to Ground_Station.tcFromMCC;
        connect Mission_Control_Centre.passPlanToGS to Ground_Station.passPlanFromMCC;

        connect Ground_Station.tmToMCC to Mission_Control_Centre.tmFromGS;
        connect Ground_Station.trackingToMCC to Mission_Control_Centre.trackingFromGS;

        connect Ground_Station.tmToDataCentre to Data_Centre.tmFromGS;
        connect Ground_Station.archiveOut to Data_Centre.recordsFromGS;

        connect Data_Centre.tmProductsToMCC to Mission_Control_Centre.tmFromGS;
    }

    // --- 5. The Complete System ---
    public part def MissionSegments {
        public part <SS> HEALIOS_Space_Segment : SpaceSegment;
        public part <GS> HEALIOS_Ground_Segment : GroundSegment;

        attribute missionName : String;
        attribute missionDuration : ISQ::DurationValue;
        attribute orbitType : String;

        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!TBA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        //perform action performScience : PerformScienceOperations;
       // perform action operateSystem : OperateSystem;
        //perform action maintainOperability : MaintainOperability;

        connect sunEntity.sunSolarEnvironment to HEALIOS_Space_Segment.satelliteSolarEnvironment;

    }

}
