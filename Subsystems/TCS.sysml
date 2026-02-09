package ThermalControlSystemPackage {
    private import HEALIOS::*;
    private import ElectricalPowerSystemPackage::*;
    private import HEALIOS_Space_Functions::*;
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

        ref part epsHeater : Heater;
        ref part payloadTemperatureSensor : TemperatureSensor;
        ref part obcTemperatureSensor : TemperatureSensor;
        ref part epsTemperatureSensor : TemperatureSensor;

        connect payloadTemperatureSensor.temperatureOUT to temperatureInformationIN;
        connect obcTemperatureSensor.temperatureOUT to temperatureInformationIN;
        connect epsTemperatureSensor.temperatureOUT to temperatureInformationIN;
        
        // In next iterations, add loop type action for OBDH control.
        perform action activateTCS {
            in command : OnBoardCommand;
            bind command = commandIN.cmd;
            loop{
                action read : ReadTemperature {
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