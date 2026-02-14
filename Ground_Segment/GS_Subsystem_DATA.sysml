package DataCentrePackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import GroundStationPackage::*;
    private import GroundActionsPackage::*;

    port def TmPort { in item telemetry_In : MissionPackage::TelemetryData; }
    port def ArchivePort { in item record_In : ArchiveRecord; }
    port def TmProductPort { out item telemetry_Out : MissionPackage::TelemetryData; }

    part def StructuredArchive {
        attribute name : String;
        attribute retention : ISQ::DurationValue;

        in port record_In : ArchivePort;
    }

    part def DataValidator {
        attribute name : String;

        in port telemetry_In : TmPort;
        out port telemetry_Validated_Out : TmProductPort;
    }

    part def DataCentre {
        port ground_Station_TM_Port : TmPort;
        port ground_Station_Records_Port : ArchivePort;
        port mission_Control_Centre_TM_Products_Port : TmProductPort;

        part structured_Archive_Part : StructuredArchive;
        part data_Validator_Part : DataValidator;

        perform action validate_Action : ValidateTelemetry;
        perform action store_Action : StoreRecord;

        bind validate_Action.Telemetry_For_Validate = ground_Station_TM_Port.telemetry_In;
        bind store_Action.Record_of_Satellite_Data = ground_Station_Records_Port.record_In;
        bind mission_Control_Centre_TM_Products_Port.telemetry_Out = ground_Station_TM_Port.telemetry_In;
    }
}
