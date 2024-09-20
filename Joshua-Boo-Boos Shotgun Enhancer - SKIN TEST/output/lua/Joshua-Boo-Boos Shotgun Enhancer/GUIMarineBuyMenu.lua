local kSpecial = enum(
{
    'Massive',
    'Electrify',
    'Burn'
})

local kSpecialDefinitions =
{
    [kSpecial.Massive] =
    {
        TextureCoordinates = { 0, 0, 717, 184 },
        Title = "BUYMENU_MASSIVE_TITLE",
        Specials =
        {
            "BUYMENU_MASSIVE_SPECIAL1",
            "BUYMENU_MASSIVE_SPECIAL2",
            "BUYMENU_MASSIVE_SPECIAL3",
            "BUYMENU_MASSIVE_SPECIAL4",
            "BUYMENU_MASSIVE_SPECIAL5",
        },
        SpecialsDebuffs = set
        {
            4, 5
        }
    },

    [kSpecial.Electrify] =
    {
        TextureCoordinates = { 0, 185, 717, 279 },
        Title = "BUYMENU_ELECTRIFY_TITLE",
        Specials =
        {
            "BUYMENU_ELECTRIFY_SPECIAL1",
        }
    },

    [kSpecial.Burn] =
    {
        TextureCoordinates = { 0, 370, 717, 464 },
        Title = "BUYMENU_BURN_TITLE",
        Specials =
        {
            "BUYMENU_BURN_SPECIAL1",
            "BUYMENU_BURN_SPECIAL2",
        }
    }
}

local kTechIdStats =
{
    [kTechId.Axe] =
    {
        LifeFormDamage = 0.1,
        StructureDamage = 0.7,
        Range = 0.1,
    },

    [kTechId.Welder] =
    {
        LifeFormDamage = 0.1,
        StructureDamage = 0.2,
        Range = 0.1,
    },

    [kTechId.Pistol] =
    {
        LifeFormDamage = 0.8,
        StructureDamage = 0.5,
        Range = 1,
    },

    [kTechId.Rifle] =
    {
        LifeFormDamage = 0.8,
        StructureDamage = 0.8,
        Range = 0.8,
    },

    [kTechId.Shotgun] =
    {
        LifeFormDamage = 1,
        StructureDamage = 0.8,
        Range = 0.4,
    },

    [kTechId.GrenadeLauncher] =
    {
        LifeFormDamage = 0.3,
        StructureDamage = 1,
        Range = 0.9,
    },

    [kTechId.HeavyMachineGun] =
    {
        LifeFormDamage = 1,
        StructureDamage = 0.6,
        Range = 0.7,
    },

    [kTechId.Flamethrower] =
    {
        LifeFormDamage = 0.6,
        StructureDamage = 1,
        Range = 0.4,
    },

    [kTechId.GasGrenade] =
    {
        LifeFormDamage = 0.4,
        StructureDamage = 0.6,
        Range = 0.7,
        RangeLabelOverride = "BUYMENU_GRENADES_RANGE_OVERRIDE",
    },

    [kTechId.ClusterGrenade] =
    {
        LifeFormDamage = 0.2,
        StructureDamage = 0.8,
        Range = 0.6,
        RangeLabelOverride = "BUYMENU_GRENADES_RANGE_OVERRIDE",
    },

    [kTechId.PulseGrenade] =
    {
        LifeFormDamage = 0.5,
        StructureDamage = 0.1,
        Range = 0.4,
        RangeLabelOverride = "BUYMENU_GRENADES_RANGE_OVERRIDE",
    },

    [kTechId.DualMinigunExosuit] =
    {
        LifeFormDamage = 0.9,
        StructureDamage = 0.8,
        Range = 0.7,
    },

    -- Prototype Lab "big" pictures are a seperate texture file.
    [kTechId.DualRailgunExosuit] =
    {
        LifeFormDamage = 1,
        StructureDamage = 0.6,
        Range = 1,
    },
}

local function GetStatsForTechId(techId)


    local stats = kTechIdStats[techId]
    if stats then
        return stats
    end

    return nil

end

kTechIdInfo_Modded =
{
    [kTechId.Pistol] =
    {
        ButtonTextureIndex = 0,
        BigPictureIndex = 0,
        Description = "PISTOL_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Pistol)
    },

    [kTechId.Rifle] =
    {
        ButtonTextureIndex = 1,
        BigPictureIndex = 1,
        Description = "RIFLE_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Rifle)
    },

    [kTechId.Shotgun] =
    {
        ButtonTextureIndex = 2,
        BigPictureIndex = 2,
        Description = "Secondary Attack Button: Switch between NS2 (W0), Buckshot (W1), Incendiary (W2), Slug (W3) cartridges. Buckshot = Less Player & More Structure Damage. Incendiary = Slightly Less Player Damage & Burns Alien Entities. Slug = 70% Normal Damage & More Damage At Range.",
        Stats = GetStatsForTechId(kTechId.Shotgun)
    },

    [kTechId.GrenadeLauncher] =
    {
        ButtonTextureIndex = 3,
        BigPictureIndex = 3,
        Description = "GRENADELAUNCHER_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.GrenadeLauncher)
    },

    [kTechId.Flamethrower] =
    {
        ButtonTextureIndex = 4,
        BigPictureIndex = 4,
        Description = "FLAMETHROWER_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Flamethrower),
        Special = kSpecial.Burn
    },

    [kTechId.HeavyMachineGun] =
    {
        ButtonTextureIndex = 5,
        BigPictureIndex = 5,
        Description = "HMG_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.HeavyMachineGun)
    },

    [kTechId.Axe] =
    {
        ButtonTextureIndex = 6,
        BigPictureIndex = 6,
        Description = "AXE_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Axe)
    },

    [kTechId.Welder] =
    {
        ButtonTextureIndex = 7,
        BigPictureIndex = 7,
        Description = "WELDER_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Welder)
    },

    [kTechId.GasGrenade] =
    {
        ButtonTextureIndex = 8,
        BigPictureIndex = 8,
        Description = "GASGRENADE_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.GasGrenade)
    },

    [kTechId.ClusterGrenade] =
    {
        ButtonTextureIndex = 9,
        BigPictureIndex = 9,
        Description = "CLUSTERGRENADE_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.ClusterGrenade)
    },

    [kTechId.PulseGrenade] =
    {
        ButtonTextureIndex = 10,
        BigPictureIndex = 10,
        Description = "PULSEGRENADE_BUYDESCRIPTION",
        Special = kSpecial.Electrify,
        Stats = GetStatsForTechId(kTechId.PulseGrenade)
    },

    [kTechId.LayMines] =
    {
        ButtonTextureIndex = 11,
        BigPictureIndex = 11,
        Description = "MINES_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.LayMines)
    },

    -- Prototype Lab "big" pictures are a seperate texture file.
    [kTechId.Jetpack] =
    {
        ButtonTextureIndex = 12,
        BigPictureIndex = 2,
        Description = "JETPACK_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.Jetpack)
    },

    [kTechId.DualRailgunExosuit] =
    {
        ButtonTextureIndex = 13,
        BigPictureIndex = 1,
        Description = "DUALRAILGUN_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.DualRailgunExosuit),
        Special = kSpecial.Massive
    },

    [kTechId.DualMinigunExosuit] =
    {
        ButtonTextureIndex = 14,
        BigPictureIndex = 0,
        Description = "DUALMINIGUN_BUYDESCRIPTION",
        Stats = GetStatsForTechId(kTechId.DualMinigunExosuit),
        Special = kSpecial.Massive
    },

}

function GUIMarineBuyMenu:_GetPigPicturePixelCoordinatesForTechID(techId)

    -- NOTE(Salads): The texture file for purchase buttons have a column for "not hovered", and another for "hovered"

    local pictureWidth = 651 -- armory dimensions
    local pictureHeight = 319
    if self.hostStructure:isa("PrototypeLab") then
        pictureWidth = 403
        pictureHeight = 424
    end

    local index = kTechIdInfo_Modded[techId].BigPictureIndex
    assert(index, "Could not find index for techid")

    local x1 = 0
    local x2 = x1 + pictureWidth

    local y1 = pictureHeight * index
    local y2 = y1 + pictureHeight

    return { x1, y1, x2, y2 }

end

function GUIMarineBuyMenu:_GetButtonPixelCoordinatesForTechID(techId, isHover)

    -- NOTE(Salads): The texture file for purchase buttons have a column for "not hovered", and another for "hovered"

    local buttonIconWidth = 441
    local buttonIconHeight = 114
    local hoverAdd = isHover and buttonIconWidth or 0
    local index = kTechIdInfo_Modded[techId].ButtonTextureIndex
    assert(index, "Could not find index for techid")

    local x1 = hoverAdd
    local x2 = x1 + buttonIconWidth

    local y1 = buttonIconHeight * index
    local y2 = y1 + buttonIconHeight

    return { x1, y1, x2, y2 }

end

function GUIMarineBuyMenu:_SetDetailsSectionTechId(techId, techCost)

    self.initialized = true

    local displayName = LookupTechData(techId, kTechDataDisplayName, nil)
    self.itemTitle:SetText(string.upper(Locale.ResolveString(displayName or "NO NAME")))

    self.costText:SetText(string.format("%s: %d", Locale.ResolveString("BUYMENU_COST"), techCost))

    local description = kTechIdInfo_Modded[techId].Description
    self.itemDescription:SetText(Locale.ResolveString(description))

    local bigPictureCoords = self:_GetPigPicturePixelCoordinatesForTechID(techId)
    self.bigPicture:SetTexturePixelCoordinates(GUIUnpackCoords(bigPictureCoords))

    local stats = kTechIdInfo_Modded[techId].Stats

    if stats then

        self.rangeBar:SetIsVisible(true)
        self.vsStructuresBar:SetIsVisible(true)
        self.vsLifeformBar:SetIsVisible(true)

        self.rangeText:SetIsVisible(true)
        self.vsStructuresText:SetIsVisible(true)
        self.vsLifeformsText:SetIsVisible(true)

        -- Grenades override the "range" label to instead say "AOE Range"
        self.rangeText:SetText(stats.RangeLabelOverride and Locale.ResolveString("BUYMENU_GRENADES_RANGE_OVERRIDE") or Locale.ResolveString("BUYMENU_RANGE"))

        self:_UpdateStatBar(self.rangeBar, stats.Range)
        self:_UpdateStatBar(self.vsLifeformBar, stats.LifeFormDamage)
        self:_UpdateStatBar(self.vsStructuresBar, stats.StructureDamage)
        self.itemDescription:SetPosition(Vector(0, self.itemDescriptionPositionY, 0))
        self.bigPicture:SetPosition(Vector(0, self.bigPicturePositionY, 0))

    else

        self.rangeBar:SetIsVisible(false)
        self.vsStructuresBar:SetIsVisible(false)
        self.vsLifeformBar:SetIsVisible(false)

        self.rangeText:SetIsVisible(false)
        self.vsStructuresText:SetIsVisible(false)
        self.vsLifeformsText:SetIsVisible(false)

        self.itemDescription:SetPosition(Vector(0, self.statBarsStartPosY, 0))
        self.bigPicture:SetPosition(Vector(0, self.bigPicturePositionY - self.bigPicturePositionYDiff, 0))

    end


    -- Update the "special" stuff.
    local techSpecial = kTechIdInfo_Modded[techId].Special
    if techSpecial then

        local specialDefinition = kSpecialDefinitions[techSpecial]
        self:_UpdateSpecialSection(specialDefinition)

        self.specialFrame:SetIsVisible(true)
    else
        self.specialFrame:SetIsVisible(false)
    end

end