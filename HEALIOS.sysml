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

    public part Healios_Mission : OperationalStructure {
        doc
        /* HEALIOS mission instance (system-of-systems: Space Segment + Ground Segment).
         * This instance explicitly redefines ports and mirrors connects that already
         * exist in the TYPE definitions so SysIDE can render them in instance diagrams.
         */

        attribute missionName redefines mission_Name = "HEALIOS";
        attribute missionDuration redefines mission_Duration = 1 [yr];
        attribute orbitType redefines orbit_Type = "LEO (~550 km, ~55 deg inclination)";

        connect HEALIOS_Space_Segment.Telecommand_Port
            to HEALIOS_Space_Segment.SS_Communication_System.RF_Link_Port;
        connect HEALIOS_Space_Segment.SS_Communication_System.RF_Link_Port
            to HEALIOS_Space_Segment.Telemetry_Port;

        connection Uplink redefines uplink
            connect HEALIOS_Ground_Segment.Telecommand_Port
            to HEALIOS_Space_Segment.Telecommand_Port;

        connection Downlink redefines downlink
            connect HEALIOS_Space_Segment.Telemetry_Port to HEALIOS_Ground_Segment.Telemetry_Port;

        // ========================
        // Space segment
        // =========================
        part HEALIOS_Space_Segment redefines space_Segment {
            state HEALIOS_Mode redefines satellite_Mode {
                in abstract port Switch_Command :>> switch_Command;
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

            attribute Total_Mass redefines total_Mass = 2.0 [SI::kg];
            attribute CubeSat_Form_Factor redefines cubeSat_Form_Factor = "1U";
            attribute Center_Of_Mass redefines center_Of_Mass =
                "TBD (set after CAD mass properties)";

            in port Satellite_Solar_Environment redefines satellite_Solar_Environment;

            port Telecommand_Port redefines telecommand_Port;
            port Telemetry_Port redefines telemetry_Port;

            // =========================
            // EPS
            // =========================
            part SS_Electrical_Power_System redefines ss_Electrical_Power_System {
                port Data_Bus redefines data_Bus;
                port Power_Bus_5V redefines power_Bus_5V;
                port Power_Bus_3V3 redefines power_Bus_3V3;
                port EPS_Solar_Input redefines eps_Solar_Input;

                part Power_Supply_Unit redefines power_Supply_Unit {
                    out port Power_Bus_5V redefines power_Bus_5V;
                    out port Power_Bus_3V3 redefines power_Bus_3V3;
                    port Battery_Power_Bus redefines battery_Power_Bus;
                    in port Power_Supply_Bus redefines power_Supply_Bus;
                    port Data_Bus redefines data_Bus;
                }
                part Deployable_Solar_Arrays redefines deployable_Solar_Arrays [2] {
                    in port Solar_Input redefines solar_Input;
                    port Electrode_Connection redefines electrode_Connection;
                }
                part Mounted_Solar_Arrays redefines mounted_Solar_Arrays [1] {
                    in port Solar_Input redefines solar_Input;
                    port Electrode_Connection redefines electrode_Connection;
                }
                part MPPT_Unit :>> mppt_Unit [3] {
                    port MPPT_Control :>> mppt_Control;
                    out port Power_Supply_Bus :>> power_Supply_Bus;
                }

                part Battery_Pack_EPS redefines battery_Pack_EPS {
                    port Battery_Power_Bus redefines battery_Power_Bus;
                    port Data_Bus redefines Data_Bus;

                    attribute Name redefines name = "Li-ion Battery Pack";
                    attribute Mass redefines mass = 0.30 [SI::kg];
                    attribute PowerConsumption redefines power_Consumption = 0.0 [SI::W];

                    attribute Capacity redefines capacity = 30.0 [SI::W * h];
                    attribute Max_Power_Generation redefines max_Power_Generation = 10.0 [SI::W];
                    part Battery_Unit redefines battery_Unit [4] {
                        port Battery_Power_Bus redefines battery_Power_Bus;
                        port Heater_Power_Bus redefines heater_Power_Bus;
                    }
                    part Main_Heater redefines main_Heater {
                        port Heater_Power_Bus;
                        attribute Name redefines name = "Battery Heater";
                        attribute Mass redefines mass = 0.02 [SI::kg];
                        attribute Power_Consumption redefines power_Consumption = 2.0 [SI::W];
                        attribute Power redefines power = 2.0 [SI::W];
                        attribute Minimal_Temperature redefines minimal_Temperature = 273.15 [
                            SI::K
                        ];
                    }

                    part Temp_Sensor redefines temp_Sensor {
                        attribute Name redefines name = "Battery Temp Sensor";
                        attribute Mass redefines mass = 0.005 [SI::kg];
                        attribute Power_Consumption redefines power_Consumption = 0.05 [SI::W];
                        attribute Power redefines power = 0.05 [SI::W];
                        out port Temperature_Measurement :>> temperature_Measurement;
                    }
                    bind Battery_Unit.Heater_Power_Bus = Main_Heater.Heater_Power_Bus;
                    bind Battery_Unit.Battery_Power_Bus = Battery_Pack_EPS.Battery_Power_Bus;
                    connect Battery_Pack_EPS.Data_Bus to SS_Electrical_Power_System.Data_Bus;
                    connect Temp_Sensor.Temperature_Measurement to Battery_Pack_EPS.Data_Bus;
                }

                bind Mounted_Solar_Arrays.Electrode_Connection = MPPT_Unit.MPPT_Control;
                bind Deployable_Solar_Arrays.Electrode_Connection = MPPT_Unit.MPPT_Control;
                bind MPPT_Unit.Power_Supply_Bus = Power_Supply_Unit.Power_Supply_Bus;

                bind Battery_Pack_EPS.Battery_Power_Bus = Power_Supply_Unit.Battery_Power_Bus;
                bind Power_Supply_Unit.Power_Bus_5V = SS_Electrical_Power_System.Power_Bus_5V;
                bind Power_Supply_Unit.Power_Bus_3V3 = SS_Electrical_Power_System.Power_Bus_3V3;
                bind SS_Electrical_Power_System.EPS_Solar_Input =
                    Deployable_Solar_Arrays.Solar_Input;
                bind SS_Electrical_Power_System.EPS_Solar_Input = Mounted_Solar_Arrays.Solar_Input;
                bind SS_Electrical_Power_System.Data_Bus = Power_Supply_Unit.Data_Bus;
            }

            // =========================
            // OBDH
            // =========================
            part SS_On_Board_Data_Handling redefines ss_On_Board_Data_Handling {
                port Power_Bus_3V3 redefines Power_Bus_3V3;

                port Data_Bus redefines Data_Bus {
                    in item Data redefines Data;
                    out item Cmd redefines Cmd;
                }

                part Carrier redefines Carrier {
                    attribute Name redefines Name = "OBC Carrier Board";
                } 

                part Primary_OBC redefines Primary_OBC {
                    attribute Name redefines Name = "Primary OBC";
                    attribute Role redefines Role = "Command & Data Handling (Primary)";
                    attribute Redundant redefines Redundant = true;

                    port Data_Bus redefines Data_Bus;
                    port Power_Bus_3V3 redefines Power_Bus_3V3;

                    part ROM redefines ROM { attribute Total_Memory redefines Total_Memory = 8.0; }
                    part RAM redefines RAM { attribute Total_Memory redefines Total_Memory = 2.0; }
                }

                part Secondary_OBC redefines Secondary_OBC {
                    attribute Name redefines Name = "Secondary OBC";
                    attribute Role redefines Role = "Command & Data Handling (Cold Redundant)";
                    attribute Redundant redefines Redundant = true;

                    port Data_Bus redefines Data_Bus;
                    port Power_Bus_3V3 redefines Power_Bus_3V3;

                    part ROM redefines ROM { attribute Total_Memory redefines Total_Memory = 8.0; }
                    part RAM redefines RAM { attribute Total_Memory redefines Total_Memory = 2.0; }
                }

                bind Primary_OBC.Data_Bus = SS_On_Board_Data_Handling.Data_Bus;
                bind Secondary_OBC.Data_Bus = SS_On_Board_Data_Handling.Data_Bus;
                bind SS_On_Board_Data_Handling.Power_Bus_3V3 = Primary_OBC.Power_Bus_3V3;
                bind SS_On_Board_Data_Handling.Power_Bus_3V3 = Secondary_OBC.Power_Bus_3V3;

                perform action Prepare_Data redefines Prepare_Data {
                    attribute Subsystem_Count :>> Subsystem_Count;
                    out Time_Tagged_Packed_Data redefines Time_Tagged_Packed_Data;
                    in Data_In[Subsystem_Count] :>> Data_In;
                    in Current_Time :>> Current_Time;
                }
            }

            part SS_Communication_System redefines ss_Communication_System {
                port Power_Bus_5V redefines power_Bus_5V;
                port RF_Link_Port redefines rF_Link_Port;
                port Data_Bus :>> data_Bus;

                attribute Supports_All_Mission_Phases redefines supports_All_Mission_Phases = true;
                attribute Has_Redundancy_Or_Fail_Safe redefines has_Redundancy_Or_Fail_Safe = false;
                attribute Worst_Case_Link_Margin_dB redefines worst_Case_Link_Margin_dB = 3.0;

                part Antenna_Part redefines antenna_Part {
                    port Antenna_Command_Port redefines antenna_Command_Port;
                    port Antenna_Status_Port redefines antenna_Status_Port;
                    port Antenna_RF_Link_Port redefines antenna_RF_Link_Port;
                    attribute Name redefines name = "UHF Antenna";
                    attribute Band redefines band = "UHF";
                    attribute Gain redefines gain = 2.0;
                }

                part Transceiver_Part redefines transceiver_Part {
                    port Transceiver_Status_Port redefines transceiver_Status_Port;
                    port Transceiver_Command_Port redefines transceiver_Command_Port;
                    attribute Name redefines name = "UHF Transceiver";
                    attribute MaxTxPower redefines maxTxPower = 1.0 [SI::W];
                    attribute DopplerToleranceHz redefines dopplerToleranceHz = 20000.0;
                    attribute ReconfigurableInOrbit redefines reconfigurableInOrbit = true;
                }

                part Crypto_Part redefines crypto_Part {
                    port Crypto_Status_Port redefines crypto_Status_Port;
                    port Crypto_Command_Port redefines crypto_Command_Port;
                    attribute Name redefines name = "Comms Crypto/Integrity";
                    attribute UplinkAuthEnabled redefines uplink_Auth_Enabled = true;
                    attribute UplinkDecryptEnabled redefines uplink_Decrypt_Enabled = true;
                    attribute DownlinkEncryptEnabled redefines downlink_Encrypt_Enabled = true;
                    attribute DownlinkIntegrityEnabled redefines downlink_Integrity_Enabled = true;
                }

                connect Crypto_Part.Crypto_Status_Port to Transceiver_Part.Transceiver_Status_Port;
                connect Transceiver_Part.Transceiver_Status_Port
                    to Antenna_Part.Antenna_Status_Port;
                connect Antenna_Part.Antenna_RF_Link_Port to SS_Communication_System.RF_Link_Port;
                connect SS_Communication_System.RF_Link_Port to Antenna_Part.Antenna_Command_Port;
                connect Antenna_Part.Antenna_Command_Port
                    to Transceiver_Part.Transceiver_Command_Port;
                connect Transceiver_Part.Transceiver_Command_Port
                    to Crypto_Part.Crypto_Command_Port;

                perform action Transmit_HealthData_Action redefines transmit_HealthData_Action {
                    in item Housekeeping_In : MissionPackage::OnBoardStatus;
                    out item Telemetry_Frame_Out : MissionPackage::TelemetryData;
                }

                perform action Encrypt_Dowmlink_Action redefines encrypt_Dowmlink_Action {
                    in item Telemetry_Frame_In : MissionPackage::TelemetryData;
                    out RF_Frame_Out : MissionPackage::TelemetryData;
                }

                perform action Decrypte_Autheticate_Action redefines decrypte_Autheticate_Action {
                    in item RF_Frame_In : MissionPackage::TelemetryData;
                    out item Rf_Frmae_Out : MissionPackage::TelemetryData;
                }

                flow SS_Communication_System.Data_Bus to Transmit_HealthData_Action.Housekeeping_In;

                flow
                    Transmit_HealthData_Action.Telemetry_Frame_Out
                    to Encrypt_Dowmlink_Action.Telemetry_Frame_In;

                flow Encrypt_Dowmlink_Action.RF_Frame_Out to SS_Communication_System.RF_Link_Port;

                flow
                    SS_Communication_System.RF_Link_Port to Decrypte_Autheticate_Action.RF_Frame_In;

                flow Decrypte_Autheticate_Action.Rf_Frmae_Out to SS_Communication_System.Data_Bus;
            }

            // =========================
            // STRUCTURE
            // =========================
            part SS_Structure_And_Mechanisms redefines ss_Structure_And_Mechanisms {
                attribute Total_Mass redefines Total_Mass = 0.40 [SI::kg];
                attribute Material redefines Material = "Aluminium (TBD alloy)";

                part Primary_Structure redefines Primary_Structure {
                    port Structural_Port redefines Structural_Port;
                }
                part Secondary_Structure redefines Secondary_Structure {
                    port Structural_Port redefines Structural_Port;
                }
                part Deployment_Switches redefines Deployment_Switches;

                connect Secondary_Structure.Structural_Port to Primary_Structure.Structural_Port;
            }

            // =========================
            // AOCS
            // =========================
            part SS_Attitude_And_Orbit_Control_System
                redefines ss_Attitude_And_Orbit_Control_System {
                port Power_Bus_3V3 :>> power_Bus_3V3;
                port Power_Bus_5V :>> power_Bus_5V;
                port Data_Bus :>> data_Bus;

                attribute Force_Output redefines force_Output;
                attribute Stop_Signal redefines stop_Signal = false;

                part Sun_Sensor redefines sun_Sensor [1] {
                    attribute Name redefines name = "Sun Sensor";
                    attribute Mass redefines mass = 0.01 [SI::kg];
                    attribute PowerConsumption redefines power_Consumption = 0.05 [SI::W];
                    port Power_Bus_3V3 redefines power_Bus_3V3;
                }

                part Magnetorquer_Board redefines magnetorquer_Board [1] {
                    port Power_Bus_5V redefines power_Bus_5V;
                    port Magnetorquer_Board_Control redefines magnetorquer_Board_Control_Input;

                    part Mounted_Magnetorquer_X redefines mounted_Magnetorquer [1] {
                        attribute Name redefines name = "MTQ_X";
                        attribute Axis redefines axis = "X";
                        attribute Force redefines force = 0.02 [SI::N];
                        attribute Mass redefines mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines power_Consumption = 0.2 [SI::W];
                    }
                    part Mounted_Magnetorquer_Y redefines mounted_Magnetorquer [2] {
                        attribute Name redefines name = "MTQ_Y";
                        attribute Axis redefines axis = "Y";
                        attribute Force redefines force = 0.02 [SI::N];
                        attribute Mass redefines mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines power_Consumption = 0.2 [SI::W];
                    }
                    part Mounted_Magnetorquer_Z redefines mounted_Magnetorquer [3] {
                        attribute Name redefines name = "MTQ_Z";
                        attribute Axis redefines axis = "Z";
                        attribute Force redefines force = 0.02 [SI::N];
                        attribute Mass redefines mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines power_Consumption = 0.2 [SI::W];
                    }
                }

                bind SS_Attitude_And_Orbit_Control_System.Power_Bus_3V3 = Sun_Sensor.Power_Bus_3V3;
                bind SS_Attitude_And_Orbit_Control_System.Power_Bus_5V =
                    Magnetorquer_Board.Power_Bus_5V;
                bind SS_Attitude_And_Orbit_Control_System.Data_Bus =
                    Magnetorquer_Board.Magnetorquer_Board_Control;

                perform action use_AOCS redefines use_AOCS {
                    in Command redefines command;
                    in Beta_Angle_Threshold redefines beta_Angle_Threshold;
                    out Force_Output redefines force_Output;

                    // if Command.Type == "Start_Command" {
                    // loop {
                    action Read_Sun_Angle redefines Read_Sun_Angle;
                    then action Correct_Attitude redefines Correct_Attitude;
                    // } until Command.Type == "Stop_Command";
                    // }

                    // ask
                }

                bind use_AOCS.Command = Data_Bus.Cmd;
                connect Data_Bus.Cmd to use_AOCS.Beta_Angle_Threshold;
                bind use_AOCS.Force_Output = SS_Attitude_And_Orbit_Control_System.Force_Output;
            }

            // =========================
            // TCS
            // =========================
            part SS_Thermal_Control_System redefines ss_Thermal_Control_System {
                abstract port Data_Bus redefines Data_Bus;

                attribute Stop_Signal redefines Stop_Signal;

                abstract part EPS_Heater redefines EPS_Heater [1] {
                    attribute Power redefines power = 10 [W];
                    attribute Minimal_Temperature redefines minimal_Temperature = 253 [K];
                }

                ref part PL_Temp_Sensor redefines PL_Temperature_Sensor [1] {
                    out port PL_Temperature_Measurement :>> PL_Temperature_Measurement;
                }
                ref part OBC_Temp_Sensor redefines OBC_Temperature_Sensor [1] {
                    out port OBC_Temperature_Measurement :>> OBC_Temperature_Measurement;
                }
                ref part EPS_Temp_Sensor redefines EPS_Temperature_Sensor [1] {
                    out port EPS_Temperature_Measurement :>> EPS_Temperature_Measurement;
                }

                connect PL_Temp_Sensor.PL_Temperature_Measurement
                    to SS_Thermal_Control_System.Data_Bus;
                connect OBC_Temp_Sensor.OBC_Temperature_Measurement
                    to SS_Thermal_Control_System.Data_Bus;
                connect EPS_Temp_Sensor.EPS_Temperature_Measurement
                    to SS_Thermal_Control_System.Data_Bus;

                bind EPS_Temp_Sensor.EPS_Temperature_Measurement =
                    Use_TCS.Measured_Temperature_Input;
                bind EPS_Heater.Power = Use_TCS.Heating_Power_Input;
                bind EPS_Heater.Minimal_Temperature = Use_TCS.Minimal_Temperature_Input;
                bind Data_Bus.Cmd = Use_TCS.Command;

                perform action Use_TCS : UseTCS {
                    in Command redefines Command;
                    in Minimal_Temperature_Input redefines Minimal_Temperature_Input;
                    in Measured_Temperature_Input redefines Measured_Temperature_Input;
                    in Heating_Power_Input redefines Heating_Power_Input;

                    // if Command.Type == "Start_Command" {
                    // loop {
                    perform action Read_Temperature redefines Read_Temperature {
                        bind temp = Measured_Temperature_Input;
                    }

                    then perform action Control_Temperature redefines Control_Temperature {
                        bind Control_Temperature.Minimal_Temperature = Minimal_Temperature_Input;
                        bind Control_Temperature.Heating_Power = Heating_Power_Input;
                        bind Control_Temperature.Temp_Reading = Read_Temperature.temp;
                    }
                    // } until Command.Type == "Stop_Command";
                    // }

                    //ask
                }
            }

            // =========================
            // PAYLOAD
            // =========================

            part SS_Satellite_Payload redefines ss_Satellite_Payload {
                port power_Bus_3V3 :>> power_Bus_3V3; //ask
                port Power_Bus_5V :>> power_Bus_5V;
                port Data_Bus :>> data_Bus;
                in port PL_Solar_Input redefines solar_Input;

                part Power_Filtering_Block redefines power_Filtering_Block {
                    port power_Bus_3V3 redefines power_Bus_3V3;
                    port power_Bus_5V redefines power_Bus_5V;
                    port Power_Bus_Filtered_5V redefines power_Bus_Filtered_5V;
                    port Power_Bus_Filtered_3V3 redefines power_Bus_Filtered_3V3;
                }

                part Mppt_Block redefines mppt_Block {
                    part Mppt_Unit redefines mppt_Unit [2] {
                        port Mppt_Controller redefines Mppt_Controller;
                    }
                    part Power_Dump_Resistor redefines power_Dump_Resistor [2];
                    port Power_Bus_Filtered_3V3 redefines power_Bus_Filtered_3V3;
                    port Mppt_Controller redefines mppt_Controller;
                    connect Mppt_Unit.Mppt_Controller to Mppt_Block.Mppt_Controller;
                }

                part Iv_Sweep_And_Reverse_Bias_Block redefines iv_Sweep_And_Reverse_Bias_Block {
                    port Power_Bus_Filtered_5V redefines power_Bus_Filtered_5V;
                    port Data_Bus redefines Data_Bus;
                    part Current_And_Voltage_Sensing_Block
                        redefines current_And_Voltage_Sensing_Block {
                        port Voltage_Current_Sense_Measurement
                            redefines voltage_Current_Sense_Measurement;
                    }

                    connect Iv_Sweep_And_Reverse_Bias_Block.Data_Bus
                        to Current_And_Voltage_Sensing_Block.Voltage_Current_Sense_Measurement;
                }

                part Env_Sensors_Block redefines env_Sensors_Block {
                    port Power_Bus_Filtered_3V3 redefines power_Bus_Filtered_3V3;
                    in port Solar_Input redefines solar_Input;

                    port Data_Bus redefines Data_Bus;

                    part Temperature_Sensor_At_Environment
                        redefines temperature_Sensor_At_Environment {
                        port Temperature_Port redefines temperature_Port;
                    }
                    part Irradiance_Sensor_Block redefines irradiance_Sensor_Block {
                        port Irradiance_Sensor_Measurement redefines irradiance_Sensor_Measurement;
                        in port Solar_Input redefines Solar_Input;
                    }
                    part Radiation_Dose_Sensor redefines radiation_Dose_Sensor {
                        port Radiation_Sensor_Measurement redefines radiation_Sensor_Measurement;
                        in port Solar_Input redefines Solar_Input;
                    }
                    part Spectrometer redefines spectrometer {
                        port Spectrometer_Sensor_Measurement
                            redefines spectrometer_Sensor_Measurement;
                        in port Solar_Input redefines Solar_Input;
                    }

                    connect Temperature_Sensor_At_Environment.Temperature_Port
                        to Env_Sensors_Block.Data_Bus;
                    connect Env_Sensors_Block.Solar_Input to Irradiance_Sensor_Block.Solar_Input;
                    connect Env_Sensors_Block.Solar_Input to Radiation_Dose_Sensor.Solar_Input;
                    connect Env_Sensors_Block.Solar_Input to Spectrometer.Solar_Input;
                    connect Irradiance_Sensor_Block.Irradiance_Sensor_Measurement
                        to Env_Sensors_Block.Data_Bus;
                    connect Spectrometer.Spectrometer_Sensor_Measurement
                        to Env_Sensors_Block.Data_Bus;
                    connect Radiation_Dose_Sensor.Radiation_Sensor_Measurement
                        to Env_Sensors_Block.Data_Bus;
                }

                part solar_Cells_Block redefines solar_Cells_Block {
                    in port Solar_Input redefines solar_Input;
                    port mppt_Controller redefines mppt_Controller;

                    part Psc_Connector_And_Protection redefines psc_Connector_And_Protection {
                        attribute Name redefines name = "Perovskite Coupon Protection";
                        attribute Mass redefines mass = 0.05 [SI::kg];
                    }

                    part Perovskite_Solar_Array_Coupon redefines perovskite_Solar_Array_Coupon [1] {
                        attribute Name redefines name = "PSC Coupon #1";
                        attribute Mass redefines mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines power_Consumption = 0.0 [SI::W];
                        attribute Power_Generation redefines power_Generation = 1.0 [SI::W];
                        attribute Manufacturer redefines manufacturer = "TBD";
                        in port Solar_Input redefines solar_Input;
                        port Electrode_Connection redefines electrode_Connection;
                    }

                    part Reference_Silicon_Solar_Array_Coupon
                        redefines reference_Silicon_Solar_Array_Coupon [1] {
                        attribute Name redefines name = "Si Reference Coupon #1";
                        attribute Mass redefines mass = 0.02 [SI::kg];
                        attribute PowerConsumption redefines power_Consumption = 0.0 [SI::W];
                        attribute Power_Generation redefines power_Generation = 1.0 [SI::W];
                        in port Solar_Input redefines solar_Input;
                        port Electrode_Connection redefines electrode_Connection;
                    }

                    bind solar_Cells_Block.Solar_Input = Perovskite_Solar_Array_Coupon.Solar_Input;
                    bind solar_Cells_Block.Solar_Input =
                        Reference_Silicon_Solar_Array_Coupon.Solar_Input;
                    bind solar_Cells_Block.mppt_Controller =
                        Perovskite_Solar_Array_Coupon.Electrode_Connection;
                    bind solar_Cells_Block.mppt_Controller =
                        Reference_Silicon_Solar_Array_Coupon.Electrode_Connection;
                }

                bind Mppt_Block.Mppt_Controller = solar_Cells_Block.mppt_Controller; //ask
                bind SS_Satellite_Payload.Data_Bus = Env_Sensors_Block.Data_Bus;
                bind SS_Satellite_Payload.Data_Bus = Iv_Sweep_And_Reverse_Bias_Block.Data_Bus;
                bind SS_Satellite_Payload.PL_Solar_Input = solar_Cells_Block.Solar_Input;
                bind SS_Satellite_Payload.PL_Solar_Input = Env_Sensors_Block.Solar_Input;
                bind SS_Satellite_Payload.Power_Bus_5V = Power_Filtering_Block.power_Bus_5V;
                bind SS_Satellite_Payload.power_Bus_3V3 = Power_Filtering_Block.power_Bus_3V3;

                connect Power_Filtering_Block.Power_Bus_Filtered_3V3
                    to Env_Sensors_Block.Power_Bus_Filtered_3V3;
                connect Power_Filtering_Block.Power_Bus_Filtered_3V3
                    to Mppt_Block.Power_Bus_Filtered_3V3;
                connect Power_Filtering_Block.Power_Bus_Filtered_5V
                    to Iv_Sweep_And_Reverse_Bias_Block.Power_Bus_Filtered_5V;
            }

            // =========================
            // SS connections
            // =========================
            connect SS_Electrical_Power_System.Data_Bus to SS_On_Board_Data_Handling.Data_Bus;

            connect SS_Satellite_Payload.Data_Bus to SS_On_Board_Data_Handling.Data_Bus;
            connect SS_Communication_System.Data_Bus to SS_On_Board_Data_Handling.Data_Bus;
            connect SS_Attitude_And_Orbit_Control_System.Data_Bus
                to SS_On_Board_Data_Handling.Data_Bus;

            // electrical

            connect SS_Electrical_Power_System.Power_Bus_5V to SS_Communication_System.Power_Bus_5V;
            connect SS_Electrical_Power_System.Power_Bus_3V3
                to SS_Attitude_And_Orbit_Control_System.Power_Bus_3V3;
            connect SS_Electrical_Power_System.Power_Bus_5V
                to SS_Attitude_And_Orbit_Control_System.Power_Bus_5V;
            connect SS_Electrical_Power_System.Power_Bus_5V to SS_Satellite_Payload.Power_Bus_5V;
            connect SS_Electrical_Power_System.Power_Bus_3V3 to SS_Satellite_Payload.power_Bus_3V3;
            connect SS_Electrical_Power_System.Power_Bus_3V3
                to SS_On_Board_Data_Handling.Power_Bus_3V3;

            // command connections

            connect SS_Electrical_Power_System.Data_Bus to SS_Thermal_Control_System.Data_Bus;

            // sun connections
            bind HEALIOS_Space_Segment.Satellite_Solar_Environment =
                SS_Electrical_Power_System.EPS_Solar_Input;
            bind HEALIOS_Space_Segment.Satellite_Solar_Environment =
                SS_Satellite_Payload.PL_Solar_Input;
        }

        part HEALIOS_Ground_Segment redefines ground_Segment {
            port Telecommand_Port redefines telecommand_Port;
            port Telemetry_Port redefines telemetry_Port;

            part Ground_Station redefines ground_Station {
                port Tc_Port redefines Telecommand_Port;
                port Tm_Port redefines Telemetry_Port;

                port Mission_Control_Centre_TC_Port redefines mission_Control_Centre_TC_Port;
                port Mission_Control_Centre_TM_Port redefines mission_Control_Centre_TM_Port;
                port Data_Centre_TM_Port redefines data_Centre_TM_Port;
                port Mission_Control_Centre_Pass_Plan_Port
                    redefines mission_Control_Centre_Pass_Plan_Port;
                port Mission_Control_Centre_Tracking_Port
                    redefines mission_Control_Centre_Tracking_Port;
                port Data_Centre_Archive_Port redefines data_Centre_Archive_Port;

                part Antenna_Part redefines antenna_Part {
                    attribute name redefines name = "UHF Ground Antenna";
                    attribute band redefines band = "UHF";
                    attribute gain redefines gain = 12.0;

                    in port Uplink_In redefines uplink_In;
                    out port Downlink_Out redefines downlink_Out;
                }

                part Crypto_Unit_Part redefines crypto_Unit_Part {
                    attribute name redefines name = "Ground Crypto/Integrity";
                    attribute downlinkVerifyEnabled redefines downlinkVerifyEnabled = true;
                    attribute downlinkDecryptEnabled redefines downlinkDecryptEnabled = true;
                    attribute uplinkAuthEnabled redefines uplinkAuthEnabled = true;
                    attribute uplinkEncryptEnabled redefines uplinkEncryptEnabled = true;

                    in port TC_In redefines telecommand_In;
                    out port TC_Out redefines telecommand_Out;

                    in port TM_In redefines telemetry_In;
                    out port TM_Out redefines telemetry_Out;
                }

                part Pass_Predictor_Part redefines pass_Predictor_Part {
                    attribute name redefines name = "Pass Predictor";
                    attribute usesTLE redefines usesTLE = true;

                    port PassPlan_Out redefines pass_Plan_Out;
                    port Tracking_Out redefines tracking_Out;
                }

                perform action Auth_Encrypt_Action redefines auth_Encrypt_Action {
                    in Telecommand_To_Encrypt : MissionPackage::GroundCommand;
                    out Secured_Encrypted_Telecommand : MissionPackage::GroundCommand;
                }

                perform action Uplink_Action redefines uplink_Action {
                    in item Modulated_Uplink_Signal : MissionPackage::GroundCommand;
                    out item Uplink_Signal_Sent : MissionPackage::GroundCommand;
                }

                perform action Downlink_Action redefines downlink_Action {
                    out item Captured_Encrypted_Telemetry : MissionPackage::TelemetryData;
                    in item Incoming_Radio_Signal : TelemetryData;
                }

                perform action Verify_Decrypt_Action redefines verify_Decrypt_Action {
                    in item Telemetry_To_Decrypt : MissionPackage::TelemetryData;
                    out item Verified_Ground_Telemetry_Data : MissionPackage::TelemetryData;
                }

                perform action Archive_Action redefines archive_Action {
                    in item Telemetry_To_Archive : MissionPackage::TelemetryData;
                    out item Record_of_Telemetry : ArchiveRecord;
                }

                perform action Tracking_Action redefines tracking_Action {
                    in item Satellite_plan : PassPlan;
                    out item Tracking_Data : TrackingData;
                }

                flow of MissionPackage::GroundCommand
                    from Mission_Control_Centre_TC_Port
                    to Auth_Encrypt_Action.Telecommand_To_Encrypt;

                flow of MissionPackage::GroundCommand
                    from Auth_Encrypt_Action.Secured_Encrypted_Telecommand
                    to Uplink_Action.Modulated_Uplink_Signal;

                flow of MissionPackage::GroundCommand
                    from Uplink_Action.Uplink_Signal_Sent to Tc_Port;

                flow of MissionPackage::TelemetryData
                    from Tm_Port to Downlink_Action.Incoming_Radio_Signal;

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
                    from Archive_Action.Record_of_Telemetry to Data_Centre_Archive_Port;

                flow of PassPlan
                    from Mission_Control_Centre_Pass_Plan_Port to Tracking_Action.Satellite_plan;

                flow of TrackingData
                    from Tracking_Action.Tracking_Data to Mission_Control_Centre_Tracking_Port;

                connect Ground_Station.Mission_Control_Centre_TC_Port to Crypto_Unit_Part.TC_In;
                connect Crypto_Unit_Part.TC_Out to Antenna_Part.Uplink_In;

                connect Antenna_Part.Downlink_Out to Crypto_Unit_Part.TM_In;
                connect Crypto_Unit_Part.TM_Out to Ground_Station.Mission_Control_Centre_TM_Port;
                connect Crypto_Unit_Part.TM_Out to Ground_Station.Data_Centre_TM_Port;

                connect Ground_Station.Mission_Control_Centre_Pass_Plan_Port
                    to Pass_Predictor_Part.PassPlan_Out;
                connect Pass_Predictor_Part.Tracking_Out
                    to Ground_Station.Mission_Control_Centre_Tracking_Port;
            }

            part Mission_Control_Centre redefines mission_Control_Centre {
                port Ground_Station_TC_Port redefines ground_Station_TC_Port;
                port Ground_Station_TM_Port redefines ground_Station_TM_Port;
                port Ground_Station_Pass_Plan_Port redefines ground_Station_Pass_Plan_Port;
                port Ground_Station_Tracking_Port redefines ground_Station_Tracking_Port;

                part Auth_Service_Part redefines auth_Service_Part {
                    attribute name redefines name = "Mission Control Centre Authentication Service";
                    attribute method redefines method = "MFA";

                    in port Auth_Request_In redefines auth_Request_In;
                    out port Auth_Token_Out redefines auth_Token_Out;
                }

                part Operations_Console_Part redefines operations_Console_Part {
                    attribute name redefines name = "Operations Console";

                    out port Operator_Request_Out redefines operator_Request_Out;
                    in port Auth_Token_In redefines auth_Token_In;

                    out port TC_Out redefines telecommand_Out;
                    in port TM_In redefines telemetry_In;
                }

                part Pass_Planner_Part redefines pass_Planner_Part {
                    attribute name redefines name = "Pass Planner";
                    attribute usesTLE redefines usesTLE = true;

                    out port PassPlan_Out redefines pass_Plan_Out;
                    in port Tracking_Satellite redefines tracking_Satellite;
                }

                connect Operations_Console_Part.Operator_Request_Out
                    to Auth_Service_Part.Auth_Request_In;
                connect Auth_Service_Part.Auth_Token_Out to Operations_Console_Part.Auth_Token_In;
                connect Mission_Control_Centre.Ground_Station_Pass_Plan_Port
                    to Pass_Planner_Part.Tracking_Satellite;
                connect Operations_Console_Part.TC_Out
                    to Mission_Control_Centre.Ground_Station_TC_Port;
                connect Mission_Control_Centre.Ground_Station_TM_Port
                    to Operations_Console_Part.TM_In;

                connect Pass_Planner_Part.PassPlan_Out
                    to Mission_Control_Centre.Ground_Station_Pass_Plan_Port;

                perform action Authorize_Action redefines authorize_Action {
                    in item Operator_Request : OperatorRequest;
                    out item Auth_Token : AuthToken;
                }

                perform action Generate_TC_Action redefines generate_Telecommand_Action {
                    in item Auth_Token : AuthToken;
                    out item Raw_Unsecured_Telecommand : MissionPackage::GroundCommand;
                }

                perform action Plan_Passes_Action redefines plan_Passes_Action {
                    out item Plan_of_Satellite_Path : PassPlan;
                    in item Track_of_Satellite_Path : TrackingData;
                }

                perform action Monitor_TM_Action redefines monitor_Telemetry_Action {
                    in item Telemetry_For_Monitoring : MissionPackage::TelemetryData;
                }

                flow of OperatorRequest
                    from Operations_Console_Part.Operator_Request_Out
                    to Authorize_Action.Operator_Request;

                flow of AuthToken
                    from Authorize_Action.Auth_Token to Operations_Console_Part.Auth_Token_In;

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

                flow of TrackingData
                    from Mission_Control_Centre.Ground_Station_Pass_Plan_Port
                    to Plan_Passes_Action.Track_of_Satellite_Path;
            }

            part Data_Centre redefines data_Centre {
                port Ground_Station_TM_Port redefines ground_Station_TM_Port;
                port Ground_Station_Records_Port redefines ground_Station_Records_Port;
                port Mission_Control_Centre_TM_Products_Port
                    redefines mission_Control_Centre_TM_Products_Port;

                part Structured_Archive_Part redefines structured_Archive_Part {
                    attribute name redefines name = "Structured Archive";
                    attribute retention redefines retention = 1825 [SI::day];

                    in port Record_In redefines record_In;
                }

                part Data_Validator_Part redefines data_Validator_Part {
                    attribute name redefines name = "Telemetry Validator";

                    in port TM_In redefines telemetry_In;
                    out port TM_Validated_Out redefines telemetry_Validated_Out;
                }

                connect Data_Centre.Ground_Station_TM_Port to Data_Validator_Part.TM_In;

                connect Data_Validator_Part.TM_Validated_Out
                    to Data_Centre.Mission_Control_Centre_TM_Products_Port;

                connect Data_Centre.Ground_Station_Records_Port
                    to Structured_Archive_Part.Record_In.record_In;

                connect Data_Centre.Ground_Station_Records_Port
                    to Structured_Archive_Part.Record_In;

                perform action Validate_Action redefines validate_Action {
                    in item Telemetry_For_Validate : MissionPackage::TelemetryData;
                    out item Validated_Telemetry : MissionPackage::TelemetryData;
                }

                perform action Store_Action redefines store_Action {
                    in item Record_of_Satellite_Data
                        redefines Record_of_Satellite_Data : ArchiveRecord;
                }

                flow of MissionPackage::TelemetryData
                    from Data_Centre.Ground_Station_TM_Port
                    to Validate_Action.Telemetry_For_Validate;

                flow of MissionPackage::TelemetryData
                    from Validate_Action.Validated_Telemetry
                    to Data_Centre.Mission_Control_Centre_TM_Products_Port;

                flow of ArchiveRecord
                    from Data_Centre.Ground_Station_Records_Port
                    to Store_Action.Record_of_Satellite_Data;
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
            bind Telemetry_Port = Ground_Station.Tm_Port;
        }
    }
}
