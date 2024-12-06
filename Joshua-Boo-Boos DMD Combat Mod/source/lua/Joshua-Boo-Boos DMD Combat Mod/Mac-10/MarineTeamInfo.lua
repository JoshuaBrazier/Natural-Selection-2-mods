if Server then
	local kTrackedMarineGadgets = debug.getupvaluex(MarineTeamInfo.UpdateUserTrackers, "kTrackedMarineGadgets")
	table.insert(kTrackedMarineGadgets, Mac10.kMapName)
end

local networkVars =
{
}

networkVars[TeamInfo_GetUserTrackerNetvarName(Mac10.kMapName)] = string.format("integer (0 to %d)", kMaxPlayers - 1)

Shared.LinkClassToMap("MarineTeamInfo", MarineTeamInfo.kMapName, networkVars)