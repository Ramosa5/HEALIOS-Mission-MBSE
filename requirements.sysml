private import HEALIOS::*;

package Mission_Requirements{

    requirement def <R_M_001> Self_Healing_Experiments {
        doc /* The mission shall perform active self-healing experiments on designated PSC samples by applying a controlled reverse-bias voltage during orbital eclipse phases. */

        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder Perovskite_Research_Institutes;
        stakeholder Perovskite_Solar_Cell_Manufacturers;

        requirement a : R_M_001_a;
        requirement b : R_M_001_b;
        requirement c : R_M_001_c;
        requirement d : R_M_001_d;

    }

    requirement def <R_M_001_a> PSC_Performance {
        doc
        /* The mission shall characterise the performance of Perovskite Solar Cells (PSC) by measuring open-circuit voltage and short-circuit current, what results in Current-Voltage (I-V) curves. */

        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_001_b> Control_Group_Benchmark {
        doc /* The mission shall utilise traditional solar cells as a control group to benchmark the degradation rates of the perovskite payload. */

        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_001_c> Enivornment_Characterisation {
        doc /* The mission shall characterise the space environment by measuring radiation, irradiance, and temperature related to Perovskite Solar Cells samples, to contextualise with observed degradation and self-healing phenomena. */

        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_001_d> Environmental_Repetitivity {
        doc /* The mission scenarios shall enable repetitive environmental conditions for the perovskite solar cells and the benchmark group. */

        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_002> Orbit_Definition {
        doc
        /* The mission shall be operated in the Low Earth Orbit (LEO). */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder ESA_Fly_Your_Satellite;
    }

    requirement def <R_M_003> Platform_Conformity {
        doc /* The mission should utilise a 1U CubeSat platform, conformant to CubeSat Design Specification Rev. 14.1 (February 2022), that enables experiment performance. */
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder ESA_Fly_Your_Satellite;
        stakeholder CubeSat_Community;
        stakeholder Satellite_COTS_Providers;
    }

    requirement def <R_M_004> Autonomous_Management {
        doc /* The mission shall autonomously manage experiment execution, including eclipse detection and data logging, to mitigate limited ground contact time. */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder Perovskite_Research_Institutes;
    }

    requirement def <R_M_005> Dataset_Format {
        doc /* The mission shall provide experiment datasets in a format and with metadata completeness necessary to support post-flight comparison to pre-flight terrestrial testing, and published literature. */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder Perovskite_Research_Institutes;
    }

    requirement def <R_M_006> ESA_Compliance {
        doc /* The mission shall comply with the programmatic and safety standards of the ESA "Fly Your Satellite!" programme. */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder ESA_Fly_Your_Satellite;
    }

    requirement def <R_M_007> Mission_Duration {
        doc /* The mission shall operate in orbit for a duration sufficient to generate statistically significant degradation and recovery data (Target: 1 Year). */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder Perovskite_Research_Institutes;
        stakeholder ESA_Fly_Your_Satellite;
        stakeholder HEALIOS_Team_Community;
    }

    requirement def <R_M_008> EOL_Plan {
        doc /* The mission documentation shall provide an EOL plan and update its relevance and applicability. */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder ESA_Fly_Your_Satellite;
    }

    requirement def <R_M_009> Core_Team_Composition {
        doc /* The core mission team shall consist of at least 4 university students enrolled in a Master's or Bachelor's programme within an ESA Member State. */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder ESA_Fly_Your_Satellite;
        stakeholder HEALIOS_Team_Community;
    }

    requirement def <R_M_010> Academic_Supervision {
        doc /* The project shall be supervised by at least 2 academic professors or lecturers who provide formal endorsement and access to university facilities. */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder ESA_Fly_Your_Satellite;
        stakeholder Gdansk_University_of_Technology;
        stakeholder HSB_Hochschule_Bremen;
        stakeholder HEALIOS_Team_Community;
    }

    requirement def <R_M_011> Academic_Integration {
        doc /* The mission team shall identify specific thesis topics or academic credits associated with the project work packages. */
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder ESA_Fly_Your_Satellite;
        stakeholder Gdansk_University_of_Technology;
        stakeholder HSB_Hochschule_Bremen;
        stakeholder HEALIOS_Team_Community;
    }

    requirement def <R_M_012> Test_Facility_Usage {
        doc /* The mission documentation shall include the use of ESA environmental test facilities (e.g., Thermal Vacuum Chamber, Electrodynamic Shaker). */
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder ESA_Fly_Your_Satellite;
    }

    requirement def <R_M_013> Educational_Return {
        doc /* The mission shall demonstrate a clear educational return. */
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder ESA_Fly_Your_Satellite;
        stakeholder Gdansk_University_of_Technology;
        stakeholder HSB_Hochschule_Bremen;
        stakeholder HEALIOS_Team_Community;
    }

    requirement def <R_M_014> Ground_Station_Support {
        doc /* The mission shall include at least one operational Ground Station capable of commanding and receiving telemetry from the CubeSat. */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder Gdansk_University_of_Technology;
        stakeholder HSB_Hochschule_Bremen;
        stakeholder HEALIOS_Team_Community;
    
    }

    requirement def <R_M_015> Safety_Implementation {
        doc /* The mission plan and procedures shall ensure the safety of personnel, equipment, and the launch vehicle by implementing hazard control measures and complying with the safety requirements of the launch provider and test facilities. */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder ESA_Fly_Your_Satellite;
        stakeholder Gdansk_University_of_Technology;
        stakeholder HSB_Hochschule_Bremen;
        stakeholder HEALIOS_Team_Community;
    }

    requirement def <R_M_016> Launcher_Compliance {
        doc /* The mission architecture and organisation shall comply with the requirements of the selected launch service provider. */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder Launch_Service_Provider;
        stakeholder HEALIOS_Team_Community;
    }

    requirement def <R_M_017> Telecommunication_Compliance {
        doc /* The mission architecture and organisation shall comply with International Telecommunication Union (ITU) and International Amatour Radio Union legislations. */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder International_Telecommunication_Union;
        stakeholder International_Amateur_Radio_Union;

        stakeholder HEALIOS_Team_Community;
    }

    requirement def <R_M_018> UN_Registration {
        doc /* The mission shall be registration of the satellite in the United Nations Register of Objects Launched into Outer Space of UNOOSA, including national registers. */
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder United_Nations_Office_for_Outer_Space_Affairs;
    }
}

package SpaceSegmentRequirement {

    requirement def <R_SS_001> Launch_Mass {
        doc /* The mission should have a total launch mass not exceeding 2 kg within 0.001 kg tolerance. */

        subject SpaceSegment : HEALIOS::SpaceSegment;
        //subject system : HEALIOS::HEALIOS_System;

        stakeholder CubeSat_Community;

    constraint {
        SpaceSegment.maxMass <= 2.0 [SI::kg]
        }
    }
}