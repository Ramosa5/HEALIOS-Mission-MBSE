package HealiosMissionInstancePackage {
    // Instance model only: reuse existing definitions from the project
    public import MissionPackage::*;
    public import UnitTypesPackage::*;
    public import SI::*;
    public import ISQ::*;
    public import ScalarValues::*;
    public import SpaceActionsPackage::*; // for Enter_Safe_Mode_Action

    public part Healios_Mission : MissionPackage::MissionSegments {
        doc
        /* HEALIOS mission instance (system-of-systems: Space Segment + Ground Segment).
         * Added missing Payload internal blocks and sensor subparts according to the
         * product tree sheet (Task Management - Product Tree SS.pdf).
         *
         * IMPORTANT:
         * - This file only instantiates/redefines what already exists in the model defs.
         * - "connect" statements that mirror type-level connections may duplicate connectors
         *   in some tools. If you see duplicates, delete the mirrored connects and keep
         *   the port/part redefinitions.
         */

        // =========================
        // Mission-level refinements
        // =========================
        attribute missionName redefines missionName = "HEALIOS";
        attribute missionDuration redefines missionDuration = 1 [UnitTypesPackage::yr];
        attribute orbitType redefines orbitType = "LEO (~550 km, ~55 deg inclination)";

        // Mirror the MissionSegments-level environment connection for visibility
        connect Sun_Entity.Sun_Solar_Environment to HEALIOS_Space_Segment.satelliteSolarEnvironment;

        // =========================
        // Space segment refinements
        // =========================
        part HEALIOS_Space_Segment redefines Space_Segment {
            state Satellite_Mode redefines Satellite_Mode;

            attribute Total_Mass redefines Total_Mass = 2.0 [SI::kg];
            attribute CubeSat_Form_Factor redefines CubeSat_Form_Factor = "1U";
            attribute Center_Of_Mass redefines Center_Of_Mass = "TBD (set after CAD mass properties)";

            // --- Ports (explicitly redefined for SysIDE visibility) ---
            in port satelliteSolarEnvironment redefines satelliteSolarEnvironment;
            port Satellite_Command_Port redefines Satellite_Command_Port;

            // --- EPS ---
            part SS_Electrical_Power_System redefines SS_Electrical_Power_System {
                // top-level EPS ports
                port EPS_I2C redefines EPS_I2C;
                port Eps_Command_In redefines Eps_Command_In;
                port Eps_Telemetry_Out redefines Eps_Telemetry_Out;
                port Power_Bus_5V redefines Power_Bus_5V;
                port Power_Bus_3V3 redefines Power_Bus_3V3;
                port Heater_Power_Bus redefines Heater_Power_Bus;

                // Exists in EPS model
                part Deployable_Solar_Arrays redefines Deployable_Solar_Arrays;

                part Battery_Pack_EPS redefines Battery_Pack_EPS {
                    attribute Name redefines Name = "Li-ion Battery Pack";
                    attribute Mass redefines Mass = 0.30 [SI::kg];
                    attribute PowerConsumption redefines PowerConsumption = 0.0 [SI::W];

                    attribute Capacity redefines Capacity = 30.0 [SI::W * h];
                    attribute Max_Power_Generation redefines Max_Power_Generation = 10.0 [SI::W];

                    part Main_Heater redefines Main_Heater {
                        attribute Name redefines Name = "Battery Heater";
                        attribute Mass redefines Mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines PowerConsumption = 2.0 [SI::W];
                        attribute Power redefines Power = 2.0 [SI::W];
                        attribute Minimal_Temperature redefines Minimal_Temperature = 273.15 [SI::K];
                    }

                    part Temp_Sensor redefines Temp_Sensor {
                        attribute Name redefines Name = "Battery Temp Sensor";
                        attribute Mass redefines Mass = 0.005 [SI::kg];
                        attribute PowerConsumption redefines PowerConsumption = 0.05 [SI::W];
                        attribute Power redefines Power = 0.05 [SI::W];
                    }
                }

                part Bus_5V redefines Bus_5V {
                    attribute Name redefines Name = "EPS_5V_REG";
                }

                part Bus_3V3 redefines Bus_3V3 {
                    attribute Name redefines Name = "EPS_3V3_REG";
                }
            }

            // --- OBDH ---
            part SS_On_Board_Data_Handling redefines SS_On_Board_Data_Handling {
                // top-level OBDH ports
                port Telecommand_In redefines Telecommand_In;
                port Telemetry_Out redefines Telemetry_Out;
                port Out_Command_Port redefines Out_Command_Port;

                port EPS_I2C redefines EPS_I2C;
                port Magnetorquer_Board_I2C redefines Magnetorquer_Board_I2C;
                port Temperature_Sensor_I2C redefines Temperature_Sensor_I2C;
                port Sun_Sensor_I2C redefines Sun_Sensor_I2C;
                port Irradiance_Sensor_I2C redefines Irradiance_Sensor_I2C;
                port Radiation_Sensor_I2C redefines Radiation_Sensor_I2C;
                port Spectrometer_I2C redefines Spectrometer_I2C;
                port Voltage_Current_Sense_I2C redefines Voltage_Current_Sense_I2C;
                port UHF_I2C redefines UHF_I2C;

                part Carrier redefines Carrier {
                    attribute Name redefines Name = "OBC Carrier Board";
                }

                part Primary_OBC redefines Primary_OBC {
                    attribute Name redefines Name = "Primary OBC";
                    attribute Role redefines Role = "Command & Data Handling (Primary)";
                    attribute Warm_Redundant redefines Warm_Redundant = true;

                    part NVM redefines NVM { attribute Total_Memory redefines Total_Memory = 8.0; }
                    part RAM redefines RAM { attribute Total_Memory redefines Total_Memory = 2.0; }
                }

                part Secondary_OBC redefines Secondary_OBC {
                    attribute Name redefines Name = "Secondary OBC";
                    attribute Role redefines Role = "Command & Data Handling (Warm Redundant)";
                    attribute Warm_Redundant redefines Warm_Redundant = true;

                    part NVM redefines NVM { attribute Total_Memory redefines Total_Memory = 8.0; }
                    part RAM redefines RAM { attribute Total_Memory redefines Total_Memory = 2.0; }
                }
            }

            // --- Communications ---
            part SS_Communication_System redefines SS_Communication_System {
                // top-level comms ports
                port commsPowerIn redefines commsPowerIn;
                port tcToOBDH redefines tcToOBDH;
                port hkFromOBDH redefines hkFromOBDH;
                port hkStatusToOBDH redefines hkStatusToOBDH;
                port rfLink redefines rfLink;
                port anomalyToOBDH redefines anomalyToOBDH;

                attribute supportsAllMissionPhases redefines supportsAllMissionPhases = true;
                attribute hasRedundancyOrFailSafe redefines hasRedundancyOrFailSafe = false;
                attribute worstCaseLinkMargin_dB redefines worstCaseLinkMargin_dB = 3.0;

                attribute beaconEnabled redefines beaconEnabled = true;
                attribute beaconContainsVitalTelemetry redefines beaconContainsVitalTelemetry = true;

                part antenna redefines antenna {
                    attribute name redefines name = "UHF Antenna";
                    attribute band redefines band = "UHF";
                    attribute gain redefines gain = 2.0;
                }

                part trx redefines trx {
                    attribute name redefines name = "UHF Transceiver";
                    attribute maxTxPower redefines maxTxPower = 1.0 [SI::W];
                    attribute dopplerToleranceHz redefines dopplerToleranceHz = 20000.0;
                    attribute modulationCoding redefines modulationCoding = "GMSK (TBD)";
                    attribute packetFormat redefines packetFormat = "AX.25 (TBD)";
                    attribute fecEnabled redefines fecEnabled = true;
                    attribute crcEnabled redefines crcEnabled = true;
                    attribute reconfigurableInOrbit redefines reconfigurableInOrbit = true;
                }

                part crypto redefines crypto {
                    attribute name redefines name = "Comms Crypto/Integrity";
                    attribute uplinkAuthEnabled redefines uplinkAuthEnabled = true;
                    attribute uplinkDecryptEnabled redefines uplinkDecryptEnabled = true;
                    attribute downlinkEncryptEnabled redefines downlinkEncryptEnabled = true;
                    attribute downlinkIntegrityEnabled redefines downlinkIntegrityEnabled = true;
                }
            }

            // --- Structure ---
            part SS_Structure_And_Mechanisms redefines SS_Structure_And_Mechanisms {
                attribute Total_Mass redefines Total_Mass = 0.40 [SI::kg];
                attribute Material redefines Material = "Aluminium (TBD alloy)";

                // From StructureSystem.sysml (deployment switches etc.)
                part Primary_Structure redefines Primary_Structure;
                part Secondary_Structure redefines Secondary_Structure;
                part Deployment_Switches redefines Deployment_Switches;
            }

            // --- AOCS ---
            part SS_Attitude_And_Orbit_Control_System redefines SS_Attitude_And_Orbit_Control_System {
                // AOCS ports
                port AOCS_Command_In redefines AOCS_Command_In;

                attribute Nominal_Force redefines Nominal_Force = 0.02 [SI::N];
                attribute Stop_Signal redefines Stop_Signal = false;

                part Sun_Sensor redefines Sun_Sensor [1] {
                    attribute Name redefines Name = "Sun Sensor";
                    attribute Mass redefines Mass = 0.01 [SI::kg];
                    attribute PowerConsumption redefines PowerConsumption = 0.05 [SI::W];
                    port Power_Bus_In_3V3 redefines Power_Bus_In_3V3;
                }

                part Magnetorquer_Board redefines Magnetorquer_Board [1] {
                    port Power_Bus_In_5V redefines Power_Bus_In_5V;
                    port Magnetorquer_Board_I2C redefines Magnetorquer_Board_I2C;

                    part Mounted_Magnetorquer_X redefines Mounted_Magnetorquer [1] {
                        attribute Name redefines Name = "MTQ_X";
                        attribute Axis redefines Axis = "X";
                        attribute Force redefines Force = 0.02 [SI::N];
                        attribute Mass redefines Mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines PowerConsumption = 0.2 [SI::W];
                    }

                    part Mounted_Magnetorquer_Y redefines Mounted_Magnetorquer [2] {
                        attribute Name redefines Name = "MTQ_Y";
                        attribute Axis redefines Axis = "Y";
                        attribute Force redefines Force = 0.02 [SI::N];
                        attribute Mass redefines Mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines PowerConsumption = 0.2 [SI::W];
                    }

                    part Mounted_Magnetorquer_Z redefines Mounted_Magnetorquer [3] {
                        attribute Name redefines Name = "MTQ_Z";
                        attribute Axis redefines Axis = "Z";
                        attribute Force redefines Force = 0.02 [SI::N];
                        attribute Mass redefines Mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines PowerConsumption = 0.2 [SI::W];
                    }
                }
            }

            // --- Thermal ---
            part SS_Thermal_Control_System redefines SS_Thermal_Control_System {
                port Command_IN redefines Command_IN;
                attribute Stop_Signal redefines Stop_Signal;
            }

            // --- Payload (ADDED missing internal blocks + sensors) ---
            part SS_Satellite_Payload redefines SS_Satellite_Payload {

                // Payload integration ports (exist in Payload.sysml)
                port Cmd_In redefines Cmd_In;
                port Status_Out redefines Status_Out;

                // Missing internal blocks from Payload.sysml
                part Power_Filtering_Block redefines Power_Filtering_Block {
                    port Power_Bus_In_3V3 redefines Power_Bus_In_3V3;
                    port Power_Bus_In_5V redefines Power_Bus_In_5V;
                    port Power_Bus_Filtered_5V redefines Power_Bus_Filtered_5V;
                    port Power_Bus_Filtered_3V3 redefines Power_Bus_Filtered_3V3;

                    part Power_Filter redefines Power_Filter;
                }

                part Mppt_Block redefines Mppt_Block {
                    port Power_Bus_Filtered_3V3 redefines Power_Bus_Filtered_3V3;
                    part Mppt_Controller redefines Mppt_Controller;
                    part Power_Dump_Resistor redefines Power_Dump_Resistor;
                }

                part Iv_Sweep_And_Reverse_Bias_Block redefines Iv_Sweep_And_Reverse_Bias_Block {
                    port Power_Bus_Filtered_5V redefines Power_Bus_Filtered_5V;

                    part Iv_Sweep_Load_Shunt_Resistor redefines Iv_Sweep_Load_Shunt_Resistor;
                    part Iv_Sweep_Load_MOSFET redefines Iv_Sweep_Load_MOSFET;
                    part Iv_Sweep_Load_OpAmp redefines Iv_Sweep_Load_OpAmp;
                    part Iv_Sweep_Load_DAC redefines Iv_Sweep_Load_DAC;

                    part Current_And_Voltage_Sensing_Block redefines Current_And_Voltage_Sensing_Block {
                        port Voltage_Current_Sense_I2C redefines Voltage_Current_Sense_I2C;
                    }
                }

                part Env_Sensors_Block redefines Env_Sensors_Block {
                    port Power_Bus_Filtered_3V3 redefines Power_Bus_Filtered_3V3;

                    port Temp_Out redefines Temp_Out;
                    port Irr_Out redefines Irr_Out;
                    port Rad_Out redefines Rad_Out;
                    port Spec_Out redefines Spec_Out;

                    part Temperature_Sensor_At_Environment redefines Temperature_Sensor_At_Environment {
                        port Temperature_Port redefines Temperature_Port;
                    }

                    part Irradiance_Sensor_Block redefines Irradiance_Sensor_Block {
                        port Irradiance_Sensor_I2C redefines Irradiance_Sensor_I2C;
                    }

                    part Radiation_Dose_Sensor redefines Radiation_Dose_Sensor {
                        port Radiation_Sensor_I2C redefines Radiation_Sensor_I2C;
                    }

                    part Spectrometer redefines Spectrometer {
                        port Spectrometer_Sensor_I2C redefines Spectrometer_Sensor_I2C;
                    }
                }

                // Existing solar-cells block (kept)
                part Solar_Cells_Block redefines Solar_Cells_Block {
                    part Psc_Connector_And_Protection redefines Psc_Connector_And_Protection {
                        attribute Name redefines Name = "Perovskite Coupon Protection";
                        attribute Mass redefines Mass = 0.05 [SI::kg];
                    }

                    part Perovskite_Solar_Array_Coupon redefines Perovskite_Solar_Array_Coupon [1] {
                        attribute Name redefines Name = "PSC Coupon #1";
                        attribute Mass redefines Mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines PowerConsumption = 0.0 [SI::W];
                        attribute Power_Generation redefines Power_Generation = 1.0 [SI::W];
                        attribute Manufacturer redefines Manufacturer = "TBD";
                    }

                    part Reference_Silicon_Solar_Array_Coupon
                        redefines Reference_Silicon_Solar_Array_Coupon [1] {
                        attribute Name redefines Name = "Si Reference Coupon #1";
                        attribute Mass redefines Mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines PowerConsumption = 0.0 [SI::W];
                        attribute Power_Generation redefines Power_Generation = 1.0 [SI::W];
                    }
                }
            }

            // --- Mirror SpaceSegment connect statements for visibility ---
            connect SS_Electrical_Power_System.EPS_I2C to SS_On_Board_Data_Handling.EPS_I2C;

            connect SS_Satellite_Payload.Env_Sensors_Block.Temperature_Sensor_At_Environment.Temperature_Port
                to SS_On_Board_Data_Handling.Temperature_Sensor_I2C;

            connect SS_Satellite_Payload.Env_Sensors_Block.Irradiance_Sensor_Block.Irradiance_Sensor_I2C
                to SS_On_Board_Data_Handling.Irradiance_Sensor_I2C;

            connect SS_Satellite_Payload.Env_Sensors_Block.Radiation_Dose_Sensor.Radiation_Sensor_I2C
                to SS_On_Board_Data_Handling.Radiation_Sensor_I2C;

            connect SS_Satellite_Payload.Env_Sensors_Block.Spectrometer.Spectrometer_Sensor_I2C
                to SS_On_Board_Data_Handling.Spectrometer_I2C;

            connect SS_Satellite_Payload.Iv_Sweep_And_Reverse_Bias_Block.Current_And_Voltage_Sensing_Block.Voltage_Current_Sense_I2C
                to SS_On_Board_Data_Handling.Voltage_Current_Sense_I2C;

            connect SS_Attitude_And_Orbit_Control_System.Magnetorquer_Board.Magnetorquer_Board_I2C
                to SS_On_Board_Data_Handling.Magnetorquer_Board_I2C;

            connect SS_Electrical_Power_System.Power_Bus_5V
                to SS_Attitude_And_Orbit_Control_System.Magnetorquer_Board.Power_Bus_In_5V;

            connect SS_Electrical_Power_System.Power_Bus_5V
                to SS_Communication_System.commsPowerIn;

            connect SS_Electrical_Power_System.Power_Bus_3V3
                to SS_Attitude_And_Orbit_Control_System.Sun_Sensor.Power_Bus_In_3V3;

            connect Satellite_Command_Port.Telecommand
                to SS_On_Board_Data_Handling.Telecommand_In;
            connect Satellite_Command_Port.Telemetry
                to SS_On_Board_Data_Handling.Telemetry_Out;

            connect SS_Communication_System.tcToOBDH.cmdOut
                to SS_On_Board_Data_Handling.Telecommand_In;
            connect SS_On_Board_Data_Handling.Telemetry_Out
                to SS_Communication_System.hkFromOBDH.hkIn;

            connect SS_On_Board_Data_Handling.Out_Command_Port
                to SS_Thermal_Control_System.Command_IN;
            connect SS_On_Board_Data_Handling.Out_Command_Port
                to SS_Attitude_And_Orbit_Control_System.AOCS_Command_In;

            // Keep your state refinement as-is
            state HEALIOS_Mode redefines Satellite_Mode {
                entry;
                then Commissioning_Mode;

                state Commissioning_Mode { doc /* The satellite waits for ground command */ }
                state Safe_Mode { doc /* The satellite charges battery and waits for commands */ }
                state Nominal_Sun_Mode { doc /* Nominal operations during sun exposure */ }
                state Nominal_Eclipse_Mode { doc /* Nominal operations during eclipse */ }

                transition Commissioning_To_Nominal
                    first Commissioning_Mode
                    accept Proceed_To_Nominal_Command : GroundCommand via Satellite_Command_Port
                    then Nominal_Sun_Mode;

                transition Sun_To_Eclipse
                    first Nominal_Sun_Mode
                    accept Proceed_To_Eclipse_Command : OnBoardCommand via Satellite_Command_Port
                    then Nominal_Eclipse_Mode;

                transition Eclipse_To_Sun
                    first Nominal_Eclipse_Mode
                    accept Proceed_To_Sun_Command : OnBoardCommand via Satellite_Command_Port
                    then Nominal_Sun_Mode;

                transition Safe_To_Nominal
                    first Safe_Mode
                    accept Proceed_To_Nominal_Command : GroundCommand via Satellite_Command_Port
                    then Nominal_Sun_Mode;

                transition Nominal_Sun_To_Safe
                    first Nominal_Sun_Mode
                    accept Enter_Safe_Mode_Command : OnBoardCommand via Satellite_Command_Port
                    do action Enter_Safe_Mode : SpaceActionsPackage::Enter_Safe_Mode_Action
                    then Safe_Mode;

                transition Nominal_Eclipse_To_Safe
                    first Nominal_Eclipse_Mode
                    accept Enter_Safe_Mode_Command : OnBoardCommand via Satellite_Command_Port
                    do action Enter_Safe_Mode : SpaceActionsPackage::Enter_Safe_Mode_Action
                    then Safe_Mode;
            }
        }

        // ==========================
        // Ground segment refinements
        // ==========================
        part HEALIOS_Ground_Segment redefines Ground_Segment {
            part Ground_Station redefines Ground_Station {
                // GroundStation ports
                port tcFromMCC redefines tcFromMCC;
                port tmToMCC redefines tmToMCC;
                port tmToDataCentre redefines tmToDataCentre;
                port passPlanFromMCC redefines passPlanFromMCC;
                port trackingToMCC redefines trackingToMCC;
                port archiveOut redefines archiveOut;

                part antenna redefines antenna {
                    attribute name redefines name = "UHF Ground Antenna";
                    attribute band redefines band = "UHF";
                    attribute gain redefines gain = 12.0;
                }

                part radio redefines radio {
                    attribute name redefines name = "SDR Ground Radio";
                    attribute supportedBands redefines supportedBands = "UHF/VHF";
                }

                part predictor redefines predictor {
                    attribute name redefines name = "Pass Predictor";
                    attribute usesTLE redefines usesTLE = true;
                }

                part doppler redefines doppler { attribute name redefines name = "Doppler Compensator"; }
                part linkBudget redefines linkBudget { attribute name redefines name = "Link Budget Tool"; }

                part crypto redefines crypto {
                    attribute name redefines name = "Ground Crypto/Integrity";
                    attribute downlinkVerifyEnabled redefines downlinkVerifyEnabled = true;
                    attribute downlinkDecryptEnabled redefines downlinkDecryptEnabled = true;
                    attribute uplinkAuthEnabled redefines uplinkAuthEnabled = true;
                    attribute uplinkEncryptEnabled redefines uplinkEncryptEnabled = true;
                }
            }

            part Mission_Control_Centre redefines Mission_Control_Centre {
                // ports from ControlCenter.sysml
                port tcToGS redefines tcToGS;
                port tmFromGS redefines tmFromGS;
                port passPlanToGS redefines passPlanToGS;
                port trackingFromGS redefines trackingFromGS;

                part auth redefines auth {
                    attribute name redefines name = "MCC Authentication";
                    attribute method redefines method = "MFA (TBD)";
                }

                part console redefines console { attribute name redefines name = "Operations Console"; }

                part planner redefines planner {
                    attribute name redefines name = "Pass Planner";
                    attribute usesTLE redefines usesTLE = true;
                }
            }

            part Data_Centre redefines Data_Centre {
                // ports from DataCenter.sysml
                port tmFromGS redefines tmFromGS;
                port recordsFromGS redefines recordsFromGS;
                port tmProductsToMCC redefines tmProductsToMCC;

                part archive redefines archive {
                    attribute name redefines name = "Structured Archive";
                    attribute retention redefines retention = 1825 [SI::day];
                }

                part validator redefines validator { attribute name redefines name = "Telemetry Validator"; }
            }

            // --- Mirror GroundSegment connect statements for visibility ---
            connect Mission_Control_Centre.tcToGS to Ground_Station.tcFromMCC;
            connect Mission_Control_Centre.passPlanToGS to Ground_Station.passPlanFromMCC;

            connect Ground_Station.tmToMCC to Mission_Control_Centre.tmFromGS;
            connect Ground_Station.trackingToMCC to Mission_Control_Centre.trackingFromGS;

            connect Ground_Station.tmToDataCentre to Data_Centre.tmFromGS;
            connect Ground_Station.archiveOut to Data_Centre.recordsFromGS;

            connect Data_Centre.tmProductsToMCC to Mission_Control_Centre.tmFromGS;
        }
    }
}
