package PayloadPackage {
    private import HEALIOS::*;
    private import HEALIOS_Space_Functions::*;
    private import ISQ::*;

    // (opcjonalnie) jeśli chcesz typować wejścia z EPS:
    // private import ElectricalPowerSystemPackage::*;

    // --- COTS blocks (definitions WITHOUT "name") ---

    part def PowerFilteringUnit { attribute name : String; } 
    part def PerovskiteCellConnectorAndProtection { attribute name : String; } 
    part def IVSweepLoad_ShuntResistor { attribute name : String; } 
    part def IVSweepLoad_MOSFET { attribute name : String; } 
    part def IVSweepLoad_OpAmp { attribute name : String; } 
    part def IVSweepLoad_DAC { attribute name : String; } 
    part def CellCurrentAndVoltageSensingBlock { attribute name : String; } 
    part def TemperatureSensorAtSolarCellSamples { attribute name : String; } 
    part def IrradianceSensorBlock { attribute name : String; } 
    part def RadiationDoseSensor { attribute name : String; } 
    part def SpectrometerPackage { attribute name : String; }

    part def EnvironmentSensorsBlock {
        // Minimal sensor data outputs (you can refine types later)
        port tempOut : HEALIOS::OnBoardStatus;
        port irrOut  : HEALIOS::OnBoardStatus;
        port radOut  : HEALIOS::OnBoardStatus;
        port specOut : HEALIOS::OnBoardStatus;

        // instances (NO default names here)
        part temperatureSensorsAtEnvironment : TemperatureSensorAtSolarCellSamples;
        part irradianceSensorBlock          : IrradianceSensorBlock;
        part radiationDoseSensor            : RadiationDoseSensor;
        part spectrometer                   : SpectrometerPackage;
    }

    part def Payload {
        // Ports for integration
        port cmdIn     : HEALIOS::OnBoardCommand;
        port statusOut : HEALIOS::OnBoardStatus;

        // Jeśli chcesz “jak EPS” (szyny zasilania), zamiast ISQ::PowerValue:
        // port powerBus5VIn  : ElectricalPowerSystemPackage::powerBus;
        // port powerBus3V3In : ElectricalPowerSystemPackage::powerBus;

        // Subparts (NO default names here)
        part powerFilteringUnit          : PowerFilteringUnit;
        part pscConnectorAndProtection   : PerovskiteCellConnectorAndProtection;

        part ivSweepLoad_Shunt           : IVSweepLoad_ShuntResistor;
        part ivSweepLoad_MOSFET          : IVSweepLoad_MOSFET;
        part ivSweepLoad_OpAmp           : IVSweepLoad_OpAmp;
        part ivSweepLoad_DAC             : IVSweepLoad_DAC;

        part cellIVSensing               : CellCurrentAndVoltageSensingBlock;
        part envSensors                  : EnvironmentSensorsBlock;

        // Actions (usages)
        perform action applyReverseBias : applyControlledReverseBiasToPSC;
        perform action measureIVCurves  : MeasureIVCurvesOfPSC;
        perform action maintainMPP      : maintainMaximumPowerPoint;
        perform action collectData      : collectExperimentalData;

        // Bind DAQ command input to the action command inputs
        bind applyReverseBias.applyReverseBiasVoltageCommand = cmdIn;
        bind measureIVCurves.measureIVCurvesOfPSCCommand     = cmdIn;
        bind maintainMPP.maintainMPPCommand                  = cmdIn;
        bind collectData.collectExperimentalDataCommand       = cmdIn;

        // Merge action outputs to payload status out
        bind statusOut = applyReverseBias.voltageApplicationStatus;
        bind statusOut = measureIVCurves.measuredIVCurvesStatus;
        bind statusOut = maintainMPP.mppStatus;

        // Forward sensor results (collectData outputs) via statusOut
        bind statusOut = collectData.measuredRadiationStatus;
        bind statusOut = collectData.measuredTemperatureStatus;
        bind statusOut = collectData.measuredSpectrumStatus;
        bind statusOut = collectData.measuredIrradianceStatus;
    }
}
