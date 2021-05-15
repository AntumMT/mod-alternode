
local S = core.get_translator(alternode.modname)


local function check_permissions(player)
	local pname = player:get_player_name()

	local granted, missing = core.check_player_privs(pname, {server=true,})
	if not granted then
		core.chat_send_player(pname,
			S("You do not have privileges to use this item (missing priviliges: @1)", table.concat(missing, ", ")))
		return false
	end

	return true
end

local function target_is_node(target)
		if target.type ~= "node" then
			core.chat_send_player(pname, S("This item only works on nodes"))
			return false
		end

		return true
end


core.register_craftitem(alternode.modname .. ":infostick", {
	description = S("Tool for retrieving information about a node"),
	short_description = S("Info Stick"),
	inventory_image = "alternode_infostick.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if not user:is_player() then return end
		if not check_permissions(user) then return end
		if not target_is_node(pointed_thing) then return end

		local pname = user:get_player_name()
		local pos = core.get_pointed_thing_position(pointed_thing, false)
		local node = core.get_node_or_nil(pos)
		if not node then
			core.chat_send_player(pname, S("That doesn't seem to be a proper node"))
			return
		end
		local meta = core.get_meta(pos)

		local infostring = S("pos: x@=@1, y@=@2, z@=@3; name@=@4",
			tostring(pos.x), tostring(pos.y), tostring(pos.z), node.name)

		for _, key in ipairs({"id", "infotext", "owner"}) do
			local value = meta:get_string(key)
			if value and value ~= "" then
				infostring = infostring .. "; "
					.. key .. "=" .. value
			end
		end

		core.chat_send_player(pname, infostring)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if not placer:is_player() then return end
		if not check_permissions(placer) then return end
		if not target_is_node(pointed_thing) then return end

		local pos = core.get_pointed_thing_position(pointed_thing, false)
		local node = core.get_node_or_nil(pos)
		if not node then
			core.chat_send_player(pname, S("That doesn't seem to be a proper node"))
			return
		end

		alternode.show_formspec(pos, node, placer)
	end,
})
