
local S = core.get_translator(alternode.modname)


local use_s_protect = core.global_exists("s_protect")

local function is_area_owner(pos, pname)
	if not pname then return false end

	if use_s_protect then
		local claim = s_protect.get_claim(pos)
		if claim then return pname == claim.owner end
	else
		return core.is_protected(pos, pname)
	end

	return false
end

local function check_node_pos(target)
		if target.type ~= "node" then return end
		local pos = core.get_pointed_thing_position(target, false)
		if not core.get_node_or_nil(pos) then return end

		return pos
end


--- The pencil is an infotext editor for players.
--
--  Players can alter infotext on nodes they own or located
--  areas owned by them.

core.register_craftitem(alternode.modname .. ":pencil", {
	description = S("Tool for editing node infotext"),
	short_description = S("Pencil"),
	inventory_image = "alternode_pencil.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if not user:is_player() then return end
		local pos = check_node_pos(pointed_thing)
		if not pos then return end

		local pname = user:get_player_name()
		if not is_area_owner(pos, pname) then
			core.chat_send_player(pname, "You cannot alter nodes in areas you do not own")
			return
		end

		local infotext = core.get_meta(pos):get_string("infotext")
		local formspec = "formspec_version[4]"
			.. "size[6,4]"
			.. "textarea[1,1;4,1.5;input;Infotext;" .. infotext .. "]"
			.. "button_exit[1.5,2.75;1.25,0.75;btn_set;Set]"
			.. "button_exit[3.3,2.75;1.25,0.75;btn_unset;Unset]"

		-- store pos info for retrieval in callbacks
		user:get_meta():set_string(alternode.modname .. ":pencil:pos", core.serialize(pos))
		core.show_formspec(pname, alternode.modname .. ":pencil", formspec)
	end,
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


core.register_on_player_receive_fields(function(player, formname, fields)
	if formname == alternode.modname .. ":pencil" then
		-- FIXME: how to get node meta without storing in player meta?
		local pmeta = player:get_meta()
		local pos = core.deserialize(pmeta:get_string(alternode.modname .. ":pencil:pos"))
		local nmeta = core.get_meta(pos)

		if fields.btn_set then
			nmeta:set_string("infotext", fields.input)
		elseif fields.btn_unset then
			nmeta:set_string("infotext", nil)
		end

		pmeta:set_string(alternode.modname .. ":pencil:pos", nil)
	end
end)
