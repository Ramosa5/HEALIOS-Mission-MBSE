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

        in port Record_In : ArchivePort;
    }

    part def DataValidator {
        attribute name : String;

        in port TM_In : TmPort;
        out port TM_Validated_Out : TmProductPort;
    }

    part def DataCentre {
        port ground_Station_TM_Port : TmPort;
        port ground_Station_Records_Port : ArchivePort;
        port mission_Control_Centre_TM_Products_Port : TmProductPort;

        part Structured_Archive_Part : StructuredArchive;
        part Data_Validator_Part : DataValidator;

        perform action Validate_Action : ValidateTelemetry;
        perform action Store_Action : StoreRecord;

        bind Validate_Action.Telemetry_For_Validate = ground_Station_TM_Port.TmIn;
        bind Store_Action.Record_of_Satellite_Data = ground_Station_Records_Port.RecordIn;
        bind mission_Control_Centre_TM_Products_Port.TmOut = ground_Station_TM_Port.TmIn;
    }
}
