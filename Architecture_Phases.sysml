private import StakeholdersDefinitionPackage::*;
private import Time;

package SystemLifeCycle {
    
    occurrence def ECSSProjectManagementReviews {
        
        // Phase 0: Mission analysis/needs identification
        timeslice Phase0 {
            // The review is held at the end of phase 0
            snapshot MDR {
                doc /* Mission Definition Review */
            }
            
        }

        // Phase A: Feasibility
        timeslice PhaseA {
            // The review is held at the end of Phase A
            snapshot PRR {
                doc /* Preliminary Requirements Review */
            }
        }

        // Phase B: Preliminary Definition
        timeslice PhaseB {
            // SRR is held during the course of Phase B
            snapshot SRR {
                doc /* System Requirements Review */
            }
            // PDR is held at the end of Phase B
            snapshot PDR {
                doc /* Preliminary Design Review */
            }
            succession PhaseB first SRR then PDR;
        }

        // Phase C: Detailed Definition
        timeslice PhaseC {
            // CDR is held at the end of phase C
            snapshot CDR {
                doc /* Critical Design Review */
            }
        }

        // Phase D: Qualification and Production
        timeslice PhaseD {
            // QR held during the course of the phase
            snapshot QR {
                doc /* Qualification Review */
            }

            first QR then AR;

            // AR held at the end of the phase
            snapshot AR {
                doc /* Acceptance Review */
            }

            first AR then ORR;

            // ORR held at the end of the phase
            snapshot ORR {
                doc /* Operational Readiness Review */
            }

        }

        // Phase E: Operations/Utilization
        timeslice PhaseE {
            // FRR held prior to launch
            snapshot FRR {
                doc /* Flight Readiness Review */
            }

            first FRR then LRR;

            // LRR held immediately prior to launch
            snapshot LRR {
                doc /* Launch Readiness Review */
            }

            first LRR then CRR;

            // CRR held after completion of on-orbit commissioning
            snapshot CRR {
                doc /* Commissioning Result Review */
            }
            first CRR then ELR;

            // ELR held at the completion of the mission
            snapshot ELR {
                doc /* End-of-Life Review */
            }
        }

        // Phase F: Disposal
        timeslice PhaseF {
            // MCR held at the end of this phase
            snapshot MCR {
                doc /* Mission Close-out Review */
            }
        }

        // Define the sequence of the project life cycle phases
        first Phase0 then PhaseA;
        first PhaseA then PhaseB;
        first PhaseB then PhaseC;
        first PhaseC then PhaseD;
        first PhaseD then PhaseE;
        first PhaseE then PhaseF;
    }
}