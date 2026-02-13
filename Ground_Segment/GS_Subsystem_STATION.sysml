package GroundStationPackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import GroundActionsPackage::*;

    item def PassPlan { attribute type : String; }
    item def TrackingData { attribute type : String; }
    item def ArchiveRecord { attribute type : String; }

    port def TcPort { in item TcIn : MissionPackage::GroundCommand; }
    port def TmPort { out item TmOut : MissionPackage::TelemetryData; }
    port def PassPlanPort { in item PlanIn : PassPlan; }
    port def TrackingPort { out item TrackingOut : TrackingData; }
    port def ArchivePort { out item RecordOut : ArchiveRecord; }

    part def Antenna {
            attribute name : String;
            attribute band : String;
            attribute gain : Real;

            port Uplink_In  : MissionPackage::GroundCommand;
            port Downlink_Out : MissionPackage::TelemetryData;
        }

    part def CryptoUnit {
        attribute name : String;
        attribute downlinkVerifyEnabled : Boolean;
        attribute downlinkDecryptEnabled : Boolean;
        attribute uplinkAuthEnabled : Boolean;
        attribute uplinkEncryptEnabled : Boolean;

        port TC_In  : MissionPackage::GroundCommand;
        port TC_Out : MissionPackage::GroundCommand;

        port TM_In  : MissionPackage::TelemetryData;
        port TM_Out : MissionPackage::TelemetryData;
    }

    part def PassPredictor {
        attribute name : String;
        attribute usesTLE : Boolean;

        port PassPlan_Out : PassPlan;
        port Tracking_Out : TrackingData;
    }

    part def GroundStation {
        port Mission_Control_Centre_TC_Port : ~TcPort;
        port Mission_Control_Centre_TM_Port : ~TmPort;
        port Data_Centre_TM_Port : ~TmPort;
        port Mission_Control_Centre_Pass_Plan_Port : ~PassPlanPort;
        port Mission_Control_Centre_Tracking_Port : ~TrackingPort;
        port Data_Centre_Archive_Port : ~ArchivePort;

        part Antenna_Part : Antenna;
        part Pass_Predictor_Part : PassPredictor;
        part Crypto_Unit_Part : CryptoUnit;

        perform action Uplink_Action : ExecuteUplink;
        perform action Downlink_Action : ReceiveDownlink;
        perform action Tracking_Action : ComputeTracking;
        perform action Archive_Action : StreamToArchive;
        perform action Verify_Decrypt_Action : VerifyAndDecryptDownlink;
        perform action Auth_Encrypt_Action : AuthenticateAndEncryptUplink;

        bind Auth_Encrypt_Action.Telecommand_To_Encrypt = Mission_Control_Centre_TC_Port.TcIn;
        bind Uplink_Action.Modulated_Uplink_Signal = Auth_Encrypt_Action.Secured_Encrypted_Telecommand;

        bind Verify_Decrypt_Action.Telemetry_To_Decrypt = Downlink_Action.Captured_Encrypted_Telemetry;
        bind Mission_Control_Centre_TM_Port.TmOut = Verify_Decrypt_Action.Telemetry_To_Decrypt;
        bind Data_Centre_TM_Port.TmOut = Verify_Decrypt_Action.Verified_Ground_Telemetry_Data;

        bind Tracking_Action.Satellite_plan = Mission_Control_Centre_Pass_Plan_Port.PlanIn;
        bind Mission_Control_Centre_Tracking_Port.TrackingOut = Tracking_Action.Tracking_Data;

        bind Archive_Action.Telemetry_To_Archive = Verify_Decrypt_Action.Verified_Ground_Telemetry_Data;
        bind Data_Centre_Archive_Port.RecordOut = Archive_Action.Record_of_Telemetry;
    }
}
