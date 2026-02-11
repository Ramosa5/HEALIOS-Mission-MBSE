package MissionPhases {
    private import StakeholdersDefinitionPackage::*;
    private import Time;
    private import MissionPackage::*;
    private import ScalarValues::*;
    private import EnvironmentPackage::*;
    private import ManagementEnvironment::*;
    private import LaunchEnvironment::*;

    occurrence def MissionLifecycle {
        doc
        /* Mission Lifecycle according to ECSS-M-ST-10C Rev.1 – Project planning and implementation (6 March 2009) */

        // Phase 0: Mission analysis/needs identification
        timeslice Phase0 {
            doc
            /* Mission Analysis and Needs Identification */

            timeslice MissionAnalysisProcess {
                doc
                /* Mission Analysis */

                action Define_Objectives_And_Constraints {
                    doc /* Define mission objectives and constraints (can be derived from primary stakeholder needs) */

                    out item Objectives_And_Constraints : String;
                }
                action Formulate_Mission_Statment {
                    doc /* Formulate mission statement */

                    in item Objectives_And_Constraints : String;
                    out item MissionStatement : String;
                }

                action Identify_Stakeholders {
                    doc /* Identify stakeholders (broader context) and their needs */
                    in item MissionStatement : String;
                    in item Objectives_And_Constraints : String;
                    out item Stakeholders : String;
                }

                action Define_Preliminary_Mission_Requirements {
                    doc /* Define preliminary mission requirements */
                    in item Objectives_And_Constraints : String;
                    in item MissionStatement : String;
                    in item Stakeholders : String;

                    out item PreliminaryMissionRequirements : String;
                }

                action Define_Altermative_Mission_Concepts {
                    doc /* Define alternative mission concepts (can be done in parallel with the above actions) */

                    in item PreliminaryMissionRequirements : String;
                    out item AlternativeMissionConcepts : String;

                    part High_Level_Risk_Assessment : Report {
                        doc /* High-level risk assessment for each concept */
                    }

                    part High_Level_Cost_Estimate : Report {
                        doc /* High-level cost estimate for each concept */
                    }

                    part Mission_Architecture : Report {
                        doc /* Mission architecture for each concept (overall design and key drivers) */
                    }

                    part Concept_of_Operations : Report {
                        doc /* Concept of operations (ConOps) for each concept */
                    }
                }

                action Evaluate_Alternative_Mission_Concepts {
                    doc /* Evaluate alternative mission concepts against complaince with defined requirement, as well as external factors (e.g., cost, time, fesibility) and select a preferred one */

                    in item AlternativeMissionConcepts : String;
                    out item PreferredMissionConcept : String;
                }

                part Early_System_Engineering_Plan : Report {
                    doc /* System engineering plan prepared for the overall mission */

                }

                part Early_Project_Management_Plan : Report {
                    doc /* Project management plan prepared for the overall mission */
                }

                part System_Concept_Report : Report {
                    doc /* System concept report:
                    
                    Assesses the different concepts from technical, programmatic and risk perspective */

                    in item MissionConceptsTradeOffAnalaysis : String;
                }

                flow Define_Objectives_And_Constraints.Objectives_And_Constraints to Formulate_Mission_Statment.Objectives_And_Constraints;
                flow Define_Objectives_And_Constraints.Objectives_And_Constraints to Define_Preliminary_Mission_Requirements.Objectives_And_Constraints;
                flow Define_Objectives_And_Constraints.Objectives_And_Constraints to Identify_Stakeholders.Objectives_And_Constraints;

                flow Formulate_Mission_Statment.MissionStatement to Define_Preliminary_Mission_Requirements.MissionStatement;
                flow Formulate_Mission_Statment.MissionStatement to Identify_Stakeholders.MissionStatement;

                flow Identify_Stakeholders.Stakeholders to Define_Preliminary_Mission_Requirements.Stakeholders;

                flow Define_Preliminary_Mission_Requirements.PreliminaryMissionRequirements to Define_Altermative_Mission_Concepts.PreliminaryMissionRequirements;

                flow Define_Altermative_Mission_Concepts.AlternativeMissionConcepts to Evaluate_Alternative_Mission_Concepts.AlternativeMissionConcepts;

                flow Evaluate_Alternative_Mission_Concepts.PreferredMissionConcept to System_Concept_Report.MissionConceptsTradeOffAnalaysis;


                connect Early_System_Engineering_Plan to System_Concept_Report;
                connect Early_Project_Management_Plan to System_Concept_Report;
            }

            first MissionAnalysisProcess then MDR;

            // The review is held at the end of phase 0
            snapshot MDR {
                doc
                /* Mission Definition Review:
                
                The primary objective of this review is to release the mission statement and assess the preliminary technical requirements specification and programmatic aspects */

                attribute BaselineApproved : Boolean;
            }
        }

        // Phase A: Feasibility
        then timeslice PhaseA {
            doc
            /* Feasibility */

            part Phase0_Baseline : PhaseBaseline {
                    doc /* Baseline established at the end of Phase 0 (MDR) */

                    attribute PhaseName redefines PhaseName = "Phase 0";

                    out item BaselineReport redefines BaselineReport;

                }

                part PhaseA_Documentation : MissionDocumentation {
                    doc /* Documentation Created through the Phase A */

                    in item Report_Item : Report [0..*];
                }

            connect Phase0_Baseline.BaselineReport to FeasibilityProcess.Phase0_Baseline_Report;
            connect FeasibilityProcess.PhaseA_Documentation_Item to PhaseA_Documentation.Report_Item;

            timeslice FeasibilityProcess {
                doc /* The main engineering and management workflow for Phase A */

                in item Phase0_Baseline_Report : Report;
                out item PhaseA_Documentation_Item : Report [0..*];


                // 1. Establish Plans
                action Establish_Preliminary_Plans {
                    doc /* Establish preliminary management, SE, and PA plans */
                    in item Last_Iteration_Artifacts : Report;

                    out item Preliminary_Management_Plan : String;
                    out item System_Engineering_Plan : String;
                    out item Product_Assurance_Plan : String;
                }

                // 2. Function Tree
                action Establish_Function_Tree {
                    doc /* Establish the function tree based on requirements */

                    in item Last_Iteration_Artifacts : Report;
                    out item Function_Tree : String;
                }

                // 3. Elaborate Concepts (Iterative loop with Phase 0 output usually implies input here)
                action Elaborate_Concepts_And_Architecture {
                    doc /* Elaborate possible system/ops concepts and architectures */
                    
                    in item Function_Tree : String;
                    out item System_Operations_Concepts : String;
                    out item System_Architectures : String;
                }

                // 4. Critical Technologies
                action Identify_Critical_Technologies {
                    doc /* Identify critical technologies and propose pre-development */
                    
                    in item System_Architectures : String;
                    out item Critical_Technologies : String;
                    out item Pre_Development_Activities : String;
                }

                // 5. Critical Elements Characterization
                action Characterize_Critical_Elements {
                    doc /* Quantify and characterize critical elements for technical/economic feasibility */
                    
                    in item Critical_Technologies : String;
                    out item Critical_Elements_Definition : String;
                }

                // 6. Feasibility Assessment
                action Assess_Feasibility {
                    doc /* Assess technical and programmatic feasibility by identifying constraints */
                    
                    in item System_Operations_Concepts : String;
                    in item System_Architectures : String;
                    out item Feasibility_Assessment_Report : String; // Includes cost, schedule, org constraints
                }

                // 7. Risk Assessment
                action Elaborate_Risk_Assessment {
                    doc /* Elaborate the risk assessment based on architectures and needs */
                    
                    in item System_Architectures : String;
                    out item Risk_Assessment : String;
                }

                // 8. Proposal for Phase B
                action Propose_System_Solution {
                    doc /* Propose system/ops concept, technical solutions, model philosophy and verification approach for Phase B */
                    
                    in item Feasibility_Assessment_Report : String;
                    in item Risk_Assessment : String;
                    in item Critical_Technologies : String;
                    
                    out item Selected_System_Concept : String;
                    out item Model_Philosophy : String;
                    out item Verification_Approach : String;
                }

                // Function Tree drives the Concepts
                flow Establish_Function_Tree.Function_Tree to Elaborate_Concepts_And_Architecture.Function_Tree;

                // Concepts and Architecture drive Tech, Elements, Feasibility, and Risk
                flow Elaborate_Concepts_And_Architecture.System_Architectures to Identify_Critical_Technologies.System_Architectures;
                flow Identify_Critical_Technologies.Critical_Technologies to Characterize_Critical_Elements.Critical_Technologies;
                flow Elaborate_Concepts_And_Architecture.System_Architectures to Assess_Feasibility.System_Architectures;
                flow Elaborate_Concepts_And_Architecture.System_Architectures to Elaborate_Risk_Assessment.System_Architectures;
                flow Elaborate_Concepts_And_Architecture.System_Operations_Concepts to Assess_Feasibility.System_Operations_Concepts;

                // Aggregating results into the Final Proposal
                flow Assess_Feasibility.Feasibility_Assessment_Report to Propose_System_Solution.Feasibility_Assessment_Report;
                flow Elaborate_Risk_Assessment.Risk_Assessment to Propose_System_Solution.Risk_Assessment;
                flow Characterize_Critical_Elements.Critical_Elements_Definition to Propose_System_Solution.Critical_Technologies;

                flow Phase0_Baseline_Report to Establish_Preliminary_Plans.Last_Iteration_Artifacts;
                flow Phase0_Baseline_Report to Establish_Function_Tree.Last_Iteration_Artifacts;

                flow Establish_Preliminary_Plans.Preliminary_Management_Plan to PhaseA_Documentation_Item;
                flow Establish_Preliminary_Plans.System_Engineering_Plan to PhaseA_Documentation_Item;
                flow Establish_Preliminary_Plans.Product_Assurance_Plan to PhaseA_Documentation_Item;

                //flow Establish_Function_Tree.Function_Tree to PhaseA_Documentation.Report_Item;
                flow Identify_Critical_Technologies.Pre_Development_Activities to PhaseA_Documentation.Report_Item;

                flow Propose_System_Solution.Selected_System_Concept to PhaseA_Documentation_Item;
                flow Propose_System_Solution.Model_Philosophy to PhaseA_Documentation_Item;   
                flow Propose_System_Solution.Verification_Approach to PhaseA_Documentation_Item;

            }

            first FeasibilityProcess then PRR;

            snapshot PRR : Report {
                doc
                /* Preliminary Requirements Review (PRR)

                PRR is held at the end of Phase A and assesses the following:

                1) Release of preliminary management, engineering and product assurance plans.
                2) Release of the technical requirements specification.
                3) Confirmation of the technical and programmatic feasibility of the system concept(s).
                4) Selection of system and operations concept(s) and technical solutions, including model philosophy and verification approach, to be carried forward into Phase B. */

                attribute BaselineApproved : Boolean;
            }
        }

        // Phase B: Preliminary Definition
        then timeslice PhaseB {
            doc
            /* Preliminary Definition */

            part PhaseA_Baseline : PhaseBaseline {
                    doc /* Baseline established at the end of Phase A (PRR) */

                    attribute PhaseName redefines PhaseName = "Phase A";

                    out item BaselineReport redefines BaselineReport;

                }

                part PhaseB_Documentation : MissionDocumentation {
                    doc /* Documentation Created through the Phase B */

                    in item Report_Item : Report [0..*];
                }

            connect PhaseA_Baseline.BaselineReport to SystemDefinitionProcess.PhaseA_Baseline_Report;
            connect SystemDefinitionProcess.PhaseB_Documentation_Item to PhaseB_Documentation.Report_Item;

            timeslice SystemDefinitionProcess {
                doc /* Work leading up to the System Requirements Review (SRR) */

                // Input from Phase A
                in item PhaseA_Baseline_Report : Report;
                out item PhaseB_Documentation_Item : Report [0..*];

                action Conduct_Trade_Offs {
                    doc /* Conduct trade-off studies and select preferred system concept */
                    in item PhaseA_Baseline_Report : Report;
                    out item Selected_System_Concept : String;
                    out item Preferred_Technical_Solutions : String;
                }

                action Prepare_System_Requirements {
                    doc /* Prepare the next level specification (System Requirements) */
                    in item Selected_System_Concept : String;
                    out item Updated_Technical_Specs : String; // Key input for SRR
                }

                action Initial_Design_Definition {
                    doc /* Establish initial preliminary design to validate requirements */
                    in item Selected_System_Concept : String;
                    out item Initial_Design_Definition : String;
                }

                flow PhaseA_Baseline_Report to Conduct_Trade_Offs.PhaseA_Baseline_Report;

                flow Conduct_Trade_Offs.Preferred_Technical_Solutions to PhaseB_Documentation_Item;
                flow Prepare_System_Requirements.Updated_Technical_Specs to PhaseB_Documentation_Item;
                flow Initial_Design_Definition.Initial_Design_Definition to PhaseB_Documentation_Item;

                // Internal Flows
                flow Conduct_Trade_Offs.Selected_System_Concept to Prepare_System_Requirements.Selected_System_Concept;
                flow Conduct_Trade_Offs.Selected_System_Concept to Initial_Design_Definition.Selected_System_Concept;
            }

            // Define the sequence: Process -> Review
            first SystemDefinitionProcess then SRR;

            snapshot SRR : Report {
                doc
                /* System Requirements Review (SRR) 
                
                SRR is held during the course of Phase B and assesses the following:

                1) Release of updated technical requirements specifications.
                2) Assessment of the preliminary design definition.
                3) Assessment of the preliminary verification program.*/

                attribute BaselineApproved : Boolean;
            }

            first SRR then PreliminaryDesignProcess;

            flow PreliminaryDesignProcess.PhaseB_Documentation_Item to PhaseB_Documentation.Report_Item;
            flow PhaseA_Baseline.BaselineReport to PreliminaryDesignProcess.Approved_Technical_Specification;

            timeslice PreliminaryDesignProcess {
                doc /* Work leading up to the Preliminary Design Review (PDR).
                       This is where the actual design based on SRR requirements happens. */

                // Inputs (Baselines from SRR)
                in item Approved_Technical_Specification : String;
                out item PhaseB_Documentation_Item : Report [0..*];

                // --- Design Actions ---
                action Elaborate_Preliminary_Design {
                    doc /* Create the detailed preliminary design definition */
                    in item Approved_Technical_Specsification : String;
                    out item Final_Preliminary_Design : String;
                }

                action Define_Interfaces {
                    doc /* Define external interfaces (ICDs) */
                    in item Final_Preliminary_Design : String;
                    out item Interface_Control_Docs : String;
                }

                action Define_Verification {
                    doc /* Define Verification Plan and Model Philosophy */
                    in item Final_Preliminary_Design : String;
                    out item Verification_Plan : String;
                }

                // --- Planning & RAMS Actions ---
                action Perform_RAMS {
                    doc /* Reliability, Availability, Maintainability, Safety Analysis */
                    in item Final_Preliminary_Design : String;
                    out item RAMS_Report : String;
                }

                action Finalize_Management_Plans {
                    doc /* Finalize SE, PA, and PM Plans */
                    in item Final_Preliminary_Design : String;
                    out item Final_Plans : String;
                }

                action Establish_WBS_And_Cost {
                    doc /* Finalize WBS, Schedule and Cost at Completion */
                    in item Final_Preliminary_Design : String;
                    out item WBS_And_Schedule : String;
                }

                
                flow Elaborate_Preliminary_Design.Final_Preliminary_Design to Define_Interfaces.Final_Preliminary_Design;
                flow Elaborate_Preliminary_Design.Final_Preliminary_Design to Define_Verification.Final_Preliminary_Design;
                flow Elaborate_Preliminary_Design.Final_Preliminary_Design to Perform_RAMS.Final_Preliminary_Design;
                flow Elaborate_Preliminary_Design.Final_Preliminary_Design to Establish_WBS_And_Cost.Final_Preliminary_Design;
                flow Elaborate_Preliminary_Design.Final_Preliminary_Design to Finalize_Management_Plans.Final_Preliminary_Design;

                flow Define_Interfaces.Interface_Control_Docs to PhaseB_Documentation_Item;
                flow Define_Verification.Verification_Plan to PhaseB_Documentation_Item;
                flow Perform_RAMS.RAMS_Report to PhaseB_Documentation_Item;
                flow Finalize_Management_Plans.Final_Plans to PhaseB_Documentation_Item;
                flow Establish_WBS_And_Cost.WBS_And_Schedule to PhaseB_Documentation_Item;

                flow Approved_Technical_Specification to Elaborate_Preliminary_Design.Approved_Technical_Specsification;
            }

            first PreliminaryDesignProcess then PDR;

            snapshot PDR : Report {
                doc
                /* Preliminary Design Review (PDR)
                
                PDR is held at the end of Phase B and assesses the following:

                1) Verification of the preliminary design of the selected concept and technical solutions against project and system requirements.
                2) Release of final management, engineering and product assurance plans.
                3) Release of product tree, work breakdown structure and specification tree.
                4) Release of the verification plan (including model philosophy).*/

                attribute BaselineApproved : Boolean;
            }
        }

        // Phase C: Detailed Definition
        then timeslice PhaseC {
            doc
            /* Detailed Definition */

            // CDR is held at the end of phase C
            snapshot CDR : Report {
                doc
                /* Critical Design Review */

                attribute BaselineApproved : Boolean;
            }
        }

        // Phase D: Qualification and Production
        then timeslice PhaseD {
            doc
            /* Qualification and Production */

            // QR held during the course of the phase
            snapshot QR : Report {
                doc
                /* Qualification Review */

                attribute BaselineApproved : Boolean;
            }

            first QR then AR;

            // AR held at the end of the phase
            snapshot AR : Report {
                doc
                /* Acceptance Review */

                attribute BaselineApproved : Boolean;
            }

            first AR then ORR;

            // ORR held at the end of the phase
            snapshot ORR : Report {
                doc
                /* Operational Readiness Review */

                attribute BaselineApproved : Boolean;
            }
        }

        // Phase E: Utilization
        then timeslice PhaseE {
            doc
            /* Utilization */

            // FRR held prior to launch
            snapshot FRR : Report {
                doc
                /* Flight Readiness Review */

                attribute BaselineApproved : Boolean;
            }

            first FRR then LRR;

            // LRR held immediately prior to launch
            snapshot LRR : Report {
                doc
                /* Launch Readiness Review */

                attribute BaselineApproved : Boolean;
            }

            first LRR then CRR;

            // CRR held after completion of on-orbit commissioning
            snapshot CRR : Report {
                doc
                /* Commissioning Result Review */

                attribute BaselineApproved : Boolean;
            }
            first CRR then ELR;

            timeslice NominalOperations {
                doc
                /*  */

                part <SS> Space_Segment : SpaceSegment {
                    in port Satellite_Solar_Environment redefines Satellite_Solar_Environment;
                    in port Telecommand_Port redefines Telecommand_Port;
                    out port Telemetry_Port redefines Telemetry_Port;

                }

                part Sun : Star {
                    out port Solar_Environment :> Stellar_Environment;
                }
                
                part <GS> Ground_Segment : GroundSegment {
                    out port Telecommand_Port redefines Telecommand_Port;
                    in port Telemetry_Port redefines Telemetry_Port;
                }

                connect Sun.Solar_Environment to Space_Segment.Satellite_Solar_Environment;
                connect Ground_Segment.Telecommand_Port to Space_Segment.Telecommand_Port;
                connect Space_Segment.Telemetry_Port to Ground_Segment.Telemetry_Port;

            }

            // ELR held at the completion of the mission
            snapshot ELR : Report {
                doc
                /* End-of-Life Review */

                attribute BaselineApproved : Boolean;
            }
        }

        // Phase F: Disposal
        then timeslice PhaseF {
            doc
            /* Disposal */

            // MCR held at the end of this phase
            snapshot MCR : Report {
                doc
                /* Mission Close-out Review */

                attribute BaselineApproved : Boolean;
            }
        }
    }
}
