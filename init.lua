
alternode = {}
alternode.modname = core.get_current_modname()
alternode.modpath = core.get_modpath(alternode.modname)

local scripts = {
	"api",
	"commands",
	"formspec",
	"infostick",
	"pencil",
	"wand",
}

for _, script in ipairs(scripts) do
	dofile(alternode.modpath .. "/" .. script .. ".lua")
end
