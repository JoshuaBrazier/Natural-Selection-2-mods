local defaults = debug.getupvaluex(GetDefaultInputValue, "defaults")
table.insert(defaults, {"RollTheDice", "None"})

local bindings = BindingsUI_GetBindingsData()
for i, v in ipairs {
	"RollTheDice",     "input", "Roll The Dice",     "None",
} do
	table.insert(bindings, i, v)
end
