package CommunicationsSystemPackage {
    private import MissionPackage::*;
    private import ISQ::*;

    // Power input from EPS (optional)
    port def powerBus {
        in voltage : ISQ::SourceVoltageValue;
    }

    // Telecommand received from ground (to be forwarded to OBDH)
    port def groundCommandPort {
        out item cmdOut : MissionPackage::GroundCommand;
    }

    // Downlink data coming from OBDH (housekeeping/status for now)
    port def obdhStatusInPort {
        in item hkIn : MissionPackage::OnBoardStatus;
    }

    // COMMS health/status to OBDH (optional feedback)
    port def commsStatusOutPort {
        out item statusOut : MissionPackage::OnBoardStatus;
    }

    // Abstract RF link
    port def rfLinkPort {
        out item rfOut : Real;
        in item rfIn : Real;
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
    }

    // --- Actions ---
    action def TransmitStatusDownlink {
        in item hkIn : MissionPackage::OnBoardStatus;
        out item rfOut : Real;
    }

    action def ReceiveGroundTelecommand {
        in item rfIn : Real;
        out item cmdOut : MissionPackage::GroundCommand;
    }

    action def ReportCommsHealth {
        out item status : MissionPackage::OnBoardStatus;
    }

    // --- COMMS subsystem ---
    part def CommunicationsSystem {
        port commsPowerIn : powerBus;

        // to/from OBDH
        port tcToOBDH : groundCommandPort;        // COMMS -> OBDH (GroundCommand)
        port hkFromOBDH : obdhStatusInPort;       // OBDH -> COMMS (OnBoardStatus)
        port hkStatusToOBDH : commsStatusOutPort; // COMMS -> OBDH (OnBoardStatus)

        // RF to ground
        port rfLink : rfLinkPort;

        part antenna : Antenna;
        part trx : Transceiver;

        perform action txHK : TransmitStatusDownlink;
        perform action rxTC : ReceiveGroundTelecommand;
        perform action health : ReportCommsHealth;

        // Binds
        bind txHK.hkIn = hkFromOBDH.hkIn;
        bind rfLink.rfOut = txHK.rfOut;

        bind rxTC.rfIn = rfLink.rfIn;
        bind tcToOBDH.cmdOut = rxTC.cmdOut;

        bind hkStatusToOBDH.statusOut = health.status;
    }
}
