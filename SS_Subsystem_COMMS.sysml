package CommunicationsSystemPackage {
    private import MissionPackage::*;
    private import ISQ::*;
    private import SpaceActionsPackage::*;

    port def powerBus {
        in voltage : ISQ::SourceVoltageValue;
    }

    port def groundCommandPort {
        out item cmdOut : MissionPackage::GroundCommand;
    }

    port def obdhStatusInPort {
        in item hkIn : MissionPackage::OnBoardStatus;
    }

    port def commsStatusOutPort {
        out item statusOut : MissionPackage::OnBoardStatus;
    }

    port def rfLinkPort {
        out item rfOut : MissionPackage::TelemetryData;
        in item rfIn : MissionPackage::TelemetryData;
    }

    item def CommsAnomaly { attribute type : String; }
    port def commsAnomalyOutPort { out item anomalyOut : CommsAnomaly; }


    part def Antenna {
        attribute name : String;
        attribute band : String;
        attribute gain : Real;
    }

    part def Transceiver {
        attribute name : String;
        attribute maxTxPower : ISQ::PowerValue;

        attribute supportsRx : Boolean;
        attribute supportsTx : Boolean;

        attribute downlinkDataRate : MissionPackage::TelemetryData;
        attribute uplinkDataRate : MissionPackage::GroundCommand;

        attribute dopplerToleranceHz : Real;
        attribute modulationCoding : String;
        attribute packetFormat : String;

        attribute fecEnabled : Boolean;
        attribute crcEnabled : Boolean;

        attribute reconfigurableInOrbit : Boolean;
    }

    part def CryptoUnit {
        attribute name : String;

        attribute uplinkAuthEnabled : Boolean;
        attribute uplinkDecryptEnabled : Boolean;

        attribute downlinkEncryptEnabled : Boolean;
        attribute downlinkIntegrityEnabled : Boolean; // e.g., MAC/signature
    }

    

    part def CommunicationsSystem {
        // Power + interface ports
        port commsPowerIn : powerBus;
        port tcToOBDH : groundCommandPort;
        port hkFromOBDH : obdhStatusInPort;
        port hkStatusToOBDH : commsStatusOutPort;
        port rfLink : rfLinkPort;
        port anomalyToOBDH : commsAnomalyOutPort;

        // Physical elements (lean)
        part antenna : Antenna;
        part trx : Transceiver;

        // Security element
        part crypto : CryptoUnit;

        attribute supportsAllMissionPhases : Boolean;
        attribute hasRedundancyOrFailSafe : Boolean;
        attribute worstCaseLinkMargin_dB : Real;

        attribute rfEmissionsCompliant : Boolean;
        attribute emcCompliant : Boolean;

        attribute beaconEnabled : Boolean;
        attribute beaconContainsVitalTelemetry : Boolean;

        attribute supportsE2ETestWithEGSE : Boolean;
        attribute supportsOverTheAirQualificationTest : Boolean;

        perform action txHK : TransmitStatusDownlink;
        perform action decryptAuth : DecryptAndAuthenticateUplink;
        perform action encryptDL : EncryptDownlinkTelemetry;
        perform action health : ReportCommsHealth;
        perform action beacon : TransmitBeacon;
        perform action logAnomaly : LogCommsAnomaly;

        bind txHK.hkIn = hkFromOBDH.hkIn;
        bind encryptDL.tmIn = txHK.tmOut;
        bind rfLink.rfOut = encryptDL.rfOut;
        bind decryptAuth.rfIn = rfLink.rfIn;
        bind tcToOBDH.cmdOut = decryptAuth.cmdOut;
        bind hkStatusToOBDH.statusOut = health.status;
        bind anomalyToOBDH.anomalyOut = logAnomaly.anomaly;
    }
}
