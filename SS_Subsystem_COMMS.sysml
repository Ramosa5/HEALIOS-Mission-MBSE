package CommunicationsSystemPackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import SpaceActionsPackage::*;
    private import ElectricalPowerSystemPackage::*;
    private import OnBoardDataHandlingSystemPackage::*;

    port def OutCommandPort {
        out item Cmd : MissionPackage::GroundCommand;
    }

    port def InStatusPort {
        in item Status : MissionPackage::OnBoardStatus;
    }

    port def RFLinkPort {
        out item RF_Out : ~TmTcPort;
        in item RF_In : ~TmTcPort;
    }

    item def CommsAnomaly {
        attribute Type : String;
    }

    port def OutAnomalyPort {
        out item Anomaly : CommsAnomaly;
    }

    part def Antenna :> GeneralElectricalComponent {
        attribute Band : String;
        attribute Gain : Real;

        port Antenna_Command_Port : OutCommandPort;
        port Antenna_Status_Port : InStatusPort;
        port Antenna_RF_Link_Port : RFLinkPort;
    }

    part def Transceiver :> GeneralElectricalComponent {

        port Transceiver_Status_Port : InStatusPort;
        port Transceiver_Command_Port : OutCommandPort;

        attribute MaxTxPower : ISQ::PowerValue;

        attribute SupportsRx : Boolean;
        attribute SupportsTx : Boolean;

        attribute DownlinkDataRate : MissionPackage::TelemetryData;
        attribute UplinkDataRate : MissionPackage::GroundCommand;

        attribute DopplerToleranceHz : Real;
        attribute ModulationCoding : String;
        attribute PacketFormat : String;
        attribute FECEnabled : Boolean;
        attribute CRCEnabled : Boolean;
        attribute ReconfigurableInOrbit : Boolean;
    }

    part def CryptoUnit {
        attribute Name : String;
        attribute UplinkAuthEnabled : Boolean;
        attribute UplinkDecryptEnabled : Boolean;
        attribute DownlinkEncryptEnabled : Boolean;
        attribute DownlinkIntegrityEnabled : Boolean;

        port Crypto_Status_Port : InStatusPort;
        port Crypto_Command_Port : OutCommandPort;
    }

    action def TransmitStatusDownlink {
        in item Housekeeping_In : MissionPackage::OnBoardStatus;
        out item Telemetry_Frame_Out : MissionPackage::TelemetryData;
    }

    action def DecryptAndAuthenticateUplink {
        in item RF_Frame_In : MissionPackage::TelemetryData;
         out item Telecommand_Out : MissionPackage::GroundCommand;
    }
    action def EncryptDownlinkTelemetry {
        in item Telemetry_Frame_In : MissionPackage::TelemetryData;
        out item RF_Frame_Out : MissionPackage::TelemetryData;
    }

    part def CommunicationsSystem {
        port Power_Bus_5V: PowerBus;
        port RF_Link_Port : RFLinkPort;
        port Data_Bus : DataBus;
        
        part Antenna_Part : Antenna;
        part Transceiver_Part : Transceiver;
        part Crypto_Part : CryptoUnit;

        attribute Supports_All_Mission_Phases : Boolean;
        attribute Has_Redundancy_Or_Fail_Safe : Boolean;
        attribute Worst_Case_Link_Margin_dB : Real;

        attribute Rf_Emissions_Compliant : Boolean;
        attribute Emc_Compliant : Boolean;

        attribute Supports_E2E_Test_With_EGSE : Boolean;
        attribute Supports_Over_The_Air_Qualification_Test : Boolean;

        perform action Transmit_HealthData_Action : TransmitStatusDownlink;
        perform action Decrypte_Autheticate_Action : DecryptAndAuthenticateUplink;
        perform action Encrypt_Dowmlink_Action : EncryptDownlinkTelemetry;

        bind Encrypt_Dowmlink_Action.Telemetry_Frame_In = Transmit_HealthData_Action.Telemetry_Frame_Out;
        bind RF_Link_Port.RF_Out = Encrypt_Dowmlink_Action.Telemetry_Frame_In;
        bind Decrypte_Autheticate_Action.Telecommand_Out = RF_Link_Port.RF_In;
    }
}
