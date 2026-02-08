package HEALIOS {
    public import ScalarValues::*;
    public import ISQ::*;
    public import Stakeholders_and_Concerns::*;
    public import Environment::*;
    public import HEALIOS_Functions::*;
    private import ElectricalPowerSystemPackage::*;
    private import PayloadPackage::*;
    private import TCSPackage::*;
    public part def Software;

    // --- 3. Define the Detailed Space Segment ---
    public part def SpaceSegment {

        // A. Attributes
        
        attribute totalMass : ISQ::MassValue;

        // B. Subsystems
        part SS_Thermal_Control_System : ThermalControlSystem;
        part <COMMS> SS_Communication_System : CommunicationSystem;
        part <EPS> SS_Electrical_Power_System[1] : ElectricalPowerSystemPackage::ElectricalPowerSystem;
        part <OBDH> SS_On_Board_Data_Handling : OnBoardDataHandling;
        part <STR> SS_Structure_And_Mechanisms : StructureAndMechanisms;
        part <DAQ> SS_Data_Acquisition : DataAcquisition;
        part <AOCS> SS_Attitude_And_Orbit_Control_System : AttitudeAndOrbitControlSystem;
        part <SPL> SS_Satellite_Payload : Payload;

        in port satelliteSolarEnvironment : SolarEnvironment{
            in item measuredRadiation : Real;
            in item measuredSpectrum : Real;
            in item measuredAngleBeta : Real;
        }
    }

    // --- 4. Ground Segment Placeholder ---
    public part def GroundSegment{
        part <GST> Ground_Station : GroundStation;
        part <MCC> Mission_Operations_Centre : MissionOperationsCentre;

            attribute reusePriority : Boolean;
            }

    // --- 5. The Complete System ---
    public part def HEALIOS_System {
        public part <SS> HEALIOS_Space_Segment : SpaceSegment {
            :>> totalMass = 1.81 [SI::kg];
        }
        public part <GS> HEALIOS_Ground_Segment : GroundSegment{
            :>> reusePriority = true;
        }

        attribute missionName : String = "HEALIOS";
        attribute missionDuration : ISQ::DurationValue = 365 [SI::day];
        attribute orbitType : String = "LEO";

        perform action performScience : PerformScienceOperations;
        perform action operateSystem : OperateSystem;
        perform action maintainOperability : MaintainOperability;
        
        connect sunEntity.sunSolarEnvironment to HEALIOS_Space_Segment.satelliteSolarEnvironment;

    }
    
    part HEALIOS_System_entity : HEALIOS_System{
        :>> HEALIOS_Space_Segment {
            :>> EPS {
                :>> epsCommandIn;
                :>> epsTelemetryOut;
                :>> powerBus5V;
                :>> powerBus3V3;

                :>>deployableSolarArrays[2] {
                    :>> name = "2-panel EXA DMSA";
                    :>> mass = 0.07 [SI::kg];
                    :>> powerGeneration = 20 [SI::W];  //tba
                }

                :>> mountedSolarCells[1] {
                    :>> name = "AZUR SPACE 3G30-Advanced 4x8";
                    :>> mass = 0.036 [SI::kg];
                    :>> powerGeneration = 5 [SI::W]; // tba
                }
                
                :>> batteryPackEPS {
                    :>> name = "NanoPower BP4";
                    :>> capacity = 34 [SI::W * SI::h]; // tbc
                    :>> maxPowerGeneration = 25 [SI::W]; // tba
                    :>> mass = 0.258 [SI::kg]; // tba
                    :>> mainHeater {
                        :>> name = "NanoPower BP4 - Resistance Heating Element";
                        :>> power = 3.5 [SI::W];
                    }
                    :>> connector {
                        :>> name = "Molex 43045-0600";
                    }   
                    :>> tempSensor {
                        :>> name = "NanoPower BP4 - TE TMP121";
                        :>> mass = 0.00 [SI::kg];
                        :>> power = 0.0 [SI::W];
                    }
                }
            }
            :>> SPL {
                :>> cmdIn;
                :>> statusOut;

                :>> powerFilteringUnit { :>> name = "TI TPS7A4501-SEP"; }

                :>> pscConnectorAndProtection {
                    :>> name = "Molex 43045-0600";
                }

                :>> ivSweepLoad_Shunt {
                    :>> name = "WSL2512R1000FEA";
                }

                :>> ivSweepLoad_MOSFET {
                    :>> name = "BSC320N20NS3G";
                }

                :>> ivSweepLoad_OpAmp {
                    :>> name = "TI OPA197";
                }

                :>> ivSweepLoad_DAC {
                    :>> name = "MCP4728";
                }

                :>> cellIVSensing {
                    :>> name = "INA226";
                }

                :>> envSensors {
                    :>> temperatureSensorsAtEnvironment {
                        :>> name = "TE TSYS03";
                    }

                    :>> irradianceSensorBlock {
                        :>> name = "Hamamatsu S1223-01";
                    }

                    :>> radiationDoseSensor {
                        :>> name = "Varadis VT02 RADFET";
                    }

                    :>> spectrometer {
                        :>> name = "Hamamatsu C12880MA";
                    }
                }
            }
        }
    }


    // itemy tutaj ktore wystepuja w systemie
    item def OnBoardCommand{
        attribute type : String;
    }

    item def OnBoardStatus{
        attribute type : String;
    }

    item def GroundCommand{
        attribute type : String;
    }

    item def TelemetryData{
        attribute type : String;
    }

}
