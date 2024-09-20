local old_GUIActionIcon_ShowIcon = GUIActionIcon.ShowIcon
function GUIActionIcon:ShowIcon(buttonText, weaponType, hintText, holdFraction)
    if weaponType == 'Mac10' then
        weaponType = 'Pistol'
    end
    return old_GUIActionIcon_ShowIcon(self, buttonText, weaponType, hintText, holdFraction)
end
