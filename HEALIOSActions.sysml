package HEALIOS_Space_Functions {
    // Ensuring explicit visibility as requested previously
    private import ScalarValues::*;
    private import HEALIOS::*;
    // Top-level definition for the Space Segment's behavior
    action def PerformSpaceSegmentMission {
    }

    // 1. Provide scientific measurements
    action def provideScientificMeasurements specializes PerformSpaceSegmentMission {
        in performScientificActionCommand [0..*] : HEALIOS::OnBoardCommand{:>> type = "MeasurementCommand";}
        out measuredData [0..*] : HEALIOS::OnBoardStatus;
        }

    // 1.1 Apply controlled reverse-bias voltage to perovskite solar cells
    action def applyControlledReverseBiasToPSC specializes provideScientificMeasurements {
        in applyReverseBiasVoltageCommand redefines performScientificActionCommand;
        out voltageApplicationStatus redefines measuredData;
        // 1.1.2 Apply reverse-bias voltage
        bind applyReverseBiasVoltage.applyReverseBiasVoltageCommand = applyReverseBiasVoltageCommand;
        flow from applyReverseBiasVoltage.reverseBiasVoltage to voltageApplicationStatus;
        action applyReverseBiasVoltage {
            in applyReverseBiasVoltageCommand;
            out reverseBiasVoltage : ISQ::voltage;
        }
    }

    action def MeasureIVCurvesOfPSC specializes provideScientificMeasurements {
        in measureIVCurvesOfPSCCommand redefines performScientificActionCommand;
        out measuredIVCurvesStatus redefines measuredData;

        bind measureIVCurvesOfPSC.ivCurvesData = measureIVCurvesOfPSCCommand;

        flow from measureIVCurvesOfPSC.ivCurvesData to measuredIVCurvesStatus;

        action measureIVCurvesOfPSC{
            in measureIVCurvesOfPSCCommand;
            out ivCurvesData : HEALIOS::OnBoardStatus;
        }
    }

    action def maintainMaximumPowerPoint specializes provideScientificMeasurements {
        // Maintain maximum power point (MPP) operating conditions
        in maintainMPPCommand redefines performScientificActionCommand;
        out mppStatus redefines measuredData;

        bind maintainMPP.maintainMPPCommand = maintainMPPCommand;

        flow from maintainMPP.mppData to mppStatus;

        action maintainMPP{
            in maintainMPPCommand;
            out mppData : HEALIOS::OnBoardStatus;
        }
    }

    action def collectExperimentalData specializes provideScientificMeasurements {
        // Collect experimental data
        in collectExperimentalDataCommand redefines performScientificActionCommand;

        out measuredRadiationStatus redefines measuredData;
        out measuredTemperatureStatus redefines measuredData;
        out measuredSpectrumStatus redefines measuredData;
        out measuredIrradianceStatus redefines measuredData;

        bind measureRadiation.measureRadiationCommand = collectExperimentalDataCommand;
        bind measureTemperature.measureTemperatureCommand = collectExperimentalDataCommand;
        bind measureSpectrum.measureSpectrumCommand = collectExperimentalDataCommand;
        bind measureIrradiance.measureIrradianceCommand = collectExperimentalDataCommand;

        flow from measureRadiation.radiationData to measuredRadiationStatus;
        flow from measureTemperature.temperatureData to measuredTemperatureStatus;
        flow from measureSpectrum.spectrumData to measuredSpectrumStatus;
        flow from measureIrradiance.irradianceData to measuredIrradianceStatus;

        // 1.2.1 - 1.2.4 Nested parameters/actions
        action measureRadiation{
            in measureRadiationCommand : HEALIOS::OnBoardCommand;
            out radiationData : HEALIOS::OnBoardStatus;
        }
        action measureTemperature{
            in measureTemperatureCommand : HEALIOS::OnBoardCommand;
            out temperatureData : HEALIOS::OnBoardStatus;
        }
        action measureSpectrum{
            in measureSpectrumCommand : HEALIOS::OnBoardCommand;
            out spectrumData : HEALIOS::OnBoardStatus;
        }
        action measureIrradiance{
            in measureIrradianceCommand : HEALIOS::OnBoardCommand;
            out irradianceData : HEALIOS::OnBoardStatus;
        }
    }
}