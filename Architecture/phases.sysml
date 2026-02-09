private import Stakeholders_and_Concerns;
private import Time;

package Mission_Phases {
    public import ScalarValues::*;
    public import ISQ::*;
    public import UnitTypesPackage::*;

    occurrence def LaunchPhase{
        duration : TimeValue = 3 [SI::hour];
    }
    
    occurrence def CommissioningPhase {
        duration : TimeValue = 7 [SI::day];
    }
    
    occurrence def NominalOperationsPhase{
        duration : TimeValue = 358 [SI::day];
    }

    occurrence def DecommissioningPhase{
        assert constraint { 
            duration < 24 [UnitTypesPackage::yr]
            }
    }

    // --- 4. Define the Mission Timeline ---
    occurrence def HEALIOS_Mission {
        
        // DECOMPOSITION: The mission is made of these phases
        occurrence launch : LaunchPhase;

        occurrence commissioning : CommissioningPhase;

        occurrence operations : NominalOperationsPhase;
        occurrence disposal : DecommissioningPhase;

        // SEQUENCING: The order of events (Succession)
        //timeslice launch[1];
        first launch then commissioning;
        //timeslice commissioning[1];
        first operations then disposal;
        //timeslice disposal[1];

    }
}