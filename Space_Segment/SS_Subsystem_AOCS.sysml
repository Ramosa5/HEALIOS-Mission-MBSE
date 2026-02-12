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
        port Magnetorquer_Board_Control : ~DataBus;

        part Mounted_Magnetorquer : Magnetorquer [0..*];
    }

    part def AttitudeAndOrbitControlSystem {
        port Power_Bus_3V3 : ~PowerBus;
        port Power_Bus_5V : ~PowerBus;
        port Data_Bus : ~DataBus;
        part Sun_Sensor : SunSensor [0..*];
        part Magnetorquer_Board : MagnetorquerBoard [0..*];
        attribute Force_Output : ISQ::ForceValue;

        attribute Stop_Signal : Boolean;
        action Activate_AOCS;
    }
}
