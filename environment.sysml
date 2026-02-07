private import ScalarValues::*;

package Environment {

  item def SolarSpectrum {
    wavelength : Real; // in nm
    intensity : Real; // in W/m^2/nm
  }

  item def SolarRadiation {
    value : Real; // in W/m^2
  }

  item def SolarAngle {
    angle : Real; // in degrees
  }

  port def SolarEnvironment {
    out item radiation : SolarRadiation;
    out item spectrum : SolarSpectrum;
    out item angleBeta : SolarAngle;
  }

  part def Sun {
    attribute visible : Boolean;
    out port sunSolarEnvironment : SolarEnvironment;
  }

  part sunEntity : Sun; // do zmiany nazwa
}
