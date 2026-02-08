package HEALIOS_Space_Functions {
    // Ensuring explicit visibility as requested previously
    private import ScalarValues::*;
    private import System::*;
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

    //----------------------------------------------------------------------------------------------------------------EPS functions

    
    // EPS-level behavior (driven by telecommand, produces telemetry)
    action def ManageElectricalPower specializes PerformSpaceSegmentMission {
        in epsCommand [0..*] : HEALIOS::OnBoardCommand {:>> type = "PowerCommand";}
        out epsTelemetry [0..*] : HEALIOS::OnBoardStatus;
    }

    // MPPT (Design Report: PMU performs MPPT internally)
    action def performMPPT specializes ManageElectricalPower {
        in mpptCommand redefines epsCommand;
        out mpptStatus redefines epsTelemetry;

        bind mpptController.mpptCommand = mpptCommand;
        flow from mpptController.mpptTelemetry to mpptStatus;

        action mpptController {
            in mpptCommand : HEALIOS::OnBoardCommand;
            out mpptTelemetry : HEALIOS::OnBoardStatus;
        }
    }

    // Battery charge/discharge management (Requirements: rechargeable batteries, safe limits)
    action def manageBatteryEnergy specializes ManageElectricalPower {
        in batteryCommand redefines epsCommand;
        out batteryStatus redefines epsTelemetry;

        bind batteryManager.batteryCommand = batteryCommand;
        flow from batteryManager.batteryTelemetry to batteryStatus;

        action batteryManager {
            in batteryCommand : HEALIOS::OnBoardCommand;
            out batteryTelemetry : HEALIOS::OnBoardStatus;
        }
    }

    // Power distribution to subsystems (Requirements: deliver power per scenario, ON state)
    action def distributePowerToLoads specializes ManageElectricalPower {
        in distributionCommand redefines epsCommand;
        out distributionStatus redefines epsTelemetry;

        bind powerDistributor.distributionCommand = distributionCommand;
        flow from powerDistributor.distributionTelemetry to distributionStatus;

        action powerDistributor {
            in distributionCommand : HEALIOS::OnBoardCommand;
            out distributionTelemetry : HEALIOS::OnBoardStatus;
        }
    }

    // Load shedding / reactivation logic (Requirements: reactivate at all times based on battery level)
    action def manageLoadSheddingAndReactivation specializes ManageElectricalPower {
        in loadMgmtCommand redefines epsCommand;
        out loadMgmtStatus redefines epsTelemetry;

        bind loadManager.loadMgmtCommand = loadMgmtCommand;
        flow from loadManager.loadMgmtTelemetry to loadMgmtStatus;

        action loadManager {
            in loadMgmtCommand : HEALIOS::OnBoardCommand;
            out loadMgmtTelemetry : HEALIOS::OnBoardStatus;
        }
    }

    // EPS state switching (Requirements: switch EPS ON/OFF via umbilical; enable ground control)
    action def switchEPSState specializes ManageElectricalPower {
        in switchCommand redefines epsCommand;
        out switchStatus redefines epsTelemetry;

        bind stateSwitch.switchCommand = switchCommand;
        flow from stateSwitch.stateTelemetry to switchStatus;

        action stateSwitch {
            in switchCommand : HEALIOS::OnBoardCommand;
            out stateTelemetry : HEALIOS::OnBoardStatus;
        }
    }

    // EPS health reporting (Requirements: EPS health via telemetry)
    action def reportEPSHealth specializes ManageElectricalPower {
        in reportCommand redefines epsCommand;
        out healthTelemetry redefines epsTelemetry;

        bind healthReporter.reportCommand = reportCommand;
        flow from healthReporter.healthData to healthTelemetry;

        action healthReporter {
            in reportCommand : HEALIOS::OnBoardCommand;
            out healthData : HEALIOS::OnBoardStatus;
        }
    }
}
