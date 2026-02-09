package AttitudeAndOrbitControlSystemPackage {
    private import MissionPackage::*;
    private import SpaceActionsPackage::*;
    private import ISQ::*;
    private import Environment::*;
    private import ElectricalPowerSystemPackage::*;
    private import OnBoardDataHandlingSystemPackage::*;

    part def SunSensor :> GeneralElectricalComponent{
        out Beta_Angle : Boolean;
    }

    part def Magnetorquer :> GeneralElectricalComponent{
        attribute Axis;
        attribute Force;
    }

    part def MagnetorquerBoard{
        port Power_Bus_In_5V : ~ElectricalPowerSystemPackage::powerBus;
        port Magnetorquer_Board_I2C : ~OnBoardDataHandlingSystemPackage::I2CPort;

        part Mounted_Magnetorquer[0..*] : Magnetorquer;
    }
    // --- EPS structure (Requirements: solar arrays + rechargeable batteries; inhibit; regulated rails) ---
    part def AttitudeAndOrbitControlSystem{
        part Sun_Sensor[0..*] : SunSensor;
        part Magnetorquer_Board[0..*] : MagnetorquerBoard;

    }
}