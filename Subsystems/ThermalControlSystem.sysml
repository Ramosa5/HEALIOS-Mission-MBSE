package ThermalControlSystemPackage {
    private import MissionPackage::*;
    private import ElectricalPowerSystemPackage::*;
    private import SpaceActionsPackage::*;
    private import ISQ::*;
    private import SI::*;

    abstract port def temperatureIN {
        in temp : ISQ::TemperatureValue;
    }

    abstract port def OBDHcommandIN {
        in cmd : OnBoardCommand;
    }

    part def ThermalControlSystem {
        port temperatureInformationIN : temperatureIN [1..*];

        port commandIN : OBDHcommandIN;
        
        //attribute TCSlastCommand : OnBoardCommand; // TBA: OBDH NEED TO HAVE ACESS TO IT VIA PORT OBDHcommandIN

        attribute stopSignal : Boolean := false;

        ref part epsHeater[0..*] : Heater;
        ref part payloadTemperatureSensor[0..*] : TemperatureSensor;
        ref part obcTemperatureSensor[1..*] : TemperatureSensor;
        ref part epsTemperatureSensor[0..*] : TemperatureSensor;

        connect payloadTemperatureSensor.temperatureOUT to temperatureInformationIN;
        connect obcTemperatureSensor.temperatureOUT to temperatureInformationIN;
        connect epsTemperatureSensor.temperatureOUT to temperatureInformationIN;
        
        // In next iterations, add loop type action for OBDH control.
        perform action activateTCS {
            in command : OnBoardCommand;
            bind command = commandIN.cmd;
            loop{
                perform action read : ReadTemperature {
                    bind temp = epsTemperatureSensor.temperatureOUT.temp;
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