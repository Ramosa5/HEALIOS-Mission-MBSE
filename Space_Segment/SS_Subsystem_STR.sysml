package StructureSystemPackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import SI::*;
    private import LaunchEnvironment::*;
    
  
    item def Separation;

    state def SwitchBehavior {

        attribute Switch_Status : String;
        entry; then Stowed;
        
        state Stowed {
            entry assign Switch_Status := "Stowed";
        }

        transition
            first Stowed
            accept Separation
            then Deployed;

        state Deployed {
            entry assign Switch_Status := "Deployed";
        }
    }

    port def StructuralMountInterface;   

    part def MountingElement {
        attribute Type : String;
        attribute Material : String;
        attribute Quantity : Integer;
    }

    part def Chassis {
        attribute Material : String;
        attribute Dimensions : String;

        port Mounting_Points : StructuralMountInterface [0..*];
        port Structural_Port : StructuralMountInterface [0..*];
        port Rail_Port : ~DispenserContactInterface [0..*];
    }

    part def PCBStack {
        attribute Material : String;
        attribute Dimensions : String;

        port Mounting_Points : StructuralMountInterface [0..*];
        port Structural_Port : StructuralMountInterface [0..*];
    }

    part def DeploymentMechanism {
        attribute Name : String;
        attribute Power_Consumption : ISQ::PowerValue;
        attribute Status : String;

        port Mounting_Port : StructuralMountInterface [0..*];
        port Plunger_Port : DispenserContactInterface [0..*];

        exhibit state Switch_State : SwitchBehavior {
            bind Switch_Status = DeploymentMechanism::Status;
        }
    }

    part def StructureSystem {
        
        attribute Total_Mass : ISQ::MassValue;
        attribute Material : String;

        part Primary_Structure : Chassis {
            part Internal_Mounting : MountingElement;
        }

        part Secondary_Structure : PCBStack {
            part Internal_Mounting : MountingElement;
        }

        part Deployment_Switches : DeploymentMechanism [2];

        connect Secondary_Structure.Structural_Port to Primary_Structure.Structural_Port;

        connect Deployment_Switches.Mounting_Port to Primary_Structure.Mounting_Points;

        // External connection to launcher dispenser
        // connect Primary_Structure.Rail_Port to Dispenser_Port;
        // connect Deployment_Switches.Plunger_Port to Dispenser_Port;
    }
}