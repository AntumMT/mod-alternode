title = "Alternode Mod for Minetest"
project = "alternode"
format = "markdown"
not_luadoc = true
boilerplate = false

file = {".", exclude={"init.lua", "misc_functions.lua",},}


local function italic(value)
	return "<span style=\"font-style:italic;\">" .. value .. "</span>"
end

new_type("setting", "Settings")
new_type("chatcmd", "Chat Commands")
new_type("craftitem", "Item")
custom_tags = {
	{"image",
		title = "Image",
		format = function(value)
			return "<img src=\"../../textures/" .. value .. "\" style=\"width:32px; height:32px;\" />"
		end,
	},
	{"use",
		title = "Use <i>(left-click)</i>",
	},
	{"place",
		title = "Place <i>(right-click)</i>",
	},
}

local function chatcmd_handler(item)
	local output = item.name
	for _, p in ipairs(item.params) do
		if item.modifiers.param[p].opt then
			output = output .. " [" .. p .. "]"
		else
			output = output .. " &lt;" .. p .. "&gt;"
		end
	end

	return output
end

local function setting_handler(item)
	if item.tags.settype and #item.tags.settype > 1 then
		error("Setting can have only one type")
	end
	if item.tags.default and #item.tags.default > 1 then
		error("Setting can have only one default")
	end

	return item.name
end

function custom_display_name_handler(item, default_handler)
	if item.type == "chatcmd" then
		return chatcmd_handler(item)
	end

	return default_handler(item)
end
