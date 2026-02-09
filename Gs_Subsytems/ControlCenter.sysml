package MissionControlCentrePackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import GroundStationPackage::*;
    private import GroundActionsPackage::*;

    item def OperatorRequest { attribute type : String; }
    item def AuthToken { attribute type : String; }

    port def tcPort { out item tcOut : MissionPackage::GroundCommand; }
    port def tmPort { in item tmIn : MissionPackage::TelemetryData; }

    port def passPlanPort { out item planOut : PassPlan; }
    port def trackingPort { in item trackingIn : TrackingData; }

    part def AuthenticationService {
        attribute name : String;
        attribute method : String; // e.g. "MFA", "SSH keys", "Role-based"
    }

    part def OperationsConsole {
        attribute name : String;
    }

    part def PassPlanner {
        attribute name : String;
        attribute usesTLE : Boolean = true;
    }

    part def MissionControlCentre {
        port tcToGS : tcPort;
        port tmFromGS : tmPort;
        port passPlanToGS : passPlanPort;
        port trackingFromGS : trackingPort;

        part auth : AuthenticationService;
        part console : OperationsConsole;
        part planner : PassPlanner;

        perform action authorize : AuthorizeCommanding;
        perform action genTC : GenerateTelecommand;
        perform action planPasses : GeneratePassPlan;
        perform action monitor : MonitorTelemetryRealtime;

        bind genTC.tc = tcToGS.tcOut;
        bind planPasses.plan = passPlanToGS.planOut;
        bind monitor.tm = tmFromGS.tmIn;
    }
}