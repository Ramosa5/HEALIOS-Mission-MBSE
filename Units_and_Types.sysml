package UnitTypesPackage {

    public import MeasurementReferences::*;
    public import SIPrefixes::*;
    public import ISQ::*;

    // ---- TIME ----

    // SI second usage

    attribute yearConv : ConversionByConvention {
        :>> referenceUnit = SI::second;
        :>> conversionFactor = 31557600; // Julian year
    }

    attribute def year :> MeasurementUnit {
        symbol = "yr";
        :>> unitConversion = yearConv;
    }

    attribute yr : year;

    // ---- INFORMATION ----
    attribute def byte :> SimpleUnit {
        symbol = "B";
    }

    attribute byte_usage : byte;

    attribute mbConv : ConversionByPrefix {
        :>> referenceUnit = byte_usage;
        :>> prefix = SIPrefixes::mega;
    }

    attribute def megabyte :> MeasurementUnit {
        symbol = "MB";
        :>> unitConversion = mbConv;
    }

    attribute MB : megabyte;

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
