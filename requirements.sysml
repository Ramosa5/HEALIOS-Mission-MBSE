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
}