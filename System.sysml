package HEALIOS {
    public import ScalarValues::*;
    public import ISQ::*;
    public import Stakeholders_and_Concerns::*;
    public import Environment::*;
    public import HEALIOS_Functions::*;
    public part def Software;

    public part def CommunicationSystem;
    public part def ElectricalPowerSystem;
    public part def OnBoardDataHandling;
    public part def StructureAndMechanisms;
    public part def DataAcquisition;
    public part def AttitudeAndOrbitControlSystem;
    public part def Payload;
    public part def GroundStation;
    public part def MissionOperationsCentre;
    public part def ThermalControlSystem;

    // --- 3. Define the Detailed Space Segment ---
    public part def SpaceSegment {
        
        // A. Subsystems
        part SS_Thermal_Control_System : ThermalControlSystem;
        part <COMMS> SS_Communication_System : CommunicationSystem;
        part <EPS> SS_Electrical_Power_System : ElectricalPowerSystem;
        part <OBDH> SS_On_Board_Data_Handling : OnBoardDataHandling;
        part <STR> SS_Structure_And_Mechanisms : StructureAndMechanisms;
        part <DAQ> SS_Data_Acquisition : DataAcquisition;
        part <AOCS> SS_Attitude_And_Orbit_Control_System : AttitudeAndOrbitControlSystem;
        part <SPL> SS_Satellite_Payload : Payload;

        in port satelliteSolarEnvironment : SolarEnvironment{
            in item measuredRadiation : Real;
            in item measuredSpectrum : Real;
            in item measuredAngleBeta : Real;
        }
    }

    // --- 4. Ground Segment Placeholder ---
    public part def GroundSegment{
        part <GST> Ground_Station : GroundStation;
        part <MCC> Mission_Operations_Centre : MissionOperationsCentre;
    }

    // --- 5. The Complete System ---
    public part def HEALIOS_System {
        part <SS> HEALIOS_Space_Segment : SpaceSegment;
        part <GS> HEALIOS_Ground_Segment : GroundSegment;
        attribute missionName : String = "HEALIOS";
        attribute missionDuration : Natural = 365 [SI::day]; // in years, to be refined
        attribute Mass : Real = 2.0 [SI::kg];

        perform action performScienceOps : PerformScienceOperations;
        perform action operateSystem : OperateSystem;
        perform action maintainOperability : MaintainOperability;
        connect sunEntity.sunSolarEnvironment to HEALIOS_Space_Segment.satelliteSolarEnvironment;

    }
    
    part HEALIOS_System_entity : HEALIOS_System;
}
