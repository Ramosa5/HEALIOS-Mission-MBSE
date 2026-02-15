package MissionControlCentrePackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import GroundStationPackage::*;
    private import GroundActionsPackage::*;

    item def OperatorRequest { attribute type : String; }
    item def AuthToken { attribute type : String; }

    port def TcPort { out item telecommand_Out : MissionPackage::GroundCommand; }
    port def TmPort { in item telemetry_In : MissionPackage::TelemetryData; }

    port def PassPlanPort { out item plan_Out : PassPlan; }
    port def TrackingPort { in item tracking_In : TrackingData; }

    part def AuthenticationService {
        attribute name : String;
        attribute method : String;

        in port auth_Request_In : AuthToken;
        port auth_Token_Out : AuthToken;
    }

    part def OperationsConsole {
        attribute name : String;

        port operator_Request_Out : OperatorRequest;
        in port auth_Token_In : AuthToken;

        port telecommand_Out : TcPort;
        in port telemetry_In : TmPort;
    }

    part def PassPlanner {
        attribute name : String;
        attribute usesTLE : Boolean;

        out port pass_Plan_Out : PassPlanPort;
        in port tracking_Satellite : TrackingPort;
    }

    part def MissionControlCentre {
        port ground_Station_TC_Port : TcPort;
        port ground_Station_TM_Port : TmPort;
        port ground_Station_Pass_Plan_Port : PassPlanPort;
        port ground_Station_Tracking_Port : TrackingPort;

        part auth_Service_Part : AuthenticationService;
        part operations_Console_Part : OperationsConsole;
        part pass_Planner_Part : PassPlanner;

        perform action authorize_Action : AuthorizeCommanding;
        perform action generate_Telecommand_Action : GenerateTelecommand;
        perform action plan_Passes_Action : GeneratePassPlan;
        perform action monitor_Telemetry_Action : MonitorTelemetryRealtime;

        bind generate_Telecommand_Action.Raw_Unsecured_Telecommand = ground_Station_TC_Port.telecommand_Out;
        bind plan_Passes_Action.Plan_of_Satellite_Path = ground_Station_Pass_Plan_Port.plan_Out;
        bind monitor_Telemetry_Action.Telemetry_For_Monitoring = ground_Station_TM_Port.telemetry_In;
    }
}
