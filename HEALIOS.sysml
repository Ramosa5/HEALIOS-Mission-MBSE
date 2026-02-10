package HEALIOS {
    // make the package itself appear as a member


    // and still import its contents for unqualified use
    public import MissionPackage::**;

    part HEALIOS_System : MissionSegments {
        part Space_Segment redefines Space_Segment {
            :>> EPS {
                :>> Eps_Command_In;
                :>> Eps_Telemetry_Out;
                :>> Power_Bus_5V;
                :>> Power_Bus_3V3;

                :>> Deployable_Solar_Arrays [2] {
                    :>> Name = "2-panel EXA DMSA";
                    :>> Mass = 0.07 [SI::kg];
                    :>> Power_Generation = 20 [SI::W]; // tba
                }

                :>> Mounted_Solar_Cells [1] {
                    :>> Name = "AZUR SPACE 3G30-Advanced 4x8";
                    :>> Mass = 0.036 [SI::kg];
                    :>> Power_Generation = 5 [SI::W]; // tba
                }

                :>> Battery_Pack_EPS {
                    :>> Name = "NanoPower BP4";
                    :>> Capacity = 34 [SI::W * SI::h]; // tbc
                    :>> Max_Power_Generation = 25 [SI::W]; // tba
                    :>> Mass = 0.258 [SI::kg]; // tba

                    :>> Main_Heater {
                        :>> Name = "NanoPower BP4 - Resistance Heating Element";
                        :>> Power = 3.5 [SI::W];
                    }

                    :>> Battery_Pack_Connector {
                        :>> Name = "Molex 43045-0600";
                    }

                    :>> Temp_Sensor {
                        :>> Name = "NanoPower BP4 - TE TMP121";
                        :>> Mass = 0.00 [SI::kg];
                        :>> Power = 0.0 [SI::W];
                    }
                }
            }

            :>> PL { // tba
                :>> Cmd_In;
                :>> Status_Out;

                // --- POWER FILTERING BLOCK ---
                :>> Power_Filtering_Block {
                    :>> Power_Filter {
                        attribute Selected_Part_Number : String = "TI TPS7A4501-SEP";
                    }
                }

                // --- SOLAR CELLS BLOCK ---
                :>> Solar_Cells_Block {
                    :>> Psc_Connector_And_Protection {
                        :>> Name = "Molex 43045-0600";
                        // :>> Mass = 0.0 [SI::kg];
                    }

                    :>> Perovskite_Solar_Array_Coupon [1] {
                        :>> Name = "Perovskite sample coupon";
                        :>> Manufacturer = "TBD";
                    }

                    :>> Reference_Silicon_Solar_Array_Coupon [1] {
                        :>> Name = "Reference silicon coupon";
                        // :>> Mass = 0.0 [SI::kg];
                        // :>> Power_Generation = 0.0 [SI::W];
                    }
                }

                // --- MPPT BLOCK ---
                :>> Mppt_Block {
                    :>> Mppt_Controller [1] {
                        :>> Name = "TBD MPPT";
                        :>> Mass = 0.0 [SI::kg];
                    }
                    :>> Power_Dump_Resistor [1] {
                        attribute Selected_Part_Number : String = "TBD";
                    }
                }

                // --- IV SWEEP + REVERSE BIAS BLOCK ---
                :>> Iv_Sweep_And_Reverse_Bias_Block {
                    :>> Iv_Sweep_Load_Shunt_Resistor [1] {
                        attribute Selected_Part_Number : String = "WSL2512R1000FEA";
                    }

                    :>> Iv_Sweep_Load_MOSFET [1] {
                        attribute Selected_Part_Number : String = "BSC320N20NS3G";
                    }

                    :>> Iv_Sweep_Load_OpAmp [1] {
                        attribute Selected_Part_Number : String = "TI OPA197";
                    }

                    :>> Iv_Sweep_Load_DAC [1] {
                        attribute Selected_Part_Number : String = "MCP4728";
                    }

                    :>> Current_And_Voltage_Sensing_Block [1] {
                        attribute Selected_Part_Number : String = "INA226";
                    }
                }

                // --- ENVIRONMENT SENSORS BLOCK ---
                :>> Env_Sensors_Block {
                    :>> Temperature_Sensor_At_Environment {
                        :>> Name = "PTC thin-film platinum Resistance Temperature Detector (Pt1k0)";
                        :>> Mass = 0.0025 [SI::kg];
                        :>> Power = 0.09 [SI::W];
                    }

                    :>> Irradiance_Sensor_Block {
                        attribute Selected_Part_Number : String = "Hamamatsu S1223-01";
                    }

                    :>> Radiation_Dose_Sensor {
                        attribute Selected_Part_Number : String = "Varadis VT02 RADFET";
                    }

                    :>> Spectrometer {
                        attribute Selected_Part_Number : String = "Hamamatsu C12880MA";
                    }
                }
            }
        }
    }
}
