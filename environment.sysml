private import ScalarValues::*;

package Environment {

  port def SolarEnvironment {
    out item irradiance : Real;
    out item radiation : Real;
    out item spectrum : Real;
    out item heat : Real;
  }

}
