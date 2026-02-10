package HealiosMissionInstancePackage {
    // Instance model only: reuse existing definitions from the project
    public import MissionPackage::*;
    public import UnitTypesPackage::*;
    public import SI::*;
    public import ISQ::*;
    public import ScalarValues::*;
    public import SpaceActionsPackage::*;

    public part Healios_Mission : MissionPackage::MissionSegments {
        doc
        /* HEALIOS mission instance (system-of-systems: Space Segment + Ground Segment).
         * This instance explicitly redefines ports and mirrors connects that already
         * exist in the TYPE definitions so SysIDE can render them in instance diagrams.
         */

        // =========================
        // Mission-level refinements
        // =========================
        attribute missionName redefines missionName = "HEALIOS";
        attribute missionDuration redefines missionDuration = 1 [UnitTypesPackage::yr];
        attribute orbitType redefines orbitType = "LEO (~550 km, ~55 deg inclination)";

        // Mirror MissionSegments type connect for visibility
        connect Sun_Entity.Sun_Solar_Environment to HEALIOS_Space_Segment.satelliteSolarEnvironment;

        // =========================
        // Space segment refinements
        // =========================
        part HEALIOS_Space_Segment redefines Space_Segment {
            state Satellite_Mode redefines Satellite_Mode;

            attribute Total_Mass redefines Total_Mass = 2.0 [SI::kg];
            attribute CubeSat_Form_Factor redefines CubeSat_Form_Factor = "1U";
            attribute Center_Of_Mass redefines Center_Of_Mass =
                "TBD (set after CAD mass properties)";

            // --- SpaceSegment external ports ---
            in port satelliteSolarEnvironment redefines satelliteSolarEnvironment;
            port Satellite_Command_Port redefines Satellite_Command_Port;

            // =========================
            // EPS
            // =========================
            part SS_Electrical_Power_System redefines SS_Electrical_Power_System {
                port EPS_I2C redefines EPS_I2C;
                port Eps_Command_In redefines Eps_Command_In;
                port Eps_Telemetry_Out redefines Eps_Telemetry_Out;
                port Power_Bus_5V redefines Power_Bus_5V;
                port Power_Bus_3V3 redefines Power_Bus_3V3;
                port Heater_Power_Bus redefines Heater_Power_Bus;

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

                part Bus_5V redefines Bus_5V { attribute Name redefines Name = "EPS_5V_REG"; }
                part Bus_3V3 redefines Bus_3V3 { attribute Name redefines Name = "EPS_3V3_REG"; }
            }

            // =========================
            // OBDH
            // =========================
            part SS_On_Board_Data_Handling redefines SS_On_Board_Data_Handling {
                // System ports
                port Telecommand_In redefines Telecommand_In;
                port Telemetry_Out redefines Telemetry_Out;
                port Out_Command_Port redefines Out_Command_Port;
                port Power_Bus_In_3V3 redefines Power_Bus_In_3V3;
                port Power_Bus_In_5V :>> Power_Bus_In_5V;

                // I2C buses
                port EPS_I2C redefines EPS_I2C;
                port TCS_I2C redefines TCS_I2C;
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

                    // Ports on the OBC that are wired out in the type definition
                    port EPS_I2C redefines EPS_I2C;
                    port Temperature_Sensor_I2C redefines Temperature_Sensor_I2C;
                    port Magnetorquer_Board_I2C redefines Magnetorquer_Board_I2C;
                    port Sun_Sensor_I2C redefines Sun_Sensor_I2C;
                    port Irradiance_Sensor_I2C redefines Irradiance_Sensor_I2C;
                    port Radiation_Sensor_I2C redefines Radiation_Sensor_I2C;
                    port Spectrometer_I2C redefines Spectrometer_I2C;
                    port Voltage_Current_Sense_I2C redefines Voltage_Current_Sense_I2C;
                    port UHF_I2C redefines UHF_I2C;

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
                
                // --- MIRROR CONNECTS from OnBoardDataHandling.sysml (for visibility) ---
                connect Primary_OBC.EPS_I2C to EPS_I2C;
                connect Primary_OBC.Temperature_Sensor_I2C to Temperature_Sensor_I2C;
                connect Primary_OBC.Magnetorquer_Board_I2C to Magnetorquer_Board_I2C;
                connect Primary_OBC.Sun_Sensor_I2C to Sun_Sensor_I2C;
                connect Primary_OBC.Irradiance_Sensor_I2C to Irradiance_Sensor_I2C;
                connect Primary_OBC.Radiation_Sensor_I2C to Radiation_Sensor_I2C;
                connect Primary_OBC.Spectrometer_I2C to Spectrometer_I2C;
                connect Primary_OBC.Voltage_Current_Sense_I2C to Voltage_Current_Sense_I2C;
                connect Primary_OBC.UHF_I2C to UHF_I2C;
            }

            
        part SS_Communication_System redefines SS_Communication_System {
            // top-level comms ports (usage names with underscores)
            port EPS_Power_Port redefines EPS_Power_Port;
            port OBDH_Command_Port redefines OBDH_Command_Port;
            port OBDH_HK_Port redefines OBDH_HK_Port;
            port OBDH_Status_Port redefines OBDH_Status_Port;
            port RF_Link_Port redefines RF_Link_Port;
            port OBDH_Anomaly_Port redefines OBDH_Anomaly_Port;

            // attributes (usage names with underscores)
            attribute Supports_All_Mission_Phases redefines Supports_All_Mission_Phases = true;
            attribute Has_Redundancy_Or_Fail_Safe redefines Has_Redundancy_Or_Fail_Safe = false;
            attribute Worst_Case_Link_Margin_dB redefines Worst_Case_Link_Margin_dB = 3.0;

            attribute Beacon_Enabled redefines Beacon_Enabled = true;
            attribute Beacon_Contains_Vital_Telemetry redefines Beacon_Contains_Vital_Telemetry = true;

            // parts (usage names with underscores)
            part Antenna_Part redefines Antenna_Part {
                attribute Name redefines Name = "UHF Antenna";
                attribute Band redefines Band = "UHF";
                attribute Gain redefines Gain = 2.0;
            }

            part Transceiver_Part redefines Transceiver_Part {
                attribute Name redefines Name = "UHF Transceiver";
                attribute MaxTxPower redefines MaxTxPower = 1.0 [SI::W];
                attribute DopplerToleranceHz redefines DopplerToleranceHz = 20000.0;
                attribute ModulationCoding redefines ModulationCoding = "GMSK (TBD)";
                attribute PacketFormat redefines PacketFormat = "AX.25 (TBD)";
                attribute FECEnabled redefines FECEnabled = true;
                attribute CRCEnabled redefines CRCEnabled = true;
                attribute ReconfigurableInOrbit redefines ReconfigurableInOrbit = true;
            }

            part Crypto_Part redefines Crypto_Part {
                attribute Name redefines Name = "Comms Crypto/Integrity";
                attribute UplinkAuthEnabled redefines UplinkAuthEnabled = true;
                attribute UplinkDecryptEnabled redefines UplinkDecryptEnabled = true;
                attribute DownlinkEncryptEnabled redefines DownlinkEncryptEnabled = true;
                attribute DownlinkIntegrityEnabled redefines DownlinkIntegrityEnabled = true;
            }
        }

            // =========================
            // STRUCTURE
            // =========================
            part SS_Structure_And_Mechanisms redefines SS_Structure_And_Mechanisms {
                attribute Total_Mass redefines Total_Mass = 0.40 [SI::kg];
                attribute Material redefines Material = "Aluminium (TBD alloy)";

                part Primary_Structure redefines Primary_Structure {
                    port Structural_Port redefines Structural_Port;
                }
                part Secondary_Structure redefines Secondary_Structure {
                    port Structural_Port redefines Structural_Port;
                }
                part Deployment_Switches redefines Deployment_Switches;

                // --- MIRROR CONNECT from StructureSystem.sysml ---
                connect Secondary_Structure.Structural_Port to Primary_Structure.Structural_Port;
            }

            // =========================
            // AOCS
            // =========================
            part SS_Attitude_And_Orbit_Control_System redefines SS_Attitude_And_Orbit_Control_System {
                port AOCS_Command_In redefines AOCS_Command_In;
                port Power_Bus_In_3V3 :>> Power_Bus_In_3V3;
                port Power_Bus_In_5V :>> Power_Bus_In_5V;
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

            // =========================
            // TCS  (ports + internal connects were missing in your instance)
            // =========================
            part SS_Thermal_Control_System redefines SS_Thermal_Control_System {
                // Ports defined in ThermalControlSystem.sysml
                port EPS_Temperature_Port redefines EPS_Temperature_Port;
                port PL_Temperature_Port redefines PL_Temperature_Port;
                port OBDH_Temperature_Port redefines OBDH_Temperature_Port;
                port Command_IN redefines Command_IN;

                attribute Stop_Signal redefines Stop_Signal;

                // ref parts exist in the TCS definition; create concrete instance usages for visibility
                ref part EPS_Heater_1 redefines EPS_Heater[1];
                ref part PL_TempSensor_1 redefines PL_Temperature_Sensor[1];
                ref part OBC_TempSensor_1 redefines OBC_Temperature_Sensor[1];
                ref part EPS_TempSensor_1 redefines EPS_Temperature_Sensor[1];

                // --- MIRROR CONNECTS from ThermalControlSystem.sysml ---
                connect PL_TempSensor_1.Temperature_Measurement to PL_Temperature_Port.Temp;
                connect OBC_TempSensor_1.Temperature_Measurement to OBDH_Temperature_Port.Temp;
                connect EPS_TempSensor_1.Temperature_Measurement to EPS_Temperature_Port.Temp;
            }

            // =========================
            // PAYLOAD (your added blocks)
            // =========================
            part SS_Satellite_Payload redefines SS_Satellite_Payload {
                port Cmd_In redefines Cmd_In;
                port Status_Out redefines Status_Out;
                port Power_Bus_In_3V3 :>> Power_Bus_In_3V3;
                port Power_Bus_In_5V :>> Power_Bus_In_5V;

                part Power_Filtering_Block redefines Power_Filtering_Block {
                    port Power_Bus_In_3V3 redefines Power_Bus_In_3V3;
                    port Power_Bus_In_5V redefines Power_Bus_In_5V;
                    port Power_Bus_Filtered_5V redefines Power_Bus_Filtered_5V;
                    port Power_Bus_Filtered_3V3 redefines Power_Bus_Filtered_3V3;
                }

                part Mppt_Block redefines Mppt_Block {
                    port Power_Bus_Filtered_3V3 redefines Power_Bus_Filtered_3V3;
                }

                part Iv_Sweep_And_Reverse_Bias_Block redefines Iv_Sweep_And_Reverse_Bias_Block {
                    port Power_Bus_Filtered_5V redefines Power_Bus_Filtered_5V;

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

            // =========================
            // SpaceSegment connects (already in type; mirrored here)
            // =========================
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
// i2c connections_____________________________________________________________________________________
            connect SS_Attitude_And_Orbit_Control_System.AOCS_I2C to SS_On_Board_Data_Handling.I2C_Bus;
            connect SS_Attitude_And_Orbit_Control_System.AOCS_I2C to SS_On_Board_Data_Handling.I2C_Bus;

// electrical connections_____________________________________________________________________________________

            connect SS_Electrical_Power_System.Power_Bus_5V
                to SS_Attitude_And_Orbit_Control_System.Magnetorquer_Board.Power_Bus_In_5V;

            connect SS_Electrical_Power_System.Power_Bus_5V
                to SS_Communication_System.EPS_Power_Port;

            connect SS_Electrical_Power_System.Power_Bus_3V3
                to SS_Attitude_And_Orbit_Control_System.Sun_Sensor.Power_Bus_In_3V3;
            connect SS_Attitude_And_Orbit_Control_System.Power_Bus_In_5V
                to SS_Attitude_And_Orbit_Control_System.Magnetorquer_Board.Power_Bus_In_5V;

            connect Satellite_Command_Port.Telecommand
                to SS_On_Board_Data_Handling.Telecommand_In;
            connect Satellite_Command_Port.Telemetry
                to SS_On_Board_Data_Handling.Telemetry_Out;

            connect SS_Communication_System.DEC_AUTH_Action.Cmd_Out
                to SS_On_Board_Data_Handling.Telecommand_In;
            connect SS_On_Board_Data_Handling.Telemetry_Out
                to SS_Communication_System.OBDH_HK_Port.HK;

            connect SS_On_Board_Data_Handling.Out_Command_Port
                to SS_Thermal_Control_System.Command_IN;
            connect SS_On_Board_Data_Handling.Out_Command_Port
                to SS_Attitude_And_Orbit_Control_System.AOCS_Command_In;

            // Keep your state refinement as-is
            state HEALIOS_Mode redefines Satellite_Mode {
                entry; then Commissioning_Mode;

                state Commissioning_Mode { doc /* waits for ground command */ }
                state Safe_Mode { doc /* charges battery & waits */ }
                state Nominal_Sun_Mode { doc /* nominal sun ops */ }
                state Nominal_Eclipse_Mode { doc /* nominal eclipse ops */ }

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

       
       part HEALIOS_Ground_Segment redefines Ground_Segment {
                part Ground_Station redefines Ground_Station {
                    port Mission_Control_Centre_TC_Port redefines Mission_Control_Centre_TC_Port;
                    port Mission_Control_Centre_TM_Port redefines Mission_Control_Centre_TM_Port;
                    port Data_Centre_TM_Port redefines Data_Centre_TM_Port;
                    port Mission_Control_Centre_Pass_Plan_Port redefines Mission_Control_Centre_Pass_Plan_Port;
                    port Mission_Control_Centre_Tracking_Port redefines Mission_Control_Centre_Tracking_Port;
                    port Data_Centre_Archive_Port redefines Data_Centre_Archive_Port;

                    part Antenna_Part redefines Antenna_Part {
                        attribute name redefines name = "UHF Ground Antenna";
                        attribute band redefines band = "UHF";
                        attribute gain redefines gain = 12.0;
                    }

                    part Radio_Unit_Part redefines Radio_Unit_Part {
                        attribute name redefines name = "SDR Ground Radio";
                        attribute supportedBands redefines supportedBands = "UHF/VHF";
                    }

                    part Pass_Predictor_Part redefines Pass_Predictor_Part {
                        attribute name redefines name = "Pass Predictor";
                        attribute usesTLE redefines usesTLE = true;
                    }

                    part Doppler_Compensator_Part redefines Doppler_Compensator_Part {
                        attribute name redefines name = "Doppler Compensator";
                    }

                    part Link_Budget_Tool_Part redefines Link_Budget_Tool_Part {
                        attribute name redefines name = "Link Budget Tool";
                    }

                    part Crypto_Unit_Part redefines Crypto_Unit_Part {
                        attribute name redefines name = "Ground Crypto/Integrity";
                        attribute downlinkVerifyEnabled redefines downlinkVerifyEnabled = true;
                        attribute downlinkDecryptEnabled redefines downlinkDecryptEnabled = true;
                        attribute uplinkAuthEnabled redefines uplinkAuthEnabled = true;
                        attribute uplinkEncryptEnabled redefines uplinkEncryptEnabled = true;
                    }
                }

                part Mission_Control_Centre redefines Mission_Control_Centre {
                    port Ground_Station_TC_Port redefines Ground_Station_TC_Port;
                    port Ground_Station_TM_Port redefines Ground_Station_TM_Port;
                    port Ground_Station_Pass_Plan_Port redefines Ground_Station_Pass_Plan_Port;
                    port Ground_Station_Tracking_Port redefines Ground_Station_Tracking_Port;

                    part Auth_Service_Part redefines Auth_Service_Part {
                        attribute name redefines name = "MCC Authentication";
                        attribute method redefines method = "MFA (TBD)";
                    }

                    part Operations_Console_Part redefines Operations_Console_Part {
                        attribute name redefines name = "Operations Console";
                    }

                    part Pass_Planner_Part redefines Pass_Planner_Part {
                        attribute name redefines name = "Pass Planner";
                        attribute usesTLE redefines usesTLE = true;
                    }
                }

                part Data_Centre redefines Data_Centre {
                    port Ground_Station_TM_Port redefines Ground_Station_TM_Port;
                    port Ground_Station_Records_Port redefines Ground_Station_Records_Port;
                    port Mission_Control_Centre_TM_Products_Port redefines Mission_Control_Centre_TM_Products_Port;

                    part Structured_Archive_Part redefines Structured_Archive_Part {
                        attribute name redefines name = "Structured Archive";
                        attribute retention redefines retention = 1825 [SI::day];
                    }

                    part Data_Validator_Part redefines Data_Validator_Part {
                        attribute name redefines name = "Telemetry Validator";
                    }
                }

                connect Mission_Control_Centre.Ground_Station_TC_Port to Ground_Station.Mission_Control_Centre_TC_Port;
                connect Mission_Control_Centre.Ground_Station_Pass_Plan_Port to Ground_Station.Mission_Control_Centre_Pass_Plan_Port;

                connect Ground_Station.Mission_Control_Centre_TM_Port to Mission_Control_Centre.Ground_Station_TM_Port;
                connect Ground_Station.Mission_Control_Centre_Tracking_Port to Mission_Control_Centre.Ground_Station_Tracking_Port;

                connect Ground_Station.Data_Centre_TM_Port to Data_Centre.Ground_Station_TM_Port;
                connect Ground_Station.Data_Centre_Archive_Port to Data_Centre.Ground_Station_Records_Port;

                connect Data_Centre.Mission_Control_Centre_TM_Products_Port to Mission_Control_Centre.Ground_Station_TM_Port;
            }
    }
}
