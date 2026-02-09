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

    part def Antenna {
        attribute name : String;
        attribute band : String;
        attribute gain : Real;
    }

    part def Transceiver {
        attribute name : String;
        attribute maxTxPower : ISQ::PowerValue;

        attribute supportsRx : Boolean = true;
        attribute supportsTx : Boolean = true;

        attribute downlinkDataRate : MissionPackage::TelemetryData;
        attribute uplinkDataRate : MissionPackage::GroundCommand;

        attribute dopplerToleranceHz : Real;
        attribute modulationCoding : String;
        attribute packetFormat : String;

        attribute fecEnabled : Boolean = true;
        attribute crcEnabled : Boolean = true;

        attribute reconfigurableInOrbit : Boolean = true;
    }

    item def CommsAnomaly { attribute type : String; }
    port def commsAnomalyOutPort { out item anomalyOut : CommsAnomaly; }

    part def CommunicationsSystem {
        port commsPowerIn : powerBus;
        port tcToOBDH : groundCommandPort;
        port hkFromOBDH : obdhStatusInPort;
        port hkStatusToOBDH : commsStatusOutPort;
        port rfLink : rfLinkPort;
        port anomalyToOBDH : commsAnomalyOutPort;

        part antenna : Antenna;
        part trx : Transceiver;

        attribute supportsAllMissionPhases : Boolean = true;
        attribute hasRedundancyOrFailSafe : Boolean = false;
        attribute worstCaseLinkMargin_dB : Real;
        attribute rfEmissionsCompliant : Boolean = true;
        attribute emcCompliant : Boolean = true;
        attribute beaconEnabled : Boolean = true;
        attribute beaconContainsVitalTelemetry : Boolean = true;
        attribute supportsE2ETestWithEGSE : Boolean = true;
        attribute supportsOverTheAirQualificationTest : Boolean = true;

        // Actions
        perform action txHK : TransmitStatusDownlink;
        perform action rxTC : ReceiveGroundTelecommand;
        perform action health : ReportCommsHealth;
        perform action beacon : TransmitBeacon;
        perform action logAnomaly : LogCommsAnomaly;

        // Binds (keep your original wiring)
        bind txHK.hkIn = hkFromOBDH.hkIn;
        bind rfLink.rfOut = txHK.rfOut;
        bind rxTC.rfIn = rfLink.rfIn;
        bind tcToOBDH.cmdOut = rxTC.cmdOut;
        bind hkStatusToOBDH.statusOut = health.status;
        bind anomalyToOBDH.anomalyOut = logAnomaly.anomaly;

    }
}
