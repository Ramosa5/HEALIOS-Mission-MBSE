package ThermalControlSystemPackage {
    private import HEALIOS::*;
    private import ElectricalPowerSystemPackage::*;
    private import HEALIOS_Space_Functions::*;
    private import ISQ::*;
    private import SI::*;

    // Configuration value for the system
    part def ThermalControlSystem {
        ref part epsHeater : Heater;
        ref part payloadTemperatureSensor : TemperatureSensor;
        ref part obcTemperatureSensor : TemperatureSensor;
        ref part epsTemperatureSensor : TemperatureSensor;
        
        perform action ControlTemperature;

        }

}