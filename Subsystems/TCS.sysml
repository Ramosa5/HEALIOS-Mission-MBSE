package ThermalControlSystemPackage {
    private import HEALIOS::*;
    private import ElectricalPowerSystemPackage::*;
    private import HEALIOS_Space_Functions::*;
    private import ISQ::*;
    private import SI::*;

    abstract port def temperatureIN {
        in temp : ISQ::TemperatureValue [1..*];
    }

    // Configuration value for the system
    part def ThermalControlSystem {
        port temperatureInformationIN : temperatureIN;

        ref part epsHeater : Heater;
        ref part payloadTemperatureSensor : TemperatureSensor;
        ref part obcTemperatureSensor : TemperatureSensor;
        ref part epsTemperatureSensor : TemperatureSensor;

        connect payloadTemperatureSensor.temperatureOUT to temperatureInformationIN;
        connect obcTemperatureSensor.temperatureOUT to temperatureInformationIN;
        connect epsTemperatureSensor.temperatureOUT to temperatureInformationIN;
        
        perform action ControlTemperatures : ControlTemperature {
            bind minimalTemperature = epsHeater.minimalTemperature;
            bind heaterPower = epsHeater.power;
            bind tempReading = epsTemperatureSensor.temperatureOUT.temp;
            }
        }
}