package ElectricalPowerSystemPackage {
    private import MissionPackage::*;
    private import SpaceActionsPackage::*;
    private import OnBoardDataHandlingSystemPackage::*;
    private import ISQ::*;
    private import EnvironmentPackage::*;
    private import UnitTypesPackage::*;

    part def GeneralElectricalComponent {
        attribute name : String;
        attribute mass : ISQ::MassValue;
        attribute power_Consumption : Wattage;
    }

    part def Resistor specializes GeneralElectricalComponent {
        attribute resistance : RV;
    }

    port def TemperaturePort specializes DataBus{
        out temp : ISQ::TemperatureValue [1..*];
    }

    port def MPPTControl :> DataBus {
        in power : Wattage;
        in voltage : ISQ::SourceVoltageValue;
        in current : ISQ::ElectricCurrentUnit;
    }

    part def TemperatureSensor specializes GeneralElectricalComponent {
        attribute power : Wattage;
        attribute temperature_Measurement : ISQ::TemperatureValue;

        port temperature_Port : TemperaturePort;
        bind temperature_Port.temp = temperature_Measurement;

        perform action read_Temperature : ReadTemperature {
            bind temp = temperature_Measurement;
        }
    }

    part def SolarArray specializes GeneralElectricalComponent {
        attribute power_Generation : Wattage;
        port electrode_Connection : ~MPPTControl;
        port solar_Input : ~MissionPackage::StellarEnvironment;
    }

    part def DeployableSolarArray specializes SolarArray {
        attribute deployment_Mechanism : String;
    }

    part def MPPTUnit specializes GeneralElectricalComponent{
        port mppt_Control : MPPTControl;
        out port power_Supply_Bus : PowerBus;
    }

    part def KillSwitchUnit specializes GeneralElectricalComponent;

    part def Connector specializes GeneralElectricalComponent;

    part def Battery :> GeneralElectricalComponent{
        attribute battery_Size : ISQ::EnergyValue;
        port battery_Power_Bus : PowerBus;
        port heater_Power_Bus : PowerBus;
    }

    part def BatteryPack specializes GeneralElectricalComponent {
        attribute capacity : ISQ::EnergyValue;
        attribute max_Power_Generation : Wattage;

        part battery_Pack_Connector : Connector;
        part battery_Unit[1..*] : Battery;
        part main_Heater : Heater;
        part temp_Sensor : TemperatureSensor;
        port battery_Power_Bus : PowerBus;
    }

    part def PowerSupplyUnit specializes GeneralElectricalComponent{
        out port power_Bus_5V : PowerBus;
        out port power_Bus_3V3 : PowerBus;
        port battery_Power_Bus : PowerBus; 
        in port power_Supply_Bus : ~PowerBus;
        port data_Bus : DataBus;
    }

    part def Heater specializes GeneralElectricalComponent {
        attribute power : Wattage;
        attribute minimal_Temperature : ISQ::TemperatureValue;
    }

    part def RegulatedPowerBus {
        attribute name : String;
        port voltage_Out : ISQ::SourceVoltageValue;
    }

    port def PowerBus {
        out voltage : ISQ::SourceVoltageValue;
    }

    // Electrical Power System
    part def ElectricalPowerSystem {
        port data_Bus : ~DataBus;
        port eps_Solar_Input : ~StellarEnvironment;

        port eps_Command_In  : MissionPackage::OnBoardCommand;
        port eps_Telemetry_Out : MissionPackage::OnBoardStatus;

        port power_Bus_5V : PowerBus;
        port power_Bus_3V3 : PowerBus;

        part battery_Pack_EPS[1..*] : BatteryPack;
        part mppt_Unit[0..*] : MPPTUnit;

        part power_Supply_Unit[1..*] : PowerSupplyUnit;

        part deployable_Solar_Arrays[0..*] : DeployableSolarArray;
        part mounted_Solar_Arrays[0..*] : SolarArray;

        perform action mppt : performMPPT;
        perform action battery_Energy : manageBatteryEnergy;
        perform action distribute : distributePowerToLoads;
        perform action load_Mgmt : manageLoadSheddingAndReactivation;
        perform action switch_State : switchEPSState;
        perform action report_Health : reportEPSHealth;

        bind mppt.mppt_Command = eps_Command_In;
        bind battery_Energy.battery_Command = eps_Command_In;
        bind distribute.distribution_Command = eps_Command_In;
        bind load_Mgmt.load_Mgmt_Command = eps_Command_In;
        bind switch_State.switch_Command = eps_Command_In;
        bind report_Health.report_Command = eps_Command_In;

        bind eps_Telemetry_Out = mppt.Mppt_Status;
        bind eps_Telemetry_Out = battery_Energy.battery_Status;
        bind eps_Telemetry_Out = distribute.distribution_Status;
        bind eps_Telemetry_Out = load_Mgmt.load_Mgmt_Status;
        bind eps_Telemetry_Out = switch_State.switch_Status;
        bind eps_Telemetry_Out = report_Health.health_Telemetry;
    }
}
