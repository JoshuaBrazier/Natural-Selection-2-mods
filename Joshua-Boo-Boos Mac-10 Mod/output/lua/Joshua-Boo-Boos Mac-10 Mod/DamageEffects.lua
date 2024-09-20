
kMac10DamageEffects = {
    damage_decal = {
        damageDecals = {
            {
                decal = "cinematics/vfx_materials/decals/bullet_hole_01.material",
                scale = 0.2,
                doer = "Mac10",
                done = true
            },
        },
    },

}

GetEffectManager():AddEffectData("Mac10DamageEffects", kMac10DamageEffects)