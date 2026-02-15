package UnitTypesPackage {

    public import MeasurementReferences::*;
    public import SIPrefixes::*;
    public import ISQ::*;
    public import SI::*;

    // ---- TIME ----

    // SI second usage
    alias FV for ISQ::ForceValue;
    alias MV for ISQ::MassValue;
    alias Wattage for ISQ::PowerValue;
    alias RV for ISQ::ResistanceValue;

    attribute yearConv : ConversionByConvention {
        :>> referenceUnit = SI::second;
        :>> conversionFactor = 31557600; // Julian year
    }

    attribute def Year :> ISQ::TimeUnit {
        symbol = "yr";
        :>> unitConversion = yearConv;
    }

    attribute yr : Year;

    // ---- INFORMATION ----
    attribute def byte :> SimpleUnit {
        symbol = "B";
    }

    attribute byte_usage : byte;

    attribute mbConv : ConversionByPrefix {
        :>> referenceUnit = byte_usage;
        :>> prefix = SIPrefixes::mega;
    }

    attribute def Megabyte :> MeasurementUnit {
        symbol = "MB";
        :>> unitConversion = mbConv;
    }
    
    attribute MB : Megabyte;

}

package Example {

    public import UnitTypesPackage::*;
    public import ScalarValues::*;

    part def OnboardMemory {
        attribute capacity = 256 [UnitTypesPackage::MB];
    }

    part def time_to_launch {
        attribute duration = 2 [UnitTypesPackage::yr];
    }
    
}
