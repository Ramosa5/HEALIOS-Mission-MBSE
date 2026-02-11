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
        port Data_Bus : ~DataBus; [0..*];
        
        //attribute TCSlastCommand : OnBoardCommand; // TBA: OBDH NEED TO HAVE ACESS TO IT VIA PORT OBDHcommandIN

        attribute Stop_Signal : Boolean := false;

        ref part EPS_Heater[0..*] : Heater;
        ref part PL_Temperature_Sensor[0..*] : TemperatureSensor{
            out port PL_Temperature_Measurement : DataBus;
        }
        ref part OBC_Temperature_Sensor[0..*] : TemperatureSensor{
            out port OBC_Temperature_Measurement : DataBus;
        }
        ref part EPS_Temperature_Sensor[0..*] : TemperatureSensor{
            out port EPS_Temperature_Measurement : DataBus;
        }
        
        // In next iterations, add loop type action for OBDH control.
        perform action activateTCS {
            in Command : OnBoardCommand;
            bind Command = Data_Bus.Cmd;
            if Command.Type == "TurnOn" {
                loop {
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