package DataCentrePackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import GroundStationPackage::*;
    private import GroundActionsPackage::*;

    port def tmPort { in item tmIn : MissionPackage::TelemetryData; }
    port def archivePort { in item recordIn : ArchiveRecord; }
    port def tmProductPort { out item tmOut : MissionPackage::TelemetryData; }

    part def StructuredArchive {
        attribute name : String;
        attribute retention : ISQ::DurationValue; 
    }

    part def DataValidator {
        attribute name : String;
    }

    part def DataCentre {
        port tmFromGS : tmPort;
        port recordsFromGS : archivePort;
        port tmProductsToMCC : tmProductPort;

        part archive : StructuredArchive;
        part validator : DataValidator;

        perform action validate : ValidateTelemetry;
        perform action store : StoreRecord;

        bind validate.tm = tmFromGS.tmIn;
        bind store.record = recordsFromGS.recordIn;
        bind tmProductsToMCC.tmOut = tmFromGS.tmIn;
    }
}