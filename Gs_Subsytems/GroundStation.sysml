package GroundStationPackage {
    private import MissionPackage::*;
    private import ISQ::*;

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

    action def ExecuteUplink {
        in item uplinkTc : MissionPackage::GroundCommand;
    }

    action def ReceiveDownlink {
        out item downlinkTm : MissionPackage::TelemetryData;
    }

    action def ComputeTracking {
        in item plan : PassPlan;
        out item tracking : TrackingData;
    }

    action def StreamToArchive {
        in item tmIn : MissionPackage::TelemetryData;
        out item record : ArchiveRecord;
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

        perform action uplink : ExecuteUplink;
        perform action downlink : ReceiveDownlink;
        perform action tracking : ComputeTracking;
        perform action archive : StreamToArchive;

        bind uplink.uplinkTc = tcFromMCC.tcIn;
        bind tmToMCC.tmOut = downlink.downlinkTm;
        bind tmToDataCentre.tmOut = downlink.downlinkTm;
        bind tracking.plan = passPlanFromMCC.planIn;
        bind trackingToMCC.trackingOut = tracking.tracking;
        bind archive.tmIn = downlink.downlinkTm;
        bind archiveOut.recordOut = archive.record;
    }
}
