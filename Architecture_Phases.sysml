package MissionPhases {
    private import StakeholdersDefinitionPackage::*;
    private import Time;
    private import ScalarValues::*;
    
    occurrence def MissionLifecycle {
        doc /* Mission Lifecycle according to ECSS-M-ST-10C Rev.1 – Project planning and implementation (6 March 2009) */
        
        // Phase 0: Mission analysis/needs identification
        timeslice Phase0 {
            doc /* Mission Analysis and Needs Identification */

            timeslice MissionAnalysisProcess {
                doc /* Mission Analysis */

                action Define_Objectives_And_Constraints {
                    doc /* Define mission objectives and constraints */

                    out MissionObjectives : String;
                    out MissionConstraints : String;
                    
                }
       
            }

            first MissionAnalysisProcess then MDR;

            // The review is held at the end of phase 0
            snapshot MDR {
                doc /* Mission Definition Review */

                attribute BaselineApproved : Boolean;
            }
            
        }

        // Phase A: Feasibility
        then timeslice PhaseA {
            doc /* Feasibility */

            // The review is held at the end of Phase A
            snapshot PRR {
                doc /* Preliminary Requirements Review */

                attribute BaselineApproved : Boolean;
            }
        }

        // Phase B: Preliminary Definition
        then timeslice PhaseB {
            doc /* Preliminary Definition */

            // SRR is held during the course of Phase B
            snapshot SRR {
                doc /* System Requirements Review */

                attribute BaselineApproved : Boolean;
            }

            first SRR then PDR;


            // PDR is held at the end of Phase B
            snapshot PDR {
                doc /* Preliminary Design Review */

                attribute BaselineApproved : Boolean;
            }
        }

        // Phase C: Detailed Definition
        then timeslice PhaseC {
            doc /* Detailed Definition */

            // CDR is held at the end of phase C
            snapshot CDR {
                doc /* Critical Design Review */

                attribute BaselineApproved : Boolean;
            }
        }

        // Phase D: Qualification and Production
        then timeslice PhaseD {
            doc /* Qualification and Production */

            // QR held during the course of the phase
            snapshot QR {
                doc /* Qualification Review */

                attribute BaselineApproved : Boolean;
            }

            first QR then AR;

            // AR held at the end of the phase
            snapshot AR {
                doc /* Acceptance Review */

                attribute BaselineApproved : Boolean;
            }

            first AR then ORR;

            // ORR held at the end of the phase
            snapshot ORR {
                doc /* Operational Readiness Review */

                attribute BaselineApproved : Boolean;
            }

        }

        // Phase E: Utilization
        then timeslice PhaseE {
            doc /* Utilization */

            // FRR held prior to launch
            snapshot FRR {
                doc /* Flight Readiness Review */

                attribute BaselineApproved : Boolean;
            }

            first FRR then LRR;

            // LRR held immediately prior to launch
            snapshot LRR {
                doc /* Launch Readiness Review */

                attribute BaselineApproved : Boolean;
            }

            first LRR then CRR;

            // CRR held after completion of on-orbit commissioning
            snapshot CRR {
                doc /* Commissioning Result Review */

                attribute BaselineApproved : Boolean;
            }
            first CRR then ELR;

            // ELR held at the completion of the mission
            snapshot ELR {
                doc /* End-of-Life Review */

                attribute BaselineApproved : Boolean;
            }
        }

        // Phase F: Disposal
        then timeslice PhaseF {
            doc /* Disposal */

            // MCR held at the end of this phase
            snapshot MCR {
                doc /* Mission Close-out Review */

                attribute BaselineApproved : Boolean;
            }
        }

    }
}