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
            out reverseBiasVoltage : ISQ::SourceVoltageValue;
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

    
    //------------------------------------------------------------------------------------------------
    // ACTION DEFINITIONS (aligned to HEALIOS OBDH concept & requirements)
    //------------------------------------------------------------------------------------------------

    // Centralised cyclic acquisition + time-referencing.
    // Data acquisition is periodic; payload data preserved “as-is” (no numerical modification).
    action def AcquireAndTimestampSubsystemData {
        in  obdhCommand  [0..*] : HEALIOS::OnBoardCommand;
        out obdhTelemetry[0..*] : HEALIOS::OnBoardStatus;

        // Inputs from subsystems (logical)
        in  epsData   [0..*] : HEALIOS::OnBoardStatus;
        in  aocsData  [0..*] : HEALIOS::OnBoardStatus;
        in  tcsData   [0..*] : HEALIOS::OnBoardStatus;

        // Payload / DAQ
        in  daqHousekeeping [0..*] : HEALIOS::OnBoardStatus;
        in  daqScienceRaw   [0..*] : HEALIOS::OnBoardStatus;

        // Outputs (time-tagged records)
        out timeTaggedHK [0..*] : HEALIOS::OnBoardStatus;
        out timeTaggedScience [0..*] : HEALIOS::OnBoardStatus;

        // Conceptual flow: tag-and-forward into storage manager
        flow from epsData to timeTaggedHK;
        flow from aocsData to timeTaggedHK;
        flow from tcsData to timeTaggedHK;
        flow from daqHousekeeping to timeTaggedHK;

        flow from daqScienceRaw to timeTaggedScience;

        // Housekeeping to telemetry path
        flow from timeTaggedHK to obdhTelemetry;
    }

    // Persistent storage & buffer management (NOR flash; survive resets; decouple from ground contact).
    action def ManagePersistentStorageAndBuffers {
        in  obdhCommand  [0..*] : HEALIOS::OnBoardCommand;
        out obdhTelemetry[0..*] : HEALIOS::OnBoardStatus;

        in  hkRecords      [0..*] : HEALIOS::OnBoardStatus;
        in  scienceRecords [0..*] : HEALIOS::OnBoardStatus;
        in  eventRecords   [0..*] : HEALIOS::OnBoardStatus;

        out storedOk       [0..*] : HEALIOS::OnBoardStatus;

        // “store raw science + HK + events in NVM, retain until confirmed downlinked”
        flow from hkRecords to storedOk;
        flow from scienceRecords to storedOk;
        flow from eventRecords to storedOk;
        flow from storedOk to obdhTelemetry;
    }

    // Data selection + prioritisation for constrained downlink windows.
    action def SelectAndPrioritizeDownlinkData {
        in  obdhCommand  [0..*] : HEALIOS::OnBoardCommand;
        out obdhTelemetry[0..*] : HEALIOS::OnBoardStatus;

        in  storedDataIndex [0..*] : HEALIOS::OnBoardStatus;
        in  linkWindowInfo  [0..*] : HEALIOS::OnBoardStatus;

        out downlinkQueue   [0..*] : HEALIOS::OnBoardStatus;

        // “critical telemetry and diagnostic info first”
        flow from storedDataIndex to downlinkQueue;
        flow from downlinkQueue to obdhTelemetry;
    }

    // During contact: pull from NVM, feed comm subsystem, keep acquisition running.
    action def ForwardDownlinkFramesToComms {
        in  obdhCommand  [0..*] : HEALIOS::OnBoardCommand;
        out obdhTelemetry[0..*] : HEALIOS::OnBoardStatus;

        in  downlinkQueue [0..*] : HEALIOS::OnBoardStatus;
        out commFrames    [0..*] : HEALIOS::OnBoardStatus;

        flow from downlinkQueue to commFrames;
        flow from commFrames to obdhTelemetry;
    }

    // Command ingest: decode, validate, dispatch to subsystem controllers (OBDH is central router).
    action def DecodeValidateAndDispatchCommands {
        in  obdhCommand  [0..*] : HEALIOS::OnBoardCommand;
        out obdhTelemetry[0..*] : HEALIOS::OnBoardStatus;

        // Outputs to subsystems (logical)
        out epsCmd   [0..*] : HEALIOS::OnBoardCommand;
        out aocsCmd  [0..*] : HEALIOS::OnBoardCommand;
        out tcsCmd   [0..*] : HEALIOS::OnBoardCommand;
        out daqCmd   [0..*] : HEALIOS::OnBoardCommand;

        out cmdAccepted [0..*] : HEALIOS::OnBoardStatus;
        out cmdRejected [0..*] : HEALIOS::OnBoardStatus;

        flow from cmdAccepted to obdhTelemetry;
        flow from cmdRejected to obdhTelemetry;
    }

    // Execute commands at specified time (time-tagged execution requirement).
    action def ExecuteTimeTaggedCommands {
        in  obdhCommand  [0..*] : HEALIOS::OnBoardCommand;
        out obdhTelemetry[0..*] : HEALIOS::OnBoardStatus;

        in  scheduledCmds [0..*] : HEALIOS::OnBoardCommand;
        out executed      [0..*] : HEALIOS::OnBoardStatus;

        flow from executed to obdhTelemetry;
    }

    // Continuous health monitoring + FDIR triggers and event logging support.
    action def PerformOBDHHealthMonitoringAndFDIR {
        in  obdhCommand  [0..*] : HEALIOS::OnBoardCommand;
        out obdhTelemetry[0..*] : HEALIOS::OnBoardStatus;

        in  hkInputs      [0..*] : HEALIOS::OnBoardStatus;
        out fdirEvents    [0..*] : HEALIOS::OnBoardStatus;
        out safeModeReq   [0..*] : HEALIOS::OnBoardCommand;

        flow from hkInputs to fdirEvents;
        flow from fdirEvents to obdhTelemetry;
    }

    // Mode management (Deployment -> Commissioning -> Nominal; Safe Mode on anomaly).
    action def ManageSpacecraftModesAndAutonomy {
        in  obdhCommand  [0..*] : HEALIOS::OnBoardCommand;
        out obdhTelemetry[0..*] : HEALIOS::OnBoardStatus;

        in  powerState    [0..*] : HEALIOS::OnBoardStatus;
        in  thermalState  [0..*] : HEALIOS::OnBoardStatus;
        in  fdirEvents    [0..*] : HEALIOS::OnBoardStatus;

        out modeChange    [0..*] : HEALIOS::OnBoardCommand;

        flow from modeChange to obdhTelemetry;
    }

    // Warm redundancy: secondary monitors heartbeat/sync; declares failure; assumes authority; enters Safe.
    action def ManageWarmRedundantAuthorityAndTakeover {
        in  obdhCommand  [0..*] : HEALIOS::OnBoardCommand;
        out obdhTelemetry[0..*] : HEALIOS::OnBoardStatus;

        in  primaryHeartbeat [0..*] : HEALIOS::OnBoardStatus;
        in  syncUpdates      [0..*] : HEALIOS::OnBoardStatus;

        out takeoverDeclared [0..*] : HEALIOS::OnBoardStatus;
        out enterSafeMode    [0..*] : HEALIOS::OnBoardCommand;

        flow from takeoverDeclared to obdhTelemetry;
    }

    // Continuous sync of the “small subset” needed for deterministic takeover.
    action def SynchronizeRedundantOBCState {
        in  obdhCommand  [0..*] : HEALIOS::OnBoardCommand;
        out obdhTelemetry[0..*] : HEALIOS::OnBoardStatus;

        in  currentState [0..*] : HEALIOS::OnBoardStatus;
        out syncPacket   [0..*] : HEALIOS::OnBoardStatus;

        flow from currentState to syncPacket;
        flow from syncPacket to obdhTelemetry;
    }

    // Dual-bank bootloader update + rollback (in-orbit SW updates).
    action def PerformDualBankSoftwareUpdateAndRollback {
        in  obdhCommand  [0..*] : HEALIOS::OnBoardCommand;
        out obdhTelemetry[0..*] : HEALIOS::OnBoardStatus;

        in  imagePackets [0..*] : HEALIOS::OnBoardStatus;

        out imageVerified [0..*] : HEALIOS::OnBoardStatus;
        out bankSwitched  [0..*] : HEALIOS::OnBoardStatus;
        out rollbackDone  [0..*] : HEALIOS::OnBoardStatus;

        flow from imageVerified to obdhTelemetry;
        flow from bankSwitched to obdhTelemetry;
        flow from rollbackDone to obdhTelemetry;
    }

    //------------------------------------------------------------------------------------------------Thermal actions

    action def EvaluateThreshold {
        in temp : ISQ::TemperatureValue;
        in threshold : ISQ::TemperatureValue; 
        out turnOn : Boolean;
    }
    
    action def StartHeater {
        in turnOn: HEALIOS::OnBoardCommand{
            :>> type = "HeaterActivationCommand";
        }
        in heaterPower : ISQ::PowerValue;
        out heaterOutput : ISQ::PowerValue;
    }
    
    action def ControlTemperature {
        in minimalTemperature : ISQ::TemperatureValue;
        in heaterPower : ISQ::PowerValue;
        in tempReading : ISQ::TemperatureValue;
        
        action heat : StartHeater;
        action evaluate : EvaluateThreshold if threshold < 0 {
            perform action heat;
        }

        flow evaluate.turnOn to heat.turnOn;

        bind evaluate.threshold = minimalTemperature;
        bind heat.heaterPower = heaterPower;
        bind evaluate.temp = tempReading;
    }

}
