package ThermalControlSystemPackage {
    private import MissionPackage::*;
    private import ElectricalPowerSystemPackage::*;
    private import SpaceActionsPackage::*;
    private import ISQ::*;
    private import SI::*;
    private import OnBoardDataHandlingSystemPackage::*;

    part def ThermalControlSystem :> PowerSinkSubsystem {
        port data_Bus : ~DataBus [0..*];

        // attribute TCSlastCommand : OnBoardCommand; // TBA: OBDH NEED TO HAVE ACESS TO IT VIA PORT OBDHcommandIN

        attribute stop_Signal : Boolean := false;

        ref part EPS_Heater : Heater [0..*];
        ref part PL_Temperature_Sensor : TemperatureSensor [0..*] {
            out port PL_Temperature_Measurement : TemperaturePort;
        }
        ref part OBC_Temperature_Sensor : TemperatureSensor [0..*] {
            out port OBC_Temperature_Measurement : TemperaturePort;
        }
        ref part EPS_Temperature_Sensor : TemperatureSensor [0..*] {
            out port EPS_Temperature_Measurement : TemperaturePort;
        }
    }
}
