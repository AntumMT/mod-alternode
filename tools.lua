
local S = core.get_translator(alternode.modname)

local use_s_protect = core.global_exists("s_protect")


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

--- Checks if a thing pointed at is a node.
--
--  @local
--  @function check_node
--  @param target pointed_thing
--  @param pname Name of player pointing.
--  @return `pos` if the pointed_thing is a node, `nil` otherwise.
local function check_node(target, pname)
	if not target then return false end

	local pos = nil
	local node = nil
	if target.type == "node" then
		pos = core.get_pointed_thing_position(target, false)
		node = core.get_node_or_nil(pos)
		if not node then
			pos = nil
		end
	end

	if not pos then
		core.chat_send_player(pname, S("This item only works on nodes"))
	end

	return pos, node
end


--- Admin tool to retrieve node node coordinates, name, & some select meta info.
--
--  @craftitem alternode:infostick
--  @use
--  @place
core.register_craftitem(alternode.modname .. ":infostick", {
	description = S("Tool for retrieving information about a node"),
	short_description = S("Info Stick"),
	inventory_image = "alternode_infostick.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if not user:is_player() then return end
		if not check_permissions(user) then return end

		local pname = user:get_player_name()
		local pos = check_node(pointed_thing, pname)
		if not pos then return end

		local nmeta = core.get_meta(pos)

		local infostring = S("pos: x@=@1, y@=@2, z@=@3; name@=@4",
			tostring(pos.x), tostring(pos.y), tostring(pos.z), node.name)

		for _, key in ipairs({"id", "infotext", "owner"}) do
			local value = nmeta:get_string(key)
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

		local pname = user:get_player_name()
		local pos, node = check_node(pointed_thing, pname)
		if not pos then return end

		-- store pos info for retrieval in callbacks
		user:get_meta():set_string(alternode.modname .. ":infostick:pos", core.serialize(pos))
		core.show_formspec(pname, alternode.modname .. ":infostick",
			alternode.get_infostick_formspec(pos, node, placer))
	end,
})


--- Player tool to alter *infotext* meta value.
--
--  @craftitem alternode:pencil
--  @use
--  @place
core.register_craftitem(alternode.modname .. ":pencil", {
	description = S("Tool for editing node infotext"),
	short_description = S("Pencil"),
	inventory_image = "alternode_pencil.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if not user:is_player() then return end

		local pname = user:get_player_name()
		local pos = check_node(pointed_thing, pname)
		if not pos then return end

		if not is_area_owner(pos, pname) then
			core.chat_send_player(pname, S("You cannot alter nodes in areas you do not own"))
			return
		end

		-- store pos info for retrieval in callbacks
		user:get_meta():set_string(alternode.modname .. ":pencil:pos", core.serialize(pos))
		core.show_formspec(pname, alternode.modname .. ":pencil",
			alternode.get_pencil_formspec(pos))
	end,
})


core.register_on_player_receive_fields(function(player, formname, fields)
	if formname == alternode.modname .. ":pencil" then
		-- FIXME: how to get node meta without storing in player meta?
		local pmeta = player:get_meta()
		local pos = core.deserialize(pmeta:get_string(alternode.modname .. ":pencil:pos"))
		local nmeta = core.get_meta(pos)

		if fields.btn_write then
			if fields.input:trim() == "" then
				nmeta:set_string("infotext", nil)
			else
				nmeta:set_string("infotext", fields.input)
			end
		elseif fields.btn_erase then
			nmeta:set_string("infotext", nil)
		end

		pmeta:set_string(alternode.modname .. ":pencil:pos", nil)
	end
end)


--- Player tool to set/unset *owner* meta value.
--
--  @craftitem alternode:key
--  @use
--  @place
core.register_craftitem(alternode.modname .. ":key", {
	description = S("Tool for setting node owner"),
	short_description = S("Node Key"),
	inventory_image = "alternode_key.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if not user:is_player() then return end

		local pname = user:get_player_name()
		local pos = check_node(pointed_thing, pname)
		if not pos then return end

		local nmeta = core.get_meta(pos)
		local node_owner = nmeta:get_string("owner")

		if node_owner ~= "" and pname ~= node_owner then
			core.chat_send_player(pname, S("You cannot take ownership of a node owned by @1", node_owner))
			return
		end

		local unown = false
		if pname == node_owner then unown = true end

		if unown then
			nmeta:set_string("owner", nil)
			core.chat_send_player(pname, S("You no longer own this node"))
		else
			if not is_area_owner(pos, pname) then
				core.chat_send_player(pname, S("You cannot take ownership of nodes in areas you do not own"))
				return
			end

			nmeta:set_string("owner", pname)
			core.chat_send_player(pname, S("You now own this node"))
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if not placer:is_player() then return end

		local pname = user:get_player_name()
		local pos = check_node(pointed_thing, pname)
		if not pos then return end

		local node_owner = core.get_meta(pos):get_string("owner")

		if node_owner == "" then
			core.chat_send_player(pname, S("This node is unowned"))
		else
			core.chat_send_player(pname, S("This node is owned by @1", node_owner))
		end
	end,
})
core.register_alias("ownit:wand", alternode.modname .. ":key")
core.register_alias(alternode.modname .. ":wand", alternode.modname .. ":key")
