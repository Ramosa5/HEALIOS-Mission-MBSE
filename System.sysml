package HEALIOS {
    public import ScalarValues::*;
    public import ISQ::*;
    public import Stakeholders_and_Concerns::*;
    public import Environment::*;
    public import HEALIOS_Functions::*;
    private import ElectricalPowerSystemPackage::*;
    private import PayloadPackage::*;
    private import ThermalControlSystemPackage::*;
    private import OnBoardDataHandlingSystemPackage::*;
    private import CommunicationsSystemPackage::*;
    private import StructureSystemPackage::*;
    private import AttitudeAndOrbitControlSystemPackage::*;
    public part def Software;
    private import GroundStationPackage::*;
    private import DataCenterPackage::*;
    private import ControlCenterPackage::*;
    
    // --- 3. Define the Detailed Space Segment ---
    public part def SpaceSegment {

        // A. Attributes
        
        attribute totalMass : ISQ::MassValue;

        // B. Subsystems
        part <TCS> SS_Thermal_Control_System : ThermalControlSystem;
        part <COMMS> SS_Communication_System : CommunicationsSystem;
        part <EPS> SS_Electrical_Power_System
            : ElectricalPowerSystemPackage::ElectricalPowerSystem [1];
        part <OBDH> SS_On_Board_Data_Handling : OnBoardDataHandlingSystem;
        part <STR> SS_Structure_And_Mechanisms : StructureSystem;
        part <AOCS> SS_Attitude_And_Orbit_Control_System : AttitudeAndOrbitControlSystem;
        part <PL> SS_Satellite_Payload : Payload;

        in port satelliteSolarEnvironment : SolarEnvironment {
            in item measuredRadiation : Real;
            in item measuredSpectrum : Real;
            in item measuredAngleBeta : Real;
        }
    }

    // --- 4. Ground Segment Placeholder ---
    public part def GroundSegment{
        part <GST> Ground_Station : GroundStation;
        part <MCC> Mission_Control_Centre : MissionControlCenter;
        part <DT> Data_Centre : DataCenter;         
    }

    // --- 5. The Complete System ---
    public part def HEALIOS_System {
        public part <SS> HEALIOS_Space_Segment : SpaceSegment {
            :>> totalMass = 1.81 [SI::kg];
        }
        public part <GS> HEALIOS_Ground_Segment : GroundSegment;

        attribute missionName : String = "HEALIOS";
        attribute missionDuration : ISQ::DurationValue = 365 [SI::day];
        attribute orbitType : String = "LEO";

        perform action performScience : PerformScienceOperations;
        perform action operateSystem : OperateSystem;
        perform action maintainOperability : MaintainOperability;
        
        connect sunEntity.sunSolarEnvironment to HEALIOS_Space_Segment.satelliteSolarEnvironment;

    }
    
    part HEALIOS_System_entity : HEALIOS_System {
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
            :>> PL { //tba
                :>> cmdIn;
                :>> statusOut;

                // --- POWER FILTERING BLOCK ---
                :>> powerFilteringBlock {
                    :>> powerFilter {
                        attribute selectedPartNumber : String = "TI TPS7A4501-SEP";
                    }
                }

                // --- SOLAR CELLS BLOCK ---
                :>> solarCellsBlock {

                    :>> pscConnectorAndProtection {
                        :>> name = "Molex 43045-0600";
                        // mass możesz dopisać jeśli znasz:
                        // :>> mass = 0.0 [SI::kg];
                    }

                    // Jeśli chcesz też nazwać kupony (opcjonalnie – podałeś wcześniej tylko COTS dla DAQ)
                    :>> perovskiteSolarArrayCoupon[1] {
                        :>> name = "Perovskite sample coupon";
                        :>> manufacturer = "TBD";
                    }

                    :>> referenceSiliconSolarArrayCoupon[1] {
                        :>> name = "Reference silicon coupon";
                        // SolarArray ma u Ciebie name/mass/powerGeneration w EPS pakiecie,
                        // więc możesz wypełnić jeśli chcesz:
                        // :>> mass = 0.0 [SI::kg];
                        // :>> powerGeneration = 0.0 [SI::W];
                    }
                }

                // --- MPPT BLOCK (jeśli masz konkretne MPPT i rezystory – możesz dopisać COTS) ---
                :>> mpptBlock {
                    :>> mpptController[1] { :>> name = "TBD MPPT"; :>> mass = 0.0 [SI::kg]; }
                    :>> powerDumpResistor[1] { attribute selectedPartNumber : String = "TBD"; }
                }

                // --- IV SWEEP + REVERSE BIAS BLOCK ---
                :>> ivSweepAndReverseBiasBlock {

                    :>> ivSweepLoadShuntResistor[1] {
                        attribute selectedPartNumber : String = "WSL2512R1000FEA";
                    }

                    :>> ivSweepLoadMOSFET[1] {
                        attribute selectedPartNumber : String = "BSC320N20NS3G";
                    }

                    :>> ivSweepLoadOpAmp[1] {
                        attribute selectedPartNumber : String = "TI OPA197";
                    }

                    :>> ivSweepLoadDAC[1] {
                        attribute selectedPartNumber : String = "MCP4728";
                    }

                    :>> currentAndVoltageSensingBlock[1] {
                        attribute selectedPartNumber : String = "INA226";
                    }
                }

                // --- ENVIRONMENT SENSORS BLOCK ---
                :>> envSensorsBlock {
                    :>> temperatureSensorAtEnvironment {
                        // TemperatureSensor jest z EPS (ma name/mass/power)
                        :>> name = "TE TSYS03";
                        :>> mass = 0.0 [SI::kg];
                        :>> power = 0.0 [SI::W];
                    }

                    :>> irradianceSensorBlock {
                        attribute selectedPartNumber : String = "Hamamatsu S1223-01";
                    }

                    :>> radiationDoseSensor {
                        attribute selectedPartNumber : String = "Varadis VT02 RADFET";
                    }

                    :>> spectrometer {
                        attribute selectedPartNumber : String = "Hamamatsu C12880MA";
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
