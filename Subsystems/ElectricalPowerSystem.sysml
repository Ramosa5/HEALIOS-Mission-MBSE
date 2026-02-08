package ElectricalPowerSystemPackage {
    private import HEALIOS::*;
    private import HEALIOS_Space_Functions::*;
    private import ISQ::*;

    // --- EPS structure (Requirements: solar arrays + rechargeable batteries; inhibit; regulated rails) ---

    part def TemperatureSensor { 
        attribute name : String;
        attribute mass : ISQ::MassValue;
        attribute power : ISQ::PowerValue;
    }

    part def SolarArray {
        attribute name : String;
        attribute mass : ISQ::MassValue;
        attribute powerGeneration : ISQ::PowerValue;
        }

    part def DeployableSolarArray specializes SolarArray {
        attribute deploymentMechanism : String;
    }

    part def MPPTUnit {
        attribute name : String;
        attribute mass : ISQ::MassValue;
    }

    part def KillSwitchUnit{
        attribute name : String;
        attribute mass : ISQ::MassValue;
    }

    part def Connector {
        attribute name : String;
    }


    part def BatteryPack {
        attribute name : String;
        attribute capacity : ISQ::EnergyValue;
        attribute maxPowerGeneration : ISQ::PowerValue;
        attribute mass : ISQ::MassValue;
        part connector : Connector;
        part mainHeater : Heater;
        part tempSensor : TemperatureSensor;
        port heaterPowerBus : powerBus;
    }

    part def PowerSupplyUnit {
        attribute name : String;
    }

    part def Heater {
        attribute name : String;
        // attribute mass : ISQ::MassValue;
        attribute power : ISQ::PowerValue;
    }

    part def RegulatedPowerBus {
        attribute name : String;
        port voltageOut : ISQ::SourceVoltageValue;
    }

    port def powerBus {
        out voltage : ISQ::SourceVoltageValue;
    }

    // Electrical Power System
    part def ElectricalPowerSystem {
        // Interfaces (telecommand/telemetry + power rails)
        port epsCommandIn : HEALIOS::OnBoardCommand;
        port epsTelemetryOut : HEALIOS::OnBoardStatus;

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