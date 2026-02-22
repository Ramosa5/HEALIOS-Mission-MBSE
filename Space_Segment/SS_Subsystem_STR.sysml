package StructureSystemPackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import SI::*;
    private import LaunchEnvironment::*;
    private import MissionPackage::*;
  
    item def Separation {
        attribute separationTime : SI::TimeValue;
    }

    state def SwitchBehavior {

        attribute switch_Status : String;
        entry; then stowed;
        
        state stowed {
            entry assign switch_Status := "Stowed";
        }

        transition
            first stowed
            accept Separation
            then deployed;

        state deployed {
            entry assign switch_Status := "Deployed";
        }
    }

    port def StructuralMountInterface;   

    part def MountingElement {
        attribute type : String;
        attribute material : String;
        attribute quantity : Integer;
    }

    part def Chassis {
        attribute material : String;
        attribute dimensions : String;

        port mounting_Points : StructuralMountInterface [0..*];
        port structural_Port : StructuralMountInterface [0..*];
        port rail_Port : ~DispenserContactInterface [0..*];
    }

    part def PCBStack {
        attribute material : String;
        attribute dimensions : String;

        port mounting_Points : StructuralMountInterface [0..*];
        port structural_Port : StructuralMountInterface [0..*];
    }

    part def DeploymentMechanism {
        attribute name : String;
        attribute power_Consumption : ISQ::PowerValue;
        attribute status : String;

        port mounting_Port : StructuralMountInterface [0..*];
        port plunger_Port : DispenserContactInterface [0..*];

        exhibit state switch_State : SwitchBehavior {
            bind switch_Status = DeploymentMechanism::status;
        }
    }

    part def StructureSystem :> SS {
        
        attribute total_Mass : ISQ::MassValue;
        attribute material : String;

        part primary_Structure : Chassis {
            part internal_Mounting : MountingElement;
        }

        part secondary_Structure : PCBStack {
            part internal_Mounting : MountingElement;
        }

        part deployment_Switches : DeploymentMechanism [2];

        connect secondary_Structure.structural_Port to primary_Structure.structural_Port;

        connect deployment_Switches.mounting_Port to primary_Structure.mounting_Points;

        // External connection to launcher dispenser
        // connect Primary_Structure.Rail_Port to Dispenser_Port;
        // connect Deployment_Switches.Plunger_Port to Dispenser_Port;
    }
}