package GroundStationPackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import GroundActionsPackage::*;

    item def PassPlan { attribute type : String; }
    item def TrackingData { attribute type : String; }
    item def ArchiveRecord { attribute type : String; }

    port def TcPort { in item telecommandIn : MissionPackage::GroundCommand; }
    port def TmPort { out item telemetryOut : MissionPackage::TelemetryData; }
    port def PassPlanPort { in item planIn : PassPlan; }
    port def TrackingPort { out item trackingOut : TrackingData; }
    port def ArchivePort { out item recordOut : ArchiveRecord; }

    part def Antenna {
            attribute name : String;
            attribute band : String;
            attribute gain : Real;

            port uplink_In  : MissionPackage::GroundCommand;
            port downlink_Out : MissionPackage::TelemetryData;
        }

    part def CryptoUnit {
        attribute name : String;
        attribute downlinkVerifyEnabled : Boolean;
        attribute downlinkDecryptEnabled : Boolean;
        attribute uplinkAuthEnabled : Boolean;
        attribute uplinkEncryptEnabled : Boolean;

        port telecommand_In  : MissionPackage::GroundCommand;
        port telecommand_Out : MissionPackage::GroundCommand;

        port telemetry_In  : MissionPackage::TelemetryData;
        port telemetry_Out : MissionPackage::TelemetryData;
    }

    part def PassPredictor {
        attribute name : String;
        attribute usesTLE : Boolean;

        port pass_Plan_Out : PassPlan;
        port tracking_Out : TrackingData;
    }

    part def GroundStation {
        port mission_Control_Centre_TC_Port : ~TcPort;
        port mission_Control_Centre_TM_Port : ~TmPort;
        port data_Centre_TM_Port : ~TmPort;
        port mission_Control_Centre_Pass_Plan_Port : ~PassPlanPort;
        port mission_Control_Centre_Tracking_Port : ~TrackingPort;
        port data_Centre_Archive_Port : ~ArchivePort;

        part antenna_Part : Antenna;
        part pass_Predictor_Part : PassPredictor;
        part crypto_Unit_Part : CryptoUnit;

        perform action uplink_Action : ExecuteUplink;
        perform action downlink_Action : ReceiveDownlink;
        perform action tracking_Action : ComputeTracking;
        perform action archive_Action : StreamToArchive;
        perform action verify_Decrypt_Action : VerifyAndDecryptDownlink;
        perform action auth_Encrypt_Action : AuthenticateAndEncryptUplink;

        bind auth_Encrypt_Action.Telecommand_To_Encrypt = mission_Control_Centre_TC_Port.telecommandIn;
        bind uplink_Action.Modulated_Uplink_Signal = auth_Encrypt_Action.Secured_Encrypted_Telecommand;

        bind verify_Decrypt_Action.Telemetry_To_Decrypt = downlink_Action.Captured_Encrypted_Telemetry;
        bind mission_Control_Centre_TM_Port.telemetryOut = verify_Decrypt_Action.Telemetry_To_Decrypt;
        bind data_Centre_TM_Port.telemetryOut = verify_Decrypt_Action.Verified_Ground_Telemetry_Data;

        bind tracking_Action.Satellite_plan = mission_Control_Centre_Pass_Plan_Port.planIn;
        bind mission_Control_Centre_Tracking_Port.trackingOut = tracking_Action.Tracking_Data;

        bind archive_Action.Telemetry_To_Archive = verify_Decrypt_Action.Verified_Ground_Telemetry_Data;
        bind data_Centre_Archive_Port.recordOut = archive_Action.Record_of_Telemetry;
    }
}
