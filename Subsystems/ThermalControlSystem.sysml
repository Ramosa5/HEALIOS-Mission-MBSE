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

        attribute Stop_Signal : Boolean := false;

        ref part EPS_Heater[0..*] : Heater;
        ref part PL_Temperature_Sensor[0..*] : TemperatureSensor;
        ref part OBC_Temperature_Sensor[0..*] : TemperatureSensor;
        ref part EPS_Temperature_Sensor[0..*] : TemperatureSensor;

        connect PL_Temperature_Sensor.temperatureOUT to PL_Temperature_Port.temp;
        connect OBC_Temperature_Sensor.temperatureOUT to OBDH_Temperature_Port.temp;
        connect EPS_Temperature_Sensor.temperatureOUT to EPS_Temperature_Port.temp;
        
        // In next iterations, add loop type action for OBDH control.
        perform action activateTCS {
            in command : OnBoardCommand;
            bind command = Command_IN.cmd;
            loop{
                perform action read : ReadTemperature {
                    bind temp = EPS_Temperature_Port.temp;
                }
                then perform action ControlTemperatures : ControlTemperature {
                    bind minimalTemperature = EPS_Heater.minimalTemperature;
                    bind heatingPower = EPS_Heater.power;
                    bind tempReading = read.temp;
                }
                then assign Stop_Signal := (command.type == "Turn Off");
            } until Stop_Signal;
        }
    }
}