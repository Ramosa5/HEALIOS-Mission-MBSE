package MissionControlCentrePackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import GroundStationPackage::*;
    private import GroundActionsPackage::*;

    item def OperatorRequest { attribute type : String; }
    item def AuthToken { attribute type : String; }

    port def TcPort { out item TcOut : MissionPackage::GroundCommand; }
    port def TmPort { in item TmIn : MissionPackage::TelemetryData; }

    port def PassPlanPort { out item PlanOut : PassPlan; }
    port def TrackingPort { in item TrackingIn : TrackingData; }

    part def AuthenticationService {
        attribute name : String;
        attribute method : String;

        in port Auth_Request_In : AuthToken;
        port Auth_Token_Out : AuthToken;
    }

    part def OperationsConsole {
        attribute name : String;

        port Operator_Request_Out : OperatorRequest;
        in port Auth_Token_In : AuthToken;

        port TC_Out : TcPort;
        in port TM_In : TmPort;
    }

    part def PassPlanner {
        attribute name : String;
        attribute usesTLE : Boolean;

        out port PassPlan_Out : PassPlanPort;
        in port Tracking_Satellite : TrackingPort;
    }

    part def MissionControlCentre {
        port ground_Station_TC_Port : TcPort;
        port ground_Station_TM_Port : TmPort;
        port ground_Station_Pass_Plan_Port : PassPlanPort;
        port ground_Station_Tracking_Port : TrackingPort;

        part Auth_Service_Part : AuthenticationService;
        part Operations_Console_Part : OperationsConsole;
        part Pass_Planner_Part : PassPlanner;

        perform action Authorize_Action : AuthorizeCommanding;
        perform action Generate_TC_Action : GenerateTelecommand;
        perform action Plan_Passes_Action : GeneratePassPlan;
        perform action Monitor_TM_Action : MonitorTelemetryRealtime;

        bind Generate_TC_Action.Raw_Unsecured_Telecommand = ground_Station_TC_Port.TcOut;
        bind Plan_Passes_Action.Plan_of_Satellite_Path = ground_Station_Pass_Plan_Port.PlanOut;
        bind Monitor_TM_Action.Telemetry_For_Monitoring = ground_Station_TM_Port.TmIn;
    }
}
