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
        port voltageOut : ISQ::voltage;
    }

    port def powerBus {
        out voltage : ISQ::voltage;
    }

    // Electrical Power System
    part def ElectricalPowerSystem {
        // Interfaces (telecommand/telemetry + power rails)
        port epsCommandIn : HEALIOS::OnBoardCommand;
        port epsTelemetryOut : HEALIOS::OnBoardStatus;

        // Regulated rails commonly referenced in your DAQ chapter
        port powerBus5V : powerBus;
        port powerBus3V3 : powerBus;

        part batteryPackEPS : BatteryPack;

        // Chosen / documented elements
        part powerSupplyUnit : PowerSupplyUnit;

        part deployableSolarArrays[0..*] : DeployableSolarArray;
        part mountedSolarCells[0..*] : SolarArray;

        part bus5V : RegulatedPowerBus;
        part bus3V3 : RegulatedPowerBus;
        part busHeater : RegulatedPowerBus;

        // Map internal bus outputs to EPS external ports
        bind powerBus5V = bus5V.voltageOut;
        bind powerBus3V3 = bus3V3.voltageOut;
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

    part HEALIOS_EPS : ElectricalPowerSystem {
        :>> epsCommandIn;
        :>> epsTelemetryOut;
        :>> powerBus5V;
        :>> powerBus3V3;

        :>>deployableSolarArrays[2] {
            :>> name = "2-panel EXA DMSA";
            :>> mass = 0.07 [SI::kg];
            :>> powerGeneration = 20 [SI::W];  //tba
        }

        :>> mountedSolarCells[1] {
            :>> name = "AZUR SPACE 3G30-Advanced 4x8";
            :>> mass = 0.036 [SI::kg];
            :>> powerGeneration = 5 [SI::W]; // tba
        }
         
        :>> batteryPackEPS {
            :>> name = "NanoPower BP4";
            :>> capacity = 34 [SI::Wh]; // tbc
            :>> maxPowerGeneration = 25 [SI::W]; // tba
            :>> mass = 0.258 [SI::kg]; // tba
            :>> mainHeater {
                :>> name = "NanoPower BP4 - Resistance Heating Element";
                :>> power = 3.5 [SI::W];
            }
            :>> connector {
                :>> name = "Molex 43045-0600";
            }   
            :>> tempSensor {
                :>> name = "NanoPower BP4 - TE TMP121";
                :>> mass = 0.00 [SI::kg];
                :>> power = 0.0 [SI::W];
            }
        }
    }
}