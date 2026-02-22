package UseCaseDefinitionsPackage {
    
    private import StakeholdersDefinitionPackage::*;
    private import ConcernsDefinitionPackage::*;
    private import MissionPackage::*;
    private import GroundActionsPackage::*;
    private import SpaceActionsPackage::*;
    private import MissionControlCentrePackage::*;
    private import DataCentrePackage::*;
    private import GroundStationPackage::*;
    private import StakeholderConcernsPackage::*;
    private import ISQ::*;

    use case def Send_Telecommand {
        doc /* Detailed operational flow for sending a secure command to the CubeSat. 
               This process ensures that only authorized personnel (HEALIOS Team) can influence the 
               satellite's state through a secured communication link. */

        subject Satellite references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment {
            in item Received_Telecommand : GroundCommand;
        }

        actor Operator : HEALIOSTeam {
            doc /* The human operator from the HEALIOS Team who initiates the command sequence. */

            out item Mission_Intent : OperatorRequest;
        }

        actor Ground_Station : GroundSegment {
            doc /* The ground station infrastructure responsible for transmitting commands 
                   to the CubeSat via radio uplink. */
        }
        
        action Authorize_Operator_Access : AuthorizeCommanding {
            doc /* Validates the operator's credentials and mission-specific permissions 
                   to initiate a commanding session. */
            in item Access_Request_Input : OperatorRequest;
            out item Valid_Session_Token : AuthToken;
        }

        action Generate_Formatted_Telecommand : GenerateTelecommand {
            doc /* Translates the operator's high-level mission intent into a specific 
                   binary packet format (Telecommand) according to the mission's data dictionary. */
            in item Session_Token_Input : AuthToken;
            out item Raw_Unsecured_Telecommand : GroundCommand;
        }

        action Protect_Uplink_Integrity : AuthenticateAndEncryptUplink {
            doc /* Applies cryptographic signatures and encryption to the telecommand 
                   to prevent unauthorized interception or replay attacks. */
            in item Telecommand_To_Encrypt : GroundCommand;
            out item Secured_Encrypted_Telecommand : GroundCommand;
        }

        action Execute_Physical_Radio_Uplink : ExecuteUplink {
            doc /* Modulates the secured command into a Radio Frequency (RF) signal and 
                   transmits it via the Ground Station antenna to the CubeSat. */
            in item Secured_Command_Input : GroundCommand;
            out item Modulated_Uplink_Signal : TelemetryData; 
        }

        flow Operator.Mission_Intent to Authorize_Operator_Access.Access_Request_Input;

        flow Authorize_Operator_Access.Valid_Session_Token to Generate_Formatted_Telecommand.Session_Token_Input;

        flow Generate_Formatted_Telecommand.Raw_Unsecured_Telecommand to Protect_Uplink_Integrity.Telecommand_To_Encrypt;

        flow Protect_Uplink_Integrity.Secured_Encrypted_Telecommand to Execute_Physical_Radio_Uplink.Secured_Command_Input;

        flow Execute_Physical_Radio_Uplink.Modulated_Uplink_Signal to Satellite.Received_Telecommand;

        objective SendCommandObjective {
            doc /* Ensure secure and reliable command transmission to maintain satellite safety and mission success. */
            frame concern CubeSat_Standard_Compliance_Concern references StakeholderConcernsPackage::CubeSat_Standard_Compliance_Concern;
            frame concern Command_Security_Concern references StakeholderConcernsPackage::Command_Security_Concern;
            frame concern Frequency_Allocation_Concern references StakeholderConcernsPackage::Frequency_Allocation_Concern;
            frame concern Programmatic_Compliance_Concern references StakeholderConcernsPackage::Programmatic_Compliance_Concern;
            frame concern Educational_Value_Concern references StakeholderConcernsPackage::Educational_Value_Concern;
        }
    }

    use case def Receive_Telemetry {
        doc /* Detailed operational flow for acquiring, downlinking, and processing 
               satellite data. This ensures mission health is monitored and scientific 
               objectives are archived for analysis. */

        subject Satellite references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Space_Segment {
            out item Time_Reference : ISQ::TimeValue;
            out item Housekeeping_Data : HousekeepingData;
            out item Science_Data : ScienceData;

        }

        actor Operator : HEALIOSTeam {
            in item Real_Time_Health_Display : TelemetryData;
        }

        actor Ground_Station : GroundSegment {
            doc /* The ground station infrastructure responsible for receiving telemetry 
                   from the CubeSat via radio downlink. */
        }

        actor Data_Centre : GroundSegment {
            doc /* The data centre responsible for archiving the received telemetry and 
                   making it available for scientific analysis. */

                   in item Archived_Record : ArchiveRecord;
        }

        // 1. Data Collection Phase
        action Acquire_And_Tag_Subsystem_Telemetry : PrepareData {
            doc /* Gathers raw health and science data from all satellite subsystems 
                   and applies high-precision timestamps. */
            out item Time_Tagged_Telemetry_Records : TimeTaggedStatus;
            in item Current_Time_Reference : ISQ::TimeValue;
        }

        // 2. Security Phase
        action Secure_Telemetry_For_Downlink : EncryptDownlinkTelemetry {
            doc /* Encrypts the telemetry packets to ensure data privacy and integrity 
                   during the radio transmission. */
            in item Telemetry_To_Encrypt : TelemetryData;
            out item Secured_Encrypted_Telemetry : TelemetryData;
        }

        // 3. Transmission Phase
        action Broadcast_Satellite_Telemetry_Signal : TransmitStatusDownlink {
            doc /* Modulates the secured data into an RF signal for transmission 
                   back to the Ground Station. */
            in item Telemetry_Input : OnBoardStatus;
            out item Transmitted_Radio_Signal : TelemetryData;
        }

        // 4. Signal Reception Phase
        action Capture_Downlink_Radio_Signal : ReceiveDownlink {
            doc /* The Ground Station antenna detects the satellite signal and 
                   converts it into a digital telemetry stream. */
            out item Captured_Encrypted_Telemetry : TelemetryData;
            in item Incoming_Radio_Signal : TelemetryData;
        }

        // 5. Ground Processing Phase
        action Decrypt_And_Verify_Telemetry_Packet : VerifyAndDecryptDownlink {
            doc /* Decrypts the received stream and validates the checksums to 
                   ensure no data was corrupted during transit. */
            in item Telemetry_To_Decrypt : TelemetryData;
            out item Verified_Ground_Telemetry_Data : TelemetryData;
        }

        // 6. Archiving Phase
        action Archive_And_Store_Mission_Data : ArchiveAndStoreMissionData {
            doc /* Streams the verified data to the Data Centre for persistent 
                   storage and future scientific retrieval. */
            in item Telemetry_To_Archive : TelemetryData;
            out item Archived_Record : ArchiveRecord;
        }

        // 7. Monitoring Phase
        action Monitor_Satellite_Health : MonitorTelemetryRealtime {
            doc /* Displays the verified telemetry to the operators in the MCC 
                   for real-time health assessment. */
            in item Telemetry_For_Monitoring : TelemetryData;
            out item Real_Time_Health_Display : TelemetryData;
        }

        flow Satellite.Time_Reference to Acquire_And_Tag_Subsystem_Telemetry.Current_Time_Reference;
        flow Satellite.Housekeeping_Data to Acquire_And_Tag_Subsystem_Telemetry.Current_Time_Reference;
        flow Satellite.Science_Data to Acquire_And_Tag_Subsystem_Telemetry.Current_Time_Reference;

        flow Acquire_And_Tag_Subsystem_Telemetry.Time_Tagged_Telemetry_Records to Secure_Telemetry_For_Downlink.Telemetry_To_Encrypt;

        flow Secure_Telemetry_For_Downlink.Secured_Encrypted_Telemetry to Broadcast_Satellite_Telemetry_Signal.Telemetry_Input;

        flow Broadcast_Satellite_Telemetry_Signal.Transmitted_Radio_Signal to Capture_Downlink_Radio_Signal.Incoming_Radio_Signal;

        flow Capture_Downlink_Radio_Signal.Captured_Encrypted_Telemetry to Decrypt_And_Verify_Telemetry_Packet.Telemetry_To_Decrypt;

        // Splitting verified data to Archive and Monitor
        flow Decrypt_And_Verify_Telemetry_Packet.Verified_Ground_Telemetry_Data to Archive_And_Store_Mission_Data.Telemetry_To_Archive;
        flow Archive_And_Store_Mission_Data.Archived_Record to Data_Centre.Archived_Record;

        flow Decrypt_And_Verify_Telemetry_Packet.Verified_Ground_Telemetry_Data to Monitor_Satellite_Health.Telemetry_For_Monitoring;
        flow Monitor_Satellite_Health.Real_Time_Health_Display to Operator.Real_Time_Health_Display;

        
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!TBC!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        objective ReceiveTelemetryObjective {
            doc /* Ensure the continuous availability of mission data and the safety of the satellite through robust telemetry acquisition. */
            frame concern DataAcquisitionConcern;
            frame concern DataAvailabilityConcern;
            frame concern LinkCompatibilityConcern;
            frame concern AmateurRadioAccessConcern;
        }
    }

    use case def Utilize_Mission_Scientific_Data {
        doc /* This use case describes how the processed mission data is accessed and analyzed by stakeholders. It specifically highlights the dual benefit for HSB and GUT: receiving scientific data for research and providing study opportunities for students. */

        subject Data_Centre references HealiosMissionInstancePackage::Healios_Mission.HEALIOS_Ground_Segment.Data_Centre {
            out item Mission_Database_Archive : ArchiveRecord;
        }

        // --- Actors ---
        actor Scientists : PerovskiteResearchInstitutes {
            in item Investigation_Opportunities : ProcessedScienceData {
                attribute redefines processing_Level = "Level 2: Processed Dataset";
                }
        }
        actor Manufacturers : PerovskiteSolarCellManufacturers {
            in item TRL_Advancement_Evidence : ProcessedScienceData {
                attribute redefines processing_Level = "Level 3: Comparative Analysis Dataset";}
}
            
        actor Academic_Community : AcademicInstitutions {
            in item Peer_Reviewed_Publication : ProcessedScienceData {
                attribute redefines processing_Level = "Level 4: Published Research Findings";}
        }
 
        actor HSB_Hochschule_Bremen : HSBHochschuleBremen {
            
            in item HSB_Student_Opportunities;
        }
        
        actor Gdansk_University_Of_Technology : GdanskUniversityOfTechnology {
            
            in item GUT_Student_Opportunities;
        }

        // --- Actions ---

        action Transform_Telemetry_Into_Scientific_Datasets : GetScientificDatasets {
            doc /* Converts raw binary archive records into human-readable datasets. */

            in item Raw_Archive_Data_Input : ArchiveRecord;
            out item Validated_Scientific_Dataset : ProcessedScienceData;
        }

        action Conduct_Academic_Studies_And_Theses : FacilitateYouthDevelopement {
            doc /* Universities use the live mission data to facilitate student 
                   theses, laboratory exercises, and hands-on operational training. */

            in item Mission_Data_For_Students : ProcessedScienceData;
            out item Academic_Educational_Outcome : ProcessedScienceData;
        }

        action Analyze_Perovskite_Self_Healing_Behavior : AnalyzePerovskiteSelfHealingBehavior {
            doc /* Investigates the self-healing properties of perovskite solar cells in space. */

            in item Dataset_For_Investigation : ProcessedScienceData;
            out item Self_Healing_Behaviour_Dataset : ProcessedScienceData;
        }

        action Benchmark_Degradation_Against_Silicon_Standards : BenchmarkDegradationAgainstSiliconStandards {
            doc /* Compares the degradation rates of perovskite solar cells against established traditional solar cell benchmarks to evaluate their performance improvements and degradation rates. */

            in item Comparative_Data_Input : ProcessedScienceData;
            out item Benchmark_Results_Dataset : ProcessedScienceData;
        }


        // Data Flow
        flow Data_Centre.Mission_Database_Archive to Transform_Telemetry_Into_Scientific_Datasets.Raw_Archive_Data_Input;
        
        flow Transform_Telemetry_Into_Scientific_Datasets.Validated_Scientific_Dataset to Conduct_Academic_Studies_And_Theses.Mission_Data_For_Students;
        flow Transform_Telemetry_Into_Scientific_Datasets.Validated_Scientific_Dataset to Scientists.Investigation_Opportunities;
        flow Transform_Telemetry_Into_Scientific_Datasets.Validated_Scientific_Dataset to Analyze_Perovskite_Self_Healing_Behavior.Dataset_For_Investigation;
        
        flow Analyze_Perovskite_Self_Healing_Behavior.Self_Healing_Behaviour_Dataset to Benchmark_Degradation_Against_Silicon_Standards.Comparative_Data_Input;
        flow Benchmark_Degradation_Against_Silicon_Standards.Benchmark_Results_Dataset to Manufacturers.TRL_Advancement_Evidence;

        flow Conduct_Academic_Studies_And_Theses.Academic_Educational_Outcome to Academic_Community.Peer_Reviewed_Publication;
        flow Conduct_Academic_Studies_And_Theses.Academic_Educational_Outcome to HSB_Hochschule_Bremen.HSB_Student_Opportunities;
        flow Conduct_Academic_Studies_And_Theses.Academic_Educational_Outcome to Gdansk_University_Of_Technology.GUT_Student_Opportunities;

        /* Mission Data will be available as open-source. Presented usage of data is representative to typical scenarioes. */

        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!TBC!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        objective ScientificUtilizationObjective {
            doc /* Maximize scientific return and fulfill educational mandates for HSB and GUT. */
            frame concern PerovskiteTRLAdvancementConcern;
            frame concern PerovskiteInvestigationConcern;
            frame concern ComparativeStudyConcern;
            frame concern DataAvailabilityConcern;
            frame concern InstitutionalVisibilityConcern;
            frame concern EducationalValueConcern;
        }
    }
}