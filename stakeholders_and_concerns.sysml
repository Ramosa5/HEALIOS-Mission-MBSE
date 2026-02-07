package Stakeholders_and_Concerns {
    doc
    /* Stakeholders for the HEALIOS System */

    part def Gdansk_University_Of_Technology;
    part def HSB_Bremen;

    part def European_Space_Agency;
    part def Perovskite_Research_Institutes; // using data
    part def Perovskite_Solar_Cell_Manufacturer; // provide psc payload
    part def HEALIOS_Team;

    part Fly_Your_Satellite_Programme : European_Space_Agency;
    part Gdansk_University_Stakeholder : Gdansk_University_Of_Technology;
    part HSB_Bremen_Stakeholder : HSB_Bremen;
    part Perovskite_Research_Institutes_Stakeholder : Perovskite_Research_Institutes;
    part Perovskire_Solar_Cell_Manufacturer_Stakeholder : Perovskite_Solar_Cell_Manufacturer;
    part HEALIOS_Team_Stakeholder : HEALIOS_Team;

    
    concern programmePhaseCompletion {
        subject HEALIOS_System;
        stakeholder Fly_Your_Satellite_Programme;
    }

    concern educationalReturn {
        subject HEALIOS_System;
        stakeholder Fly_Your_Satellite_Programme;
    }

    concern reviewProcessCompliance {
        subject HEALIOS_System;
        stakeholder Fly_Your_Satellite_Programme;
    }

    concern UniversityEngagement {
        subject HEALIOS_System;
        stakeholder Gdansk_University_Stakeholder;
        stakeholder HSB_Bremen_Stakeholder;
    }

    // 3. Viewpoints
    // A Viewpoint defines the rules for constructing a view to address the concerns
    viewpoint def ManagementViewpoint {
        doc /* Viewpoint to address phase completion and review compliance. */
        
        // This is the critical link: FRAMING the concern
        frame programmePhaseCompletion;
        
        // You can require specific content in views of this type
        require constraint {
            doc /* Must show project timeline and milestone status. */
        }
    }

    viewpoint def OutreachViewpoint {
        doc /* Viewpoint focusing on educational value and university engagement. */
        
        frame educationalReturn;
        // You can frame multiple concerns
        // frame UniversityEngagement; 
    }

    // 4. Views
    // The actual "product" (diagram, document, table) that satisfies the viewpoint
    view phaseReviewReport : ManagementViewpoint {
        doc /* The generated report for the Phase C review. */
        
        // Expose the parts of the system model relevant to this view
        expose HEALIOS::*;
        
        // (Optional) Filter or render specific elements
        // filter @Milestone;
    }

}
