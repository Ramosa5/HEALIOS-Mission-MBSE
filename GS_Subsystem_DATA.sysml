package DataCentrePackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import GroundStationPackage::*;
    private import GroundActionsPackage::*;

    port def TmPort { in item TmIn : MissionPackage::TelemetryData; }
    port def ArchivePort { in item RecordIn : ArchiveRecord; }
    port def TmProductPort { out item TmOut : MissionPackage::TelemetryData; }

    part def StructuredArchive {
        attribute name : String;
        attribute retention : ISQ::DurationValue;
    }

    part def DataValidator {
        attribute name : String;
    }

    part def DataCentre {
        port Ground_Station_TM_Port : TmPort;
        port Ground_Station_Records_Port : ArchivePort;
        port Mission_Control_Centre_TM_Products_Port : TmProductPort;

        part Structured_Archive_Part : StructuredArchive;
        part Data_Validator_Part : DataValidator;

        perform action Validate_Action : ValidateTelemetry;
        perform action Store_Action : StoreRecord;

        bind Validate_Action.Telemetry_For_Validate = Ground_Station_TM_Port.TmIn;
        bind Store_Action.Record_of_Satellite_Data = Ground_Station_Records_Port.RecordIn;
        bind Mission_Control_Centre_TM_Products_Port.TmOut = Ground_Station_TM_Port.TmIn;
    }
}
