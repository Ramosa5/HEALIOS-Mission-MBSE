package MissionDomainPackage {
    private import MissionPackage::* ;
    
    // The subject of the Use Cases
    part def CubeSat :> SpaceSegment;

    // Actors derived from Stakeholders and Environment
    part def GroundOperator; // Represents HEALIOS Team / GS
    part def Sun; // For Sun Pointing / Eclipse
    part def LEO_Environment; // For Radiation/Thermal
    part def LaunchVehicle;
}

package MissionUseCasesDef {
    private import MissionDomainPackage::*;
    private import MissionRequirementsPackage::*;
    private import SpaceSegmentRequirement::*;
    private import GroundSegmentRequirementsPackage::*;

    // **Use Case: Perform Self-Healing Experiment**
    use case def PerformSelfHealingExperiment {
        subject sat : CubeSat;
        actor sun : Sun;
        
        objective {
            doc /*
             * The CubeSat shall detect eclipse and perform the reverse-bias experiment
             * on Perovskite samples to test self-healing capabilities.
             */
             
             // Linking to the specific requirements this UC satisfies
             requirement R_M_001; // Self_Healing_Experiments
             requirement R_SS_004; // Reverse_Bias_Control
        }
    }

    // **Use Case: Characterise Performance**
    use case def CharacterisePerformance {
        subject sat : CubeSat;
        
        objective {
            doc /*
             * Measure I-V curves of the PSC Payload and Control Group.
             */
             requirement R_M_001_a; // PSC_Performance
             requirement R_SS_002; // PV_Data_Gathering
        }
    }

    // **Use Case: Apply Reverse Bias**
    use case def ApplyReverseBias {
        subject sat : CubeSat;
        
        objective {
            doc /*
             * Apply controlled voltage (-5V to 0V) during eclipse phases.
             */
             requirement R_SS_004_a; // Voltage_Range
             requirement R_SS_008;   // Eclipse_Trigger
        }
    }

    // **Use Case: Log Environmental Data**
    use case def LogEnvironment {
        subject sat : CubeSat;
        actor env : LEO_Environment;
        
        objective {
            doc /*
             * Log temperature, radiation, and illumination data.
             */
             requirement R_M_001_c; // Environment_Characterisation
             requirement R_SS_003;  // Environment_Logging
        }
    }

    // **Use Case: Execute Ground Communication**
    use case def ExecuteGroundCommunication {
        subject sat : CubeSat;
        actor operator : GroundOperator;
        
        objective {
            doc /*
             * Manage uplink of commands and downlink of scientific/telemetry data
             * during station overpasses.
             */
             requirement R_M_014; // Ground_Station_Support
             requirement R_SS_013; // Telemetry_Protocol
        }
    }

    // **Use Case: Downlink Data**
    use case def DownlinkData {
        subject sat : CubeSat;
        actor operator : GroundOperator;
        
        objective {
            doc /* Transmit stored experiment and housekeeping data. */
            requirement R_M_005; // Dataset_Format
        }
    }

    // **Use Case: Maintain Attitude**
    use case def MaintainAttitude {
        subject sat : CubeSat;
        actor sun : Sun;

        objective {
            doc /* Point solar panels/sensors towards the sun during illuminated phases. */
            requirement R_SS_005; // Sun_Pointing
        }
    }

    // **Use Case: Handle Faults (FDIR)**
    use case def HandleFaults {
        subject sat : CubeSat;
        
        objective {
            doc /* Detect faults and autonomously recover or enter Safe Mode. */
            requirement R_M_019; // FDIR_Implementation
            requirement R_SS_015; // Space Segment FDIR
        }
    }
}