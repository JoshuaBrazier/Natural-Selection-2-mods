table.insert(kMarineTechMap, { kTechId.Mac10Tech, 4.5, 5.5 })
table.insert(kMarineLines, GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.Mac10Tech))

--Currently unused as Advanced weapons are unlocked by the Tech Advanced Weaponry. Left this in here incase i decide to have a separate CannonTech research. Not currently hooked in so no impact.