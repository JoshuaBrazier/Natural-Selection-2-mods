local upgrade = CombatMarineUpgrade()

upgrade:Initialize(kCombatUpgrades.Mac10, "mac10", "Mac10", kTechId.Mac10, nil, kCombatUpgrades.Weapons1, 1, kCombatUpgradeTypes.Weapon, false, 0, { kCombatUpgrades.Exosuit, kCombatUpgrades.RailGunExosuit, kCombatUpgrades.DualMinigunExosuit })

table.insert(UpsList, upgrade)