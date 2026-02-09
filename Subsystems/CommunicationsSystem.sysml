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
    }


    part def CommunicationsSystem {
        port commsPowerIn : powerBus;
        port tcToOBDH : groundCommandPort;        
        port hkFromOBDH : obdhStatusInPort;       
        port hkStatusToOBDH : commsStatusOutPort; 
        port rfLink : rfLinkPort;

        part antenna : Antenna;
        part trx : Transceiver;

        perform action txHK : TransmitStatusDownlink;
        perform action rxTC : ReceiveGroundTelecommand;
        perform action health : ReportCommsHealth;

        bind txHK.hkIn = hkFromOBDH.hkIn;
        bind rfLink.rfOut = txHK.rfOut;
        bind rxTC.rfIn = rfLink.rfIn;
        bind tcToOBDH.cmdOut = rxTC.cmdOut;
        bind hkStatusToOBDH.statusOut = health.status;
    }
}
