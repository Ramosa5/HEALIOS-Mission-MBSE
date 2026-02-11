package CommunicationsSatelliteSystemDomain {

    package LifeCycle {
    private import ScalarValues::*;
   
    // =====================================
    // COMMON SYSTEM ELEMENTS
    // =====================================
   
    abstract part def SystemEntity;
    abstract part def EnvironmentalFactor;
    abstract part def PhysicalInterface;
    abstract item def EnergySource;
    abstract item def SignalSource;
   
     occurrence def SatelliteMission {
        //timeslices represent a portion of the instances of the containing occurrence definition
        timeslice missionDevelopmentStage {
            attribute contaminationLevel : Real;
            attribute ambientConditions;

            ref part satelliteDevelopmentStage :> satelliteSystem.satelliteDevelopmentStage;
            part :>> DevelopmentDomain::vibrationTable;
            part :>> DevelopmentDomain::thermalVacuum;
            part :>> DevelopmentDomain::anechoicChamber;

            connect satelliteDevelopmentStage to vibrationTable;
            connect satelliteDevelopmentStage to thermalVacuum;
            connect satelliteDevelopmentStage to anechoicChamber;
        }
        then timeslice missionProductionStage{
            attribute particleContamination : Real;
            attribute molecularContamination : Real;
            attribute electrostaticCharge : Real;

            ref part satelliteProductionStage :> satelliteSystem.satelliteProductionStage;
            part :>> ProductionDomain::assemblyFixtures [*];
            part :>> ProductionDomain::cleanroomZones[*];
            part :>> ProductionDomain::temperatureControlledAreas[*];
            part :>> ProductionDomain::electrostaticProtectionZones[*];

            connect [*] satelliteProductionStage to [1]assemblyFixtures;
            connect satelliteProductionStage to electrostaticProtectionZones;
        }
        then timeslice missionTransitionStage {
            timeslice missionTransportStage {
                attribute shockLevel : Real;
                attribute vibrationLevel : Real;
                attribute accelerationConstraint : Real;
                
                ref part satelliteTransportStage :> satelliteSystem.satelliteTransitionStage.satelliteTransportStage;
                part :>> DeliveryDomain::roadTransport;
                part :>> DeliveryDomain::airTransport;
                part :>> DeliveryDomain::seaTransport;

                connect satelliteTransportStage to roadTransport;
                connect satelliteTransportStage to airTransport;
                connect satelliteTransportStage to seaTransport;
            }
            then timeslice missionLaunchStage {
                ref part satelliteLaunchStage :> satelliteSystem.satelliteTransitionStage.satelliteLaunchStage;
                ref part launchVehicle :> DeliveryDomain::launchVehicle;
                part :>> DeliveryDomain::processingFacility;
                part :>> DeliveryDomain::electricalGroundSupport;
                part :>> DeliveryDomain::communicationLinks[*];

                connect satelliteLaunchStage to launchVehicle;
                connect [*]satelliteLaunchStage to communicationLinks;
                connect satelliteLaunchStage to electricalGroundSupport;
            }
            then timeslice missionAtmosphericEnvironmentStage {
                //attributes in the transition at the atmosphere stage
                attribute windSpeed : Real;
                attribute windDirection : Real;
                attribute precipitation : Real;
                attribute lightningActivity : Real;
                attribute atmosphericDensity : Real;

                ref part satelliteAtmosphericEnvironmentStage :> satelliteSystem.satelliteTransitionStage.satelliteAtmosphericEnvironmentStage;
                ref part launchVehicle :> DeliveryDomain::launchVehicle;

                connect satelliteAtmosphericEnvironmentStage to launchVehicle;
            }
            then timeslice missionEarlyOrbitEnvironmentStage {
                ref part satelliteEarlyOrbitEnvironmentStage :> satelliteSystem.satelliteTransitionStage.satelliteEarlyOrbitEnvironmentStage;
                ref part launchVehicle :> DeliveryDomain::launchVehicle;

                connect satelliteEarlyOrbitEnvironmentStage to launchVehicle; 
            }
            then timeslice missionSpaceEnvironmentStage{
                ref part satelliteSpaceEnvironmentStage :> satelliteSystem.satelliteTransitionStage.satelliteSpaceEnvironmentStage;
            }
        }
        then timeslice missionOperationalStage {
            attribute vacuumLevel : Real;
            attribute temperatureCycling;
            attribute galacticCosmicRays;
            attribute trappedRadiation;
            attribute totalIonizingDose : Real;
            attribute singleEventUpset;
            //Radiofrequency attributes
            attribute interferenceSource[*];
            attribute atmosphericNoise;
            attribute ionosphericEffects;
            attribute rainAttenuation;     
            attribute spectrumOccupancy;
            attribute regulatoryConstraints[*];
            
            ref part satelliteOperationalStage :> satelliteSystem.satelliteOperationalStage;
            part :>> OperationsDomain::sun;
            part :>> OperationsDomain::earth;
            part :>> OperationsDomain::micrometeoroidDebris[*];
            part :>> OperationsDomain::magnetosphericEnvironment;
            part :>> OperationsDomain::communicationPartners[*];

            connect satelliteOperationalStage to sun;
            connect satelliteOperationalStage to earth;
            connect [*] satelliteOperationalStage to micrometeoroidDebris;
            connect satelliteOperationalStage to magnetosphericEnvironment;
            connect [*] satelliteOperationalStage to communicationPartners;

            //Represents a portion of the instances of the definition(s) of that containing usage
            timeslice missionMaintenanceStage {
                ref part satelliteMaintenenaceStage :> satelliteSystem.satelliteOperationalStage.maintenanceStage;
            }
        }

        then timeslice missionDecommissionStage {
            attribute spaceDebrisGeneration;
            attribute atmosphericContamination;
            attribute groundImpactRisk;
            attribute radioactiveContamination;

            ref part satelliteDecommissionStage :> satelliteSystem.satelliteDecommissionStage;
            item :>> DecommissionDomain::debrisField;

            connect satelliteDecommissionStage to debrisField;
        }
    }
    
    part def SatelliteSystem {
        timeslice satelliteDevelopmentStage {
            part testInterface : DevelopmentDomain::TestInterface;
            part meaurementReferencePoint : DevelopmentDomain::MeasurementReferencePoint [1..*];
            part diagnosticInterface : DevelopmentDomain::DiagnosticInterface;
            part prototypeCommunicationPayload : DevelopmentDomain::PrototypeComponent :>> communicationPayload;
            part prototypePlatformSubsystems : DevelopmentDomain::PrototypeComponent :>> platformSubsystems;
            part prototypeStructuralElements : DevelopmentDomain::PrototypeComponent :>> structuralElements;
        }
        then timeslice satelliteProductionStage {
            part componentCommunicationPayload : ProductionDomain::ComponentSupplyChain :>> communicationPayload;
            part componentPlatformSubsystems : ProductionDomain::ComponentSupplyChain :>> platformSubsystems;
            part componentStructuralElements : ProductionDomain::ComponentSupplyChain :>> structuralElements;
        }
        
        then timeslice satelliteTransitionStage {
            timeslice satelliteTransportStage {
                part transportLatchingMechanism : DeliveryDomain::TransportLatchingMechanism;
            }
            then timeslice satelliteLaunchStage {
                //attributes in the transition at the launch stage
                attribute vibrationSpectrum;
                attribute acousticLevel : Real;
                attribute temperatureTransient;
                attribute pressureProfile;

                part launcherLatchingMechanism : DeliveryDomain::LauncherLatchingMechanism;
            }
            then timeslice satelliteAtmosphericEnvironmentStage{
                attribute vibrationSpectrum;
                attribute acousticLevel : Real;
                attribute temperatureTransient;
                attribute pressureProfile;    

                part launcherLatchingMechanism : DeliveryDomain::LauncherLatchingMechanism;
            }
            then timeslice satelliteEarlyOrbitEnvironmentStage{
                //attributes in the transition at the early orbit stage
                attribute vacuumExposure;
                attribute thermalShock;
                attribute solarExposure;
                attribute micrometeoroidFlux;

                part launcherLatchingMechanism : DeliveryDomain::LauncherLatchingMechanism;
            }
            then timeslice satelliteSpaceEnvironmentStage{
                //attributes in the transition at the space stage
                attribute orbitGeometry;
                attribute earthAlbedo;
                attribute magneticField;
                attribute atmosphericDrag;
            }
        }
        then timeslice satelliteOperationalStage{
            //attributes in the operational stage
            attribute continuousSpaceExposure;
            attribute cyclicStresses[*];
            attribute cumulativeRadiationDose;
            attribute thermalFatigue;
            attribute internalHeatSources[*];
            attribute thermalCycling;
            attribute spacecraftCharging;
            attribute electrostaticDischarge;
            timeslice maintenanceStage[*]{
                //attributes in the maintenance stage
                attribute uvDegradation : Real;
                attribute thermalCyclingDamage : Real;
                attribute radiationDamage : Real;
                attribute micrometeoriteErosion : Real;
                attribute outgassing : Real;
                attribute componentWearOut;
                attribute solarArrayDegradation;
                attribute batteryCapacityLoss;
                attribute thrusterPerformanceLoss;

                part diagnosticSystems : MaintenanceDomain::DiagnosticSystems;
                part maintenanceInterfaces : MaintenanceDomain::MaintenanceInterfaces;
                part autonomousMaintenanceSystem : MaintenanceDomain::AutonomousMaintenanceSystem;
                part :>> MaintenanceDomain::mechanicalWearIndicator[*];
                part :>> MaintenanceDomain::electricalPerformanceIndicator[*];
                part :>> MaintenanceDomain::thermalPerformanceIndicator[*];
                part :>> MaintenanceDomain::signalQualityIndicator[*];

                item :>> MaintenanceDomain::propellantReserves[*];
                item :>> MaintenanceDomain::batteryCapacity;
                item :>> MaintenanceDomain::lubricants;
                item :>> MaintenanceDomain::coolants;

            }
        }
        then timeslice satelliteDecommissionStage{
            //attributes in the decommissioning stage
            attribute naturalPerturbations[*];
            attribute artificialPerturbations[*];
            //decommission in orbit
            attribute orbitAltitude : Real;
            attribute orbitStability : Real;
            attribute collisionProbability : Real;
            attribute perturbationForces[*];
            //decommission by reentry
            attribute atmosphericDensityProfile;
            attribute heatingProfile;
            attribute aerodynamicForces;
            attribute breakupAltitude : Real;
            attribute impactFootprint;

            part passivationSystem : DecommissionDomain::PassivationSystem;
            part shutDownSystem : DecommissionDomain::ShutDownSystem;
            part monitoringSystem : DecommissionDomain::MonitoringSystem;

            item ::> DecommissionDomain::residualFuel;
            item ::> DecommissionDomain::storedEnergy;
            item ::> DecommissionDomain::pressurizedFluids[*];
            item ::> DecommissionDomain::radioactiveMaterials[*];
        }

        part communicationPayload;
        part platformSubsystems;
        part structuralElements;
       
        attribute systemMass : Real;
        attribute systemVolume : Real;
        attribute operatingTemperatureRange : Real[2];
        attribute radiationTolerance : Real;
    }

    part satelliteSystem : SatelliteSystem;
   
    // =====================================
    // DEVELOPMENT DOMAIN
    // =====================================
   
    package DevelopmentDomain {
       
        // Physical test interfaces and measurement systems
        part def TestInterface :> PhysicalInterface {
            attribute interfaceType : TestInterfaceType;
            attribute accessibilityLevel : Real;
        }
       
        enum def TestInterfaceType {
            ElectricalTestPoint;
            MechanicalTestFixture;
            ThermalProbe;
            OpticalAlignment;
            RFTestPort;
            DataBus;
        }
       
        part def MeasurementReferencePoint :> SystemEntity {
            attribute coordinateSystem : CoordinateSystem;
            attribute tolerance : Real;
            attribute measurabilityConstraint : String;
        }
       
        enum def CoordinateSystem {
            BodyFixed;
            LaunchVehicleInterface;
            AntennaFrame;
            SolarArrayFrame;
            ThrusterFrame;
        }

        part vibrationTable : TestChamber;
        part thermalVacuum : TestChamber;
        part anechoicChamber : TestChamber;
        part prototypeComponent : PrototypeComponent [*];
       
        part def TestChamber :> EnvironmentalFactor {
            attribute pressureRange : Real[2];
            attribute temperatureRange : Real[2];
            attribute humidityRange : Real[2];
            attribute vibrationSpectrum;
        }
       
        part def CalibrationSource :> SignalSource {
            attribute sourceType : CalibrationSourceType;
            attribute frequency : Real;
            attribute amplitude : Real;
            attribute stability : Real;
        }
       
        enum def CalibrationSourceType {
            RFSignalGenerator;
            OpticalCalibrator;
            PrecisionVoltageSource;
            FrequencyStandard;
            NoiseSource;
        }
       
        part def DiagnosticInterface :> PhysicalInterface {
            part dataAcquisitionPortst[*];
            part powerMonitoringPoints[*];
            part temperatureSensors[*];
            part pressureTapPoints[*];
        }
       
        part def PrototypeComponent :> SystemEntity {
            part breadboardCircuits[*];
            part engineeringModels[*];
            part mockupStructures[*];
           
            attribute fidelityLevel : FidelityLevel;
        }
       
        enum def FidelityLevel {
            Conceptual;
            Breadboard;
            EngineeringModel;
            QualificationModel;
            FlightModel;
        }
       
        // Development-stage physical constraints
        part def HandlingFixture :> PhysicalInterface {
            attribute liftPoint[*];
            attribute supportSurface;
            attribute accessibilityConstraint;
        }
       
        part def DevelopmentPowerSource :> EnergySource {
            attribute voltageLevel : Real;
            attribute currentCapacity : Real;
            attribute regulationAccuracy : Real;
            attribute ripple : Real;
        }
    }
   
    // =====================================
    // PRODUCTION DOMAIN
    // =====================================
   
    package ProductionDomain {
       
        part assemblyFixtures : AssemblyFixture[*];
        part cleanroomZones[*];
        part temperatureControlledAreas[*];
        part electrostaticProtectionZones[*];
       
        part def AssemblyFixture :> PhysicalInterface {
            attribute fixtureType : AssemblyFixtureType;
            attribute positioningAccuracy : Real;
            attribute loadCapacity : Real;
            attribute accessAngles : Real[*];
        }
       
        enum def AssemblyFixtureType {
            RotationFixture;
            IntegrationStand;
            AlignmentJig;
            WeldingFixture;
            BondingPlatform;
        }
       
        part def QualityInspectionSystem :> SystemEntity {
            part dimensionalMeasurement;
            part xrayInspection;
            part ultrasonicTesting;
            part opticalInspection;
        }
       
        part def ComponentSupplyChain :> SystemEntity {
            part rawMaterials[*];
            part electronicComponents[*];
            part mechanicalComponents[*];
            part chemicalSubstances[*];
           
            attribute traceabilityCode : String;
            attribute qualityGrade : QualityGrade;
        }
       
        enum def QualityGrade {
            Commercial;
            Industrial;
            Military;
            Space;
            SpaceHeritage;
        }
       
        part def ProductionTooling :> PhysicalInterface {
            part cuttingTools[*];
            part weldingEquipment[*];
            part bondingEquipment[*];
            part cleaningStations[*];
        }
       
        part def TestingInfrastructure :> SystemEntity {
            part functionalTestSets[*];
            part environmentalTestChambers[*];
            part performanceTestEquipment[*];
           
            attribute testCoverage : Real;
            attribute measurementUncertainty : Real;
        }
       
        part def MaterialHandlingSystem :> SystemEntity {
            part transportMechanisms[*];
            part storageContainers[*];
            part liftingEquipment[*];
           
            attribute contaminationControl : Boolean;
        }
       
        part def ProductionWasteStreams :> EnvironmentalFactor {
            item solidWaste;
            item liquidWaste;
            item gasEmissions;
            item chemicalByproducts[*];
        }
    }
   
    // =====================================
    // DELIVERY DOMAIN
    // =====================================
   
    package DeliveryDomain {
       
        part launchVehicle : LaunchVehicle;
        part processingFacility : ProcessingFacility;
        part electricalGroundSupport : GroundSupportEquipment;
        part communicationLinks : GroundSupportEquipment [*];
        //transportation stage
        part roadTransport;
        part airTransport;
        part seaTransport;
        
        part def TransportLatchingMechanism;
        part def LauncherLatchingMechanism;

        part def LaunchVehicle :> SystemEntity {
            part payloadFairing;
            part separationMechanism;
            part payloadAttachFitting;
           
            attribute accelerationProfile;
            attribute vibrationEnvironment;
            attribute acousticEnvironment;
        }
       
        part def ProcessingFacility :> EnvironmentalFactor {
            attribute cleanlinessLevel : Real;
            attribute temperatureStability : Real;
            attribute humidityControl : Real;
            attribute accessControlLevel;
        }
       
        part def GroundSupportEquipment :> SystemEntity {
            part umbilicalConnectors[*];
            part servicingPorts[*];
            part monitoringProbes[*];
            part purgeConnections[*];
           
            attribute disconnectionSequence;
        }
    }
   
    // =====================================
    // OPERATIONS DOMAIN
    // =====================================
   
    package OperationsDomain {
       
        part sun : Sun;
        part earth : Earth;
        part micrometeoroidDebris[*];
        part magnetosphericEnvironment;
        part communicationPartners : CommunicationPartners[*];
        
       
        item def Sun :> EnergySource {
            attribute solarConstant : Real; // W/m²
            attribute solarCycleVariation : Real;
            attribute eclipseGeometry;
            attribute solarFlareActivity;
            attribute solarEnergeticParticles;
            attribute solarRadiationPressure;
            attribute solarHeating;
        }
       
        part def CommunicationPartners :> SystemEntity {
            part groundStations : GroundStation[*];
            part relayStations : GroundStation[*];
            part otherSatellites : SatelliteSystem[*];
        }
       
        part def GroundStation :> SystemEntity {
            part antennaSystem;
            part rfSubsystem;
            part baseband;
           
            attribute elevationMask : Real;
            attribute linkMargin : Real;
            attribute trackingAccuracy : Real;
            attribute geographicLocation;
        }
       
        part def Earth {
            attribute gravitationalField;
            attribute atmosphericDrag;
            attribute thirdBodyPerturbations[*];
            attribute stationKeepingRequirements;
            attribute earthInfraredRadiation;
            attribute thermalCycling;
            attribute earthAlbedoReflection;
            attribute magneticFieldVariation;
        }
       
        part def NavigationReferences :> SystemEntity {
            part gnssConstellations[*];
            part celestialReferences[*];
            part groundBeacons[*];
            part inertialReferences[*];
        }
    }
   
    // =====================================
    // MAINTENANCE DOMAIN
    // =====================================
   
    package MaintenanceDomain {
       
        part def DiagnosticSystems :> SystemEntity {
            part healthMonitoringSensors : HealthSensor[*];
            part builtInTestEquipment[*];
            part telemetrySystem;
            part dataRecorders[*];
        }
       
        part def HealthSensor :> SystemEntity {
            attribute sensorType : HealthSensorType;
            attribute measurementRange : Real[2];
            attribute accuracy : Real;
            attribute samplingRate : Real;
        }
       
        enum def HealthSensorType {
            Temperature;
            Voltage;
            Current;
            Vibration;
            Pressure;
            FlowRate;
            Position;
            SpinRate;
        }
       
        part def MaintenanceInterfaces :> PhysicalInterface {
            part reconfigurationSwitches[*];
            part redundantPaths[*];
            part bypassModes[*];
            part safeMode;
        }
       
        item def RemainingConsumables {
            attribute remainingLifetime : Real;
        }
        item propellantReserves : RemainingConsumables[*];
        item batteryCapacity : RemainingConsumables;
        item lubricants : RemainingConsumables;
        item coolants : RemainingConsumables;
       
        part def WearIndicator;
        part mechanicalWearIndicator : WearIndicator[*];
        part electricalPerformanceIndicator : WearIndicator[*];
        part thermalPerformanceIndicator : WearIndicator[*];
        part signalQualityIndicator : WearIndicator[*];
       
        part def AutonomousMaintenanceSystem :> SystemEntity {
            part faultDetectionSystem;
            part faultIsolationSystem;
            part automaticReconfigurationSystem;
            part performanceOptimizationSystem;
        }
    }
   
    // =====================================
    // DECOMMISSION DOMAIN
    // =====================================
   
    package DecommissionDomain {
       
        item debrisField;
        
        part def PassivationSystem :> SystemEntity {
            part fuelVentingSystem;
            part batteryPassivationSystem;
            part pressureVessels[*];
            part energyStorageSystems[*];
           
            attribute passivationCompleteness : Real;
        }
       
        part def ShutDownSystem :> SystemEntity {
            part propulsionShutdownSystem;
            part powerSystemShutdownSystem;
            part payloadShutdownSystem;
            part safetyIsolationSystem;
        }
       
        part def RemainingResources {
            attribute hazardLevel : HazardLevel;
        }
        enum def HazardLevel {
            Minimal;
            Low;
            Moderate;
            High;
            Extreme;
        }

        item residualFuel : RemainingResources;
        item storedEnergy : RemainingResources;
        item pressurizedFluids : RemainingResources[*];
        item radioactiveMaterials : RemainingResources[*];
       
       
        part def MonitoringSystem :> SystemEntity {
            part trackingBeacons[*];
            part positionReportingSystem;
            part statusTelemetrySystem;
            part emergencyBeacons[*];
        }
    }
    }
    package viewpointsAndViews {
        
        concern MissionLifeCycleOverview {
            doc /*
            * To ensure that the whole mission life cycle is up to date
            * and available to all stakeholders for reference and review
            */
            subject SatelliteMission;
        }

        concern SystemLifeCycleOverview {
            doc /*
            * To ensure that the whole life cycle of a paticular system is up to date
            * and available to all stakeholders for reference and review
            */
            subject SatelliteMission;
        }
        
        viewpoint LifeCyclePerspective {
            frame MissionLifeCycleOverview;
            frame SystemLifeCycleOverview;
            require constraint {
                doc /*
                * A life cycle view shall show the whole Life Cycle of a particular subject
                * including the system-of-interest as a part of the domain in each life cycle stage.
                */
            }
        }
        view def LifeCycleView {
            satisfy LifeCyclePerspective;
            filter @SysML::PartUsage;
        }
        view missionLifeCycleView : LifeCycleView {
            expose LifeCycle::SatelliteMission::*;
        }
        view systemLifeCycleView : LifeCycleView {
            expose LifeCycle::SatelliteSystem::*;
        }
        view systemView : LifeCycleView {
            expose LifeCycle::SatelliteMission::missionOperationalStage::*;
        }
    }
   
}