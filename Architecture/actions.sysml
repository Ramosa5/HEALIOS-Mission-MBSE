package SpaceActionsPackage{
    private import ScalarValues::*;
    private import MissionPackage::*;

    // Top-level definition for the Space Segment's behavior
    action def PerformSpaceSegmentMission {
    }

    // 1. Provide scientific measurements
    action def provideScientificMeasurements specializes PerformSpaceSegmentMission {
        in Perform_Scientific_Action_Command [0..*] : MissionPackage::OnBoardCommand {:>> Type = "MeasurementCommand";}
        out Measured_Data [0..*] : MissionPackage::OnBoardStatus;
    }

    // 1.1 Apply controlled reverse-bias voltage to perovskite solar cells
    action def applyControlledReverseBiasToPSC specializes provideScientificMeasurements {
        in Apply_Reverse_Bias_Voltage_Command redefines Perform_Scientific_Action_Command;
        out Voltage_Application_Status redefines Measured_Data;

        bind Apply_Reverse_Bias_Voltage.Apply_Reverse_Bias_Voltage_Command = Apply_Reverse_Bias_Voltage_Command;
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

        action Measure_IV_Curves_Of_PSC{
            in Measure_IV_Curves_Of_PSC_Command;
            out Iv_Curves_Data : MissionPackage::OnBoardStatus;
        }
    }

    action def maintainMaximumPowerPoint specializes provideScientificMeasurements {
        in Maintain_MPP_Command redefines Perform_Scientific_Action_Command;
        out Mpp_Status redefines Measured_Data;

        bind Maintain_MPP.Maintain_MPP_Command = Maintain_MPP_Command;
        flow from Maintain_MPP.Mpp_Data to Mpp_Status;

        action Maintain_MPP{
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

        action Measure_Radiation{
            in Measure_Radiation_Command : MissionPackage::OnBoardCommand;
            out Radiation_Data : MissionPackage::OnBoardStatus;
        }
        action Measure_Temperature{
            in Measure_Temperature_Command : MissionPackage::OnBoardCommand;
            out Temperature_Data : MissionPackage::OnBoardStatus;
        }
        action Measure_Spectrum{
            in Measure_Spectrum_Command : MissionPackage::OnBoardCommand;
            out Spectrum_Data : MissionPackage::OnBoardStatus;
        }
        action Measure_Irradiance{
            in Measure_Irradiance_Command : MissionPackage::OnBoardCommand;
            out Irradiance_Data : MissionPackage::OnBoardStatus;
        }
    }

    //----------------------------------------------------------------------------------------------------------------EPS functions

    action def ManageElectricalPower specializes PerformSpaceSegmentMission {
        in Eps_Command [0..*] : MissionPackage::OnBoardCommand {:>> Type = "PowerCommand";}
        out Eps_Telemetry [0..*] : MissionPackage::OnBoardStatus;
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

    //------------------------------------------------------------------------------------------------
    // ACTION DEFINITIONS (aligned to HEALIOS OBDH concept & requirements)
    //------------------------------------------------------------------------------------------------
action def AcquireAndTimestampSubsystemData {

        // Command in / telemetry out (keep as you have)
        in  Obdh_Command   [0..*] : MissionPackage::OnBoardCommand;
        out Obdh_Telemetry [0..*] : MissionPackage::OnBoardStatus;

        // -------- Raw inputs from subsystems (expand to match your architecture) --------
        in Eps_Data   [0..*] : MissionPackage::OnBoardStatus;
        in Aocs_Data  [0..*] : MissionPackage::OnBoardStatus;
        in Tcs_Data   [0..*] : MissionPackage::OnBoardStatus;

        // Payload / DAQ-style feeds (your existing naming)
        in Daq_Housekeeping [0..*] : MissionPackage::OnBoardStatus;
        in Daq_Science_Raw  [0..*] : MissionPackage::OnBoardStatus;

        // (Optional but useful) explicit payload sensor streams
        in Pl_Radiation [0..*] : MissionPackage::OnBoardStatus;
        in Pl_Irradiance[0..*] : MissionPackage::OnBoardStatus;
        in Pl_Spectrum  [0..*] : MissionPackage::OnBoardStatus;
        in Pl_Temperature[0..*] : MissionPackage::OnBoardStatus;

        // Time source (modelled as input; could be GPS time, OBC time, etc.)
        in Current_Time [1] : ISQ::TimeValue;

        // Outputs: actually time-tagged types
        out Time_Tagged_HK      [0..*] : MissionPackage::TimeTaggedStatus;
        out Time_Tagged_Science [0..*] : MissionPackage::TimeTaggedStatus;

        // ------------------------------------------------------------------------------------------------
        // Internal actions
        // ------------------------------------------------------------------------------------------------

        // A) Tag HK records
        action Tag_HK {
            in  time [1] : ISQ::TimeValue;

            in  eps   [0..*] : MissionPackage::OnBoardStatus;
            in  aocs  [0..*] : MissionPackage::OnBoardStatus;
            in  tcs   [0..*] : MissionPackage::OnBoardStatus;
            in  daqHK [0..*] : MissionPackage::OnBoardStatus;

            out tagged [0..*] : MissionPackage::TimeTaggedStatus;

            // semantic intent (you can later replace with transformations / mapping rules)
            // Here we simply state that each input becomes a TimeTaggedStatus with same content + timestamp.
        }

        // B) Tag Science records
        action Tag_Science {
            in  time [1] : ISQ::TimeValue;

            in  daqSci [0..*] : MissionPackage::OnBoardStatus;
            in  rad    [0..*] : MissionPackage::OnBoardStatus;
            in  irr    [0..*] : MissionPackage::OnBoardStatus;
            in  spec   [0..*] : MissionPackage::OnBoardStatus;
            in  temp   [0..*] : MissionPackage::OnBoardStatus;

            out tagged [0..*] : MissionPackage::TimeTaggedStatus;
        }

        // C) Publish (select what goes immediately to OBDH telemetry vs stored later)
        action Publish {
            in hkTagged   [0..*] : MissionPackage::TimeTaggedStatus;
            in sciTagged  [0..*] : MissionPackage::TimeTaggedStatus;

            out outTelemetry [0..*] : MissionPackage::OnBoardStatus;

            // e.g. "HK always; science maybe only summaries"
        }

        // ------------------------------------------------------------------------------------------------
        // Bindings / flows (this is the “perform action on them” wiring)
        // ------------------------------------------------------------------------------------------------

        // Bind time source
        bind Tag_HK.time = Current_Time;
        bind Tag_Science.time = Current_Time;

        // Bind raw inputs into taggers
        bind Tag_HK.eps   = Eps_Data;
        bind Tag_HK.aocs  = Aocs_Data;
        bind Tag_HK.tcs   = Tcs_Data;
        bind Tag_HK.daqHK = Daq_Housekeeping;

        bind Tag_Science.daqSci = Daq_Science_Raw;
        bind Tag_Science.rad    = Pl_Radiation;
        bind Tag_Science.irr    = Pl_Irradiance;
        bind Tag_Science.spec   = Pl_Spectrum;
        bind Tag_Science.temp   = Pl_Temperature;

        // Outputs
        bind Time_Tagged_HK      = Tag_HK.tagged;
        bind Time_Tagged_Science = Tag_Science.tagged;

        // Publish step
        bind Publish.hkTagged  = Time_Tagged_HK;
        bind Publish.sciTagged = Time_Tagged_Science;

        // What is sent onward as "Obdh_Telemetry"
        bind Obdh_Telemetry = Publish.outTelemetry;
    }

    action def ManagePersistentStorageAndBuffers {
        in  Obdh_Command  [0..*] : MissionPackage::OnBoardCommand;
        out Obdh_Telemetry[0..*] : MissionPackage::OnBoardStatus;

        in  Hk_Records      [0..*] : MissionPackage::OnBoardStatus;
        in  Science_Records [0..*] : MissionPackage::OnBoardStatus;
        in  Event_Records   [0..*] : MissionPackage::OnBoardStatus;

        out Stored_Ok       [0..*] : MissionPackage::OnBoardStatus;

        flow from Hk_Records to Stored_Ok;
        flow from Science_Records to Stored_Ok;
        flow from Event_Records to Stored_Ok;
        flow from Stored_Ok to Obdh_Telemetry;
    }

    action def SelectAndPrioritizeDownlinkData {
        in  Obdh_Command  [0..*] : MissionPackage::OnBoardCommand;
        out Obdh_Telemetry[0..*] : MissionPackage::OnBoardStatus;

        in  Stored_Data_Index [0..*] : MissionPackage::OnBoardStatus;
        in  Link_Window_Info  [0..*] : MissionPackage::OnBoardStatus;

        out Downlink_Queue   [0..*] : MissionPackage::OnBoardStatus;

        flow from Stored_Data_Index to Downlink_Queue;
        flow from Downlink_Queue to Obdh_Telemetry;
    }

    action def ForwardDownlinkFramesToComms {
        in  Obdh_Command  [0..*] : MissionPackage::OnBoardCommand;
        out Obdh_Telemetry[0..*] : MissionPackage::OnBoardStatus;

        in  Downlink_Queue [0..*] : MissionPackage::OnBoardStatus;
        out Comm_Frames    [0..*] : MissionPackage::OnBoardStatus;

        flow from Downlink_Queue to Comm_Frames;
        flow from Comm_Frames to Obdh_Telemetry;
    }

    action def DecodeValidateAndDispatchCommands {
        in  Obdh_Command  [0..*] : MissionPackage::OnBoardCommand;
        out Obdh_Telemetry[0..*] : MissionPackage::OnBoardStatus;

        out Eps_Cmd   [0..*] : MissionPackage::OnBoardCommand;
        out Aocs_Cmd  [0..*] : MissionPackage::OnBoardCommand;
        out Tcs_Cmd   [0..*] : MissionPackage::OnBoardCommand;
        out Daq_Cmd   [0..*] : MissionPackage::OnBoardCommand;

        out Cmd_Accepted [0..*] : MissionPackage::OnBoardStatus;
        out Cmd_Rejected [0..*] : MissionPackage::OnBoardStatus;

        flow from Cmd_Accepted to Obdh_Telemetry;
        flow from Cmd_Rejected to Obdh_Telemetry;
    }

    action def ExecuteTimeTaggedCommands {
        in  Obdh_Command  [0..*] : MissionPackage::OnBoardCommand;
        out Obdh_Telemetry[0..*] : MissionPackage::OnBoardStatus;

        in  Scheduled_Cmds [0..*] : MissionPackage::OnBoardCommand;
        out Executed      [0..*] : MissionPackage::OnBoardStatus;

        flow from Executed to Obdh_Telemetry;
    }

    action def PerformOBDHHealthMonitoringAndFDIR {
        in  Obdh_Command  [0..*] : MissionPackage::OnBoardCommand;
        out Obdh_Telemetry[0..*] : MissionPackage::OnBoardStatus;

        in  Hk_Inputs      [0..*] : MissionPackage::OnBoardStatus;
        out Fdir_Events    [0..*] : MissionPackage::OnBoardStatus;
        out Safe_Mode_Req  [0..*] : MissionPackage::OnBoardCommand;

        flow from Hk_Inputs to Fdir_Events;
        flow from Fdir_Events to Obdh_Telemetry;
    }

    action def ManageSpacecraftModesAndAutonomy {
        in  Obdh_Command  [0..*] : MissionPackage::OnBoardCommand;
        out Obdh_Telemetry[0..*] : MissionPackage::OnBoardStatus;

        in  Power_State    [0..*] : MissionPackage::OnBoardStatus;
        in  Thermal_State  [0..*] : MissionPackage::OnBoardStatus;
        in  Fdir_Events    [0..*] : MissionPackage::OnBoardStatus;

        out Mode_Change    [0..*] : MissionPackage::OnBoardCommand;

        flow from Mode_Change to Obdh_Telemetry;
    }

    action def ManageWarmRedundantAuthorityAndTakeover {
        in  Obdh_Command  [0..*] : MissionPackage::OnBoardCommand;
        out Obdh_Telemetry[0..*] : MissionPackage::OnBoardStatus;

        in  Primary_Heartbeat [0..*] : MissionPackage::OnBoardStatus;
        in  Sync_Updates      [0..*] : MissionPackage::OnBoardStatus;

        out Takeover_Declared [0..*] : MissionPackage::OnBoardStatus;
        out Enter_Safe_Mode   [0..*] : MissionPackage::OnBoardCommand;

        flow from Takeover_Declared to Obdh_Telemetry;
    }

    action def SynchronizeRedundantOBCState {
        in  Obdh_Command  [0..*] : MissionPackage::OnBoardCommand;
        out Obdh_Telemetry[0..*] : MissionPackage::OnBoardStatus;

        in  Current_State [0..*] : MissionPackage::OnBoardStatus;
        out Sync_Packet   [0..*] : MissionPackage::OnBoardStatus;

        flow from Current_State to Sync_Packet;
        flow from Sync_Packet to Obdh_Telemetry;
    }

    action def PerformDualBankSoftwareUpdateAndRollback {
        in  Obdh_Command  [0..*] : MissionPackage::OnBoardCommand;
        out Obdh_Telemetry[0..*] : MissionPackage::OnBoardStatus;

        in  Image_Packets [0..*] : MissionPackage::OnBoardStatus;

        out Image_Verified [0..*] : MissionPackage::OnBoardStatus;
        out Bank_Switched  [0..*] : MissionPackage::OnBoardStatus;
        out Rollback_Done  [0..*] : MissionPackage::OnBoardStatus;

        flow from Image_Verified to Obdh_Telemetry;
        flow from Bank_Switched to Obdh_Telemetry;
        flow from Rollback_Done to Obdh_Telemetry;
    }

    //------------------------------------------------------------------------------------------------Thermal actions

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

    action def ReadTemperature {
        out Temp : ISQ::TemperatureValue;
    }
}
    //------------------------------------------------------------------------------------------------
    // ACTION DEFINITIONS aocs
        //------------------------------------------------------------------------------------------------
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
        in Threshold : ISQ::AngularMeasureValue; //0 to pi
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





