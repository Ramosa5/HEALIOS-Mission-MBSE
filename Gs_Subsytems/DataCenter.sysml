package DataCentrePackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import GroundStationPackage::*;


    port def tmPort { in item tmIn : MissionPackage::TelemetryData; }
    port def archivePort { in item recordIn : ArchiveRecord; }

    // Optional output port for validated/curated data products
    port def tmProductPort { out item tmOut : MissionPackage::TelemetryData; }

    part def StructuredArchive {
        attribute name : String;
        attribute retention : ISQ::DurationValue = 730 [SI::day]; // 2 years baseline
    }

    part def DataValidator {
        attribute name : String;
    }

    action def ValidateTelemetry {
        in item tm : MissionPackage::TelemetryData;
    }

    action def StoreRecord {
        in item record : ArchiveRecord;
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

        // Minimal: forward "products" as the same TM (can be replaced later by processed products)
        bind tmProductsToMCC.tmOut = tmFromGS.tmIn;
    }
}