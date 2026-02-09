package Subsystems {
    private import MissionPackage::*;
    private import SpaceActionsPackage::*;
    private import ISQ::*;

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
        port tempOut : MissionPackage::OnBoardStatus;
        port irrOut  : MissionPackage::OnBoardStatus;
        port radOut  : MissionPackage::OnBoardStatus;
        port specOut : MissionPackage::OnBoardStatus;

        part temperatureSensorsAtEnvironment : TemperatureSensorAtSolarCellSamples { :>> name = "TE TSYS03"; }
        part irradianceSensorBlock : IrradianceSensorBlock { :>> name = "Hamamatsu S1223-01"; }
        part radiationDoseSensor : RadiationDoseSensor { :>> name = "Varadis VT02 RADFET"; }
        part spectrometer : SpectrometerPackage { :>> name = "Hamamatsu C12880MA"; }
    }

    part def DataAcquisitionSystem {

        // Ports for integration
        port cmdIn     : MissionPackage::OnBoardCommand;
        port statusOut : MissionPackage::OnBoardStatus;
        port powerIn   : ISQ::PowerValue;

        // Instances
        part powerFilteringUnit : PowerFilteringUnit { :>> name = "TI TPS7A4501-SEP"; }
        part pscConnectorAndProtection : PerovskiteCellConnectorAndProtection { :>> name = "Molex 43045-0600"; }

        part ivSweepLoad_Shunt  : IVSweepLoad_ShuntResistor { :>> name = "WSL2512R1000FEA"; }
        part ivSweepLoad_MOSFET : IVSweepLoad_MOSFET        { :>> name = "BSC320N20NS3G"; }
        part ivSweepLoad_OpAmp  : IVSweepLoad_OpAmp         { :>> name = "TI OPA197"; }
        part ivSweepLoad_DAC    : IVSweepLoad_DAC           { :>> name = "MCP4728"; }

        part cellIVSensing : CellCurrentAndVoltageSensingBlock { :>> name = "INA226"; }
        part envSensors : EnvironmentSensorsBlock;

        // External connections (now via ports / instances)
        //connect statusOut to SS_On_Board_Data_Handling.onBoardComputer; // if onBoardComputer is a port/feature
        //connect powerIn   to SS_Electrical_Power_System.powerBus;       // if powerBus is a port/feature

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

        // Merge action outputs to DAQ status out (simple pattern; refine later)
        bind statusOut = applyReverseBias.voltageApplicationStatus;
        bind statusOut = measureIVCurves.measuredIVCurvesStatus;
        bind statusOut = maintainMPP.mppStatus;

        // Optionally also forward sensor results (collectData outputs) via statusOut
        bind statusOut = collectData.measuredRadiationStatus;
        bind statusOut = collectData.measuredTemperatureStatus;
        bind statusOut = collectData.measuredSpectrumStatus;
        bind statusOut = collectData.measuredIrradianceStatus;
    }
}
