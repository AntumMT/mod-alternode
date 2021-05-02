
alternode = {}
alternode.name = core.get_current_modname()


core.register_craftitem(alternode.name .. ":infostick", {
	description = "Tool for retrieving information about node",
	short_description = "Info Stick",
	inventory_image = "alternode_infostick.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if not user:is_player() then return end

		local pname = user:get_player_name()

		local granted, missing = core.check_player_privs(pname, {server=true,})
		if not granted then
			core.chat_send_player(pname, "You do not have privileges to use this item (missing priviliges: " .. table.concat(missing, ", ") .. ")")
			return
		end

		if pointed_thing.type ~= "node" then
			core.chat_send_player(pname, "This item only works on nodes")
			return
		end

		local pos = core.get_pointed_thing_position(pointed_thing, false)
		local node = core.get_node_or_nil(pos)
		if not node then
			core.chat_send_player(pname, "That doesn't seem to be a proper node")
			return
		end
		local meta = core.get_meta(pos)

		local infostring = "pos: x=" .. tostring(pos.x)
			.. ", y=" .. tostring(pos.y)
			.. ", z=" .. tostring(pos.z)
			.. "; name=" .. node.name

		for _, key in ipairs({"infotext", "owner"}) do
			local value = meta:get_string(key)
			if value and value ~= "" then
				infostring = infostring .. "; "
					.. key .. "=" .. value
			end
		end

		core.chat_send_player(pname, infostring)
	end,
})

function alternode.get(pos, key)
	return core.get_meta(pos):get_string(key)
end

function alternode.set(pos, key, value)
	local meta = core.get_meta(pos)
	meta:set_string(key, value)
	return meta:get_string(key) == value
end


core.register_chatcommand("setmeta", {
	params = "<x> <y> <z> <key> <value>",
	description = "Alter meta data of a node",
	privs = {server=true,},
	func = function(player, param)
		local plist = string.split(param, " ")

		if #plist < 3 then
			core.chat_send_player(player, "You must supply proper coordinates")
			return false
		end

		for _, p in ipairs({plist[1], plist[2], plist[3]}) do
			if tonumber(p) == nil then
				core.chat_send_player(player, "You must supply proper coordinates")
				return false
			end
		end

		local pos = {
			x = tonumber(plist[1]),
			y = tonumber(plist[2]),
			z = tonumber(plist[3]),
		}

		local key = plist[4]
		if key then key = key:trim() end

		if not key or key == "" then
			core.chat_send_player(player, "You must supply a key parameter")
			return false
		end

		local value = {}
		for idx, word in ipairs(plist) do
			if idx > 4 then
				table.insert(value, word)
			end
		end

		if #value == 0 then
			core.chat_send_player(player, "You must supply a value parameter")
			return false
		end

		local retval = alternode.set(pos, key, table.concat(value, " "):trim())

		if not retval then
			core.chat_send_player(player,
				"Failed to set node meta at "
				.. tostring(pos.x) .. ","
				.. tostring(pos.y) .. ","
				.. tostring(pos.z))
		else
			core.chat_send_player(player,
				"Set meta \"" .. key .. "="
				.. core.get_meta(pos):get_string(key)
				.. "\" for node at "
				.. tostring(pos.x) .. ","
				.. tostring(pos.y) .. ","
				.. tostring(pos.z))
		end

		return retval
	end,
})

core.register_chatcommand("getmeta", {
	params = "<x> <y> <z> <key>",
	description = "Retrieve meta data of a node",
	privs = {server=true,},
	func = function(player, param)
		local plist = string.split(param, " ")

		if #plist < 3 then
			core.chat_send_player(player, "You must supply proper coordinates")
			return false
		end

		for _, p in ipairs({plist[1], plist[2], plist[3]}) do
			if tonumber(p) == nil then
				core.chat_send_player(player, "You must supply proper coordinates")
				return false
			end
		end

		local pos = {
			x = tonumber(plist[1]),
			y = tonumber(plist[2]),
			z = tonumber(plist[3]),
		}

		local key = plist[4]
		if key then key = key:trim() end

		if not key or key == "" then
			core.chat_send_player(player, "You must supply a key parameter")
			return false
		end

		local value = alternode.get(pos, key)
		if not value or value == "" then
			core.chat_send_player(player,
				"\"" .. key .. "\" key value not present in node meta data")
		else
			core.chat_send_player(player,
				"Meta value: " .. key .. "=" .. value)
		end

		return true
	end,
})
