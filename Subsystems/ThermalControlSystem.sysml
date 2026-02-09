package ThermalControlSystemPackage {
    private import MissionPackage::*;
    private import ElectricalPowerSystemPackage::*;
    private import SpaceActionsPackage::*;
    private import ISQ::*;
    private import SI::*;

    abstract port def OBDHcommandIN {
        in cmd : OnBoardCommand;
    }

    abstract port def temperatureReadingPort {
        in temp : ISQ::TemperatureValue;
    }

    part def ThermalControlSystem {
       
        port EPS_Temperature_Port : temperatureReadingPort [0..*];
        port PL_Temperature_Port : temperatureReadingPort [0..*];
        port OBDH_Temperature_Port : temperatureReadingPort [0..*];
        port Command_IN : OBDHcommandIN [0..*];
        
        //attribute TCSlastCommand : OnBoardCommand; // TBA: OBDH NEED TO HAVE ACESS TO IT VIA PORT OBDHcommandIN

        attribute stopSignal : Boolean := false;

        ref part epsHeater[0..*] : Heater;
        ref part payloadTemperatureSensor[0..*] : TemperatureSensor;
        ref part obcTemperatureSensor[0..*] : TemperatureSensor;
        ref part epsTemperatureSensor[0..*] : TemperatureSensor;

        connect payloadTemperatureSensor.temperatureOUT to PL_Temperature_Port.temp;
        connect obcTemperatureSensor.temperatureOUT to OBDH_Temperature_Port.temp;
        connect epsTemperatureSensor.temperatureOUT to EPS_Temperature_Port.temp;
        
        // In next iterations, add loop type action for OBDH control.
        perform action activateTCS {
            in command : OnBoardCommand;
            bind command = Command_IN.cmd;
            loop{
                perform action read : ReadTemperature {
                    bind temp = EPS_Temperature_Port.temp;
                }
                then perform action ControlTemperatures : ControlTemperature {
                    bind minimalTemperature = epsHeater.minimalTemperature;
                    bind heatingPower = epsHeater.power;
                    bind tempReading = read.temp;
                }
                then assign stopSignal := (command.type == "Turn Off");
            } until stopSignal;
        }
    }
}