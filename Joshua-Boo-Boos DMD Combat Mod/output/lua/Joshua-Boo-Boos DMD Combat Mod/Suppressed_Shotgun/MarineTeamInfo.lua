if Server then
	local kTrackedMarineGadgets = debug.getupvaluex(MarineTeamInfo.UpdateUserTrackers, "kTrackedMarineGadgets")
	table.insert(kTrackedMarineGadgets, SuppressedShotgun.kMapName)
end

local networkVars =
{
}

networkVars[TeamInfo_GetUserTrackerNetvarName(SuppressedShotgun.kMapName)] = string.format("integer (0 to %d)", kMaxPlayers - 1)

Shared.LinkClassToMap("MarineTeamInfo", MarineTeamInfo.kMapName, networkVars)