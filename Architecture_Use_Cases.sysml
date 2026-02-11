package UseCaseDefinitionsPackage {
    
    private import StakeholdersDefinitionPackage::*;
    private import StakeholderConcernsPackage::*;
    private import MissionPackage::*;
    private import GroundActionsPackage::*;
    private import ISQ::*;
    private import MissionControlCentrePackage::*;

    use case def SendCommand {
        doc /* Detailed operational flow for sending a secure command to the CubeSat. 
               This process ensures that only authorized personnel (HEALIOS Team) can influence the 
               satellite's state through a secured communication link. */

        subject Satellite : SpaceSegment {
            in item Received_Satellite_Command : GroundCommand;
        }

        actor Operator : HEALIOSTeam {
            doc /* The human operator from the HEALIOS Team who initiates the command sequence. */

            out item Mission_Intent : OperatorRequest;
        }

        actor Ground_Station : GroundSegment {
            doc /* The ground station infrastructure responsible for transmitting commands 
                   to the CubeSat via radio uplink. */
        }

        // 0. Initial State: Operator formulates a mission intent to send a command to the CubeSat.

        // 1. Authorization Phase
        action Authorize_Operator_Access : AuthorizeCommanding {
            doc /* Validates the operator's credentials and mission-specific permissions 
                   to initiate a commanding session. */
            in item Access_Request_Input : OperatorRequest;
            out item Valid_Session_Token : AuthToken;
        }

        // 2. Command Formatting Phase
        action Generate_Formatted_Telecommand : GenerateTelecommand {
            doc /* Translates the operator's high-level mission intent into a specific 
                   binary packet format (Telecommand) according to the mission's data dictionary. */
            in item Session_Token_Input : AuthToken;
            out item Raw_Unsecured_Telecommand : GroundCommand;
        }

        // 3. Security Phase
        action Protect_Uplink_Integrity : AuthenticateAndEncryptUplink {
            doc /* Applies cryptographic signatures and encryption to the telecommand 
                   to prevent unauthorized interception or replay attacks. */
            in item Telecommand_To_Encrypt : GroundCommand;
            out item Secured_Encrypted_Telecommand : GroundCommand;
        }

        // 4. Transmission Phase
        action Execute_Physical_Radio_Uplink : ExecuteUplink {
            doc /* Modulates the secured command into a Radio Frequency (RF) signal and 
                   transmits it via the Ground Station antenna to the CubeSat. */
            in item Secured_Command_Input : GroundCommand;
            out item Modulated_Uplink_Signal : GroundCommand; 
        }

        // 5. Final State: The CubeSat receives the command and processes it according to its onboard software.

        flow Operator.Mission_Intent to Authorize_Operator_Access.Access_Request_Input;

        flow Authorize_Operator_Access.Valid_Session_Token to Generate_Formatted_Telecommand.Session_Token_Input;

        flow Generate_Formatted_Telecommand.Raw_Unsecured_Telecommand to Protect_Uplink_Integrity.Telecommand_To_Encrypt;

        flow Protect_Uplink_Integrity.Secured_Encrypted_Telecommand to Execute_Physical_Radio_Uplink.Secured_Command_Input;

        flow Execute_Physical_Radio_Uplink.Modulated_Uplink_Signal to Satellite.Received_Satellite_Command;

        objective SendCommandObjective {
            frame concern CommandSecurityConcern;
            frame concern LinkCompatibilityConcern;
            frame concern FrequencyAllocationConcern;
            frame concern ProgrammaticComplianceConcern;
            frame concern EducationalValueConcern;
        }
    }
}