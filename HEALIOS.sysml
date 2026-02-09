package HEALIOS {
    private import MissionPackage::*;

    part HEALIOS_System : MissionSegments {
        :>> HEALIOS_Space_Segment {
            :>> EPS {
                :>> epsCommandIn;
                :>> epsTelemetryOut;
                :>> powerBus5V;
                :>> powerBus3V3;

                :>> deployableSolarArrays [2] {
                    :>> name = "2-panel EXA DMSA";
                    :>> mass = 0.07 [SI::kg];
                    :>> powerGeneration = 20 [SI::W]; // tba
                }

                :>> mountedSolarCells [1] {
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
            :>> PL { // tba
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
                    :>> perovskiteSolarArrayCoupon [1] {
                        :>> name = "Perovskite sample coupon";
                        :>> manufacturer = "TBD";
                    }

                    :>> referenceSiliconSolarArrayCoupon [1] {
                        :>> name = "Reference silicon coupon";
                        // SolarArray ma u Ciebie name/mass/powerGeneration w EPS pakiecie,
                        // więc możesz wypełnić jeśli chcesz:
                        // :>> mass = 0.0 [SI::kg];
                        // :>> powerGeneration = 0.0 [SI::W];
                    }
                }

                // --- MPPT BLOCK (jeśli masz konkretne MPPT i rezystory – możesz dopisać COTS) ---
                :>> mpptBlock {
                    :>> mpptController [1] {
                        :>> name = "TBD MPPT";
                        :>> mass = 0.0 [SI::kg];
                    }
                    :>> powerDumpResistor [1] { attribute selectedPartNumber : String = "TBD"; }
                }

                // --- IV SWEEP + REVERSE BIAS BLOCK ---
                :>> ivSweepAndReverseBiasBlock {
                    :>> ivSweepLoadShuntResistor [1] {
                        attribute selectedPartNumber : String = "WSL2512R1000FEA";
                    }

                    :>> ivSweepLoadMOSFET [1] {
                        attribute selectedPartNumber : String = "BSC320N20NS3G";
                    }

                    :>> ivSweepLoadOpAmp [1] {
                        attribute selectedPartNumber : String = "TI OPA197";
                    }

                    :>> ivSweepLoadDAC [1] {
                        attribute selectedPartNumber : String = "MCP4728";
                    }

                    :>> currentAndVoltageSensingBlock [1] {
                        attribute selectedPartNumber : String = "INA226";
                    }
                }

                // --- ENVIRONMENT SENSORS BLOCK ---
                :>> envSensorsBlock {
                    :>> temperatureSensorAtEnvironment {
                        // TemperatureSensor jest z EPS (ma name/mass/power)
                        :>> name = "PTC thin-film platinum Resistance Temperature Detector (Pt1k0)";
                        :>> mass = 0.0025 [SI::kg];
                        :>> power = 0.09 [SI::W];
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
}
