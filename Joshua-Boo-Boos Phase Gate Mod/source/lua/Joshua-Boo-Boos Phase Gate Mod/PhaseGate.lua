PhaseGate.kModelName = PrecacheAsset("models/PhaseGate.model")

local PhaseGateBone1 = "Entry 1"
local PhaseGateBone2 = "Entry 2"
local PhaseGateBone3 = "Entry 3"

local phasegate_linked = PrecacheAsset("cinematics/marine/phasegate/phasegate.cinematic")

function PhaseGate:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = true })
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    -- Compute link state on server and propagate to client for looping effects
    self.linked = false
    self.phase = false
    self.deployed = false
    self.destLocationId = Entity.invalidId
    if Server then
        self.directionBackwards = false
    end

    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    self.relevancyPortalIndex = -1 -- invalid index = no relevancyPortal.
    
end

function PhaseGate:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(PhaseGate.kModelName, kAnimationGraph)
    
    if Server then
    
        self:AddTimedCallback(PhaseGate.Update, kUpdateInterval)
        self.timeOfLastPhase = nil
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        InitMixin(self, MinimapConnectionMixin)
        InitMixin(self, SupplyUserMixin)

        self.performedPhaseLastUpdate = false
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    InitMixin(self, IdleMixin)

    self.simplePhysicsEnabled = true
    UpdatePhysics(self)
    
    self.collisionRep = CollisionRep.Damage
    self.physicsGroup = PhysicsGroup.DefaultGroup
    self.physicsGroupFilterMask = PhysicsMask.None
    
    self:SetPhysicsGroup(self.physicsGroup)
    self:SetPhysicsGroupFilterMask(self.physicsGroupFilterMask)
    
end

function PhaseGate:OnUpdateRender()

    self.phasegatecinematics = {}

    PROFILE("PhaseGate:OnUpdateRender")

    if self.clientLinked ~= self.linked then
    
        self.clientLinked = self.linked

        if Client and self.linked and self:GetIsVisible() then
        
            self.phaseGateCinematic1 = Client.CreateCinematic(RenderScene.Zone_Default)
            self.phaseGateCinematic1:SetCinematic(phasegate_linked)
            self.phaseGateCinematic1:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.phaseGateCinematic1:SetParent(self)
            self.phaseGateCinematic1:SetCoords(Coords.GetIdentity())
            self.phaseGateCinematic1:SetAttachPoint(self:GetAttachPointIndex(PhaseGateBone1))

            self.phaseGateCinematic2 = Client.CreateCinematic(RenderScene.Zone_Default)
            self.phaseGateCinematic2:SetCinematic(phasegate_linked)
            self.phaseGateCinematic2:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.phaseGateCinematic2:SetParent(self)
            self.phaseGateCinematic2:SetCoords(Coords.GetIdentity())
            self.phaseGateCinematic2:SetAttachPoint(self:GetAttachPointIndex(PhaseGateBone2))

            self.phaseGateCinematic3 = Client.CreateCinematic(RenderScene.Zone_Default)
            self.phaseGateCinematic3:SetCinematic(phasegate_linked)
            self.phaseGateCinematic3:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.phaseGateCinematic3:SetParent(self)
            self.phaseGateCinematic3:SetCoords(Coords.GetIdentity())
            self.phaseGateCinematic3:SetAttachPoint(self:GetAttachPointIndex(PhaseGateBone3))

        end
        
        -- local effects = ConditionalValue(self.linked and self:GetIsVisible(), "phase_gate_linked", "phase_gate_unlinked")
        -- self:TriggerEffects(effects) --FIXME This is really wasteful
        
    end

end