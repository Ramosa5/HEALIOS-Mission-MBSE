private import ScalarValues::*;
private import StructureSystemPackage::*;

package Environment {

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

  port def SolarEnvironment {
    out item Radiation : SolarRadiation;
    out item Spectrum : SolarSpectrum;
    out item Angle_Beta : SolarAngle;
  }

  part def Sun {
    attribute Visible : Boolean;
    out port Sun_Solar_Environment : SolarEnvironment;
  }

  part Sun_Entity : Sun;
}

package LaunchEnvironment {

  port def DispenserContactInterface;

  part def Launcher {
    attribute Name : String;
    attribute Payload_Capacity : ISQ::MassValue;
    attribute Launch_Site : String;
  }

  part def CubeSatDispenser {
    attribute Name : String;
    attribute Status : String;

    port Mounting_Port : DispenserContactInterface;
  }

}
