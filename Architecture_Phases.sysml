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
                    
                    Assesses the different concept from technical, programmatic and risk perspective */

                    in item PreferredMissionConcept : String;
                }

                flow Define_Objectives_And_Constraints.Objectives_And_Constraints to Formulate_Mission_Statment.Objectives_And_Constraints;
                flow Define_Objectives_And_Constraints.Objectives_And_Constraints to Define_Preliminary_Mission_Requirements.Objectives_And_Constraints;
                flow Define_Objectives_And_Constraints.Objectives_And_Constraints to Identify_Stakeholders.Objectives_And_Constraints;

                flow Formulate_Mission_Statment.MissionStatement to Define_Preliminary_Mission_Requirements.MissionStatement;
                flow Formulate_Mission_Statment.MissionStatement to Identify_Stakeholders.MissionStatement;

                flow Identify_Stakeholders.Stakeholders to Define_Preliminary_Mission_Requirements.Stakeholders;

                flow Define_Preliminary_Mission_Requirements.PreliminaryMissionRequirements to Define_Altermative_Mission_Concepts.PreliminaryMissionRequirements;

                flow Define_Altermative_Mission_Concepts.AlternativeMissionConcepts to Evaluate_Alternative_Mission_Concepts.AlternativeMissionConcepts;

                flow Evaluate_Alternative_Mission_Concepts.PreferredMissionConcept to System_Concept_Report.PreferredMissionConcept;


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

            // The review is held at the end of Phase A
            snapshot PRR : Report {
                doc
                /* Preliminary Requirements Review:
                
                1)The primary objectives of this review are: 
                Release of preliminary management, engineering and product assurance plans.
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

            // SRR is held during the course of Phase B
            snapshot SRR : Report {
                doc
                /* System Requirements Review */

                attribute BaselineApproved : Boolean;
            }

            first SRR then PDR;

            // PDR is held at the end of Phase B
            snapshot PDR : Report {
                doc
                /* Preliminary Design Review */

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
