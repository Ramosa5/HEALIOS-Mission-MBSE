package Stakeholders_and_Concerns {
    doc
    /* Stakeholders for the HEALIOS System */

    // 1. Stakeholders

    //part def Gdansk_University_Of_Technology;
    //part def HSB_Bremen;
    part def Academic_Institutions;
    part def European_Space_Agency;
    part def Research_Institutes; // using data
    part def Manufacturers;
    part def HEALIOS_Team;
    part def Regulatory_Bodies;

    part Fly_Your_Satellite_Programme : European_Space_Agency;
    part CubeSat_Community : Manufacturers;

    part Satellite_COTS_Manufacturers : Manufacturers;
    
    part <GUT> Gdansk_University_of_Technology : Academic_Institutions;
    part <HSB> HSB_Hochschule_Bremen : Academic_Institutions;
    
    part Perovskite_Research_Institutes : Research_Institutes;
    part Perovskire_Solar_Cell_Manufacture : Manufacturers;
    
    part HEALIOS_Team_Community : HEALIOS_Team;

    part <IARU> International_Amateur_Radio_Union : Regulatory_Bodies;
    part <ITU> International_Telecommunication_Union : Regulatory_Bodies;
    part <LSP> Launch_Service_Provider : Regulatory_Bodies;
    part <UNOOSA> United_Nations_Office_for_Outer_Space_Affairs : Regulatory_Bodies;

    // 2. Concerns - TBC: REMEMBER TO CHANGE!
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
