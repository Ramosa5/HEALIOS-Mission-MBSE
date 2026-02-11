private import ScalarValues::*;
private import StructureSystemPackage::*;

package EnvironmentPackage {

  item def SolarSpectrum {
    Wavelength : Real; // in nm
    Intensity : Real;  // in W/m^2/nm
  }

  item def SolarRadiation {
    Value : Real; // in W/m^2
  }

  item def SolarAngle {
    Angle : Real; // in degrees
  }

  port def StellarEnvironment {
    out item Radiation : SolarRadiation;
    out item Spectrum : SolarSpectrum;
    out item Angle_Beta : SolarAngle;
  }

  part def Star {
    attribute Visible : Boolean;
    out port Stellar_Environment : StellarEnvironment;
  }
}

package LaunchEnvironment {

  port def DispenserContactInterface;

  port def MechanicalAdapterInterface;

  part def Launcher {
    attribute Name : String;
    attribute Payload_Capacity : ISQ::MassValue;
    attribute Launch_Site : String;

    port Payload_Adapter : MechanicalAdapterInterface;
  }

  part def CubeSatDispenser {
    attribute Name : String;
    attribute Status : String;
    
    port Mounting_Plate : ~MechanicalAdapterInterface;
    port Deployment_Slot : DispenserContactInterface;
  }
}

package ManagementEnvironment {

  part def Report {
    attribute Approved : Boolean;
  }

  part def PhaseBaseline {
    attribute PhaseName : String;
    attribute Date : String;

    out item BaselineReport : Report;
  }

  part def Phase {
    attribute Name : String;
    attribute StartDate : String;
    attribute EndDate : String;

    out item PhaseReport : Report;
  }

  part def MissionDocumentation {
    in item ReportItem : Report [0..*];
  }

}
