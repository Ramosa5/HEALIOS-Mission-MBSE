package MissionControlCentrePackage {
    private import HEALIOS::*;
    private import ISQ::*;
    private import GroundStationPackage::*;


    item def OperatorRequest { attribute type : String; }
    item def AuthToken { attribute type : String; }

    port def tcPort { out item tcOut : HEALIOS::GroundCommand; }
    port def tmPort { in item tmIn : HEALIOS::TelemetryData; }

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

    action def AuthorizeCommanding {
        in item request : OperatorRequest;
        out item token : AuthToken;
    }

    action def GenerateTelecommand {
        in item token : AuthToken;
        out item tc : HEALIOS::GroundCommand;
    }

    action def GeneratePassPlan {
        out item plan : PassPlan;
    }

    action def MonitorTelemetryRealtime {
        in item tm : HEALIOS::TelemetryData;
    }

    part def MissionControlCentre {

        // Interfaces to Ground Station
        port tcToGS : tcPort;
        port tmFromGS : tmPort;
        port passPlanToGS : passPlanPort;
        port trackingFromGS : trackingPort;

        // Internal parts
        part auth : AuthenticationService;
        part console : OperationsConsole;
        part planner : PassPlanner;

        // Actions
        perform action authorize : AuthorizeCommanding;
        perform action genTC : GenerateTelecommand;
        perform action planPasses : GeneratePassPlan;
        perform action monitor : MonitorTelemetryRealtime;

        // Simple bindings (minimal)
        bind genTC.tc = tcToGS.tcOut;
        bind planPasses.plan = passPlanToGS.planOut;
        bind monitor.tm = tmFromGS.tmIn;
    }
}