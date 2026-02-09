package ElectricalPowerSystemPackage {
    private import MissionPackage::*;
    private import SpaceActionsPackage::*;
    private import ISQ::*;
    private import Environment::*; 

    // --- EPS structure (Requirements: solar arrays + rechargeable batteries; inhibit; regulated rails) ---
    part def GeneralElectricalComponent {
        attribute name : String;
        attribute mass : ISQ::MassValue;
    } 

    part def Resistor specializes GeneralElectricalComponent {
        attribute resistance : ISQ::ResistanceValue;
    }

    port def TemperaturePort {
            out temp : ISQ::TemperatureValue [1..*];
        }
        
    part def TemperatureSensor specializes GeneralElectricalComponent { 
        attribute power : ISQ::PowerValue;
        attribute temperatureMeasurement : ISQ::TemperatureValue;
        
        port temperatureOUT : TemperaturePort;
        bind temperatureOUT.temp = temperatureMeasurement;

        perform action readTemperature : ReadTemperature {
            bind temp = temperatureMeasurement;
        }
    }

    part def SolarArray specializes GeneralElectricalComponent {
        attribute powerGeneration : ISQ::PowerValue;
        port electrodeConnection : solarArrayElectrodeConnection;
        port solarEnvironment : MissionPackage::SolarEnvironment;
        }

    part def DeployableSolarArray specializes SolarArray {
        attribute deploymentMechanism : String;
    }

    part def MPPTUnit specializes GeneralElectricalComponent;

    part def KillSwitchUnit specializes GeneralElectricalComponent;

    part def Connector specializes GeneralElectricalComponent;


    part def BatteryPack specializes GeneralElectricalComponent{
        attribute capacity : ISQ::EnergyValue;
        attribute maxPowerGeneration : ISQ::PowerValue;
        part connector : Connector;
        part mainHeater : Heater;
        part tempSensor : TemperatureSensor;
        port heaterPowerBus : powerBus;

        //perform action readEPSTemperature : ReadTemperature; -> IN Temperature Sensor
    }

    part def PowerSupplyUnit specializes GeneralElectricalComponent;

    part def Heater specializes GeneralElectricalComponent{
        attribute power : ISQ::PowerValue;
        attribute minimalTemperature : ISQ::TemperatureValue;
    }

    part def RegulatedPowerBus {
        attribute name : String;
        port voltageOut : ISQ::SourceVoltageValue;
    }

    port def powerBus {
        out voltage : ISQ::SourceVoltageValue;
    }

    port def solarArrayElectrodeConnection {
        out voltage : ISQ::SourceVoltageValue;
        out current : ISQ::ElectricCurrentUnit;
    }

    // Electrical Power System
    part def ElectricalPowerSystem {
        // Interfaces (telecommand/telemetry + power rails)
        port epsCommandIn : MissionPackage::OnBoardCommand;
        port epsTelemetryOut : MissionPackage::OnBoardStatus;

        // Regulated rails commonly referenced in your DAQ chapter
        port powerBus5V : powerBus;
        port powerBus3V3 : powerBus;
        port heaterPowerBus : powerBus;

        part batteryPackEPS : BatteryPack;

        // Chosen / documented elements
        part powerSupplyUnit : PowerSupplyUnit;

        part deployableSolarArrays[0..*] : DeployableSolarArray;
        part mountedSolarCells[0..*] : SolarArray;

        part bus5V : RegulatedPowerBus;
        part bus3V3 : RegulatedPowerBus;

        // Map internal bus outputs to EPS external ports
        bind powerBus5V = bus5V.voltageOut;
        bind powerBus3V3 = bus3V3.voltageOut;
        bind heaterPowerBus = batteryPackEPS.heaterPowerBus;
        
        // --- EPS actions (wired to EPS command/telemetry ports) ---

        perform action mppt : performMPPT;
        perform action batteryEnergy : manageBatteryEnergy;
        perform action distribute : distributePowerToLoads;
        perform action loadMgmt : manageLoadSheddingAndReactivation;
        perform action switchState : switchEPSState;
        perform action reportHealth : reportEPSHealth;

        // Bind EPS ports into all EPS actions (command in, telemetry out)
        bind mppt.mpptCommand = epsCommandIn;
        bind batteryEnergy.batteryCommand = epsCommandIn;
        bind distribute.distributionCommand = epsCommandIn;
        bind loadMgmt.loadMgmtCommand = epsCommandIn;
        bind switchState.switchCommand = epsCommandIn;
        bind reportHealth.reportCommand = epsCommandIn;

        bind epsTelemetryOut = mppt.mpptStatus;
        bind epsTelemetryOut = batteryEnergy.batteryStatus;
        bind epsTelemetryOut = distribute.distributionStatus;
        bind epsTelemetryOut = loadMgmt.loadMgmtStatus;
        bind epsTelemetryOut = switchState.switchStatus;
        bind epsTelemetryOut = reportHealth.healthTelemetry;
    }
}