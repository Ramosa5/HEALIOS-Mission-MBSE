package StructureSystemPackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import SI::*;
    private import LaunchEnvironment::*;
    
  
   item def Separation;

    // --- 2. Define the Behavior ---
    state def SwitchBehavior {

        attribute Switch_Status : String;
        // entry point is the standard way to start a state machine
        entry; then Stowed;
        
        state Stowed {
            entry assign Switch_Status := "Stowed";
        }

        // Transition from Stowed to Deployed accepting the Separation signal
        transition
            first Stowed
            accept Separation
            then Deployed;

        state Deployed {
            entry assign Switch_Status := "Deployed";
        }
    }



    // --- Component Definitions ---

    port def StructuralMountInterface;   

    part def MountingElement {
        attribute Type : String;
        attribute Material : String;
        attribute Quantity : Integer;
    }

    part def Chassis {
        attribute Material : String;
        attribute Dimensions : String;

        // Internal mounting
        port Mounting_Points : StructuralMountInterface [0..*];
        // Internal structural connections
        port Structural_Port : StructuralMountInterface [0..*];
        // External mounting
        port Rail_Port : ~DispenserContactInterface [0..*];
    }

    part def PCBStack {
        attribute Material : String;
        attribute Dimensions : String;

        // Internal mounting
        port Mounting_Points : StructuralMountInterface [0..*];
        // Internal structural connections
        port Structural_Port : StructuralMountInterface [0..*];
    }

    part def DeploymentMechanism {
        attribute Name : String;
        attribute Power_Consumption : ISQ::PowerValue;
        attribute Status : String;

        // Mounting interface for deployment switches
        port Mounting_Port : StructuralMountInterface [0..*];
        // Optional interface for deployment mechanism actuation
        port Plunger_Port : DispenserContactInterface [0..*];

        exhibit state Switch_State : SwitchBehavior {
            bind Switch_Status = DeploymentMechanism::Status;
        }
    }

    // --- The Main System Definition ---

    part def StructureSystem {
        
        attribute Total_Mass : ISQ::MassValue;
        attribute Material : String;

        // Primary structure
        part Primary_Structure : Chassis {
            part Internal_Mounting : MountingElement;
        }

        // Secondary structure (PCB stack)
        part Secondary_Structure : PCBStack {
            part Internal_Mounting : MountingElement;
        }

        // Deployment switches
        part Deployment_Switches : DeploymentMechanism [2];

        // Internal connections
        connect Secondary_Structure.Structural_Port to Primary_Structure.Structural_Port;

        // Switches mounted to structure
        connect Deployment_Switches.Mounting_Port to Primary_Structure.Mounting_Points;

        // External connection to launcher dispenser
        // connect Primary_Structure.Rail_Port to Dispenser_Port;
        // connect Deployment_Switches.Plunger_Port to Dispenser_Port;
    }
}