
local S = core.get_translator(alternode.modname)


--- The pencil is an infotext editor for players.
--
--  Players can alter infotext on nodes they own or located
--  areas owned by them.

core.register_craftitem(alternode.modname .. ":pencil", {
	description = S("Tool for editing node infotext"),
	short_description = S("Pencil"),
	inventory_image = "alternode_pencil.png",
	stack_max = 1,
})


-- craft recipe
-- FIXME: don't need to depend on default if "group:stick" exists
if core.global_exists("default") and core.global_exists("technic") then
	core.register_craft({
		output = alternode.modname .. ":pencil",
		recipe = {
			{"", "", "technic:lead_lump"},
			{"", "group:stick", ""},
			{"technic:rubber", "", ""},
		},
	})
end