-- define OP_TT_ColorPicker just incase ns2plus hasn't been loaded
Script.Load("lua/menu2/widgets/GUIMenuColorPickerWidget.lua") -- doesn't get loaded by vanilla menu
OP_TT_ColorPicker = OP_TT_ColorPicker or GetMultiWrappedClass(GUIMenuColorPickerWidget, {"Option", "Tooltip"})

local menu =
{
	categoryName = "rollTheDice",
	entryConfig =
	{
		name = "rollTheDiceModEntry",
		class = GUIMenuCategoryDisplayBoxEntry,
		params =
		{
			label = "ROLL THE DICE OPTIONS",
		},
	},
	contentsConfig = ModsMenuUtils.CreateBasicModsMenuContents
	{
		layoutName = "rollTheDiceOptions",
		contents =
		{
			{
				name = "rollTheDice",
				class = OP_Keybind,
				params = {
					optionPath = "input/RollTheDice",
					optionType = "string",
					default = "None",

					bindGroup = "general",
				},
				properties = {
					{ "Label", "ROLL THE DICE" },
				},
			},
		},
	}
}
table.insert(gModsCategories, menu)