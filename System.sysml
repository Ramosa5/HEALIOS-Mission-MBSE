// Main System Model

package HEALIOS {
    // --- 0. Import ---
    public import HEALIOS_Space_Functions::*;

    // --- 1. Define the Components ---
    public part def TemperatureSensor;
    public part def Heater;
    public part def BatteryPack;

    public part def OnBoardComputer;
    public part def Software;

    // --- 2. Define Subsystem Types ---
    public part def ThermalControlSystem{
        ref part tempSensorOBDH : TemperatureSensor;
        ref part tempSensorPL : TemperatureSensor;
        ref part tempSensorEPS : TemperatureSensor;
        ref part mainHeater : Heater;
    }
    
    public part def CommunicationSystem;

    public part def ElectricalPowerSystem{
        part softwareEPS : Software;
        part batteryPack : BatteryPack{
            part tempSensorEPS : TemperatureSensor;
            part mainHeater : Heater;
        }
    }
    public part def OnBoardDataHandling{
        part softwareOBDH : Software;
        part OBC : OnBoardComputer{
            part tempSensorOBDH : TemperatureSensor;
        }
    }
    public part def StructureAndMechanisms;
    public part def DataAcquisition{
        part tempSensorPL : TemperatureSensor;
    }
    public part def AttitudeAndOrbitControlSystem;
    public part def Payload;

    // --- 3. Define the Detailed Space Segment ---
    public part def SpaceSegment {
        
        // A. Subsystems
        part TCS : ThermalControlSystem;
        part COMMS : CommunicationSystem;
        part EPS : ElectricalPowerSystem;
        part OBDH : OnBoardDataHandling;
        part STR : StructureAndMechanisms;
        part DAQ : DataAcquisition;
        part AOCS : AttitudeAndOrbitControlSystem;
        part PL : Payload;

        // B. Internal Connections
        bind TCS.tempSensorPL = DAQ.tempSensorPL;
        bind TCS.tempSensorOBDH = OBDH.OBC.tempSensorOBDH;
        bind TCS.tempSensorEPS = EPS.batteryPack.tempSensorEPS;

        // C. Behavior
        perform action performSpaceMission : PerformSpaceSegmentMission;

        // D. Allocations
        allocate performSpaceMission.provideScientificMeasurements.applyControlledReverseBiasToPSC to PL;
        allocate performSpaceMission.provideScientificMeasurements.collectExperimentalData to DAQ;

        allocate performSpaceMission.provideElectricalPower to EPS;

        allocate performSpaceMission.provideSpaceEnvironmentProtection.provideThermalStability to TCS;
        allocate performSpaceMission.provideSpaceEnvironmentProtection.provideStructuralStability to STR;

        allocate performSpaceMission.provideSunPointingCapability.provideTimeAndOrbitKnowledge to OBDH;
        allocate performSpaceMission.provideSunPointingCapability.determineAttitude to AOCS;
        allocate performSpaceMission.provideSunPointingCapability.controlSatelliteAttitude to AOCS;
        allocate performSpaceMission.provideSunPointingCapability.stabiliseSatellite to AOCS;
        allocate performSpaceMission.provideSunPointingCapability.maintainSunPointingAttitude to AOCS;

        allocate performSpaceMission.provideOnBoardDataHandling to OBDH;

        allocate performSpaceMission.provideTMTCLink.downlinkTMData to COMMS;

        allocate performSpaceMission.provideSafetyAndFDIRCapability to OBDH;

        allocate performSpaceMission.manageMissionPhases to OBDH;

    }

    // --- 4. Ground Segment Placeholder ---
    public part def GroundSegment;

    // --- 5. The Complete System ---
    public part def HEALIOS_System {
        part spaceSegment : SpaceSegment;
        part groundSegment : GroundSegment;
    }
}

// Functional Decomposition of the Space Segment's behavior for the HEALIOS mission

package HEALIOS_Space_Functions {
    // Ensuring explicit visibility as requested previously
    public import ScalarValues::*;

    // Top-level definition for the Space Segment's behavior
    public action def PerformSpaceSegmentMission {
        
        // 1. Provide scientific measurements
        action provideScientificMeasurements {
            // 1.1 Apply controlled reverse-bias to PSC
            action applyControlledReverseBiasToPSC;
            // 1.2 Collect experimental data
            action collectExperimentalData {
                // 1.2.1 - 1.2.5 Nested parameters/actions
                action measureOpenCircuitVoltage;
                action measureShortCircuitCurrent;
                action determineMaximumPowerOutput;
                action measureTemperature;
                action monitorLightConditions; // TBC
            }
        }
        // 2. Provide Electrical Power
        action provideElectricalPower {
            // 2.1 Generate power
            action generatePower;
            // 2.2 Regulate and condition power
            action regulateAndConditionPower;
            // 2.3 Store energy
            action storeEnergy;
            // 2.4 Distribute power
            action distributePower;
            // 2.5 Protect the power architecture
            action protectPowerArchitecture;
        }
        // 3. Provide space environment protection
        action provideSpaceEnvironmentProtection {
            // 3.1 Provide thermal stability
            action provideThermalStability{
                // 3.1.1 Monitor temperature
                action monitorTemperature;
                // 3.1.2 Control heaters
                action controlHeaters;
            }
            // 3.2 Provide structural stability
            action provideStructuralStability{
                // 3.2.1 Withstand launch environment
                action withstandLaunchEnvironment;
                // 3.2.2 Withstand on-orbit environment
                action withstandOnOrbitEnvironment;
            }
        }
        // 4. Provide sun-pointing capability
        action provideSunPointingCapability {
            // 4.1 Determine satellite key parameters
            action provideTimeAndOrbitKnowledge {
                action maintainOnboardTime;
                action propagateOrbitState;
                action determineAttitude;
            }
            // 4.2 Determine satellite attitude
            action determineAttitude;
            // 4.3 Control satellite attitude
            action controlSatelliteAttitude;
            // 4.4 Stabilise satellite
            action stabiliseSatellite;
            // 4.5 Maintain sun-pointing attitude
            action maintainSunPointingAttitude;
        }
        // 5. Provide on-board data handling
        action provideOnBoardDataHandling {
            // 5.1 Interprete telecommands
            action interpreteTelecommands;
            // 5.2 Execute onboard software
            action executeOnboardSoftware;
            // 5.3 Manage spacecraft modes
            action manageSpacecraftModes;
            // 5.4 Collect housekeeping data
            action collectHousekeepingData;
            // 5.5 Store telemetry data
            action storeTelemetryData;
            // 5.6 Distribute timing and synchronisation
            action distributeTimingAndSync;
        }
        // 6. Provide TM and TC link
        action provideTMTCLink {
            // 6.1 Support TM downlink
            action downlinkTMData{
                // 6.1.1 Support scientific data downlink
                action supportScientificDataDownlink;
                // 6.1.2 Support housekeeping data downlink
                action supportHousekeepingDataDownlink;
            }
            // 6.2 Support TC receive
            action receiveTCData;
            // 6.3 Manage communication protocols
            action manageCommunicationProtocols;
            // 6.4 Manage RF links
            action manageRFLinks;
        }
        // 7. Provide FDIR and Safety capability
        action provideSafetyAndFDIRCapability {
            // 7.1 Monitor system health
            action monitorSystemHealth;
            // 7.2 Detect off-nominal conditions
            action detectOffNominalConditions;
            // 7.3 Transition to safe mode
            action transitionToSafeMode;
            // 7.4 Perform fault isolation
            action performFaultIsolation;
            // 7.5 Perform fault recovery
            action recoverNominalOperation;
        }
        // 8. Provide mission phase management
        action manageMissionPhases {
            // 8.1 Manage Launch and Early Orbit Phase
            action manageLEOP{
                action manageLaunchPhase;
                action manageCommissioningPhase;
            }
            // 8.2 Manage Operational Phase
            action manageOperationalPhase{
                action manageNominalMode{
                    action manageSunMode;
                    action manageEclipseMode;
                }
                action manageSafeMode;
            }
            // 8.3 Manage End of Life Phase
            action manageEOLPhase;
        }
    }
}