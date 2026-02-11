package ElectricalPowerSystemPackage {
    private import MissionPackage::*;
    private import SpaceActionsPackage::*;
    private import OnBoardDataHandlingSystemPackage::*;
    private import ISQ::*;
    private import EnvironmentPackage::*;

    // --- EPS structure (Requirements: solar arrays + rechargeable batteries; inhibit; regulated rails) ---
    part def GeneralElectricalComponent {
        attribute Name : String;
        attribute Mass : ISQ::MassValue;
        attribute PowerConsumption : ISQ::PowerValue;
    }

    part def Resistor specializes GeneralElectricalComponent {
        attribute Resistance : ISQ::ResistanceValue;
    }

    port def TemperaturePort specializes I2CBus{
        out Temp : ISQ::TemperatureValue [1..*];
    }

    part def TemperatureSensor specializes GeneralElectricalComponent {
        attribute Power : ISQ::PowerValue;
        attribute Temperature_Measurement : ISQ::TemperatureValue;

        port Temperature_Port : TemperaturePort;
        bind Temperature_Port.Temp = Temperature_Measurement;

        perform action Read_Temperature : ReadTemperature {
            bind Temp = Temperature_Measurement;
        }
    }

    part def SolarArray specializes GeneralElectricalComponent {
        attribute Power_Generation : ISQ::PowerValue;
        port Electrode_Connection : SolarArrayElectrodeConnection;
        port Solar_Input : ~MissionPackage::StellarEnvironment;
    }

    part def DeployableSolarArray specializes SolarArray {
        attribute Deployment_Mechanism : String;
    }

    part def MPPTUnit specializes GeneralElectricalComponent;

    part def KillSwitchUnit specializes GeneralElectricalComponent;

    part def Connector specializes GeneralElectricalComponent;

    part def Battery :> GeneralElectricalComponent{
        attribute Battery_Size : ISQ::EnergyValue;
    }

    part def BatteryPack specializes GeneralElectricalComponent {
        attribute Capacity : ISQ::EnergyValue;
        attribute Max_Power_Generation : ISQ::PowerValue;

        part Battery_Pack_Connector : Connector;
        part Battery_Unit[1..*] : Battery;
        part Main_Heater : Heater;
        part Temp_Sensor : TemperatureSensor;
        port Battery_Power_Bus : PowerBus;
        port Heater_Power_Bus : PowerBus;
    }

    part def PowerSupplyUnit specializes GeneralElectricalComponent{
        port Power_Bus_5V : PowerBus;
        port Power_Bus_3V3 : PowerBus;
        port Solar_Array_Power_Bus : PowerBus;
        port Battery_Power_Bus : PowerBus; 
    }

    part def Heater specializes GeneralElectricalComponent {
        attribute Power : ISQ::PowerValue;
        attribute Minimal_Temperature : ISQ::TemperatureValue;
    }

    part def RegulatedPowerBus {
        attribute Name : String;
        port Voltage_Out : ISQ::SourceVoltageValue;
    }

    port def PowerBus {
        out Voltage : ISQ::SourceVoltageValue;
    }

    port def SolarArrayElectrodeConnection {
        out Voltage : ISQ::SourceVoltageValue;
        out Current : ISQ::ElectricCurrentUnit;
    }

    // Electrical Power System
    part def ElectricalPowerSystem {
        // Interfaces (telecommand/telemetry + power rails)
        port I2C_Bus : ~I2CBus;
        port EPS_Solar_Input : ~StellarEnvironment;

        // Internal EPS command/telemetry ports used to bind actions
        port Eps_Command_In  : MissionPackage::OnBoardCommand;
        port Eps_Telemetry_Out : MissionPackage::OnBoardStatus;

        // Regulated rails commonly referenced in your DAQ chapter
        port Power_Bus_5V : PowerBus;
        port Power_Bus_3V3 : PowerBus;

        part Battery_Pack_EPS[1..*] : BatteryPack;

        // Chosen / documented elements
        part Power_Supply_Unit[1..*] : PowerSupplyUnit;

        part Deployable_Solar_Arrays[0..*] : DeployableSolarArray;
        part Mounted_Solar_Arrays[0..*] : SolarArray;

        // Map internal bus outputs to EPS external ports
        //bind Heater_Power_Bus = Battery_Pack_EPS.Heater_Power_Bus;

        // --- EPS actions (wired to EPS command/telemetry ports) ---
        perform action Mppt : performMPPT;
        perform action Battery_Energy : manageBatteryEnergy;
        perform action Distribute : distributePowerToLoads;
        perform action Load_Mgmt : manageLoadSheddingAndReactivation;
        perform action Switch_State : switchEPSState;
        perform action Report_Health : reportEPSHealth;

        // Bind EPS ports into all EPS actions (command in, telemetry out)
        bind Mppt.Mppt_Command = Eps_Command_In;
        bind Battery_Energy.Battery_Command = Eps_Command_In;
        bind Distribute.Distribution_Command = Eps_Command_In;
        bind Load_Mgmt.Load_Mgmt_Command = Eps_Command_In;
        bind Switch_State.Switch_Command = Eps_Command_In;
        bind Report_Health.Report_Command = Eps_Command_In;

        bind Eps_Telemetry_Out = Mppt.Mppt_Status;
        bind Eps_Telemetry_Out = Battery_Energy.Battery_Status;
        bind Eps_Telemetry_Out = Distribute.Distribution_Status;
        bind Eps_Telemetry_Out = Load_Mgmt.Load_Mgmt_Status;
        bind Eps_Telemetry_Out = Switch_State.Switch_Status;
        bind Eps_Telemetry_Out = Report_Health.Health_Telemetry;

        // Optional: tie I2C payload into the same channels (if you want I2C to carry these)
        // bind EPS_I2C.Cmd  = Eps_Command_In;
        // bind Eps_Telemetry_Out = EPS_I2C.Data;
    }
}
