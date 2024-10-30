ModLoader.SetupFileHook( "lua/Balance.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Balance.lua", "post" )
ModLoader.SetupFileHook( "lua/Globals.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Globals.lua", "post" )

ModLoader.SetupFileHook( "lua/NS2Utility.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/NS2Utility.lua", "post" )
ModLoader.SetupFileHook( "lua/TechTreeButtons.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/TechTreeButtons.lua", "post" )

ModLoader.SetupFileHook( "lua/TechData.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/TechData.lua", "post" )
ModLoader.SetupFileHook( "lua/Armory.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Armory.lua", "post" )

ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/TechTreeConstants.lua", "post" )
ModLoader.SetupFileHook( "lua/GUIActionIcon.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/GUIActionIcon.lua", "post" )
-- ModLoader.SetupFileHook( "lua/MarineWeaponEffects.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/MarineWeaponEffects.lua", "post" )
ModLoader.SetupFileHook( "lua/DamageEffects.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/DamageEffects.lua", "post" )
ModLoader.SetupFileHook( "lua/HitSounds.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/HitSounds.lua", "post" )
ModLoader.SetupFileHook( "lua/UmbraMixin.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/UmbraMixin.lua", "post" )

ModLoader.SetupFileHook( "lua/MarineTeam.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/MarineTeam.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/ClipWeapon.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/ClipWeapon.lua", "post" )

ModLoader.SetupFileHook( "lua/AmmoPack.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/AmmoPack.lua", "post" )

ModLoader.SetupFileHook( "lua/Player.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Player.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Marine.lua", "post" )
ModLoader.SetupFileHook( "lua/Onos.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Onos.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineBuy_Client.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/MarineBuy_Client.lua", "post" )

ModLoader.SetupFileHook( "lua/GUIPickups.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/GUIPickups.lua", "post" )
ModLoader.SetupFileHook( "lua/Scoreboard.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Scoreboard.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/WeaponDisplayManager.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/WeaponDisplayManager.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineTeamInfo.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/MarineTeamInfo.lua", "post" )
ModLoader.SetupFileHook( "lua/GUIMarineBuyMenu.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/GUIMarineBuyMenu.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineVariantMixin.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/MarineVariantMixin.lua", "post" )
ModLoader.SetupFileHook( "lua/Hud/GUIInventory.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/GUIInventory.lua", "post" )
ModLoader.SetupFileHook( "lua/GUIDeathMessages.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/GUIDeathMessages.lua", "post" )

--Combat
ModLoader.SetupFileHook( "lua/Combat/ExperienceData.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Combat data/ExperienceData.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/ExperienceEnums.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Combat data/ExperienceEnums.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/MarineBuyFuncs.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Combat data/MarineBuyFuncs.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/Player_Upgrades.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Combat data/Player_Upgrades.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/CombatMarineUpgrade.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Combat data/CombatMarineUpgrade.lua", "post" )

--SHOTGUN MOD
ModLoader.SetupFileHook( "lua/Hud/Marine/GUIMarineHUD.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/GUIMarineHUD.lua", "replace" ) -- Shotgun changes / GUIShotgunDisplay.lua
ModLoader.SetupFileHook( "lua/GUIShotgunDisplay.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/GUIShotgunDisplay.lua", "replace" ) -- Shotgun changes / GUIShotgunDisplay.lua
ModLoader.SetupFileHook( "lua/Weapons/Marine/Shotgun.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Shotgun.lua", "replace" ) -- Shotgun changes / Shotgun.lua
ModLoader.SetupFileHook( "lua/Player_Client.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Player_Client.lua", "post" ) -- Shotgun changes / Player_Client.lua
ModLoader.SetupFileHook( "lua/Player_Server.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Player_Server.lua", "post" ) -- Shotgun changes / Player_Server.lua

--BONEWALL MOD
ModLoader.SetupFileHook( "lua/CommAbilities/Alien/BoneWall.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/BoneWall.lua", "replace" )
ModLoader.SetupFileHook( "lua/Onos.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Onos_BoneWall.lua", "post" )

--RTD MOD
if not Shine then
    ModLoader.SetupFileHook( "lua/Chat.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/Chat.lua", "post" )
    ModLoader.SetupFileHook( "lua/NetworkMessages.lua", "lua/Joshua-Boo-Boos DMD Combat Mod/NetworkMessages.lua", "post" )
end