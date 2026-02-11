package PayloadPackage {
    private import MissionPackage::*;
    private import SpaceActionsPackage::*;
    private import ElectricalPowerSystemPackage::*;
    private import ISQ::*;
    private import EnvironmentPackage::*;
    private import OnBoardDataHandlingSystemPackage::*;

    // --- COTS blocks (definitions WITHOUT "name") ---
    part def PerovskiteCellConnectorAndProtection {
        attribute Name : String;
        attribute Mass : ISQ::MassValue;
    }

    part def IVSweepLoad_MOSFET specializes GeneralElectricalComponent;
    part def IVSweepLoad_OpAmp specializes GeneralElectricalComponent;
    part def CurrentAndVoltageSensingBlock specializes GeneralElectricalComponent{
        port Voltage_Current_Sense_Measurement : ~OnBoardDataHandlingSystemPackage::DataBus;
    }
    part def IVSweepLoad_DAC specializes GeneralElectricalComponent;
    part def IrradianceSensorBlock specializes GeneralElectricalComponent {
        port Irradiance_Sensor_Measurement : ~OnBoardDataHandlingSystemPackage::DataBus;
    }
    part def RadiationDoseSensor specializes GeneralElectricalComponent {
        port Radiation_Sensor_Measurement : ~OnBoardDataHandlingSystemPackage::DataBus;
    }
    part def SpectrometerPackage specializes GeneralElectricalComponent{
        port Spectrometer_Sensor_Measurement : ~OnBoardDataHandlingSystemPackage::DataBus;
    }
    part def PowerFilteringUnit specializes GeneralElectricalComponent;
    part def DigitalAnalogConverter specializes GeneralElectricalComponent;

    part def PerovskiteSolarArray specializes SolarArray {
        attribute Manufacturer : String;
    }

    part def PowerFilteringBlock {
        port Power_Bus_3V3 : ElectricalPowerSystemPackage::PowerBus;
        port Power_Bus_5V : ElectricalPowerSystemPackage::PowerBus;
        port Power_Bus_Filtered_5V : ElectricalPowerSystemPackage::PowerBus;
        port Power_Bus_Filtered_3V3 : ElectricalPowerSystemPackage::PowerBus;

        part Power_Filter : PowerFilteringUnit;
    }

    part def SolarCellsBlock {
        part Perovskite_Solar_Array_Coupon : PerovskiteSolarArray [1..*];
        part Reference_Silicon_Solar_Array_Coupon : SolarArray [1..*];
        part Psc_Connector_And_Protection : PerovskiteCellConnectorAndProtection;
        port Solar_Input : ~StellarEnvironment;
        port Mppt_Controller : MPPTControl;
    }

    part def MPPTBlock {
        port Power_Bus_Filtered_3V3 : ElectricalPowerSystemPackage::PowerBus;
        port Mppt_Controller : MPPTControl;
        part Mppt_Unit : MPPTUnit [1..*];
        part Power_Dump_Resistor : Resistor [1..*];
    }

    part def IVSweepAndReverseBiasBlock {
        port Power_Bus_Filtered_5V : ElectricalPowerSystemPackage::PowerBus;

        part Iv_Sweep_Load_Shunt_Resistor : Resistor [1];
        part Iv_Sweep_Load_MOSFET : IVSweepLoad_MOSFET [1];
        part Iv_Sweep_Load_OpAmp : IVSweepLoad_OpAmp [1];
        part Iv_Sweep_Load_DAC : IVSweepLoad_DAC [1];
        part Current_And_Voltage_Sensing_Block : CurrentAndVoltageSensingBlock [1];
    }

    part def EnvironmentSensorsBlock {
        port Power_Bus_Filtered_3V3 : ElectricalPowerSystemPackage::PowerBus;
    
        port Temp_Out : MissionPackage::OnBoardStatus;
        port Irr_Out : MissionPackage::OnBoardStatus;
        port Rad_Out : MissionPackage::OnBoardStatus;
        port Spec_Out : MissionPackage::OnBoardStatus;
        port Solar_Input : ~StellarEnvironment;

        part Temperature_Sensor_At_Environment : TemperatureSensor;
        part Irradiance_Sensor_Block : IrradianceSensorBlock;
        part Radiation_Dose_Sensor : RadiationDoseSensor;
        part Spectrometer : SpectrometerPackage;

        action Read_PL_Temperature : ReadTemperature;
    }

    part def Payload {
        // Ports for integration
        port Power_Bus_3V3 : ~PowerBus;
        port Power_Bus_5V : ~PowerBus;
        port Data_Bus : ~DataBus;
        port Solar_Input : ~StellarEnvironment;
        
        // Subparts (NO default names here)
        part Power_Filtering_Block : PowerFilteringBlock;
        part Solar_Cells_Block : SolarCellsBlock;
        part Mppt_Block : MPPTBlock;
        part Iv_Sweep_And_Reverse_Bias_Block : IVSweepAndReverseBiasBlock;
        part Env_Sensors_Block : EnvironmentSensorsBlock;

        bind Env_Sensors_Block.Power_Bus_Filtered_3V3 =
            Power_Filtering_Block.Power_Bus_Filtered_3V3;
        bind Iv_Sweep_And_Reverse_Bias_Block.Power_Bus_Filtered_5V =
            Power_Filtering_Block.Power_Bus_Filtered_5V;
        bind Mppt_Block.Power_Bus_Filtered_3V3 = Power_Filtering_Block.Power_Bus_Filtered_3V3;

        // Actions (usages)
        perform action Apply_Reverse_Bias : applyControlledReverseBiasToPSC;
        perform action Measure_Iv_Curves : MeasureIVCurvesOfPSC;
        perform action Maintain_Mpp : maintainMaximumPowerPoint;
        perform action Collect_Data : collectExperimentalData;

        // Bind command input to the action command inputs
        bind Apply_Reverse_Bias.Apply_Reverse_Bias_Voltage_Command = Data_Bus.Cmd;
        bind Measure_Iv_Curves.Measure_IV_Curves_Of_PSC_Command = Data_Bus.Cmd;
        bind Maintain_Mpp.Maintain_MPP_Command = Data_Bus.Cmd;
        bind Collect_Data.Collect_Experimental_Data_Command = Data_Bus.Cmd;

        // Merge action outputs to payload status out
        bind Data_Bus.Data = Apply_Reverse_Bias.Voltage_Application_Status;
        bind Data_Bus.Data = Measure_Iv_Curves.Measured_IV_Curves_Status;
        bind Data_Bus.Data = Maintain_Mpp.Mpp_Status;

        // Forward sensor results (collectData outputs) via statusOut
        bind Data_Bus.Data = Collect_Data.Measured_Radiation_Status;
        bind Data_Bus.Data = Collect_Data.Measured_Temperature_Status;
        bind Data_Bus.Data = Collect_Data.Measured_Spectrum_Status;
        bind Data_Bus.Data = Collect_Data.Measured_Irradiance_Status;
    }
}
