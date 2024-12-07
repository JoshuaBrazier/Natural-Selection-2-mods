local upgrade = CombatMarineUpgrade()

upgrade:Initialize(kCombatUpgrades.SuppressedShotgun, "suppressedshotgun", "SuppressedShotgun", kTechId.SuppressedShotgun, nil, kCombatUpgrades.Shotgun, 1, kCombatUpgradeTypes.Weapon, false, 0, { kCombatUpgrades.Exosuit, kCombatUpgrades.RailGunExosuit, kCombatUpgrades.DualMinigunExosuit })

table.insert(UpsList, upgrade)