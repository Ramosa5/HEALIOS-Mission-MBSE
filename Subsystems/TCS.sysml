package ThermalControlSystem {
    private import HEALIOS::*;
    private import ElectricalPowerSystemPackage::*;
    private import ISQ::*;
    private import SI::*;

    // Configuration value for the system
    attribute minimalTemperature : ISQ::TemperatureValue;
    attribute heaterPower : ISQ::PowerValue;
    
    action def ReadTemperature {
        out temp : ISQ::TemperatureValue;
    }

    action def EvaluateThreshold {
        in temp : ISQ::TemperatureValue;
        in threshold : ISQ::TemperatureValue; 
        out turnOn : Boolean;
    }

    action def CommandHeater {
        in turnOn : Boolean;
        in heaterPower : ISQ::PowerValue;
        out heaterOutput : ISQ::PowerValue;
    }
    
    action def ControlTemperature {
        
        action read : ReadTemperature;
        action evaluate : EvaluateThreshold;
        action heat : CommandHeater;

        flow read.temp to evaluate.temp;
        flow evaluate.turnOn to heat.turnOn;

        bind evaluate.threshold = minimalTemperature;
        bind heat.heaterPower = heaterPower;
    }
}