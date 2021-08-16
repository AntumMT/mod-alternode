
-- Place this file in mod's ".ldoc" directory
--
-- This configuration requires a customized version of LDoc:
--   https://github.com/AntumDeluge/ldoc/tree/custom

local dofile = import("dofile")
local print = import("print")
local error = import("error")
local type = import("type")
local table = import("table")
local ipairs = import("ipairs")
local pairs = import("pairs")
local string = import("string")
local tostring = import("tostring")


project = "Alternode"
title = "Node Meta Manipulation"
format = "markdown"
not_luadoc = true
boilerplate = false
wrap = false
--style = true
favicon = "https://www.minetest.net/media/icon.svg"

file = {
	"api.lua",
	"commands.lua",
	"formspec.lua",
	"tools.lua",
	"crafts.lua",
}


new_type("setting", "Settings")
new_type("chatcmd", "Chat Commands")
new_type("feature", "Features")
new_type("item", "Items")
new_type("tool", "Tools")
new_type("node", "Nodes")
new_type("craft", "Crafting")

alias("craftitem", "item")


local function video_frame(src)
	return '<iframe width="560" height="315" src="' .. src
		.. '" title="Video Player" frameborder="0"'
		.. ' allow="fullscreen;"></iframe>'
end

local tags
tags, custom_tags = dofile(".ldoc/tags.ld")


-- START: handling items to prevent re-parsing

local registered_items = {}

local is_registered = function(item)
	if not registered_items[item.type] then return false end

	for _, tbl in ipairs(registered_items[item.type]) do
		if item == tbl then
			return true
		end
	end

	return false
end

local register = function(item)
	if not registered_items[item.type] then
		registered_items[item.type] = {}
	end

	if not is_registered(item) then
		table.insert(registered_items[item.type], item)
	end
end

-- END:


local set_names_hierarchy = function(name, sorted)
	local m = modules.by_name[name]
	if m then
		m.names_hierarchy = sorted
	end
end

local format_string = function(value, flags)
	local st = '<span style="'
	if flags.color then
		st = st .. 'color:' .. flags.color .. ';'
	end
	if flags.size then
		st = st .. 'font-size:' .. flags.size .. ';'
	end

	return st .. '">' .. value:gsub("_", "\\_") .. '</span>'
end

local format_setting_tag = function(desc, value)
	return "\n- " .. format_string("`" .. desc .. ":`", {size="80%"}) .. " " .. value
end


local setting_handler = function(item)
	local tags = {
		{"settype", "type"},
		{"default"},
		{"min", "minimum value"},
		{"max", "maximum value"},
	}

	local def = {
		["settype"] = format_setting_tag("type", "string"),
	}

	for _, t in ipairs(tags) do
		local name = t[1]
		local desc = t[2]
		if not desc then desc = name end

		local value = item.tags[name]
		if type(value) == "table" then
			if #value > 1 then
				local msg = item.file.filename .. " (line " .. item.lineno
					.. "): multiple instances of tag \"" .. name .. "\" found"
				if error then
					error(msg)
				elseif print then
					print("WARNING: " .. msg)
				end
			end

			if value[1] then
				def[name] = format_setting_tag(desc, value[1])
			end
		end
	end

	item.description = item.description .. "\n\n**Definition:**\n" .. def.settype
	for _, t in ipairs({def.default, def.min, def.max}) do
		if t then
			item.description = item.description .. t
		end
	end

	registered.settings[item.name] = true

	return item
end

local chatcmd_handler = function(item)
	for _, p in ipairs(item.params) do
		if item.modifiers.param[p].opt then
			item.name = item.name .. " [" .. p .. "]"
		else
			item.name = item.name .. " &lt;" .. p .. "&gt;"
		end
	end

	return item
end

local craft_handler = function(item)
	if item.tags.output then
		local output = '<a href="tools.html#'..item.tags.output[1]..'">'
			..item.tags.output[1]..'</a>'
		item.description = item.description.."\n\n**Output:** "..output
	end

	if item.tags.recipe then
		local recipe = item.tags.recipe[1]:gsub("\n", "\n  ")
		recipe = "<details><summary>**Recipe:**</summary>\n"
			..recipe.."\n</details>"
		item.description  = item.description.."\n\n"..recipe
	end

	return item
end

custom_display_name_handler = function(item, default_handler)
	if not is_registered(item) then
		if item.type == "setting" then
			item = setting_handler(item)
		elseif item.type == "chatcmd" then
			item = chatcmd_handler(item)
		elseif item.type == "craft" then
			item = craft_handler(item)
		end

		local parse_tags = {"priv", "note"}
		for _, pt in ipairs(parse_tags) do
			local tvalues = item.tags[pt]
			if tvalues then
				local tstring = ""

				local title = tags.get_title(pt)
				if title then
					tstring = tstring .. "\n\n### " .. title .. ":\n"
				end

				for _, tv in ipairs(tvalues) do
					tstring = tstring .. "\n- " .. tags.format(pt, tv)
				end

				item.description = item.description .. tstring
			end
		end
	end

	register(item)
	return default_handler(item)
end


local custom_see_links = {
	["ObjectRef"] = "https://minetest.gitlab.io/minetest/class-reference/#objectref",
	["PlayerMetaRef"] = "https://minetest.gitlab.io/minetest/class-reference/#playermetaref",
	["SorageRef"] = "https://minetest.gitlab.io/minetest/class-reference/#storageref",
	["NodeMetaRef"] = "https://minetest.gitlab.io/minetest/class-reference/#nodemetaref",
	["ItemStackMetaRef"] = "https://minetest.gitlab.io/minetest/class-reference/#itemstackmetaref",
	["MetaDataRef"] = "https://minetest.gitlab.io/minetest/class-reference/#metadataref",
	["InvRef"] = "https://minetest.gitlab.io/minetest/class-reference/#invref",
	["ItemDef"] = "https://minetest.gitlab.io/minetest/definition-tables/#item-definition",
	["ToolDef"] = "https://minetest.gitlab.io/minetest/tools/#tools-definition",
	["ItemStack"] = "https://minetest.gitlab.io/minetest/class-reference/#itemstack",
	["Node"] = "https://minetest.gitlab.io/minetest/nodes/",
	["groups"] = "https://minetest.gitlab.io/minetest/groups/",
	["entity_damage_mechanism"] = "https://minetest.gitlab.io/minetest/entity-damage-mechanism/",
	["vector"] = "https://minetest.gitlab.io/minetest/representations-of-simple-things/#positionvector",
	["SoundParams"] = "https://minetest.gitlab.io/minetest/sounds/",
}

local format_custom_see = function(name, section)
	local url = custom_see_links[name]
	if not url then
		url = ""
	end

	if not name then
		name = ""
	end

	return name, url
end

custom_see_handler("^(ObjectRef)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(PlayerMetaRef)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(StorageRef)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(NodeMetaRef)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(ItemStackMetaRef)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(MetaDataRef)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(InvRef)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(ItemDef)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(ToolDef)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(groups)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(entity_damage_mechanism)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(ItemStack)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(Node)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(vector)$", function(name, section)
	return format_custom_see(name, section)
end)

custom_see_handler("^(SoundParams)$", function(name, section)
	return format_custom_see(name, section)
end)
