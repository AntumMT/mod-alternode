
local S = core.get_translator(alternode.modname)


--- Retrieves formspec layout for `alternode:infostick` item.
--
--  TODO: add fields for get, set, & unset meta data
--
--  @function alternode.get_infostick_formspec
--  @param pos
--  @param node
--  @param player
--  @treturn string Formspec formatted string.
function alternode.get_infostick_formspec(pos, node, player)
	local nmeta = core.get_meta(pos)
	local infostring = S("pos: x@=@1, y@=@2, z@=@3; name@=@4",
		tostring(pos.x), tostring(pos.y), tostring(pos.z), node.name)

	-- some commonly used meta keys
	for _, key in ipairs({"id", "infotext", "owner"}) do
		local value = nmeta:get_string(key)
		if value and value ~= "" then
			infostring = infostring .. "; "
				.. key .. "=" .. value
		end
	end

	-- linebreaks are added here so we can keep translator string same as on on_use method
	infostring = infostring:gsub("; ", "\n")

	local formspec = "formspec_version[4]"
		.. "size[16,10]"
		.. "label[0.15,0.25;" .. core.formspec_escape(infostring) .. "]"

	return formspec
end

--- Retrieves formspec layout for `alternode:pencil` item.
--
--  @function alternode.get_pencil_formspec
--  @param pos
--  @treturn string Formspec formatted string.
function alternode.get_pencil_formspec(pos)
	local infotext = core.get_meta(pos):get_string("infotext")
	local formspec = "formspec_version[4]"
		.. "size[6,4]"
		.. "textarea[1,1;4,1.5;input;" .. S("Infotext") .. ";" .. infotext .. "]"
		.. "button_exit[1.5,2.75;1.25,0.75;btn_write;" .. S("Write") .. "]"
		.. "button_exit[3.3,2.75;1.25,0.75;btn_erase;" .. S("Erase") .. "]"

	return formspec
end
