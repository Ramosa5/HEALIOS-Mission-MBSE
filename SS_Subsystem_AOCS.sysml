package AttitudeAndOrbitControlSystemPackage {
    private import MissionPackage::*;
    private import SpaceActionsPackage::*;
    private import ISQ::*;
    private import EnvironmentPackage::*;
    private import ElectricalPowerSystemPackage::*;
    private import OnBoardDataHandlingSystemPackage::*;


    part def SunSensor :> GeneralElectricalComponent {
        port Power_Bus_3V3 : PowerBus;
        out Beta_Angle : Boolean;
    }

    part def Magnetorquer :> GeneralElectricalComponent {
        attribute Axis : String;
        attribute Force : ISQ::ForceValue;
    }

    part def MagnetorquerBoard {
        port Power_Bus_5V : ~PowerBus;
        port Magnetorquer_Board_I2C : ~I2CBus;

        part Mounted_Magnetorquer : Magnetorquer [0..*];
    }

    // --- EPS structure (Requirements: solar arrays + rechargeable batteries; inhibit; regulated rails) ---
    part def AttitudeAndOrbitControlSystem {
        port AOCS_Command_In : ~TmTcPort;
        port Power_Bus_3V3 : ~PowerBus;
        port Power_Bus_5V : ~PowerBus;
        port I2C_Bus : ~I2CBus;
        part Sun_Sensor : SunSensor [0..*];
        part Magnetorquer_Board : MagnetorquerBoard [0..*];
        attribute Nominal_Force : ISQ::ForceValue;

        attribute Stop_Signal : Boolean;
        action Activate_AOCS;
    }
}
