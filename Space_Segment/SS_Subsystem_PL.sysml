package PayloadPackage {
    private import MissionPackage::*;
    private import SpaceActionsPackage::*;
    private import ElectricalPowerSystemPackage::*;
    private import ISQ::*;
    private import EnvironmentPackage::*;
    private import OnBoardDataHandlingSystemPackage::*;
    private import UnitTypesPackage::*;

    part def PerovskiteCellConnectorAndProtection {
        attribute name : String;
        attribute mass : MV;
    }

    part def IVSweepLoad_MOSFET specializes GeneralElectricalComponent;
    part def IVSweepLoad_OpAmp specializes GeneralElectricalComponent;
    part def CurrentAndVoltageSensingBlock specializes GeneralElectricalComponent{
        port voltage_Current_Sense_Measurement : ~OnBoardDataHandlingSystemPackage::DataBus;
    }
    part def IVSweepLoad_DAC specializes GeneralElectricalComponent;
    part def IrradianceSensorBlock specializes GeneralElectricalComponent {
        port irradiance_Sensor_Measurement : ~OnBoardDataHandlingSystemPackage::DataBus;
    }
    part def RadiationDoseSensor specializes GeneralElectricalComponent {
        port radiation_Sensor_Measurement : ~OnBoardDataHandlingSystemPackage::DataBus;
    }
    part def SpectrometerPackage specializes GeneralElectricalComponent{
        port spectrometer_Sensor_Measurement : ~OnBoardDataHandlingSystemPackage::DataBus;
    }
    part def PowerFilteringUnit specializes GeneralElectricalComponent;
    part def DigitalAnalogConverter specializes GeneralElectricalComponent;

    part def PerovskiteSolarArray specializes SolarArray {
        attribute manufacturer : String;
    }

    part def PowerFilteringBlock {
        port power_Bus_3V3 : ElectricalPowerSystemPackage::PowerBus;
        port power_Bus_5V : ElectricalPowerSystemPackage::PowerBus;
        port power_Bus_Filtered_5V : ElectricalPowerSystemPackage::PowerBus;
        port power_Bus_Filtered_3V3 : ElectricalPowerSystemPackage::PowerBus;

        part power_Filter : PowerFilteringUnit;
    }

    part def SolarCellsBlock {
        part perovskite_Solar_Array_Coupon : PerovskiteSolarArray [1..*];
        part reference_Silicon_Solar_Array_Coupon : SolarArray [1..*];
        part psc_Connector_And_Protection : PerovskiteCellConnectorAndProtection;
        port solar_Input : ~StellarEnvironment;
        port mppt_Controller : MPPTControl;
    }

    part def MPPTBlock {
        port power_Bus_Filtered_3V3 : ElectricalPowerSystemPackage::PowerBus;
        port mppt_Controller : MPPTControl;
        part mppt_Unit : MPPTUnit [1..*];
        part power_Dump_Resistor : Resistor [1..*];
    }

    part def IVSweepAndReverseBiasBlock {
        port power_Bus_Filtered_5V : ElectricalPowerSystemPackage::PowerBus;

        part iv_Sweep_Load_Shunt_Resistor : Resistor [1];
        part iv_Sweep_Load_MOSFET : IVSweepLoad_MOSFET [1];
        part iv_Sweep_Load_OpAmp : IVSweepLoad_OpAmp [1];
        part iv_Sweep_Load_DAC : IVSweepLoad_DAC [1];
        part current_And_Voltage_Sensing_Block : CurrentAndVoltageSensingBlock [1];
    }

    part def EnvironmentSensorsBlock {
        port power_Bus_Filtered_3V3 : ElectricalPowerSystemPackage::PowerBus;
    
        port temp_Out : MissionPackage::OnBoardStatus;
        port irr_Out : MissionPackage::OnBoardStatus;
        port rad_Out : MissionPackage::OnBoardStatus;
        port spec_Out : MissionPackage::OnBoardStatus;
        port solar_Input : ~StellarEnvironment;

        part temperature_Sensor_At_Environment : TemperatureSensor;
        part irradiance_Sensor_Block : IrradianceSensorBlock;
        part radiation_Dose_Sensor : RadiationDoseSensor;
        part spectrometer : SpectrometerPackage;

        action read_PL_Temperature : ReadTemperature;
    }

    part def Payload {
        port power_Bus_3V3 : ~PowerBus;
        port power_Bus_5V : ~PowerBus;
        port data_Bus : ~DataBus;
        port solar_Input : ~StellarEnvironment;

        part power_Filtering_Block : PowerFilteringBlock;
        part solar_Cells_Block : SolarCellsBlock;
        part mppt_Block : MPPTBlock;
        part iv_Sweep_And_Reverse_Bias_Block : IVSweepAndReverseBiasBlock;
        part env_Sensors_Block : EnvironmentSensorsBlock;

        bind env_Sensors_Block.power_Bus_Filtered_3V3 =
            power_Filtering_Block.power_Bus_Filtered_3V3;
        bind iv_Sweep_And_Reverse_Bias_Block.power_Bus_Filtered_5V =
            power_Filtering_Block.power_Bus_Filtered_5V;
        bind mppt_Block.power_Bus_Filtered_3V3 = power_Filtering_Block.power_Bus_Filtered_3V3;

        perform action apply_Reverse_Bias : applyControlledReverseBiasToPSC;
        perform action measure_Iv_Curves : MeasureIVCurvesOfPSC;
        perform action maintain_Mpp : maintainMaximumPowerPoint;
        perform action collect_Data : collectExperimentalData;

        bind apply_Reverse_Bias.apply_Reverse_Bias_Voltage_Command = data_Bus.Cmd;
        bind measure_Iv_Curves.measure_IV_Curves_Of_PSC_Command = data_Bus.Cmd;
        bind maintain_Mpp.maintain_MPP_Command = data_Bus.Cmd;
        bind collect_Data.collect_Experimental_Data_Command = data_Bus.Cmd;

        bind data_Bus.Data = apply_Reverse_Bias.voltage_Application_Status;
        bind data_Bus.Data = measure_Iv_Curves.measured_IV_Curves_Status;
        bind data_Bus.Data = maintain_Mpp.mpp_Status;

        bind data_Bus.Data = collect_Data.measured_Radiation_Status;
        bind data_Bus.Data = collect_Data.measured_Temperature_Status;
        bind data_Bus.Data = collect_Data.measured_Spectrum_Status;
        bind data_Bus.Data = collect_Data.measured_Irradiance_Status;
    }
}
