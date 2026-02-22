package AttitudeAndOrbitControlSystemPackage {
    private import MissionPackage::*;
    private import SpaceActionsPackage::*;
    private import ISQ::*;
    private import EnvironmentPackage::*;
    private import ElectricalPowerSystemPackage::*;
    private import OnBoardDataHandlingSystemPackage::*;
    private import UnitTypesPackage::*;

    part def SunSensor :> GeneralElectricalComponent {
        port power_Bus_3V3 : PowerBus;
        out beta_Angle : Boolean;
    }

    part def Magnetorquer :> GeneralElectricalComponent {
        attribute axis : String;
        attribute force : FV;
    }

    part def MagnetorquerBoard {
        port power_Bus_5V : ~PowerBus;
        port magnetorquer_Board_Control_Input : ~DataBus;

        part mounted_Magnetorquer : Magnetorquer [0..*];
    }

    part def AttitudeAndOrbitControlSystem :> PowerSinkSubsystem {
        port power_Bus_3V3 : ~PowerBus;
        port power_Bus_5V : ~PowerBus;
        port data_Bus : ~DataBus;
        part sun_Sensor : SunSensor [0..*];
        part magnetorquer_Board : MagnetorquerBoard [0..*];
        attribute force_Output : FV;

        attribute stop_Signal : Boolean;
        
        perform action use_AOCS : UseAOCS {
            in command : MissionPackage::OnBoardCommand;
            if command.type == "TurnOn" {
                loop {
                    perform action read_Sun_Angle : ReadSunAngle {
                        bind beta_Angle = sun_Sensor.beta_Angle;
                    }
                    then perform action correct_Attitude : CorrectAttitude {
                        bind force = force_Output;
                        bind sun_Sensor_Reading = read_Sun_Angle.beta_Angle;
                        bind force_Value = magnetorquer_Board.mounted_Magnetorquer.force;
                    }
                    then assign stop_Signal := command.type == "TurnOff";
                } until stop_Signal;
            }
        }
    }
}
