package TCS_Subsystem_Definition {
    private import HEALIOS::*;
    private import HEALIOS_Space_Functions::*;
    private import ISQ::*;
    private import SI::*;

    public part def TemperatureSensor { 
        attribute name : String;
        attribute mass : ISQ::MassValue;
        attribute power : ISQ::PowerValue;
        }
    public part def Heater { 
        attribute name : String;
        //attribute mass : ISQ::MassValue;
        attribute power : ISQ::PowerValue;
        }

    part tempSensorOBDH : TemperatureSensor {
        :>> name = "NanoMind A3200 - Digital Temperature Sensor";
        :>> mass = 0.00 [kg];
        :>> power = 0.0 [W];
    }
    part tempSensorPL : TemperatureSensor {
        :>> name = "PTC thin-film platinum Resistance Temperature Detector (Pt1k0)";
        :>> mass = 0.0025 [kg];
        :>> power = 0.09 [W];
    }
    part tempSensorEPS : TemperatureSensor{
        :>> name = "NanoPower BP4 - TE TMP121";
        :>> mass = 0.00 [kg];
        :>> power = 0.0 [W];
    }

    part mainHeater : Heater {
        :>> name = "NanoPower BP4 - Resistance Heating Element";
        //:>> mass = 0.00 [kg];
        :>> power = 3.5 [W];
    }

}
