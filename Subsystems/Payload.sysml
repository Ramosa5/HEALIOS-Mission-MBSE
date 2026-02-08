package PayloadPackage {
    private import HEALIOS::*;
    private import HEALIOS_Space_Functions::*;
    private import ElectricalPowerSystemPackage::*;
    private import ISQ::*;
    private import Environment::*;
    // (opcjonalnie) jeśli chcesz typować wejścia z EPS:
    // private import ElectricalPowerSystemPackage::*;

    // --- COTS blocks (definitions WITHOUT "name") ---
    part def PerovskiteCellConnectorAndProtection {
        attribute name : String;
        attribute mass : ISQ::MassValue;
    } 
    part def IVSweepLoad_MOSFET specializes GeneralElectricalComponent;
    part def IVSweepLoad_OpAmp specializes GeneralElectricalComponent;
    part def CurrentAndVoltageSensingBlock specializes GeneralElectricalComponent;
    part def IVSweepLoad_DAC specializes GeneralElectricalComponent;
    part def IrradianceSensorBlock specializes GeneralElectricalComponent; 
    part def RadiationDoseSensor specializes GeneralElectricalComponent;
    part def SpectrometerPackage specializes GeneralElectricalComponent;
    part def PowerFilteringUnit specializes GeneralElectricalComponent;
    part def DigitalAnalogConverter specializes GeneralElectricalComponent;

    part def PerovskiteSolarArray specializes SolarArray {
        attribute manufacturer : String;
    }

    part def PowerFilteringBlock { 
        port powerBusIn3V3 : ElectricalPowerSystemPackage::powerBus;
        port powerBusIn5V : ElectricalPowerSystemPackage::powerBus;
        port powerBusFiltered5V : ElectricalPowerSystemPackage::powerBus;
        port powerBusFiltered3V3 : ElectricalPowerSystemPackage::powerBus;

        part powerFilter : PowerFilteringUnit; 
    } 

    part def SolarCellsBlock {
        part perovskiteSolarArrayCoupon[1..*] : PerovskiteSolarArray;
        part referenceSiliconSolarArrayCoupon[1..*] : SolarArray;
        part pscConnectorAndProtection   : PerovskiteCellConnectorAndProtection;
    }

    part def MPPTBlock {
        port powerBusFiltered3V3 : ElectricalPowerSystemPackage::powerBus;
        
        part mpptController[1..*] : MPPTUnit;
        part powerDumpResistor[1..*] : Resistor;
    }

    part def IVSweepAndReverseBiasBlock {
        port powerBusFiltered5V : ElectricalPowerSystemPackage::powerBus;
        part ivSweepLoadShuntResistor[1] : Resistor;
        part ivSweepLoadMOSFET[1] : IVSweepLoad_MOSFET;
        part ivSweepLoadOpAmp[1] : IVSweepLoad_OpAmp;
        part ivSweepLoadDAC[1] : IVSweepLoad_DAC;
        part currentAndVoltageSensingBlock[1] : CurrentAndVoltageSensingBlock;
    }

    part def EnvironmentSensorsBlock {
        // Minimal sensor data outputs (you can refine types later)
        port powerBusFiltered3V3 : ElectricalPowerSystemPackage::powerBus;
        port tempOut : HEALIOS::OnBoardStatus;
        port irrOut  : HEALIOS::OnBoardStatus;
        port radOut  : HEALIOS::OnBoardStatus;
        port specOut : HEALIOS::OnBoardStatus;

        // instances (NO default names here)
        part temperatureSensorsAtEnvironment : TemperatureSensor;
        part irradianceSensorBlock          : IrradianceSensorBlock;
        part radiationDoseSensor            : RadiationDoseSensor;
        part spectrometer                   : SpectrometerPackage;
    }

    part def Payload {
        // Ports for integration
        port cmdIn     : HEALIOS::OnBoardCommand;
        port statusOut : HEALIOS::OnBoardStatus;

        // Subparts (NO default names here)
        part powerFilteringBlock         : PowerFilteringBlock;
        part solarCellsBlock             : SolarCellsBlock;
        part mpptBlock                   : MPPTBlock;  
        part ivSweepAndReverseBiasBlock  : IVSweepAndReverseBiasBlock;
        part envSensorsBlock                  : EnvironmentSensorsBlock;

        bind envSensorsBlock.powerBusFiltered3V3 = powerFilteringBlock.powerBusFiltered3V3;
        bind ivSweepAndReverseBiasBlock.powerBusFiltered5V = powerFilteringBlock.powerBusFiltered5V;
        bind mpptBlock.powerBusFiltered3V3 = powerFilteringBlock.powerBusFiltered3V3;

        // Actions (usages)
        perform action applyReverseBias : applyControlledReverseBiasToPSC;
        perform action measureIVCurves  : MeasureIVCurvesOfPSC;
        perform action maintainMPP      : maintainMaximumPowerPoint;
        perform action collectData      : collectExperimentalData;

        // Bind DAQ command input to the action command inputs
        bind applyReverseBias.applyReverseBiasVoltageCommand = cmdIn;
        bind measureIVCurves.measureIVCurvesOfPSCCommand     = cmdIn;
        bind maintainMPP.maintainMPPCommand                  = cmdIn;
        bind collectData.collectExperimentalDataCommand      = cmdIn;

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
