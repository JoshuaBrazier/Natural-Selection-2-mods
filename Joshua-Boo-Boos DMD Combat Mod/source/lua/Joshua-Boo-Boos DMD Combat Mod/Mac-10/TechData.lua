local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
							
	table.insert(techData,{

        [kTechDataId] = kTechId.Mac10,
        [kTechDataMaxHealth] = kMarineWeaponHealth,
        [kTechDataTooltipInfo] = "MAC10_TOOLTIP",
        [kTechDataPointValue] = kMac10PointValue,
        [kTechDataMapName] = Mac10.kMapName,
        [kTechDataDisplayName] = "MAC10",
        [kTechDataModel] = Mac10.kModelName,
        [kTechDataDamageType] = kMac10DamageType,
        [kTechDataCostKey] = kMac10Cost,} )


    table.insert(techData,{

        [kTechDataId] = kTechId.Mac10Tech,
        [kTechDataCostKey] = kMac10TechResearchCost,
        [kTechDataResearchTimeKey] = kMac10TechResearchTime,
        [kTechDataDisplayName] = "RESEARCH_MAC10",
        [kTechDataTooltipInfo] = "MAC10_TOOLTIP", } )

    table.insert(techData,{

        [kTechDataId] = kTechId.DropMac10,
        [kTechDataMapName] = Mac10.kMapName,
        [kTechDataDisplayName] = "MAC10_DROP",
        [kTechIDShowEnables] = false,
        [kTechDataTooltipInfo] = "MAC10_TOOLTIP",
        [kTechDataModel] = Mac10.kModelName,
        [kTechDataCostKey] = kMac10Cost,
        [kStructureAttachId] = { kTechId.AdvancedArmory },
        [kStructureAttachRange] = kArmoryWeaponAttachRange,
        [kStructureAttachRequiresPower] = true, } )
   
    return techData

end
