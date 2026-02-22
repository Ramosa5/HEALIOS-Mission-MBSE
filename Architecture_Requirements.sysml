// TO DO:
    // Check Space Segment and Ground Segment requirements for compliance.
    // Check that all Space Segment and Ground Segment requirements are correctly linked to the higher-level.
    // Check that all requirements are correctly linked to the relevant stakeholders and concerns.
// At the end:
    // Do satifaction and verification implementation.

package MissionRequirementsPackage{
    private import MissionPackage::*;
    private import StakeholdersDefinitionPackage::*;
    private import ConcernsDefinitionPackage::*;
    private import SpaceSegmentRequirementPackage::*;
    private import GroundSegmentRequirementsPackage::*;
    private import StakeholderConcernsPackage::*;


    requirement def <R_M_001> Self_Healing_Experiments {
        doc /* The mission shall perform active self-healing experiments on designated PSC samples by applying a controlled reverse-bias voltage during orbital eclipse phases. */

        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;
        
        stakeholder Perovskite_Research_Institutes : PerovskiteResearchInstitutes;
        stakeholder Perovskite_Solar_Cell_Manufacturers : PerovskiteSolarCellManufacturers;

        frame concern PerovskiteInvestigationConcern;
        frame concern ComparativeStudyConcern;
        frame concern DataAcquisitionConcern;

        requirement <R_M_001_a> PSC_Performance {
            doc
            /* The mission shall characterise the performance of Perovskite Solar Cells (PSC) by measuring open-circuit voltage and short-circuit current, what results in Current-Voltage (I-V) curves. */

            subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;
        }

        requirement <R_M_001_b> Control_Group_Benchmark {
            doc /* The mission shall utilise traditional solar cells as a control group to benchmark the degradation rates of the perovskite payload. */

            subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;
        }
        requirement <R_M_001_c> Environment_Characterisation {
            doc /* The mission shall characterise the space environment by measuring radiation, irradiance, and temperature related to Perovskite Solar Cells samples, to contextualise with observed degradation and self-healing phenomena. */

            subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;
        }
        requirement <R_M_001_d> Environmental_Repeatability {
            doc /* The mission scenarios shall enable repetitive environmental conditions for the perovskite solar cells and the benchmark group. */

            subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;
        }
    }

    requirement def <R_M_002> Orbit_Definition {
        doc
        /* The mission shall be operated in the Low Earth Orbit (LEO). */
        
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme;

        frame concern PerovskiteTRLAdvancementConcern;
        frame concern ProgrammaticComplianceConcern;
        frame concern ComponentReliabilityConcern;
    }

    requirement def <R_M_003> Platform_Conformity {
        doc /* The mission should utilise a 1U CubeSat platform, conformant to CubeSat Design Specification Rev. 14.1 (February 2022), which enables experiment performance. */
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder FYS references StakeholderConcernsPackage::European_Space_Agency.Fly_Your_Satellite_programme;
        stakeholder CubeSat_Community references  StakeholderConcernsPackage::CubeSat_Community;
        stakeholder Satellite_COTS_Providers references StakeholderConcernsPackage::Satellite_COTS_Providers;

        frame concern CubeSat_Standard_Compliance_Concern references StakeholderConcernsPackage::CubeSat_Standard_Compliance_Concern;

        requirement Form_Factor_Compliance : R_SS_017;
        requirement Mass_Compliance : R_SS_018;
    }

    requirement def <R_M_004> Autonomous_Management {
        doc /* The mission shall autonomously manage experiment execution, including eclipse detection and data logging, to mitigate limited ground contact time. */
        
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder Perovskite_Research_Institutes : PerovskiteResearchInstitutes;

        frame concern DataAcquisitionConcern;
    }

    requirement def <R_M_005> Dataset_Format {
        doc /* The mission shall provide experiment datasets in a format and with metadata completeness necessary to support post-flight comparison to pre-flight terrestrial testing, and published literature. */
        
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder Perovskite_Research_Institutes : PerovskiteResearchInstitutes;

        frame concern DataAvailabilityConcern;
        frame concern ComparativeStudyConcern;
    }

    requirement def <R_M_006> ESA_Compliance {
        doc /* The mission shall comply with the programmatic and safety standards of the ESA "Fly Your Satellite!" programme. */
        
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme;

        frame concern ProgrammaticComplianceConcern;
    }

    requirement def <R_M_007> Mission_Duration {
        doc /* The mission shall operate in orbit for a duration sufficient to generate statistically significant degradation and recovery data (Target: 1 Year). */
        
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder Perovskite_Research_Institutes : PerovskiteResearchInstitutes;
        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme;
        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;

        frame concern ComponentReliabilityConcern;
        frame concern PerovskiteTRLAdvancementConcern;
    }

    requirement def <R_M_008> EOL_Plan {
        doc /* The mission documentation shall provide an EOL plan and update its relevance and applicability. */
        
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme;

        frame concern SpaceDebrisMitigationConcern;
    }

    requirement def <R_M_009> Core_Team_Composition {
        doc /* The core mission team shall consist of at least 4 university students enrolled in a Master's or Bachelor's programme within an ESA Member State. */
        
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme;
        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;
        
        //frame concern InstitutionalVisibilityConcern;
        frame concern EducationalValueConcern;
        frame concern ProgrammaticComplianceConcern;
    }

    requirement def <R_M_010> Academic_Supervision {
        doc /* The project shall be supervised by at least 2 academic professors or lecturers who provide formal endorsement and access to university facilities. */
        
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme;
        stakeholder Gdansk_University_of_Technology : GdanskUniversityOfTechnology;
        stakeholder HSB_Hochschule_Bremen : HSBHochschuleBremen;
        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;

        frame concern InstitutionalVisibilityConcern;
        //frame concern EducationalValueConcern;
        frame concern ProgrammaticComplianceConcern;
    }

    requirement def <R_M_011> Academic_Integration {
        doc /* The mission team shall identify specific thesis topics or academic credits associated with the project work packages. */
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme;
        stakeholder Gdansk_University_of_Technology : GdanskUniversityOfTechnology;
        stakeholder HSB_Hochschule_Bremen : HSBHochschuleBremen;
        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;

        frame concern InstitutionalVisibilityConcern;
        frame concern EducationalValueConcern;
        frame concern ProgrammaticComplianceConcern;
    }

    requirement def <R_M_012> Test_Facility_Usage {
        doc /* The mission documentation shall include the use of ESA environmental test facilities (e.g., Thermal Vacuum Chamber, Electrodynamic Shaker). */
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme;

        frame concern InstitutionalVisibilityConcern;
        frame concern ProgrammaticComplianceConcern;
        frame concern ComponentReliabilityConcern;
    }

    requirement def <R_M_013> Educational_Return {
        doc /* The mission shall demonstrate a clear educational return. */
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme;
        stakeholder Gdansk_University_of_Technology : GdanskUniversityOfTechnology;
        stakeholder HSB_Hochschule_Bremen : HSBHochschuleBremen;
        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;

        frame concern InstitutionalVisibilityConcern;
        frame concern EducationalValueConcern;
        frame concern ProgrammaticComplianceConcern;
    }

    requirement def <R_M_014> Ground_Station_Support {
        doc /* The mission shall include at least one operational Ground Station capable of commanding and receiving telemetry from the CubeSat. */
        
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder Gdansk_University_of_Technology : GdanskUniversityOfTechnology;
        stakeholder HSB_Hochschule_Bremen : HSBHochschuleBremen;
        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;

        frame concern LinkCompatibilityConcern;
    }

    requirement def <R_M_015> Safety_Implementation {
        doc /* The mission plan and procedures shall ensure the safety of personnel, equipment, and the launch vehicle by implementing hazard control measures and complying with the safety requirements of the launch provider and test facilities. */
        
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme;
        stakeholder Gdansk_University_of_Technology : GdanskUniversityOfTechnology;
        stakeholder HSB_Hochschule_Bremen : HSBHochschuleBremen;
        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;

        frame concern SafetyConcern;
        frame concern ProgrammaticComplianceConcern;
    }

    requirement def <R_M_016> Launcher_Compliance {
        doc /* The mission architecture and organisation shall comply with the requirements of the selected launch service provider. */
        
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder Launch_Service_Provider : LaunchServiceProvider;
        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;

        frame concern SafetyConcern;
    }

    requirement def <R_M_017> Telecommunication_Compliance {
        doc /* The mission architecture and organisation shall comply with International Telecommunication Union (ITU) and International Amatour Radio Union legislations. */
        
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder International_Telecommunication_Union : InternationalTelecommunicationUnion;
        stakeholder International_Amateur_Radio_Union : InternationalAmateurRadioUnion;

        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;

        frame concern FrequencyAllocationConcern;
        frame concern AmateurRadioAccessConcern;
    }

    requirement def <R_M_018> UN_Registration {
        doc /* The mission shall provide registration of the satellite in the United Nations Register of Objects Launched into Outer Space of UNOOSA, including national registers. */
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder United_Nations_Office_for_Outer_Space_Affairs : UnitedNationsOfficeForOuterSpaceAffairs;

        frame concern SpaceDebrisMitigationConcern;
        frame concern RegistrationComplianceConcern;

    }

    requirement def <R_M_019> FDIR_Implementation {
        doc /* The mission shall implement a Fault Detection, Isolation, and Recovery (FDIR) strategy to enhance system reliability. */
        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;

        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme ;

        frame concern ComponentReliabilityConcern;
    }

    requirement def <R_M_020> Security_Architecture {
        doc /* The mission shall implement secure data transmission link and relevant protection mechanisms to ensure the integrity against external threats, unauthorized access, and invalid data ingestion. */

        subject Healios_Mission references HealiosMissionInstancePackage::Healios_Mission;
        stakeholder ITU : InternationalTelecommunicationUnion;
        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;

        frame concern CommandSecurityConcern;
    }
}

package SpaceSegmentRequirementPackage {
    private import MissionPackage::*;
    private import MissionRequirementsPackage::*;
    private import StakeholdersDefinitionPackage::*;
    private import ConcernsDefinitionPackage::*;
    private import StakeholderConcernsPackage::*;

    requirement def <R_SS_001> Payload_Accommodation specializes R_M_001 { // ASK ABOUT THIS: If A is satisfied, B is automatically satisfied.
        doc /* The Space Segment shall accommodate and support the operation of the perovskite solar cells payload. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
    }

    requirement def <R_SS_002> PV_Data_Gathering specializes R_M_001 {
        doc /* The Space Segment shall autonomously gather, store, and timestamp electrical performance data (Voltage, Current) of all photovoltaic technologies onboard throughout the mission, with a frequency higher than once per orbit. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
    }

    requirement def <R_SS_003> Environment_Logging specializes R_M_001 {
        doc /* The Space Segment shall log orbital environment parameters: thermal state, illumination condition, time since deployment, with a frequency higher than once per orbit. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
    }

    requirement def <R_SS_004> Reverse_Bias_Control specializes R_M_001 {
        doc /* The Space Segment shall be capable of applying a controlled reverse-bias voltage to selected perovskite solar cells. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;

        requirement def <R_SS_004_a> Voltage_Range {
            doc /* The Space Segment shall apply a reverse-bias voltage in the range of 0 to -5 V with a resolution of at least 0.1 V. */
        }

        requirement def <R_SS_004_b> Reverse_Bias_Safety {
            doc /* The Space Segment shall ensure that reverse-bias conditions applied during self-healing cycles over the mission lifetime do not exceed material degradation thresholds. */
        }
    }

    requirement def <R_SS_005> Sun_Pointing specializes R_M_001 {
        doc /* The Space Segment shall maintain a sun-pointing attitude during the illuminated orbital phase to ensure consistent environmental conditions for the payload. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
    }

    requirement def <R_SS_006> Environmental_Survival specializes R_M_002, R_M_007 {
        doc /* The Space Segment shall survive the launch and operate in the LEO environment for the mission duration. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;

        requirement def <R_SS_006_a> Launch_Survival {
            doc /* The Space Segment shall withstand the mechanical and thermal stresses of the launch environment, including vibrations, shocks, and acoustic loads. */
        }
        requirement def <R_SS_006_b> LEO_Survival {
            doc /* The Space Segment shall withstand the thermal and radiation environment of Low Earth Orbit (LEO) for a minimum operational lifetime of one year. */
        }
    }
    
    requirement def <R_SS_007> Deployer_Compatibility specializes R_M_003, R_M_016 {
        doc /* The Space Segment shall be compatible with the deployer environment. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
    }

    requirement def <R_SS_008> Eclipse_Trigger specializes R_M_004 {
        doc /* The Space Segment shall detect the orbital eclipse phase to trigger the experiment. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
    }

    requirement def <R_SS_009> NonContact_Storage specializes R_M_004 {
        doc /* The Space Segment shall include a system capable of storing experiment data during non-contact phases for later downlink. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
    }

    requirement def <R_SS_010> Autonomous_Execution specializes R_M_004 {
        doc /* The Space Segment shall maintain autonomous execution of the experiment timeline such that temporary loss of ground communication does not interrupt scheduled phases. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
    }

    requirement def <R_SS_011> Deployment_Transition specializes R_M_004 {
        doc /* The Space Segment shall perform a specific transition scenario from deployment configuration to nominal mode, initialising essential functions and starting mission timing sequences without requiring ground intervention. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
    }

    requirement def <R_SS_012> FYS_Config_Compatibility specializes R_M_006 {
        doc /* The Space Segment shall maintain configuration compatibility with the Fly Your Satellite! testing flow, including environmental and functional test setups. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme;
    }

    requirement def <R_SS_013> Telemetry_Protocol specializes R_M_014 {
        doc /* The Space Segment shall transmit telemetry data compatible with the defined Ground Segment protocols to enable correlation with terrestrial data. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
    }

    requirement def <R_SS_014> Beacon_Signal specializes R_M_014 {
        doc /* The Space Segment shall transmit a beacon signal to facilitate initial tracking and acquisition by the Ground Segment. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        }

    requirement def <R_SS_015> FDIR_Implementation specializes R_M_019, R_M_020 {
        doc /* The Space Segment shall provide Foult Detection, Isolation, and Recovery (FDIR) capability to ensure spacecraft safety and experiment integrity. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;

        requirement def <R_SS_015_a> Fault_Detection {
            doc /* The Space Segment shall implement fault detection mechanisms or architecture. */
        }
        requirement def <R_SS_015_b> Fault_Isolation {
            doc /* The Space Segment shall implement fault isolation mechanisms or architecture. */
        }
        requirement <R_SS_015_c> Fault_Recovery {
            doc /* The Space Segment shall implement progressive fault recovery sequences that attempt subsystem restart before invoking full safe mode. */
            subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        }
        requirement <R_SS_015_d> Software_Updates {
            doc /* The Space Segment shall provide the capability to apply software updates throught the mission. */
            subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        }

        requirement <R_SS_015_e> Safe_Mode {
            doc /* The Space Segment shall implement a safe mode that maintains basic spacecraft health and beacon transmission while non-essential functions are suspended. */
            subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        }
    }

    requirement def <R_SS_016> PFM_Campaign specializes R_M_006, R_M_012, R_M_015 {
        doc /* The Space Segment shall undergo a Proto-Flight Model (PFM) test campaign. */
        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme ;

        requirement def <R_SS_016_a> PFM_Exclusions {
            doc /* The Space Segment PFM shall not be subjected to Life Testing, Burst Pressure, and Electrostatic Discharge (ESD) qualification. */
            subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        }

        requirement def <R_SS_016_b> Random_Vibration {
            doc /* The Space Segment shall undergo a random vibration test on all three axes. */
            subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        }

        requirement def <R_SS_016_c> Sinusoidal_Vibration {
            doc /* The Space Segment shall undergo a sinusoidal vibration test. */
            subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        }

        requirement def <R_SS_016_d> Quasi_Static_Load {
            doc /* The Space Segment shall undergo a Quasi-static load test. */
            subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        }

        requirement def <R_SS_016_e> Thermal_Cycling {
            doc /* The Space Segment shall undergo thermal cycling ( TVAC). */
            subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        }

        requirement def <R_SS_016_f> Bakeout {
            doc /* The Space Segment shall undergo a bakeout campaign. */
            subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        }

        requirement def <R_SS_016_g> PFM_Testing_Safety {
            doc /* The Space Segment PFM test campaign shall be planned and executed to ensure the safety of personnel, equipment, and facilities. */
            subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;
        }
    }

    requirement def <R_SS_017> Launch_Mass {
        doc /* The Space Segment should have a total launch mass not exceeding 2 kg within 0.001 kg tolerance. */

        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;

        attribute Mass_Limit  : ISQ::MassValue = 2.0 [SI::kg];
        attribute Mass_Tolerance : ISQ::MassValue = 0.001 [SI::kg];
        attribute Actual_Mass : ISQ::MassValue = Space_Segment.Total_Mass;

        require constraint {
            (Actual_Mass > 0.0 [SI::kg]) and
            (Actual_Mass <= Mass_Limit + Mass_Tolerance)
        }
    }

    requirement def <R_SS_018> Form_Factor_Requirement {
    doc /* The Space Segment shall conform to the 1U CubeSat form factor as defined by the CubeSat Design Specification. */

        subject Space_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment;

        attribute required_size : String = "1U";
        attribute actual_size : String = Space_Segment.CubeSat_Form_Factor;

        require constraint {
            actual_size == required_size
        }
    }
}

package GroundSegmentRequirementsPackage {
    private import MissionPackage::*;
    private import MissionRequirementsPackage::*;
    private import StakeholdersDefinitionPackage::*;
    private import ConcernsDefinitionPackage::*;
    private import StakeholderConcernsPackage::*;

    requirement def <R_GS_001> Reuse_Institutional_Infrastructure specializes R_M_014 {
        doc /* The Ground Segment architecture shall prioritise the reuse of existing institutional ground station infrastructure (or relevant technology) where compliant with mission needs. */

        subject Ground_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment;

        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;
        stakeholder Gdansk_University_of_Technology : GdanskUniversityOfTechnology ;
        stakeholder HSB_Hochschule_Bremen : HSBHochschuleBremen;
}

     requirement def <R_GS_002> Bidirectional_Communication specializes R_M_014 {
        doc /* At least one ground station shall enable communication with the spacecraft. */
        subject Ground_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment;

        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;
        stakeholder Gdansk_University_of_Technology : GdanskUniversityOfTechnology ;
        stakeholder HSB_Hochschule_Bremen : HSBHochschuleBremen;
    }

    requirement def <R_GS_003> Real_Time_Health_Monitoring specializes R_M_014 {
        doc /* The Ground Segment shall provide real-time monitoring of spacecraft health parameters during each visibility window. */
        subject Ground_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment;
    }

    requirement def <R_GS_004> Secure_Commanding_Authentication specializes R_M_014 {
        doc /* The Ground Segment shall implement secure authentication for access to all commanding operations. */
        subject Ground_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment;
    }

    requirement def <R_GS_005> Doppler_Compensation specializes R_M_014 {
        doc /* The Ground Segment shall apply Doppler compensation for both uplink and downlink during LEO passes. */
        subject Ground_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment;
    }

    requirement def <R_GS_006> TLE_Based_Pass_Prediction specializes R_M_014 {
        doc /* The Ground Segment shall use pass prediction algorithms consistent with TLE-based orbital propagation models. */
        subject Ground_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment;
    }

    requirement def <R_GS_007> Prelaunch_Link_Budget specializes R_M_014 {
        doc /* The Ground Segment shall perform link-budget estimation and verification prior to launch using simulated orbital profiles. */
        subject Ground_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment;
    }

    requirement def <R_GS_008> IARU_Coordination specializes R_M_017 {
        doc /* If the use of radio amateur frequencies is foreseen, the CubeSat operators shall coordinate with the International Amateur Radio Union (IARU). */
        subject Ground_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment;

        stakeholder International_Amateur_Radio_Union;
        stakeholder International_Telecommunication_Union;
        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;
    }

    requirement def <R_GS_009> Data_Archive specializes R_M_005 {
        doc /* The Ground Segment shall store all scientific and housekeeping data in a structured archive for mission lifetime for at least 2 years. */
        
        subject Ground_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment;

        stakeholder Perovskite_Research_Institutes : PerovskiteResearchInstitutes;
        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;
    }

    requirement def <R_GS_010> Data_Format_And_Range_Validation specializes R_M_005 {
        doc /* The Ground Segment shall automatically check if the format of the data adheres to the accepted logical grammar and if the values of the data adhere to the accepted logical type and range. */
        
        subject Ground_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment;
    }

    requirement def <R_GS_011> HEALIOS_Operated_GS specializes R_M_006, R_M_009 {
        doc /* The ground station should be fully controlled and operated by the HEALIOS team. */
        subject Ground_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment;

        stakeholder HEALIOS_Team_Community : HEALIOSTeamCommunity;
        stakeholder FYS references European_Space_Agency.Fly_Your_Satellite_programme ;

    }

    requirement def <R_GS_012> MCC_Location specializes R_M_014 {
        doc /* The Mission Control Centre shall be located in at least one of the locations: HSB Hochschule Bremen - City University of Applied Sciences (Germany) and Gdańsk Univeristy of Technology (Poland). */
        subject Ground_Segment references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment;

        stakeholder Gdansk_University_of_Technology : GdanskUniversityOfTechnology ;
        stakeholder HSB_Hochschule_Bremen : HSBHochschuleBremen;
    }
}

