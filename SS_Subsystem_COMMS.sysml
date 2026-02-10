package CommunicationsSystemPackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import SpaceActionsPackage::*;
    private import ElectricalPowerSystemPackage::*;

    port def PowerBusPort {
        in Voltage : ISQ::SourceVoltageValue;
    }

    port def OutCommandPort {
        out item Cmd : MissionPackage::GroundCommand;
    }

    port def InHKPort {
        in item HK : MissionPackage::OnBoardStatus;
    }

    port def OutStatusPort {
        out item Status : MissionPackage::OnBoardStatus;
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
    }

    part def Transceiver :> GeneralElectricalComponent {
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
    }

    action def TransmitStatusDownlink {
        in item HK_In : MissionPackage::OnBoardStatus;
        out item TM_Out : MissionPackage::TelemetryData;
    }

    action def DecryptAndAuthenticateUplink {
        in item RF_In : MissionPackage::TelemetryData;
        out item Cmd_Out : MissionPackage::GroundCommand;
    }

    action def EncryptDownlinkTelemetry {
        in item TM_In : MissionPackage::TelemetryData;
        out item RF_Out : MissionPackage::TelemetryData;
    }

    action def ReportCommsHealth {
        out item Status_Out : MissionPackage::OnBoardStatus;
    }

    action def TransmitBeacon {
        out item Beacon_Out : MissionPackage::TelemetryData;
    }

    action def LogCommsAnomaly {
        out item Anomaly_Out : CommsAnomaly;
    }

    part def CommunicationsSystem {
        port EPS_Power_Port : PowerBusPort;
        port OBDH_Command_Port : OutCommandPort;
        port OBDH_HK_Port : InHKPort;
        port OBDH_Status_Port : OutStatusPort;
        port RF_Link_Port : RFLinkPort;
        port OBDH_Anomaly_Port : OutAnomalyPort;

        part Antenna_Part : Antenna;
        part Transceiver_Part : Transceiver;
        part Crypto_Part : CryptoUnit;

        attribute Supports_All_Mission_Phases : Boolean;
        attribute Has_Redundancy_Or_Fail_Safe : Boolean;
        attribute Worst_Case_Link_Margin_dB : Real;

        attribute Rf_Emissions_Compliant : Boolean;
        attribute Emc_Compliant : Boolean;

        attribute Beacon_Enabled : Boolean;
        attribute Beacon_Contains_Vital_Telemetry : Boolean;

        attribute Supports_E2E_Test_With_EGSE : Boolean;
        attribute Supports_Over_The_Air_Qualification_Test : Boolean;

        perform action TX_HK_Action : TransmitStatusDownlink;
        perform action DEC_AUTH_Action : DecryptAndAuthenticateUplink;
        perform action ENC_DL_Action : EncryptDownlinkTelemetry;
        perform action HEALTH_Action : ReportCommsHealth;
        perform action BEACON_Action : TransmitBeacon;
        perform action LOG_ANOM_Action : LogCommsAnomaly;

        bind TX_HK_Action.HK_In = OBDH_HK_Port.HK;
        bind ENC_DL_Action.TM_In = TX_HK_Action.TM_Out;
        bind RF_Link_Port.RF_Out = ENC_DL_Action.RF_Out;

        bind DEC_AUTH_Action.RF_In = RF_Link_Port.RF_In;
        bind OBDH_Command_Port.Cmd = DEC_AUTH_Action.Cmd_Out;

        bind OBDH_Status_Port.Status = HEALTH_Action.Status_Out;
        bind OBDH_Anomaly_Port.Anomaly = LOG_ANOM_Action.Anomaly_Out;
    }
}
