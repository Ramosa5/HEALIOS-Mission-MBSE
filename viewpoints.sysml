package Viewpoints {
    private import Stakeholders::*;

    viewpoint def conopsViewpoint {
        doc
        /* Viewpoint for the Concept of Operations (ConOps) of the HEALIOS system */

        concern EducationalReturn {
            subject HEALIOS_System;
            stakeholder ESA_Fly_Your_Satellite;
        }

        concern def ProgrammePhaseCompletion{
            subject HEALIOS_System;
            stakeholder ESA_Fly_Your_Satellite;
        }

        concern def ReviewProcessCompliance{
            subject HEALIOS_System;
            stakeholder ESA_Fly_Your_Satellite;
        }

        concern UniversityEngagement {
            subject HEALIOS_System;
            stakeholder Gdansk_University_Of_Technology;
            stakeholder HSB_Bremen;
        }
    }
}
