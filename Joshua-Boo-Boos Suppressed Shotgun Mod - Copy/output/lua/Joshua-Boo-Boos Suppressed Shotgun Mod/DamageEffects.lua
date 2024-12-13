
kSuppressedShotgunDamageEffects = {
    damage_decal = {
        damageDecals = {
            {
                decal = "cinematics/vfx_materials/decals/bullet_hole_01.material",
                scale = 0.2,
                doer = "SuppressedShotgun",
                done = true
            },
        },
    },

}

GetEffectManager():AddEffectData("SuppressedShotgunDamageEffects", kSuppressedShotgunDamageEffects)