package CommunicationsSystemPackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import SpaceActionsPackage::*;
    private import ElectricalPowerSystemPackage::*;
    private import OnBoardDataHandlingSystemPackage::*;

    port def OutCommandPort {
        out item ground_Command : MissionPackage::GroundCommand;
    }

    port def InStatusPort {
        in item status : MissionPackage::OnBoardStatus;
    }

    port def RFLinkPort {
        out item rF_Out : ~TmTcPort;
        in item rF_In : ~TmTcPort;
    }

    part def Antenna :> GeneralElectricalComponent {
        attribute band : String;
        attribute gain : Real;

        port antenna_Command_Port : OutCommandPort;
        port antenna_Status_Port : InStatusPort;
        port antenna_RF_Link_Port : RFLinkPort;
    }

    part def Transceiver :> GeneralElectricalComponent {

        port transceiver_Status_Port : InStatusPort;
        port transceiver_Command_Port : OutCommandPort;

        attribute maxTxPower : ISQ::PowerValue;

        attribute supportsRx : Boolean;
        attribute supportsTx : Boolean;

        attribute downlinkDataRate : MissionPackage::TelemetryData;
        attribute uplinkDataRate : MissionPackage::GroundCommand;
        attribute dopplerToleranceHz : Real;
        attribute reconfigurableInOrbit : Boolean;
    }

    part def CryptoUnit {
        attribute name : String;
        attribute uplink_Auth_Enabled : Boolean;
        attribute uplink_Decrypt_Enabled : Boolean;
        attribute downlink_Encrypt_Enabled : Boolean;
        attribute downlink_Integrity_Enabled : Boolean;

        port crypto_Status_Port : InStatusPort;
        port crypto_Command_Port : OutCommandPort;
    }

    action def TransmitStatusDownlink {
        in item housekeeping_In : MissionPackage::OnBoardStatus;
        out item Telemetry_Frame_Out : MissionPackage::TelemetryData;
    }

    action def DecryptAndAuthenticateUplink {
        in item rf_Frame_In : MissionPackage::TelemetryData;
         out item telecommand_Out : MissionPackage::GroundCommand;
    }
    action def EncryptDownlinkTelemetry {
        in item telemetry_Frame_In : MissionPackage::TelemetryData;
        out item rF_Frame_Out : MissionPackage::TelemetryData;
    }

    part def CommunicationsSystem  :> PowerSinkSubsystem {
        port power_Bus_5V: PowerBus;
        port rF_Link_Port : RFLinkPort;
        port data_Bus : DataBus;
        
        part antenna_Part : Antenna;
        part transceiver_Part : Transceiver;
        part crypto_Part : CryptoUnit;

        attribute supports_All_Mission_Phases : Boolean;
        attribute has_Redundancy_Or_Fail_Safe : Boolean;
        attribute worst_Case_Link_Margin_dB : Real;

        perform action transmit_HealthData_Action : TransmitStatusDownlink;
        perform action decrypte_Autheticate_Action : DecryptAndAuthenticateUplink;
        perform action encrypt_Dowmlink_Action : EncryptDownlinkTelemetry;

        bind encrypt_Dowmlink_Action.telemetry_Frame_In = transmit_HealthData_Action.Telemetry_Frame_Out;
        bind rF_Link_Port.rF_Out = encrypt_Dowmlink_Action.telemetry_Frame_In;
        bind decrypte_Autheticate_Action.telecommand_Out = rF_Link_Port.rF_In;
    }
}
