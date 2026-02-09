package StructureSystemPackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import SI::*;

    // --- Component Definitions ---

    port def MechanicalInterface;

    part def MountingElement {
        attribute type : String; // e.g., "Bolt", "Rivet", "Weld", "Separator", "Adhesive", "Adapter"
        attribute material : String;
        attribute quantity : Integer;
    }

    part def Chassis {
        attribute material : String;
        attribute dimensions : String;

        // Mechanical interface for mounting components (e.g., PCBs, payload, solar arrays)
        port mountingPoints : MechanicalInterface;
        
        // Mechanical interface for connecting to other structural elements (e.g., stack rods)
        port structuralInterface : MechanicalInterface;
    }

    part def Mechanism {
        attribute name : String;
        attribute powerConsumption : ISQ::PowerValue;
        attribute status : String; // e.g., "Stowed", "Deployed"

        port mountingInterface : MechanicalInterface;
    }

    part def CubeSatDispenser {
        attribute name : String;
        attribute status : String; // e.g., "Stowed", "Deployed"

        port mountingInterface : MechanicalInterface;
    }

    // --- The Main System Definition ---

    part def StructureSystem {
        
        // A. Physical Attributes of the Structure Subsystem itself
        attribute totalMass : ISQ::MassValue;
        attribute material : String;

        // B. Mechanical Parts

        // The main frame of the satellite (Primary Structure)
        part primaryStructure : Chassis {
            //:>> material = "Aluminum Alloy";
            //:>> dimensions = "1U form factor";

            part internal_mounting : MountingElement {
                //:>> type = "General";
            }
        }

        // PCB-Stack Definition (Secondary Structure)
        part secondaryStructure : Chassis {
           // :>> material = "Aluminum Alloy";
           // :>> dimensions = "PC-104 form factor";

            part internal_mounting : MountingElement {
               // :>> type = "General";
            }
        }

        // Separation springs / Switches for the POD interface
        part deploymentSwitches : Mechanism [2] {
            //:>> name = "POD Separation Switch";
            //:>> powerConsumption = 0 [SI::W];
            //:>> status = "Stowed";
        }

        // C. Internal Connections (The Assembly Logic)

        // Connect the Secondary Structure (Stack) to the Primary Structure (Frame)
        connect secondaryStructure.structuralInterface to primaryStructure.structuralInterface;

        // Connect the Deployment Switches to the Primary Structure
        connect deploymentSwitches.mountingInterface to primaryStructure.mountingPoints;

        // D. External Interfaces
        
        // Mechanical interface to the Launch Adapter (POD) - Connected to the Frame
        port PPOD : CubeSatDispenser {
            //:>> name = "PPOD Interface";
            //:>> status = "Stowed";
        }
        connect PPOD.mountingInterface to primaryStructure.structuralInterface;
        connect PPOD.mountingInterface to deploymentSwitches.mountingInterface;
    }
}