package SpaceActionsPackage {
    private import ScalarValues::*;
    private import MissionPackage::*;
    private import ISQ::*;
    private import CommunicationsSystemPackage::*;

    // Top-level definition for the Space Segment's behavior
    action def PerformSpaceSegmentMission {}

    // 1. Provide scientific measurements
    action def provideScientificMeasurements specializes PerformSpaceSegmentMission {
        in Perform_Scientific_Action_Command : MissionPackage::OnBoardCommand [0..*] {
            :>> Type = "MeasurementCommand";
        }
        out Measured_Data : MissionPackage::OnBoardStatus [0..*];
    }

    // 1.1 Apply controlled reverse-bias voltage to perovskite solar cells
    action def applyControlledReverseBiasToPSC specializes provideScientificMeasurements {
        in Apply_Reverse_Bias_Voltage_Command redefines Perform_Scientific_Action_Command;
        out Voltage_Application_Status redefines Measured_Data;

        bind Apply_Reverse_Bias_Voltage.Apply_Reverse_Bias_Voltage_Command =
            Apply_Reverse_Bias_Voltage_Command;
        flow from Apply_Reverse_Bias_Voltage.Reverse_Bias_Voltage to Voltage_Application_Status;

        action Apply_Reverse_Bias_Voltage {
            in Apply_Reverse_Bias_Voltage_Command;
            out Reverse_Bias_Voltage : ISQ::SourceVoltageValue;
        }
    }

    action def MeasureIVCurvesOfPSC specializes provideScientificMeasurements {
        in Measure_IV_Curves_Of_PSC_Command redefines Perform_Scientific_Action_Command;
        out Measured_IV_Curves_Status redefines Measured_Data;

        bind Measure_IV_Curves_Of_PSC.Iv_Curves_Data = Measure_IV_Curves_Of_PSC_Command;
        flow from Measure_IV_Curves_Of_PSC.Iv_Curves_Data to Measured_IV_Curves_Status;

        action Measure_IV_Curves_Of_PSC {
            in Measure_IV_Curves_Of_PSC_Command;
            out Iv_Curves_Data : MissionPackage::OnBoardStatus;
        }
    }

    action def maintainMaximumPowerPoint specializes provideScientificMeasurements {
        in Maintain_MPP_Command redefines Perform_Scientific_Action_Command;
        out Mpp_Status redefines Measured_Data;

        bind Maintain_MPP.Maintain_MPP_Command = Maintain_MPP_Command;
        flow from Maintain_MPP.Mpp_Data to Mpp_Status;

        action Maintain_MPP {
            in Maintain_MPP_Command;
            out Mpp_Data : MissionPackage::OnBoardStatus;
        }
    }

    action def collectExperimentalData specializes provideScientificMeasurements {
        in Collect_Experimental_Data_Command redefines Perform_Scientific_Action_Command;

        out Measured_Radiation_Status redefines Measured_Data;
        out Measured_Temperature_Status redefines Measured_Data;
        out Measured_Spectrum_Status redefines Measured_Data;
        out Measured_Irradiance_Status redefines Measured_Data;

        bind Measure_Radiation.Measure_Radiation_Command = Collect_Experimental_Data_Command;
        bind Measure_Temperature.Measure_Temperature_Command = Collect_Experimental_Data_Command;
        bind Measure_Spectrum.Measure_Spectrum_Command = Collect_Experimental_Data_Command;
        bind Measure_Irradiance.Measure_Irradiance_Command = Collect_Experimental_Data_Command;

        flow from Measure_Radiation.Radiation_Data to Measured_Radiation_Status;
        flow from Measure_Temperature.Temperature_Data to Measured_Temperature_Status;
        flow from Measure_Spectrum.Spectrum_Data to Measured_Spectrum_Status;
        flow from Measure_Irradiance.Irradiance_Data to Measured_Irradiance_Status;

        action Measure_Radiation {
            in Measure_Radiation_Command : MissionPackage::OnBoardCommand;
            out Radiation_Data : MissionPackage::OnBoardStatus;
        }
        action Measure_Temperature {
            in Measure_Temperature_Command : MissionPackage::OnBoardCommand;
            out Temperature_Data : MissionPackage::OnBoardStatus;
        }
        action Measure_Spectrum {
            in Measure_Spectrum_Command : MissionPackage::OnBoardCommand;
            out Spectrum_Data : MissionPackage::OnBoardStatus;
        }
        action Measure_Irradiance {
            in Measure_Irradiance_Command : MissionPackage::OnBoardCommand;
            out Irradiance_Data : MissionPackage::OnBoardStatus;
        }
    }

    // ----------------------------------------------------------------------------------------------------------------EPS functions

    action def ManageElectricalPower specializes PerformSpaceSegmentMission {
        in Eps_Command : MissionPackage::OnBoardCommand [0..*] { :>> Type = "PowerCommand"; }
        out Eps_Telemetry : MissionPackage::OnBoardStatus [0..*];
    }

    action def performMPPT specializes ManageElectricalPower {
        in Mppt_Command redefines Eps_Command;
        out Mppt_Status redefines Eps_Telemetry;

        bind Mppt_Controller.Mppt_Command = Mppt_Command;
        flow from Mppt_Controller.Mppt_Telemetry to Mppt_Status;

        action Mppt_Controller {
            in Mppt_Command : MissionPackage::OnBoardCommand;
            out Mppt_Telemetry : MissionPackage::OnBoardStatus;
        }
    }

    action def manageBatteryEnergy specializes ManageElectricalPower {
        in Battery_Command redefines Eps_Command;
        out Battery_Status redefines Eps_Telemetry;

        bind Battery_Manager.Battery_Command = Battery_Command;
        flow from Battery_Manager.Battery_Telemetry to Battery_Status;

        action Battery_Manager {
            in Battery_Command : MissionPackage::OnBoardCommand;
            out Battery_Telemetry : MissionPackage::OnBoardStatus;
        }
    }

    action def distributePowerToLoads specializes ManageElectricalPower {
        in Distribution_Command redefines Eps_Command;
        out Distribution_Status redefines Eps_Telemetry;

        bind Power_Distributor.Distribution_Command = Distribution_Command;
        flow from Power_Distributor.Distribution_Telemetry to Distribution_Status;

        action Power_Distributor {
            in Distribution_Command : MissionPackage::OnBoardCommand;
            out Distribution_Telemetry : MissionPackage::OnBoardStatus;
        }
    }

    action def manageLoadSheddingAndReactivation specializes ManageElectricalPower {
        in Load_Mgmt_Command redefines Eps_Command;
        out Load_Mgmt_Status redefines Eps_Telemetry;

        bind Load_Manager.Load_Mgmt_Command = Load_Mgmt_Command;
        flow from Load_Manager.Load_Mgmt_Telemetry to Load_Mgmt_Status;

        action Load_Manager {
            in Load_Mgmt_Command : MissionPackage::OnBoardCommand;
            out Load_Mgmt_Telemetry : MissionPackage::OnBoardStatus;
        }
    }

    action def switchEPSState specializes ManageElectricalPower {
        in Switch_Command redefines Eps_Command;
        out Switch_Status redefines Eps_Telemetry;

        bind State_Switch.Switch_Command = Switch_Command;
        flow from State_Switch.State_Telemetry to Switch_Status;

        action State_Switch {
            in Switch_Command : MissionPackage::OnBoardCommand;
            out State_Telemetry : MissionPackage::OnBoardStatus;
        }
    }

    action def reportEPSHealth specializes ManageElectricalPower {
        in Report_Command redefines Eps_Command;
        out Health_Telemetry redefines Eps_Telemetry;

        bind Health_Reporter.Report_Command = Report_Command;
        flow from Health_Reporter.Health_Data to Health_Telemetry;

        action Health_Reporter {
            in Report_Command : MissionPackage::OnBoardCommand;
            out Health_Data : MissionPackage::OnBoardStatus;
        }
    }

    // ------------------------------------------------------------------------------------------------
    // ACTION DEFINITIONS (aligned to HEALIOS OBDH concept & requirements)
    // ------------------------------------------------------------------------------------------------
    action def AcquireAndTimestampSubsystemData {
        // Command in / telemetry out (keep as you have)
        in Obdh_Command : MissionPackage::OnBoardCommand [0..*];
        out Obdh_Telemetry : MissionPackage::OnBoardStatus [0..*];

        // -------- Raw inputs from subsystems (expand to match your architecture) --------
        in Eps_Data : MissionPackage::OnBoardStatus [0..*];
        in Aocs_Data : MissionPackage::OnBoardStatus [0..*];
        in Tcs_Data : MissionPackage::OnBoardStatus [0..*];

        // Payload / DAQ-style feeds (your existing naming)
        in Daq_Housekeeping : MissionPackage::OnBoardStatus [0..*];
        in Daq_Science_Raw : MissionPackage::OnBoardStatus [0..*];

        // (Optional but useful) explicit payload sensor streams
        in Pl_Radiation : MissionPackage::OnBoardStatus [0..*];
        in Pl_Irradiance : MissionPackage::OnBoardStatus [0..*];
        in Pl_Spectrum : MissionPackage::OnBoardStatus [0..*];
        in Pl_Temperature : MissionPackage::OnBoardStatus [0..*];

        // Time source (modelled as input; could be GPS time, OBC time, etc.)
        in Current_Time : ISQ::TimeValue [1];

        // Outputs: actually time-tagged types
        out Time_Tagged_HK : MissionPackage::TimeTaggedStatus [0..*];
        out Time_Tagged_Science : MissionPackage::TimeTaggedStatus [0..*];

        // ------------------------------------------------------------------------------------------------
        // Internal actions
        // ------------------------------------------------------------------------------------------------

        // A) Tag HK records
        action Tag_HK {
            in time : ISQ::TimeValue [1];

            in eps : MissionPackage::OnBoardStatus [0..*];
            in aocs : MissionPackage::OnBoardStatus [0..*];
            in tcs : MissionPackage::OnBoardStatus [0..*];
            in daqHK : MissionPackage::OnBoardStatus [0..*];

            out tagged : MissionPackage::TimeTaggedStatus [0..*];

            // semantic intent (you can later replace with transformations / mapping rules)
            // Here we simply state that each input becomes a TimeTaggedStatus with same content + timestamp.
        }

        // B) Tag Science records
        action Tag_Science {
            in time : ISQ::TimeValue [1];

            in daqSci : MissionPackage::OnBoardStatus [0..*];
            in rad : MissionPackage::OnBoardStatus [0..*];
            in irr : MissionPackage::OnBoardStatus [0..*];
            in spec : MissionPackage::OnBoardStatus [0..*];
            in temp : MissionPackage::OnBoardStatus [0..*];

            out tagged : MissionPackage::TimeTaggedStatus [0..*];
        }

        // C) Publish (select what goes immediately to OBDH telemetry vs stored later)
        action Publish {
            in hkTagged : MissionPackage::TimeTaggedStatus [0..*];
            in sciTagged : MissionPackage::TimeTaggedStatus [0..*];

            out outTelemetry : MissionPackage::OnBoardStatus [0..*];

            // e.g. "HK always; science maybe only summaries"
        }

        // ------------------------------------------------------------------------------------------------
        // Bindings / flows (this is the “perform action on them” wiring)
        // ------------------------------------------------------------------------------------------------

        // Bind time source
        bind Tag_HK.time = Current_Time;
        bind Tag_Science.time = Current_Time;

        // Bind raw inputs into taggers
        bind Tag_HK.eps = Eps_Data;
        bind Tag_HK.aocs = Aocs_Data;
        bind Tag_HK.tcs = Tcs_Data;
        bind Tag_HK.daqHK = Daq_Housekeeping;

        bind Tag_Science.daqSci = Daq_Science_Raw;
        bind Tag_Science.rad = Pl_Radiation;
        bind Tag_Science.irr = Pl_Irradiance;
        bind Tag_Science.spec = Pl_Spectrum;
        bind Tag_Science.temp = Pl_Temperature;

        // Outputs
        bind Time_Tagged_HK = Tag_HK.tagged;
        bind Time_Tagged_Science = Tag_Science.tagged;

        // Publish step
        bind Publish.hkTagged = Time_Tagged_HK;
        bind Publish.sciTagged = Time_Tagged_Science;

        // What is sent onward as "Obdh_Telemetry"
        bind Obdh_Telemetry = Publish.outTelemetry;
    }

    action def ManagePersistentStorageAndBuffers {
        in Obdh_Command : MissionPackage::OnBoardCommand [0..*];
        out Obdh_Telemetry : MissionPackage::OnBoardStatus [0..*];

        in Hk_Records : MissionPackage::OnBoardStatus [0..*];
        in Science_Records : MissionPackage::OnBoardStatus [0..*];
        in Event_Records : MissionPackage::OnBoardStatus [0..*];

        out Stored_Ok : MissionPackage::OnBoardStatus [0..*];

        flow from Hk_Records to Stored_Ok;
        flow from Science_Records to Stored_Ok;
        flow from Event_Records to Stored_Ok;
        flow from Stored_Ok to Obdh_Telemetry;
    }

    action def SelectAndPrioritizeDownlinkData {
        in Obdh_Command : MissionPackage::OnBoardCommand [0..*];
        out Obdh_Telemetry : MissionPackage::OnBoardStatus [0..*];

        in Stored_Data_Index : MissionPackage::OnBoardStatus [0..*];
        in Link_Window_Info : MissionPackage::OnBoardStatus [0..*];

        out Downlink_Queue : MissionPackage::OnBoardStatus [0..*];

        flow from Stored_Data_Index to Downlink_Queue;
        flow from Downlink_Queue to Obdh_Telemetry;
    }

    action def ForwardDownlinkFramesToComms {
        in Obdh_Command : MissionPackage::OnBoardCommand [0..*];
        out Obdh_Telemetry : MissionPackage::OnBoardStatus [0..*];

        in Downlink_Queue : MissionPackage::OnBoardStatus [0..*];
        out Comm_Frames : MissionPackage::OnBoardStatus [0..*];

        flow from Downlink_Queue to Comm_Frames;
        flow from Comm_Frames to Obdh_Telemetry;
    }

    action def DecodeValidateAndDispatchCommands {
        in Obdh_Command : MissionPackage::OnBoardCommand [0..*];
        out Obdh_Telemetry : MissionPackage::OnBoardStatus [0..*];

        out Eps_Cmd : MissionPackage::OnBoardCommand [0..*];
        out Aocs_Cmd : MissionPackage::OnBoardCommand [0..*];
        out Tcs_Cmd : MissionPackage::OnBoardCommand [0..*];
        out Daq_Cmd : MissionPackage::OnBoardCommand [0..*];

        out Cmd_Accepted : MissionPackage::OnBoardStatus [0..*];
        out Cmd_Rejected : MissionPackage::OnBoardStatus [0..*];

        flow from Cmd_Accepted to Obdh_Telemetry;
        flow from Cmd_Rejected to Obdh_Telemetry;
    }

    action def ExecuteTimeTaggedCommands {
        in Obdh_Command : MissionPackage::OnBoardCommand [0..*];
        out Obdh_Telemetry : MissionPackage::OnBoardStatus [0..*];

        in Scheduled_Cmds : MissionPackage::OnBoardCommand [0..*];
        out Executed : MissionPackage::OnBoardStatus [0..*];

        flow from Executed to Obdh_Telemetry;
    }

    action def PerformOBDHHealthMonitoringAndFDIR {
        in Obdh_Command : MissionPackage::OnBoardCommand [0..*];
        out Obdh_Telemetry : MissionPackage::OnBoardStatus [0..*];

        in Hk_Inputs : MissionPackage::OnBoardStatus [0..*];
        out Fdir_Events : MissionPackage::OnBoardStatus [0..*];
        out Safe_Mode_Req : MissionPackage::OnBoardCommand [0..*];

        flow from Hk_Inputs to Fdir_Events;
        flow from Fdir_Events to Obdh_Telemetry;
    }

    action def ManageSpacecraftModesAndAutonomy {
        in Obdh_Command : MissionPackage::OnBoardCommand [0..*];
        out Obdh_Telemetry : MissionPackage::OnBoardStatus [0..*];

        in Power_State : MissionPackage::OnBoardStatus [0..*];
        in Thermal_State : MissionPackage::OnBoardStatus [0..*];
        in Fdir_Events : MissionPackage::OnBoardStatus [0..*];

        out Mode_Change : MissionPackage::OnBoardCommand [0..*];

        flow from Mode_Change to Obdh_Telemetry;
    }

    action def ManageWarmRedundantAuthorityAndTakeover {
        in Obdh_Command : MissionPackage::OnBoardCommand [0..*];
        out Obdh_Telemetry : MissionPackage::OnBoardStatus [0..*];

        in Primary_Heartbeat : MissionPackage::OnBoardStatus [0..*];
        in Sync_Updates : MissionPackage::OnBoardStatus [0..*];

        out Takeover_Declared : MissionPackage::OnBoardStatus [0..*];
        out Enter_Safe_Mode : MissionPackage::OnBoardCommand [0..*];

        flow from Takeover_Declared to Obdh_Telemetry;
    }

    action def SynchronizeRedundantOBCState {
        in Obdh_Command : MissionPackage::OnBoardCommand [0..*];
        out Obdh_Telemetry : MissionPackage::OnBoardStatus [0..*];

        in Current_State : MissionPackage::OnBoardStatus [0..*];
        out Sync_Packet : MissionPackage::OnBoardStatus [0..*];

        flow from Current_State to Sync_Packet;
        flow from Sync_Packet to Obdh_Telemetry;
    }

    action def PerformDualBankSoftwareUpdateAndRollback {
        in Obdh_Command : MissionPackage::OnBoardCommand [0..*];
        out Obdh_Telemetry : MissionPackage::OnBoardStatus [0..*];

        in Image_Packets : MissionPackage::OnBoardStatus [0..*];

        out Image_Verified : MissionPackage::OnBoardStatus [0..*];
        out Bank_Switched : MissionPackage::OnBoardStatus [0..*];
        out Rollback_Done : MissionPackage::OnBoardStatus [0..*];

        flow from Image_Verified to Obdh_Telemetry;
        flow from Bank_Switched to Obdh_Telemetry;
        flow from Rollback_Done to Obdh_Telemetry;
    }

    // ------------------------------------------------------------------------------------------------Thermal actions

    action def EvaluateThreshold {
        in Temp : ISQ::TemperatureValue;
        in Threshold : ISQ::TemperatureValue;
        out ref Turn_On : Boolean;

        if Temp > Threshold {
            assign Turn_On := false;
        } else {
            assign Turn_On := true;
        }
    }

    action def StartHeater {
        in Enable_Signal : Boolean;
        in Heater_Power_Value : ISQ::PowerValue;
        out ref Heater_Output : ISQ::PowerValue;

        if Enable_Signal {
            assign Heater_Output := Heater_Power_Value;
        } else {
            assign Heater_Output := 0 [SI::W];
        }
    }

    action def ControlTemperature {
        in Minimal_Temperature : ISQ::TemperatureValue;
        in Heating_Power : ISQ::PowerValue;
        in Temp_Reading : ISQ::TemperatureValue;

        action Evaluate : EvaluateThreshold {
            bind Temp = Temp_Reading;
            bind Threshold = Minimal_Temperature;
        }

        then action Heat : StartHeater {
            bind Heater_Power_Value = Heating_Power;
            bind Enable_Signal = Evaluate.Turn_On;
        }
    }

    action def UseTCS {
        in Command : OnBoardCommand;
        in Minimal_Temperature_Input : ISQ::TemperatureValue;
        in Measured_Temperature_Input : ISQ::TemperatureValue;
        in Heating_Power_Input : ISQ::PowerValue;

        // if Command.Type == "Start_Command" {
        //     loop {
                perform action Read_Temperature : ReadTemperature {
                    bind Temp = Measured_Temperature_Input;
                }
                then perform action Control_Temperature : ControlTemperature {
                    bind Control_Temperature.Minimal_Temperature = Minimal_Temperature_Input;
                    bind Control_Temperature.Heating_Power = Heating_Power_Input;
                    bind Control_Temperature.Temp_Reading = Read_Temperature.Temp;
                }
        //     } until Command.Type == "Stop_Command";
        // }
    }

    action def ReadTemperature {
        out Temp : ISQ::TemperatureValue;
    }

    // aocsssssssssssssssssssssssssssssssssssss_______________________________________________________

    action def ReadSunAngle {
        out Beta_Angle : ISQ::AngularMeasureValue;
    }

    action def UseMagnetorquer {
        in Beta_Angle : ISQ::AngularMeasureValue;
        in Threshold : ISQ::AngularMeasureValue;
        out Force : ISQ::ForceValue;
    }

    action def CorrectAttitude {
        in Force_Value : ISQ::ForceValue;
        in Sun_Sensor_Reading : ISQ::AngularMeasureValue;
        in Threshold : ISQ::AngularMeasureValue; // 0 to pi
        out Force : ISQ::ForceValue;

        then action Use_Magnetorquer : UseMagnetorquer {
            bind UseMagnetorquer::Threshold = CorrectAttitude::Threshold;
            bind UseMagnetorquer::Beta_Angle = Sun_Sensor_Reading;
            bind UseMagnetorquer::Force = CorrectAttitude::Force;
            if Beta_Angle > Threshold {
                assign Force := Force_Value;
            } else {
                assign Force := 0 [SI::N];
            }
        }
    }

    action def UseAOCS {
        in Command : OnBoardCommand;
        in Beta_Angle_Threshold : ISQ::AngularMeasureValue;
        out Force_Output : ISQ::ForceValue;
        // if Command.Type == "Start_Command"{
        // loop {
        action Read_Sun_Angle : ReadSunAngle;
        then action Correct_Attitude : CorrectAttitude;
        // } until Command.Type == "Stop_Command";
        // }
    }

    action def TransmitStatusDownlink {
        in item Telemetry_Input : MissionPackage::OnBoardStatus;
        out item Transmitted_Radio_Signal : MissionPackage::TelemetryData;
    }

    action def DecryptAndAuthenticateUplink {
        in item Telemetry_To_Encrypt : MissionPackage::TelemetryData;
        out item cmdOut : MissionPackage::GroundCommand;
    }

    action def EncryptDownlinkTelemetry {
        in item Telemetry_To_Encrypt : MissionPackage::TelemetryData;
        out item Secured_Encrypted_Telemetry : MissionPackage::TelemetryData;
    }

    action def TransmitBeacon {
        out item Secured_Encrypted_Telemetry : MissionPackage::TelemetryData;
    }

    action def ArchiveAndStoreMissionData {
        in item Telemetry_To_Archive : MissionPackage::TelemetryData;
        out item Archived_Record : GroundStationPackage::ArchiveRecord;
    }

    // ----------------safe mode coomands

    action def Enter_Safe_Mode_Action specializes PerformSpaceSegmentMission {
        in Trigger_Command : MissionPackage::OnBoardCommand [0..*] { :>> Type = "ErrorCommand"; }
        out Payload_Power_Off_Cmd : MissionPackage::OnBoardCommand [0..*] {
            :>> Type = "PowerCommand";
        }
        out Safe_Mode_Cmd : MissionPackage::OnBoardCommand [0..*] { :>> Type = "ModeCommand"; }
        out Safe_Mode_Status : MissionPackage::OnBoardStatus [0..*];

        // 1) Shed non-essential loads (incl. payload) via EPS load management
        action Shed_Payload_Loads : manageLoadSheddingAndReactivation;
        bind Shed_Payload_Loads.Load_Mgmt_Command = Payload_Power_Off_Cmd;
        flow from Shed_Payload_Loads.Load_Mgmt_Status to Safe_Mode_Status;

        // 2) Command the spacecraft to transition into Safe Mode
        // (interpreted by the mode manager / OBDH)
        // NOTE: Specific decoding of Safe_Mode_Cmd is handled elsewhere; here we only emit it.
    }
}

package GroundActionsPackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import GroundStationPackage::*;
    private import MissionControlCentrePackage::*;

    action def ExecuteUplink {
        in item Secured_Command_Input : MissionPackage::GroundCommand;
        out item Modulated_Uplink_Signal : MissionPackage::TelemetryData;
    }

    action def ReceiveDownlink {
        out item Captured_Encrypted_Telemetry : MissionPackage::TelemetryData;
        in item Incoming_Radio_Signal : TelemetryData;
    }

    action def ComputeTracking {
        in item Satellite_plan : PassPlan;
        out item Tracking_Data : TrackingData;
    }

    action def StreamToArchive {
        in item Telemetry_To_Archive : MissionPackage::TelemetryData;
        out item Record_of_Telemetry : ArchiveRecord;
    }

    action def VerifyAndDecryptDownlink {
        in item Telemetry_To_Decrypt : MissionPackage::TelemetryData;
        out item Verified_Ground_Telemetry_Data : MissionPackage::TelemetryData;
    }

    action def AuthenticateAndEncryptUplink {
        in item Telecommand_To_Encrypt : MissionPackage::GroundCommand;
        out item Secured_Encrypted_Telecommand : MissionPackage::GroundCommand;
    }

    action def ValidateTelemetry {
        in item Telemetry_For_Validate : MissionPackage::TelemetryData;
        out item Validated_Telemetry : MissionPackage::TelemetryData;
    }

    action def StoreRecord {
        in item Record_of_Satellite_Data : ArchiveRecord;
    }

    action def AuthorizeCommanding {
        in item Access_Request_Input : OperatorRequest;
        out item Valid_Session_Token : AuthToken;
    }

    action def GenerateTelecommand {
        in item Session_Token_Input : AuthToken;
        out item Raw_Unsecured_Telecommand : MissionPackage::GroundCommand;
    }

    action def GeneratePassPlan {
        out item Plan_of_Satellite_Path : PassPlan;
    }

    action def MonitorTelemetryRealtime {
        in item Telemetry_For_Monitoring : MissionPackage::TelemetryData;
        out item Real_Time_Health_Display : TelemetryData;
    }

    action def GetScientificDatasets {
        doc
        /* Converts archive records into human-readable datasets. */

        in item Raw_Archive_Data_Input : ArchiveRecord;
        out item Validated_Scientific_Dataset : ProcessedScienceData;
    }

    action def FacilitateYouthDevelopement {
        doc
        /* Universities use the live mission data to facilitate student theses, laboratory exercises, and hands-on operational training. */

        in item Mission_Data_For_Students : ProcessedScienceData;
        out item Academic_Educational_Outcome : ProcessedScienceData;
    }

    action def AnalyzePerovskiteSelfHealingBehavior {
        doc
        /* Investigates the self-healing properties of perovskite solar cells 
         * in space by analyzing I-V curves and efficiency recovery during 
         * eclipse phases.
         */

        in item Dataset_For_Investigation : ProcessedScienceData;
        out item Self_Healing_Behaviour_Dataset : ProcessedScienceData;
    }

    action def BenchmarkDegradationAgainstSiliconStandards {
        doc
        /* Compares the degradation rates of perovskite solar cells against 
         * established traditional solar cell benchmarks (e.g., Triple-Junction 
         * Silicon) to evaluate performance and Technology Readiness Level (TRL).
         */

        in item Comparative_Data_Input : ProcessedScienceData;
        out item Benchmark_Results_Dataset : ProcessedScienceData;
    }
}
