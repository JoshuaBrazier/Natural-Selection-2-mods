local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
							
	table.insert(techData,{

        [kTechDataId] = kTechId.SuppressedShotgun,
        [kTechDataMaxHealth] = kMarineWeaponHealth,
        [kTechDataTooltipInfo] = "SUPPRESSEDSHOTGUN_TOOLTIP",
        [kTechDataPointValue] = kSuppressedShotgunPointValue,
        [kTechDataMapName] = SuppressedShotgun.kMapName,
        [kTechDataDisplayName] = "SUPPRESSEDSHOTGUN",
        [kTechDataModel] = SuppressedShotgun.kModelName,
        [kTechDataDamageType] = kSuppressedShotgunDamageType,
        [kTechDataCostKey] = kSuppressedShotgunCost,} )


    table.insert(techData,{

        [kTechDataId] = kTechId.SuppressedShotgunTech,
        [kTechDataCostKey] = kSuppressedShotgunTechResearchCost,
        [kTechDataResearchTimeKey] = kSuppressedShotgunTechResearchTime,
        [kTechDataDisplayName] = "RESEARCH_SUPPRESSEDSHOTGUN",
        [kTechDataTooltipInfo] = "SUPPRESSEDSHOTGUN_TOOLTIP", } )

    table.insert(techData,{

        [kTechDataId] = kTechId.DropSuppressedShotgun,
        [kTechDataMapName] = SuppressedShotgun.kMapName,
        [kTechDataDisplayName] = "SUPPRESSEDSHOTGUN_DROP",
        [kTechIDShowEnables] = false,
        [kTechDataTooltipInfo] = "SUPPRESSEDSHOTGUN_TOOLTIP",
        [kTechDataModel] = SuppressedShotgun.kModelName,
        [kTechDataCostKey] = kSuppressedShotgunCost,
        [kStructureAttachId] = { kTechId.AdvancedArmory },
        [kStructureAttachRange] = kArmoryWeaponAttachRange,
        [kStructureAttachRequiresPower] = true, } )
   
    return techData

end
