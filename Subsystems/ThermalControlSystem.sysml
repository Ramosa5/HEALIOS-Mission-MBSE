package ThermalControlSystemPackage {
    private import MissionPackage::*;
    private import ElectricalPowerSystemPackage::*;
    private import SpaceActionsPackage::*;
    private import ISQ::*;
    private import SI::*;
    private import OnBoardDataHandlingSystemPackage::*;


    abstract port def temperatureReadingPort {
        in Temp : ISQ::TemperatureValue;
    }

    part def ThermalControlSystem {
       
        port EPS_Temperature_Port : temperatureReadingPort [0..*];
        port PL_Temperature_Port : temperatureReadingPort [0..*];
        port OBDH_Temperature_Port : temperatureReadingPort [0..*];
        port Command_IN : ~OutCommandPort; [0..*];
        
        //attribute TCSlastCommand : OnBoardCommand; // TBA: OBDH NEED TO HAVE ACESS TO IT VIA PORT OBDHcommandIN

        attribute Stop_Signal : Boolean := false;

        ref part EPS_Heater[0..*] : Heater;
        ref part PL_Temperature_Sensor[0..*] : TemperatureSensor;
        ref part OBC_Temperature_Sensor[0..*] : TemperatureSensor;
        ref part EPS_Temperature_Sensor[0..*] : TemperatureSensor;

        connect PL_Temperature_Sensor.Temperature_Measurement to PL_Temperature_Port.Temp;
        connect OBC_Temperature_Sensor.Temperature_Measurement to OBDH_Temperature_Port.Temp;
        connect EPS_Temperature_Sensor.Temperature_Measurement to EPS_Temperature_Port.Temp;
        
        // In next iterations, add loop type action for OBDH control.
        perform action activateTCS {
            in Command : OnBoardCommand;
            bind Command = Command_IN.Cmd;
            if Command.Type == "TurnOn" {
                loop{
                    perform action read : ReadTemperature {
                        bind Temp = EPS_Temperature_Port.Temp;
                    }
                    then perform action ControlTemperatures : ControlTemperature {
                        bind Minimal_Temperature = EPS_Heater.Minimal_Temperature;
                        bind Heating_Power = EPS_Heater.Power;
                        bind Temp_Reading = read.Temp;
                    }
                    then assign Stop_Signal := (Command.Type == "TurnOff");
                } until Stop_Signal;
            }

        }
    }
}