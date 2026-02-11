package HealiosMissionInstancePackage {
    // Instance model only: reuse existing definitions from the project
    public import MissionPackage::*;
    public import UnitTypesPackage::*;
    public import SI::*;
    public import ISQ::*;
    public import ScalarValues::*;
    public import SpaceActionsPackage::*;
    private import GroundStationPackage::*;
    private import MissionControlCentrePackage::*;

    attribute yr : year;

    public part Healios_Mission : MissionPackage::MissionSegments {
        doc
        /* HEALIOS mission instance (system-of-systems: Space Segment + Ground Segment).
         * This instance explicitly redefines ports and mirrors connects that already
         * exist in the TYPE definitions so SysIDE can render them in instance diagrams.
         */

        // =========================
        // Mission-level refinements
        // =========================
        attribute missionName redefines Mission_Name = "HEALIOS";
        attribute missionDuration redefines Mission_Duration = 1 [yr];
        attribute orbitType redefines Orbit_Type = "LEO (~550 km, ~55 deg inclination)";

        // Mirror MissionSegments type connect for visibility
        connect HEALIOS_Space_Segment.Telecommand_Port
            to HEALIOS_Space_Segment.SS_Communication_System.RF_Link_Port;
        connect HEALIOS_Space_Segment.SS_Communication_System.RF_Link_Port
            to HEALIOS_Space_Segment.Telemetry_Port;

        connection Uplink redefines Uplink
            connect HEALIOS_Ground_Segment.Telecommand_Port
            to HEALIOS_Space_Segment.Telecommand_Port;

        connection Downlink redefines Downlink
            connect HEALIOS_Space_Segment.Telemetry_Port to HEALIOS_Ground_Segment.Telemetry_Port;

        // ========================
        // Space segment refinements
        // =========================
        part HEALIOS_Space_Segment redefines Space_Segment {
            state HEALIOS_Mode redefines Satellite_Mode {
                entry;
                then Commissioning_Mode;

                state Commissioning_Mode {
                    doc
                    /* waits for ground command */
                }
                state Safe_Mode {
                    doc
                    /* charges battery & waits */
                }
                state Nominal_Sun_Mode {
                    doc
                    /* nominal sun ops */
                }
                state Nominal_Eclipse_Mode {
                    doc
                    /* nominal eclipse ops */
                }

                transition Commissioning_To_Nominal
                    first Commissioning_Mode
                    accept Proceed_To_Nominal_Command : GroundCommand via Telecommand_Port
                    then Nominal_Sun_Mode;

                transition Sun_To_Eclipse
                    first Nominal_Sun_Mode
                    accept Proceed_To_Eclipse_Command : OnBoardCommand via Telecommand_Port
                    then Nominal_Eclipse_Mode;

                transition Eclipse_To_Sun
                    first Nominal_Eclipse_Mode
                    accept Proceed_To_Sun_Command : OnBoardCommand via Telecommand_Port
                    then Nominal_Sun_Mode;

                transition Safe_To_Nominal
                    first Safe_Mode
                    accept Proceed_To_Nominal_Command : GroundCommand via Telecommand_Port
                    then Nominal_Sun_Mode;

                transition Nominal_Sun_To_Safe
                    first Nominal_Sun_Mode
                    accept Enter_Safe_Mode_Command : OnBoardCommand via Telecommand_Port
                    do action Enter_Safe_Mode : SpaceActionsPackage::Enter_Safe_Mode_Action
                    then Safe_Mode;

                transition Nominal_Eclipse_To_Safe
                    first Nominal_Eclipse_Mode
                    accept Enter_Safe_Mode_Command : OnBoardCommand via Telecommand_Port
                    do action Enter_Safe_Mode : SpaceActionsPackage::Enter_Safe_Mode_Action
                    then Safe_Mode;
            }

            attribute Total_Mass redefines Total_Mass = 2.0 [SI::kg];
            attribute CubeSat_Form_Factor redefines CubeSat_Form_Factor = "1U";
            attribute Center_Of_Mass redefines Center_Of_Mass =
                "TBD (set after CAD mass properties)";

            // --- SpaceSegment external ports ---
            in port Satellite_Solar_Environment redefines Satellite_Solar_Environment;

            port Telecommand_Port redefines Telecommand_Port;
            port Telemetry_Port redefines Telemetry_Port;

            // =========================
            // EPS
            // =========================
            part SS_Electrical_Power_System redefines SS_Electrical_Power_System {
                port Data_Bus redefines Data_Bus;
                port Power_Bus_5V redefines Power_Bus_5V;
                port Power_Bus_3V3 redefines Power_Bus_3V3;
                port EPS_Solar_Input redefines EPS_Solar_Input;

                part Power_Supply_Unit redefines Power_Supply_Unit {
                    out port Power_Bus_5V redefines Power_Bus_5V;
                    out port Power_Bus_3V3 redefines Power_Bus_3V3;
                    port Battery_Power_Bus redefines Battery_Power_Bus;
                    in port Power_Supply_Bus redefines Power_Supply_Bus;
                }
                part Deployable_Solar_Arrays redefines Deployable_Solar_Arrays [2] {
                    in port Solar_Input redefines Solar_Input;
                    port Electrode_Connection redefines Electrode_Connection;

                }
                part Mounted_Solar_Arrays redefines Mounted_Solar_Arrays [1] {
                    in port Solar_Input redefines Solar_Input;
                    port Electrode_Connection redefines Electrode_Connection;
                }
                part MPPT_Unit[3] :>> MPPT_Unit {
                    port MPPT_Control :>> MPPT_Control;
                    out port Power_Supply_Bus :>> Power_Supply_Bus;
                }

                part Battery_Pack_EPS redefines Battery_Pack_EPS {
                    port Battery_Power_Bus redefines Battery_Power_Bus;
                    port Heater_Power_Bus redefines Heater_Power_Bus;

                    attribute Name redefines Name = "Li-ion Battery Pack";
                    attribute Mass redefines Mass = 0.30 [SI::kg];
                    attribute PowerConsumption redefines PowerConsumption = 0.0 [SI::W];

                    attribute Capacity redefines Capacity = 30.0 [SI::W * h];
                    attribute Max_Power_Generation redefines Max_Power_Generation = 10.0 [SI::W];
                    part Battery_Unit redefines Battery_Unit [4] {
                        port Battery_Power_Bus;
                    }
                    part Main_Heater redefines Main_Heater {
                        port Heater_Power_Bus;
                        attribute Name redefines Name = "Battery Heater";
                        attribute Mass redefines Mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines PowerConsumption = 2.0 [SI::W];
                        attribute Power redefines Power = 2.0 [SI::W];
                        attribute Minimal_Temperature redefines Minimal_Temperature = 273.15 [
                            SI::K
                        ];
                    }

                    part Temp_Sensor redefines Temp_Sensor {
                        attribute Name redefines Name = "Battery Temp Sensor";
                        attribute Mass redefines Mass = 0.005 [SI::kg];
                        attribute PowerConsumption redefines PowerConsumption = 0.05 [SI::W];
                        attribute Power redefines Power = 0.05 [SI::W];
                    }
                    connect Battery_Pack_EPS.Heater_Power_Bus to Main_Heater.Heater_Power_Bus;
                    connect Battery_Unit.Battery_Power_Bus to Battery_Pack_EPS.Battery_Power_Bus;
                }
                connect Mounted_Solar_Arrays.Electrode_Connection to MPPT_Unit.MPPT_Control;
                connect Deployable_Solar_Arrays.Electrode_Connection to MPPT_Unit.MPPT_Control;
                connect MPPT_Unit.Power_Supply_Bus to Power_Supply_Unit.Power_Supply_Bus;

                connect Battery_Pack_EPS.Battery_Power_Bus to Power_Supply_Unit.Battery_Power_Bus;
                connect Power_Supply_Unit.Battery_Power_Bus to Battery_Pack_EPS.Battery_Power_Bus;
                connect Power_Supply_Unit.Power_Bus_5V to SS_Electrical_Power_System.Power_Bus_5V;
                connect Power_Supply_Unit.Power_Bus_3V3 to SS_Electrical_Power_System.Power_Bus_3V3;
                connect SS_Electrical_Power_System.EPS_Solar_Input to Deployable_Solar_Arrays.Solar_Input;
                connect SS_Electrical_Power_System.EPS_Solar_Input to Mounted_Solar_Arrays.Solar_Input;
            }

            // =========================
            // OBDH
            // =========================
            part SS_On_Board_Data_Handling redefines SS_On_Board_Data_Handling {
                // System ports
                port Power_Bus_3V3 redefines Power_Bus_3V3;

                // I2C buses
                port Data_Bus redefines Data_Bus;

                part Carrier redefines Carrier {
                    attribute Name redefines Name = "OBC Carrier Board";
                }

                part Primary_OBC redefines Primary_OBC {
                    attribute Name redefines Name = "Primary OBC";
                    attribute Role redefines Role = "Command & Data Handling (Primary)";
                    attribute Warm_Redundant redefines Warm_Redundant = true;

                    // Ports on the OBC that are wired out in the type definition
                    port Data_Bus redefines Data_Bus;

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

                connect Primary_OBC.Data_Bus to SS_On_Board_Data_Handling.Data_Bus;
            }

            
            part SS_Communication_System redefines SS_Communication_System {
                // top-level comms ports (usage names with underscores)
                port Power_Bus_5V redefines Power_Bus_5V;
                port RF_Link_Port redefines RF_Link_Port;
                port Data_Bus :>> Data_Bus;

                    // attributes (usage names with underscores)
                    attribute Supports_All_Mission_Phases redefines Supports_All_Mission_Phases = true;
                    attribute Has_Redundancy_Or_Fail_Safe redefines Has_Redundancy_Or_Fail_Safe = false;
                    attribute Worst_Case_Link_Margin_dB redefines Worst_Case_Link_Margin_dB = 3.0;


                // parts (usage names with underscores)
                part Antenna_Part redefines Antenna_Part {
                    port Antenna_Command_Port redefines Antenna_Command_Port ;
                    port Antenna_Status_Port redefines Antenna_Status_Port ;
                    port Antenna_RF_Link_Port redefines Antenna_RF_Link_Port;
                    attribute Name redefines Name = "UHF Antenna";
                    attribute Band redefines Band = "UHF";
                    attribute Gain redefines Gain = 2.0;
                }

                part Transceiver_Part redefines Transceiver_Part {
                    port Transceiver_Status_Port redefines Transceiver_Status_Port;
                    port Transceiver_Command_Port redefines Transceiver_Command_Port;
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
                    port Crypto_Status_Port redefines Crypto_Status_Port;
                    port Crypto_Command_Port redefines Crypto_Command_Port;
                    attribute Name redefines Name = "Comms Crypto/Integrity";
                    attribute UplinkAuthEnabled redefines UplinkAuthEnabled = true;
                    attribute UplinkDecryptEnabled redefines UplinkDecryptEnabled = true;
                    attribute DownlinkEncryptEnabled redefines DownlinkEncryptEnabled = true;
                    attribute DownlinkIntegrityEnabled redefines DownlinkIntegrityEnabled = true;
                }

                connect Crypto_Part.Crypto_Status_Port to Transceiver_Part.Transceiver_Status_Port;
                connect Transceiver_Part.Transceiver_Status_Port to Antenna_Part.Antenna_Status_Port;
                connect Antenna_Part.Antenna_RF_Link_Port to SS_Communication_System.RF_Link_Port;
                connect SS_Communication_System.RF_Link_Port to Antenna_Part.Antenna_Command_Port;
                connect Antenna_Part.Antenna_Command_Port to Transceiver_Part.Transceiver_Command_Port;
                connect Transceiver_Part.Transceiver_Command_Port to Crypto_Part.Crypto_Command_Port;

                perform action Transmit_HealthData_Action redefines Transmit_HealthData_Action {
                    in item Housekeeping_In : MissionPackage::OnBoardStatus;
                    out item Telemetry_Frame_Out : MissionPackage::TelemetryData;
                }

                perform action Encrypt_Dowmlink_Action redefines Encrypt_Dowmlink_Action {
                    in item Telemetry_Frame_In : MissionPackage::TelemetryData;
                    out RF_Frame_Out : MissionPackage::TelemetryData;  
                }

                perform action Decrypte_Autheticate_Action redefines Decrypte_Autheticate_Action {
                    in item RF_Frame_In : MissionPackage::TelemetryData; 
                    out item Rf_Frmae_Out : MissionPackage::TelemetryData;
                }    

                flow SS_Communication_System.Data_Bus to Transmit_HealthData_Action.Housekeeping_In;


                flow Transmit_HealthData_Action.Telemetry_Frame_Out to Encrypt_Dowmlink_Action.Telemetry_Frame_In;


                flow Encrypt_Dowmlink_Action.RF_Frame_Out to SS_Communication_System.RF_Link_Port;


                flow SS_Communication_System.RF_Link_Port to Decrypte_Autheticate_Action.RF_Frame_In;


                flow Decrypte_Autheticate_Action.Rf_Frmae_Out to SS_Communication_System.Data_Bus;
                
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
            part SS_Attitude_And_Orbit_Control_System
                redefines SS_Attitude_And_Orbit_Control_System {
                port Power_Bus_3V3 :>> Power_Bus_3V3;
                port Power_Bus_5V :>> Power_Bus_5V;
                port Data_Bus :>> Data_Bus;

                attribute Nominal_Force redefines Nominal_Force = 0.02 [SI::N];
                attribute Stop_Signal redefines Stop_Signal = false;

                part Sun_Sensor redefines Sun_Sensor [1] {
                    attribute Name redefines Name = "Sun Sensor";
                    attribute Mass redefines Mass = 0.01 [SI::kg];
                    attribute PowerConsumption redefines PowerConsumption = 0.05 [SI::W];
                    port Power_Bus_3V3 redefines Power_Bus_3V3;
                }

                part Magnetorquer_Board redefines Magnetorquer_Board [1] {
                    port Power_Bus_5V redefines Power_Bus_5V;
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

                connect SS_Attitude_And_Orbit_Control_System.Power_Bus_3V3
                    to Sun_Sensor.Power_Bus_3V3;
                connect SS_Attitude_And_Orbit_Control_System.Power_Bus_5V
                    to Magnetorquer_Board.Power_Bus_5V;
                connect SS_Attitude_And_Orbit_Control_System.Data_Bus
                    to Magnetorquer_Board.Magnetorquer_Board_I2C;

                fgfgfg daje zeby bylo na czerowno zeby to ogarnac perform action Activate_AOCS redefines Activate_AOCS {
                    in AOCS_Command : MissionPackage::OnBoardCommand;

                    if AOCS_Command.Type == "TurnOn" {
                        loop {
                            perform action Read_Sun_Angle : ReadSunAngle {
                                bind Beta_Angle = Sun_Sensor.Beta_Angle;
                            }
                            then perform action Correct_Attitude : CorrectAttitude {
                                bind Force = Magnetorquer_Board.Mounted_Magnetorquer_X.Force;
                                bind Sun_Sensor_Reading = Read_Sun_Angle.Beta_Angle;
                                bind Force_Value = Nominal_Force;
                            }
                            then assign Stop_Signal := AOCS_Command.Type == "TurnOff";
                        } until Stop_Signal;
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
                in abstract port Data_Bus redefines Data_Bus;

                attribute Stop_Signal redefines Stop_Signal;

                // ref parts exist in the TCS definition; create concrete instance usages for visibility
                abstract part EPS_Heater redefines EPS_Heater [1];
                ref part PL_TempSensor redefines PL_Temperature_Sensor [1];
                ref part OBC_TempSensor redefines OBC_Temperature_Sensor [1];
                ref part EPS_TempSensor redefines EPS_Temperature_Sensor [1];

                // --- MIRROR CONNECTS from ThermalControlSystem.sysml ---
                connect PL_TempSensor.Temperature_Measurement to PL_Temperature_Port.Temp;
                connect OBC_TempSensor.Temperature_Measurement to OBDH_Temperature_Port.Temp;
                connect EPS_TempSensor.Temperature_Measurement to EPS_Temperature_Port.Temp;
            }

            // =========================
            // PAYLOAD
            // =========================

            part SS_Satellite_Payload redefines SS_Satellite_Payload {
                port Power_Bus_3V3 :>> Power_Bus_3V3;
                port Power_Bus_5V :>> Power_Bus_5V;
                port Data_Bus :>> Data_Bus;
                in port PL_Solar_Input redefines Solar_Input;

                part Power_Filtering_Block redefines Power_Filtering_Block {
                    port Power_Bus_3V3 redefines Power_Bus_3V3;
                    port Power_Bus_5V redefines Power_Bus_5V;
                    port Power_Bus_Filtered_5V redefines Power_Bus_Filtered_5V;
                    port Power_Bus_Filtered_3V3 redefines Power_Bus_Filtered_3V3;
                }

                part Mppt_Block redefines Mppt_Block {
                    part Mppt_Unit[2] redefines Mppt_Unit;
                    part Power_Dump_Resistor[2] redefines Power_Dump_Resistor;
                    port Power_Bus_Filtered_3V3 redefines Power_Bus_Filtered_3V3;
                    port Mppt_Controller redefines Mppt_Controller;
                }

                part Iv_Sweep_And_Reverse_Bias_Block redefines Iv_Sweep_And_Reverse_Bias_Block {
                    port Power_Bus_Filtered_5V redefines Power_Bus_Filtered_5V;

                    part Current_And_Voltage_Sensing_Block
                        redefines Current_And_Voltage_Sensing_Block {
                        port Voltage_Current_Sense_I2C redefines Voltage_Current_Sense_I2C;
                    }
                }

                part Env_Sensors_Block redefines Env_Sensors_Block {
                    port Power_Bus_Filtered_3V3 redefines Power_Bus_Filtered_3V3;
                    in port Solar_Input redefines Solar_Input;

                    port Temp_Out redefines Temp_Out;
                    port Irr_Out redefines Irr_Out;
                    port Rad_Out redefines Rad_Out;
                    port Spec_Out redefines Spec_Out;

                    part Temperature_Sensor_At_Environment
                        redefines Temperature_Sensor_At_Environment {
                        port Temperature_Port redefines Temperature_Port;
                    }
                    part Irradiance_Sensor_Block redefines Irradiance_Sensor_Block {
                        port Irradiance_Sensor_I2C redefines Irradiance_Sensor_I2C;
                        in port Solar_Input redefines Solar_Input;

                    }
                    part Radiation_Dose_Sensor redefines Radiation_Dose_Sensor {
                        port Radiation_Sensor_I2C redefines Radiation_Sensor_I2C;
                        in port Solar_Input redefines Solar_Input;

                    }
                    part Spectrometer redefines Spectrometer {
                        port Spectrometer_Sensor_I2C redefines Spectrometer_Sensor_I2C;
                        in port Solar_Input redefines Solar_Input;
                    }

                    connect Env_Sensors_Block.Solar_Input to Irradiance_Sensor_Block.Solar_Input;
                    connect Env_Sensors_Block.Solar_Input to Radiation_Dose_Sensor.Solar_Input;
                    connect Env_Sensors_Block.Solar_Input to Spectrometer.Solar_Input;
                }

                part Solar_Cells_Block redefines Solar_Cells_Block {
                    in port Solar_Input redefines Solar_Input;
                    port Mppt_Controller redefines Mppt_Controller;

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
                        in port Solar_Input redefines Solar_Input;
                        port Electrode_Connection redefines Electrode_Connection;
                    }

                    part Reference_Silicon_Solar_Array_Coupon
                        redefines Reference_Silicon_Solar_Array_Coupon [1] {
                        attribute Name redefines Name = "Si Reference Coupon #1";
                        attribute Mass redefines Mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines PowerConsumption = 0.0 [SI::W];
                        attribute Power_Generation redefines Power_Generation = 1.0 [SI::W];
                        in port Solar_Input redefines Solar_Input;
                        port Electrode_Connection redefines Electrode_Connection;
                    }

                    connect Solar_Cells_Block.Solar_Input to Perovskite_Solar_Array_Coupon.Solar_Input;
                    connect Solar_Cells_Block.Solar_Input to Reference_Silicon_Solar_Array_Coupon.Solar_Input;
                    connect Solar_Cells_Block.Mppt_Controller to Perovskite_Solar_Array_Coupon.Electrode_Connection;
                    connect Solar_Cells_Block.Mppt_Controller to Reference_Silicon_Solar_Array_Coupon.Electrode_Connection;
                }
                connect Mppt_Block.Mppt_Controller to Solar_Cells_Block.Mppt_Controller;

                connect SS_Satellite_Payload.PL_Solar_Input to Solar_Cells_Block.Solar_Input;
                connect SS_Satellite_Payload.PL_Solar_Input to Env_Sensors_Block.Solar_Input;
                connect SS_Satellite_Payload.Power_Bus_5V to Power_Filtering_Block.Power_Bus_5V;
                connect SS_Satellite_Payload.Power_Bus_3V3 to Power_Filtering_Block.Power_Bus_3V3;

                connect Power_Filtering_Block.Power_Bus_Filtered_3V3
                    to Env_Sensors_Block.Power_Bus_Filtered_3V3;
                connect Power_Filtering_Block.Power_Bus_Filtered_3V3
                    to Mppt_Block.Power_Bus_Filtered_3V3;
                connect Power_Filtering_Block.Power_Bus_Filtered_5V
                    to Iv_Sweep_And_Reverse_Bias_Block.Power_Bus_Filtered_5V;
            }

            // =========================
            // SpaceSegment connects (already in type; mirrored here)
            // =========================
            // i2c connections_____________________________________________________________________________________
            connect SS_Electrical_Power_System.Data_Bus to SS_On_Board_Data_Handling.Data_Bus;

            connect SS_Satellite_Payload.Data_Bus to SS_On_Board_Data_Handling.Data_Bus;
            connect SS_Communication_System.Data_Bus to SS_On_Board_Data_Handling.Data_Bus;
            connect SS_Attitude_And_Orbit_Control_System.Data_Bus
                to SS_On_Board_Data_Handling.Data_Bus;

            // electrical connections_____________________________________________________________________________________

            connect SS_Electrical_Power_System.Power_Bus_5V to SS_Communication_System.Power_Bus_5V;
            connect SS_Electrical_Power_System.Power_Bus_3V3
                to SS_Attitude_And_Orbit_Control_System.Sun_Sensor.Power_Bus_3V3;
            connect SS_Attitude_And_Orbit_Control_System.Power_Bus_5V
                to SS_Attitude_And_Orbit_Control_System.Magnetorquer_Board.Power_Bus_5V;
            connect SS_Electrical_Power_System.Power_Bus_5V to SS_Satellite_Payload.Power_Bus_5V;
            connect SS_Electrical_Power_System.Power_Bus_3V3 to SS_Satellite_Payload.Power_Bus_3V3;
            connect SS_Electrical_Power_System.Power_Bus_3V3
                to SS_On_Board_Data_Handling.Power_Bus_3V3;

            // command connections

            connect SS_Electrical_Power_System.Data_Bus
                to SS_Thermal_Control_System.Data_Bus;
            connect SS_On_Board_Data_Handling.Data_Bus
                to SS_Attitude_And_Orbit_Control_System.Data_Bus;

            // sun connections
            connect HEALIOS_Space_Segment.Satellite_Solar_Environment to SS_Electrical_Power_System.EPS_Solar_Input;
            connect HEALIOS_Space_Segment.Satellite_Solar_Environment to SS_Satellite_Payload.PL_Solar_Input;
        }

        part HEALIOS_Ground_Segment redefines Ground_Segment {
            port Telecommand_Port redefines Telecommand_Port;
            port Telemetry_Port redefines Telemetry_Port;

            part Ground_Station redefines Ground_Station {
                port Tc_Port redefines Telecommand_Port;
                port Tm_Port redefines Telemetry_Port;

                port Mission_Control_Centre_TC_Port redefines Mission_Control_Centre_TC_Port;
                port Mission_Control_Centre_TM_Port redefines Mission_Control_Centre_TM_Port;
                port Data_Centre_TM_Port redefines Data_Centre_TM_Port;
                port Mission_Control_Centre_Pass_Plan_Port
                    redefines Mission_Control_Centre_Pass_Plan_Port;
                port Mission_Control_Centre_Tracking_Port
                    redefines Mission_Control_Centre_Tracking_Port;
                port Data_Centre_Archive_Port redefines Data_Centre_Archive_Port;

                part Antenna_Part redefines Antenna_Part {
                    attribute name redefines name = "UHF Ground Antenna";
                    attribute band redefines band = "UHF";
                    attribute gain redefines gain = 12.0;

                    in port Uplink_In redefines Uplink_In;
                    out port Downlink_Out redefines Downlink_Out;
                }

                part Crypto_Unit_Part redefines Crypto_Unit_Part {
                    attribute name redefines name = "Ground Crypto/Integrity";
                    attribute downlinkVerifyEnabled redefines downlinkVerifyEnabled = true;
                    attribute downlinkDecryptEnabled redefines downlinkDecryptEnabled = true;
                    attribute uplinkAuthEnabled redefines uplinkAuthEnabled = true;
                    attribute uplinkEncryptEnabled redefines uplinkEncryptEnabled = true;

                    in port TC_In redefines TC_In;
                    out port TC_Out redefines TC_Out;

                    in port TM_In redefines TM_In;
                    out port TM_Out redefines TM_Out;
                }

                part Pass_Predictor_Part redefines Pass_Predictor_Part {
                    attribute name redefines name = "Pass Predictor";
                    attribute usesTLE redefines usesTLE = true;

                    port PassPlan_Out redefines PassPlan_Out;
                    port Tracking_Out redefines Tracking_Out;
                }

                perform action Auth_Encrypt_Action redefines Auth_Encrypt_Action {
                    in Telecommand_To_Encrypt : MissionPackage::GroundCommand;
                    out Secured_Encrypted_Telecommand : MissionPackage::GroundCommand;
                }

                perform action Uplink_Action redefines Uplink_Action {
                    in Modulated_Uplink_Signal : MissionPackage::GroundCommand;
                    out Uplink_Signal_Sent : MissionPackage::GroundCommand;
                }

                perform action Downlink_Action redefines Downlink_Action {
                    out item Captured_Encrypted_Telemetry : MissionPackage::TelemetryData;
                    in item Incoming_Radio_Signal : TelemetryData;
                    
                }

                perform action Verify_Decrypt_Action redefines Verify_Decrypt_Action {
                    in Telemetry_To_Decrypt : MissionPackage::TelemetryData;
                    out Verified_Ground_Telemetry_Data : MissionPackage::TelemetryData;
                }

                perform action Archive_Action redefines Archive_Action {
                    in item Telemetry_To_Archive : MissionPackage::TelemetryData;
                    out item Record_of_Telemetry : ArchiveRecord;
                }

                perform action Tracking_Action redefines Tracking_Action {
                    in Satellite_plan : PassPlan;
                    out Tracking_Data : TrackingData;
                }   

                 flow of MissionPackage::GroundCommand
                    from Mission_Control_Centre_TC_Port
                    to Auth_Encrypt_Action.Telecommand_To_Encrypt;

                flow of MissionPackage::GroundCommand
                    from Auth_Encrypt_Action.Secured_Encrypted_Telecommand
                    to Uplink_Action.Modulated_Uplink_Signal;

                flow of MissionPackage::GroundCommand
                    from Uplink_Action.Uplink_Signal_Sent
                    to Tc_Port;

                // --- DOWNLINK (TM) ---
                flow of MissionPackage::TelemetryData
                    from Tm_Port
                    to Downlink_Action.Incoming_Radio_Signal;

                flow of MissionPackage::TelemetryData
                    from Downlink_Action.Captured_Encrypted_Telemetry
                    to Verify_Decrypt_Action.Telemetry_To_Decrypt;

                flow of MissionPackage::TelemetryData
                    from Verify_Decrypt_Action.Verified_Ground_Telemetry_Data
                    to Mission_Control_Centre_TM_Port;

                flow of MissionPackage::TelemetryData
                    from Verify_Decrypt_Action.Verified_Ground_Telemetry_Data
                    to Data_Centre_TM_Port;

                flow of MissionPackage::TelemetryData
                    from Verify_Decrypt_Action.Verified_Ground_Telemetry_Data
                    to Archive_Action.Telemetry_To_Archive;

                flow of ArchiveRecord
                    from Archive_Action.Record_of_Telemetry
                    to Data_Centre_Archive_Port;

                // --- PASS PLAN / TRACKING ---
                flow of PassPlan
                    from Mission_Control_Centre_Pass_Plan_Port
                    to Tracking_Action.Satellite_plan;

                flow of TrackingData
                    from Tracking_Action.Tracking_Data
                    to Mission_Control_Centre_Tracking_Port;

                
                connect Ground_Station.Mission_Control_Centre_TC_Port to Crypto_Unit_Part.TC_In;
                connect Crypto_Unit_Part.TC_Out to Antenna_Part.Uplink_In;

                // --- TM downlink ---
                connect Antenna_Part.Downlink_Out to Crypto_Unit_Part.TM_In;
                connect Crypto_Unit_Part.TM_Out to Ground_Station.Mission_Control_Centre_TM_Port;
                connect Crypto_Unit_Part.TM_Out to Ground_Station.Data_Centre_TM_Port;

                // --- pass plan / tracking ---
                connect Ground_Station.Mission_Control_Centre_Pass_Plan_Port to Pass_Predictor_Part.PassPlan_Out;
                connect Pass_Predictor_Part.Tracking_Out to Ground_Station.Mission_Control_Centre_Tracking_Port;


            }

            part Mission_Control_Centre redefines Mission_Control_Centre {
                port Ground_Station_TC_Port redefines Ground_Station_TC_Port;
                port Ground_Station_TM_Port redefines Ground_Station_TM_Port;
                port Ground_Station_Pass_Plan_Port redefines Ground_Station_Pass_Plan_Port;
                port Ground_Station_Tracking_Port redefines Ground_Station_Tracking_Port;

                part Auth_Service_Part redefines Auth_Service_Part {
                    attribute name redefines name = "MCC Authentication";
                    attribute method redefines method = "MFA (TBD)";

                    in port Auth_Request_In redefines Auth_Request_In;
                    out port Auth_Token_Out redefines Auth_Token_Out;
                }

                part Operations_Console_Part redefines Operations_Console_Part {
                    attribute name redefines name = "Operations Console";

                    out port Operator_Request_Out redefines Operator_Request_Out;
                    in port Auth_Token_In redefines Auth_Token_In;

                    out port TC_Out redefines TC_Out;
                    in port TM_In redefines TM_In;
                }

                part Pass_Planner_Part redefines Pass_Planner_Part {
                    attribute name redefines name = "Pass Planner";
                    attribute usesTLE redefines usesTLE = true;

                    out port PassPlan_Out redefines PassPlan_Out;
                }

                connect Operations_Console_Part.Operator_Request_Out to Auth_Service_Part.Auth_Request_In;
                connect Auth_Service_Part.Auth_Token_Out to Operations_Console_Part.Auth_Token_In;

                connect Operations_Console_Part.TC_Out to Mission_Control_Centre.Ground_Station_TC_Port;
                connect Mission_Control_Centre.Ground_Station_TM_Port to Operations_Console_Part.TM_In;

                connect Pass_Planner_Part.PassPlan_Out to Mission_Control_Centre.Ground_Station_Pass_Plan_Port;

                perform action Authorize_Action redefines Authorize_Action {
                    in item Operator_Request  : OperatorRequest;
                    out item  Auth_Token : AuthToken;
                }

                perform action Generate_TC_Action redefines Generate_TC_Action {
                    in item Auth_Token  : AuthToken;
                    out item Raw_Unsecured_Telecommand : MissionPackage::GroundCommand;
                }

                perform action Plan_Passes_Action redefines Plan_Passes_Action {
                    out item  Plan_of_Satellite_Path : PassPlan;
                }

                perform action Monitor_TM_Action redefines Monitor_TM_Action {
                    in item  Telemetry_For_Monitoring : MissionPackage::TelemetryData;
                }

                flow of OperatorRequest
                    from Operations_Console_Part.Operator_Request_Out
                    to Authorize_Action.Operator_Request;

                flow of AuthToken
                    from Authorize_Action.Auth_Token
                    to Operations_Console_Part.Auth_Token_In;


                flow of AuthToken
                    from Operations_Console_Part.Operator_Request_Out
                    to Generate_TC_Action.Auth_Token;

                flow of MissionPackage::GroundCommand
                    from Generate_TC_Action.Raw_Unsecured_Telecommand
                    to Mission_Control_Centre.Ground_Station_TC_Port;

                flow of PassPlan
                    from Plan_Passes_Action.Plan_of_Satellite_Path
                    to Mission_Control_Centre.Ground_Station_Pass_Plan_Port;

                flow of MissionPackage::TelemetryData
                    from Mission_Control_Centre.Ground_Station_TM_Port
                    to Monitor_TM_Action.Telemetry_For_Monitoring;

            }

            part Data_Centre redefines Data_Centre {
                port Ground_Station_TM_Port redefines Ground_Station_TM_Port;
                port Ground_Station_Records_Port redefines Ground_Station_Records_Port;
                port Mission_Control_Centre_TM_Products_Port
                    redefines Mission_Control_Centre_TM_Products_Port;

                part Structured_Archive_Part redefines Structured_Archive_Part {
                    attribute name redefines name = "Structured Archive";
                    attribute retention redefines retention = 1825 [SI::day];
                }

                part Data_Validator_Part redefines Data_Validator_Part {
                    attribute name redefines name = "Telemetry Validator";
                }
            }

            connect Mission_Control_Centre.Ground_Station_TC_Port
                to Ground_Station.Mission_Control_Centre_TC_Port;
            connect Mission_Control_Centre.Ground_Station_Pass_Plan_Port
                to Ground_Station.Mission_Control_Centre_Pass_Plan_Port;

            connect Ground_Station.Mission_Control_Centre_TM_Port
                to Mission_Control_Centre.Ground_Station_TM_Port;
            connect Ground_Station.Mission_Control_Centre_Tracking_Port
                to Mission_Control_Centre.Ground_Station_Tracking_Port;

            connect Ground_Station.Data_Centre_TM_Port to Data_Centre.Ground_Station_TM_Port;
            connect Ground_Station.Data_Centre_Archive_Port
                to Data_Centre.Ground_Station_Records_Port;

            connect Data_Centre.Mission_Control_Centre_TM_Products_Port
                to Mission_Control_Centre.Ground_Station_TM_Port;
            bind Telecommand_Port = Ground_Station.Tc_Port;
            bind Telemetry_Port= Ground_Station.Tm_Port;
            }
               
    }
}
