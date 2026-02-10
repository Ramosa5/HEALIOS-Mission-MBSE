package MissionDomainPackage {
    private import MissionPackage::* ;
    private import StakeholdersDefinitionPackage::*;
    private import Environment::*;
    
    part def CubeSat;
    part def GroundSegmentOperators;
}

package MissionUseCasesDef {
    private import MissionDomainPackage::*;
    private import MissionRequirementsPackage::*;
    private import SpaceSegmentRequirement::*;
    private import GroundSegmentRequirementsPackage::*;

    // **Use Case: Perform Self-Healing Experiment**
    use case def SendCommand {
        doc /* The Ground Segment Operators send a command to the CubeSat. */
        subject Satellite : CubeSat;
        actor HEALIOS_Ground_Segment_Operator : GroundSegmentOperators;
        
        objective {
            doc /* The CubeSat detects eclipse and perform the reverse-bias experiment on Perovskite samples to test self-healing capabilities. Acquires the science data and transfers it to the on-board memory. */
        }
    }

    use case def ProvideData {
        doc /* The HEALIOS mission science data are open-source ready. */
        subject Satellite : CubeSat;
        actor HEALIOS_Ground_Segment_Operator : GroundSegmentOperators;
    }
}