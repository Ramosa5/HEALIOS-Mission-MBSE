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
            : ElectricalPowerSystemPackage::ElectricalPowerSystem [1];
        part <OBDH> SS_On_Board_Data_Handling : OnBoardDataHandlingSystem;
        part <STR> SS_Structure_And_Mechanisms : StructureSystem;
        part <AOCS> SS_Attitude_And_Orbit_Control_System : AttitudeAndOrbitControlSystem;
        part <PL> SS_Satellite_Payload : Payload;

        in port satelliteSolarEnvironment : SolarEnvironment {
            in item measuredRadiation : Real;
            in item measuredSpectrum : Real;
            in item measuredAngleBeta : Real;
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

    // itemy tutaj ktore wystepuja w systemie
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
}
