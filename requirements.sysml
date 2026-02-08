private import HEALIOS::*;

package Mission_Requirements{
    requirement def <R_M_001> PSC_Performance {
        doc
        /* The mission shall characterise the performance of Perovskite Solar Cells (PSC) by measuring Current-Voltage (I-V) curves. */

        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder Perovskite_Research_Institutes;
        stakeholder Perovskire_Solar_Cell_Manufacturer;
    }

    requirement def <R_M_002> Orbit_Definition {
        doc
        /* The mission shall be operated in the Low Earth Orbit (LEO). */
        
        subject Mission : HEALIOS::HEALIOS_System;

        stakeholder ESA_Fly_Your_Satellite;
    }

    requirement def <R_M_003> Self_Healing_Experiments {
        doc /* The mission shall perform active self-healing experiments on designated PSC samples by applying a controlled reverse-bias voltage during orbital eclipse phases. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_004> Control_Group_Benchmark {
        doc /* The mission shall utilise traditional solar cells as a control group to benchmark the degradation rates of the perovskite payload. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_005> Environmental_Repetitivity {
        doc /* The mission scenarios shall enable repetitive environmental conditions for the perovskite solar cells and the benchmark group. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_006> Platform_Conformity {
        doc /* The mission should utilise a 1U CubeSat platform conformant to Figure 5 and Figure 6. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_007> Launch_Mass {
        doc /* The mission should have a total launch mass not exceeding 2 kg within 0.001 kg tolerance. */
        subject system : HEALIOS::HEALIOS_System;

    constraint {
        system.maxMass <= 2.0 [SI::kg]
        }
    }

    requirement def <R_M_008> Autonomous_Management {
        doc /* The mission shall autonomously manage experiment execution, including eclipse detection and data logging, to mitigate limited ground contact time. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_009> Commissioning_Start {
        doc /* The mission shall ensure that all commissioning activities are started after the deployment from the dispenser. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_010> Telemetry_Correlation {
        doc /* The mission shall provide downlinked telemetry data suitable for correlation with terrestrial ageing data and literature. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_011> ESA_Compliance {
        doc /* The mission shall comply with the programmatic and safety standards of the ESA "Fly Your Satellite!" programme. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_012> Mission_Duration {
        doc /* The mission shall operate in orbit for a duration sufficient to generate statistically significant degradation and recovery data (Target: 1 Year). */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_013> EOL_Plan {
        doc /* The mission documentation shall provide an EOL plan and update its relevance and applicability. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_014> Core_Team_Composition {
        doc /* The core mission team shall consist of at least 4 university students enrolled in a Master's or Bachelor's programme within an ESA Member State. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_015> Academic_Supervision {
        doc /* The project shall be supervised by at least 2 academic professors or lecturers who provide formal endorsement and access to university facilities. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_016> Academic_Integration {
        doc /* The mission team shall identify specific thesis topics or academic credits associated with the project work packages. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_017> Test_Facility_Usage {
        doc /* The mission documentation shall include the use of ESA environmental test facilities (e.g., Thermal Vacuum Chamber, Electrodynamic Shaker). */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_018> Educational_Return {
        doc /* The mission shall demonstrate a clear educational return. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_019> Dataset_Format {
        doc /* The mission shall provide experiment datasets in a format and with metadata completeness necessary to support post-flight comparison to pre-flight terrestrial testing and published literature. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_020> Ground_Station_Support {
        doc /* The mission shall include at least one operational GS capable of commanding and receiving telemetry from the 1U CubeSat. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_021> Safety_Implementation {
        doc /* The mission plan and procedures shall ensure the safety of personnel, equipment, and the launch vehicle by implementing hazard control measures and complying with the safety requirements of the launch provider and test facilities. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_022> ITU_Compliance {
        doc /* The CubeSat and ground station shall comply with International Telecommunication Union (ITU) requirements. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_023> National_Registration {
        doc /* The CubeSat Team shall provide evidence of the successful registration of the satellite in the national register of space objects. */
        subject Mission : HEALIOS::HEALIOS_System;
    }

    requirement def <R_M_024> UN_Registration {
        doc /* The CubeSat Team shall provide documentation of the successful registration of the satellite in the United Nations Register of Objects Launched into Outer Space of UNOOSA. */
        subject Mission : HEALIOS::HEALIOS_System;
    }
}
