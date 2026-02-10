package GroundStationPackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import GroundActionsPackage::*;

    item def PassPlan { attribute type : String; }
    item def TrackingData { attribute type : String; }
    item def ArchiveRecord { attribute type : String; }

    port def tcPort { in item tcIn : MissionPackage::GroundCommand; }
    port def tmPort { out item tmOut : MissionPackage::TelemetryData; }
    port def passPlanPort { in item planIn : PassPlan; }
    port def trackingPort { out item trackingOut : TrackingData; }
    port def archivePort { out item recordOut : ArchiveRecord; }

    part def Antenna {
        attribute name : String;
        attribute band : String;
        attribute gain : Real;
    }

    part def RadioUnit {
        attribute name : String;
        attribute supportedBands : String;
    }

    part def PassPredictor {
        attribute name : String;
        attribute usesTLE : Boolean = true;
    }

    part def DopplerCompensator {
        attribute name : String;
    }

    part def LinkBudgetTool {
        attribute name : String;
    }

    part def CryptoUnit {
        attribute name : String;

        // Downlink: verify integrity / optional decrypt
        attribute downlinkVerifyEnabled : Boolean = true;
        attribute downlinkDecryptEnabled : Boolean = true;

        // Uplink: authenticate / optional encrypt
        attribute uplinkAuthEnabled : Boolean = true;
        attribute uplinkEncryptEnabled : Boolean = true;
    }


    part def GroundStation {
        port tcFromMCC : tcPort;
        port tmToMCC : tmPort;
        port tmToDataCentre : tmPort;
        port passPlanFromMCC : passPlanPort;
        port trackingToMCC : trackingPort;
        port archiveOut : archivePort;
        part antenna : Antenna;
        part radio : RadioUnit;
        part predictor : PassPredictor;
        part doppler : DopplerCompensator;
        part linkBudget : LinkBudgetTool;
        part crypto : CryptoUnit;

        perform action uplink : ExecuteUplink;
        perform action downlink : ReceiveDownlink;
        perform action tracking : ComputeTracking;
        perform action archive : StreamToArchive;
        perform action verifyDecrypt : VerifyAndDecryptDownlink;
        perform action authEncrypt : AuthenticateAndEncryptUplink;

        bind authEncrypt.tcIn = tcFromMCC.tcIn;
        bind uplink.uplinkTc = authEncrypt.tcOut;
        bind verifyDecrypt.tmIn = downlink.downlinkTm;
        bind tmToMCC.tmOut = verifyDecrypt.tmOut;
        bind tmToDataCentre.tmOut = verifyDecrypt.tmOut;
        bind tracking.plan = passPlanFromMCC.planIn;
        bind trackingToMCC.trackingOut = tracking.tracking;
        bind archive.tmIn = verifyDecrypt.tmOut;
        bind archiveOut.recordOut = archive.record;
    }
}
