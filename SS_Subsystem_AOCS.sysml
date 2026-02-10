package AttitudeAndOrbitControlSystemPackage {
    private import MissionPackage::*;
    private import SpaceActionsPackage::*;
    private import ISQ::*;
    private import Environment::*;
    private import ElectricalPowerSystemPackage::*;
    private import OnBoardDataHandlingSystemPackage::*;


    part def SunSensor :> GeneralElectricalComponent {
        port Power_Bus_In_3V3 : PowerBus;
        out Beta_Angle : Boolean;
    }

    part def Magnetorquer :> GeneralElectricalComponent {
        attribute Axis : String;
        attribute Force : ISQ::ForceValue;
    }

    part def MagnetorquerBoard {
        port Power_Bus_In_5V : ~PowerBus;
        port Magnetorquer_Board_I2C : ~OnBoardDataHandlingSystemPackage::I2CPort;

        part Mounted_Magnetorquer : Magnetorquer [0..*];
    }

    // --- EPS structure (Requirements: solar arrays + rechargeable batteries; inhibit; regulated rails) ---
    part def AttitudeAndOrbitControlSystem {
        port AOCS_Command_In : ~TmTcPort;
        port Power_Bus_In_3V3 : ~PowerBus;
        port Power_Bus_In_5V : ~PowerBus;
        part Sun_Sensor : SunSensor [0..*];
        part Magnetorquer_Board : MagnetorquerBoard [0..*];
        attribute Nominal_Force : ISQ::ForceValue;

        attribute Stop_Signal : Boolean;

        perform action Activate_AOCS {
            in AOCS_Command : MissionPackage::OnBoardCommand;

            if AOCS_Command.Type == "TurnOn" {
                loop {
                    perform action Read_Sun_Angle : ReadSunAngle {
                        bind Beta_Angle = Sun_Sensor.Beta_Angle;
                    }
                    then perform action Correct_Attitude : CorrectAttitude {
                        bind Force = Magnetorquer_Board.Mounted_Magnetorquer.Force;
                        bind Sun_Sensor_Reading = Read_Sun_Angle.Beta_Angle;
                        bind Force_Value = Nominal_Force;
                    }
                    then assign Stop_Signal := AOCS_Command.Type == "TurnOff";
                } until Stop_Signal;
            }
        }
    }
}
