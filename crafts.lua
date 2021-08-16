
--- Crafting
--
--  @topic crafting


-- pencil
local pencil = {
	lead = "technic:lead_lump",
	stick = "group:stick",
	rubber = "technic:rubber",
}

-- FIXME: how to check if items are registered under "group:stick"
if core.global_exists("default") and
		core.registered_items[pencil.lead] and core.registered_items[pencil.rubber] then

	--- @craft pencil
	--  @output alternode:pencil
	--  @recipe
	--  Key:
	--  - L: technic:lead_lump
	--  - S: group:stick
	--  - R: technic:rubber
	--
	--  ╔═══╦═══╦═══╗
	--  ║   ║   ║ L ║
	--  ╠═══╬═══╬═══╣
	--  ║   ║ S ║   ║
	--  ╠═══╬═══╬═══╣
	--  ║ R ║   ║   ║
	--  ╚═══╩═══╩═══╝
	core.register_craft({
		output = alternode.modname .. ":pencil",
		recipe = {
			{"", "", pencil.lead},
			{"", pencil.stick, ""},
			{pencil.rubber, "", ""},
		},
	})
end


-- key
local key = {
	main = "basic_materials:brass_ingot",
}

if core.registered_items[key.main] then
	--- @craft key
	--  @output alternode:key
	--  @recipe
	--  Key:
	--  - B: basic_materials:brass_ingot
	--
	--  ╔═══╦═══╗
	--  ║   ║ B ║
	--  ╠═══╬═══╣
	--  ║ B ║   ║
	--  ╚═══╩═══╝
	core.register_craft({
		output = alternode.modname .. ":key",
		recipe = {
			{"", key.main},
			{key.main, ""},
		},
	})
end
