local mod = get_mod("doomrocket")

AttachmentNodeLinking.ai_doomrocket = {
    wielded = {
        {
            target = 0,
            source = "j_leftweaponattach"
        },
        {
            target = "a_barrel",
            source = "j_leftweaponcomponent1"
        },
        {
            target = "handle",
            source = "j_lefthand"
        },
    },
    unwielded = {
        {
            target = 0,
            source = "a_spear"
        }
    }
}

AttachmentNodeLinking.doomrocket_pack = {
    {
        target = 0,
        source = "a_spear"
    },
}

AttachmentNodeLinking.doomrocket_armor = {
    {
        target = 0,
        source = "root_point",
    },
    {
        target = "j_hips",
        source = "j_hips",
    },
    {
        target = "j_leftupleg",
        source = "j_leftupleg",
    },
    {
        target = "j_rightupleg",
        source = "j_rightupleg",
    },
    {
        target = "j_spine",
        source = "j_spine",
    },
    -- {
    --     target = "j_leftupleg_scale",
    --     source = "j_leftupleg_scale",
    -- },
    -- {
    --     target = "j_rightupleg_scale",
    --     source = "j_rightupleg_scale",
    -- },
    -- {
    --     target = "j_spine_scale",
    --     source = "j_spine_scale",
    -- },
    {
        target = "j_leftleg",
        source = "j_leftleg",
    },
    {
        target = "j_rightleg",
        source = "j_rightleg",
    },
    {
        target = "j_spine1",
        source = "j_spine1",
    },
    {
        target = "j_leftfoot",
        source = "j_leftfoot",
    },
    {
        target = "j_leftshoulder",
        source = "j_leftshoulder",
    },
    {
        target = "j_neck",
        source = "j_neck",
    },
    {
        target = "j_rightfoot",
        source = "j_rightfoot",
    },
    {
        target = "j_rightshoulder",
        source = "j_rightshoulder",
    },
    {
        target = "j_leftarm",
        source = "j_leftarm",
    },
    {
        target = "j_lefttoebase",
        source = "j_lefttoebase",
    },
    {
        target = "j_neck_1",
        source = "j_neck_1",
    },
    {
        target = "j_rightarm",
        source = "j_rightarm",
    },
    {
        target = "j_righttoebase",
        source = "j_righttoebase",
    },
    {
        target = "j_head",
        source = "j_head",
    },
    {
        target = "j_leftforearm",
        source = "j_leftforearm",
    },
    {
        target = "j_rightforearm",
        source = "j_rightforearm",
    },
    {
        target = "j_leftforearmroll",
        source = "j_leftforearmroll",
    },
    {
        target = "j_lefthand",
        source = "j_lefthand",
    },
    {
        target = "j_rightforearmroll",
        source = "j_rightforearmroll",
    },
    {
        target = "j_righthand",
        source = "j_righthand",
    },
    {
        target = "j_leftweaponattach",
        source = "j_leftweaponattach",
    },
    {
        target = "j_rightweaponattach",
        source = "j_rightweaponattach",
    },
    {
        target = "j_leftweaponcomponent1",
        source = "j_leftweaponcomponent1",
    },
    {
        target = "j_leftweaponcomponent10",
        source = "j_leftweaponcomponent10",
    },
    {
        target = "j_leftweaponcomponent2",
        source = "j_leftweaponcomponent2",
    },
    {
        target = "j_leftweaponcomponent3",
        source = "j_leftweaponcomponent3",
    },
    {
        target = "j_leftweaponcomponent4",
        source = "j_leftweaponcomponent4",
    },
    {
        target = "j_leftweaponcomponent5",
        source = "j_leftweaponcomponent5",
    },
    {
        target = "j_leftweaponcomponent6",
        source = "j_leftweaponcomponent6",
    },
    {
        target = "j_leftweaponcomponent7",
        source = "j_leftweaponcomponent7",
    },
    {
        target = "j_leftweaponcomponent8",
        source = "j_leftweaponcomponent8",
    },
    {
        target = "j_leftweaponcomponent9",
        source = "j_leftweaponcomponent9",
    },
    {
        target = "j_rightweaponcomponent1",
        source = "j_rightweaponcomponent1",
    },
    {
        target = "j_rightweaponcomponent10",
        source = "j_rightweaponcomponent10",
    },
    {
        target = "j_rightweaponcomponent2",
        source = "j_rightweaponcomponent2",
    },
    {
        target = "j_rightweaponcomponent3",
        source = "j_rightweaponcomponent3",
    },
    {
        target = "j_rightweaponcomponent4",
        source = "j_rightweaponcomponent4",
    },
    {
        target = "j_rightweaponcomponent5",
        source = "j_rightweaponcomponent5",
    },
    {
        target = "j_rightweaponcomponent6",
        source = "j_rightweaponcomponent6",
    },
    {
        target = "j_rightweaponcomponent7",
        source = "j_rightweaponcomponent7",
    },
    {
        target = "j_rightweaponcomponent8",
        source = "j_rightweaponcomponent8",
    },
    {
        target = "j_rightweaponcomponent9",
        source = "j_rightweaponcomponent9",
    },
    -- {
    --     target = "j_jaw",
    --     source = "j_jaw",
    -- },
    -- {
    --     target = "j_leftear",
    --     source = "j_leftear",
    -- },
    -- {
    --     target = "j_rightear",
    --     source = "j_rightear",
    -- },
    {
        target = "j_lefthandindex1",
        source = "j_lefthandindex1",
    },
    {
        target = "j_lefthandmiddle1",
        source = "j_lefthandmiddle1",
    },
    {
        target = "j_lefthandpinky1",
        source = "j_lefthandpinky1",
    },
    {
        target = "j_lefthandring1",
        source = "j_lefthandring1",
    },
    {
        target = "j_leftinhandthumb",
        source = "j_leftinhandthumb",
    },
    {
        target = "j_righthandindex1",
        source = "j_righthandindex1",
    },
    {
        target = "j_righthandmiddle1",
        source = "j_righthandmiddle1",
    },
    {
        target = "j_righthandpinky1",
        source = "j_righthandpinky1",
    },
    {
        target = "j_righthandring1",
        source = "j_righthandring1",
    },
    {
        target = "j_rightinhandthumb",
        source = "j_rightinhandthumb",
    },
    {
        target = "j_lefthandindex2",
        source = "j_lefthandindex2",
    },
    {
        target = "j_lefthandmiddle2",
        source = "j_lefthandmiddle2",
    },
    {
        target = "j_lefthandpinky2",
        source = "j_lefthandpinky2",
    },
    {
        target = "j_lefthandring2",
        source = "j_lefthandring2",
    },
    {
        target = "j_lefthandthumb1",
        source = "j_lefthandthumb1",
    },
    {
        target = "j_righthandindex2",
        source = "j_righthandindex2",
    },
    {
        target = "j_righthandmiddle2",
        source = "j_righthandmiddle2",
    },
    {
        target = "j_righthandpinky2",
        source = "j_righthandpinky2",
    },
    {
        target = "j_righthandring2",
        source = "j_righthandring2",
    },
    {
        target = "j_righthandthumb1",
        source = "j_righthandthumb1",
    },
    {
        target = "j_lefthandindex3",
        source = "j_lefthandindex3",
    },
    {
        target = "j_lefthandmiddle3",
        source = "j_lefthandmiddle3",
    },
    {
        target = "j_lefthandpinky3",
        source = "j_lefthandpinky3",
    },
    {
        target = "j_lefthandring3",
        source = "j_lefthandring3",
    },
    {
        target = "j_lefthandthumb2",
        source = "j_lefthandthumb2",
    },
    {
        target = "j_righthandindex3",
        source = "j_righthandindex3",
    },
    {
        target = "j_righthandmiddle3",
        source = "j_righthandmiddle3",
    },
    {
        target = "j_righthandpinky3",
        source = "j_righthandpinky3",
    },
    {
        target = "j_righthandring3",
        source = "j_righthandring3",
    },
    {
        target = "j_righthandthumb2",
        source = "j_righthandthumb2",
    },
}


local rocket_glaive_1 = {
	unit_extension_template = "ai_weapon_unit",
    unit_name = "units/rocket/pRocketLauncher",
	attachment_node_linking = AttachmentNodeLinking.ai_doomrocket,
    extension_init_data = {
        weapon_system = {
            weapon_template = "ratling_gun"
        }
    },
    drop_reasons = {
        death = true,
    },
}

local bombadier_pack_1 = {
	unit_extension_template = "ai_outfit_unit",
    unit_name = "units/bombadier/Backpack",
	attachment_node_linking = AttachmentNodeLinking.doomrocket_pack,
    drop_reasons = {
        death = false,
    },
}

local bombadier_curiass = {
	unit_extension_template = "ai_outfit_unit",
    unit_name = "units/beings/enemies/skaven_plague_monk/chr_skaven_plague_monk",
	attachment_node_linking = AttachmentNodeLinking.doomrocket_armor,
    drop_reasons = {
        death = false,
    },
}

local rocket_glaives = {
    rocket_glaive_1,
    count = 1,
    name = 'doomrocket_inventory',
}

local bombadier_pack = {
    bombadier_pack_1,
    count = 1,
    name = 'doomrocket_inventory',
}

local bombadier_armor = {
    bombadier_curiass,
    count = 1,
    name = 'doomrocket_inventory',
}

InventoryConfigurations['doomrocket_inventory'] = {
    enemy_hit_sound = "bullet",
	anim_state_event = "idle",
	items = {
		bombadier_pack,
        -- bombadier_armor,
        -- bloodletter_heads,
        rocket_glaives,
        -- bloodletter_outfits,
        
	},
    items_n = 3
}

InventoryConfigurations['warlock_engineer'] = {
    enemy_hit_sound = "spear",
	anim_state_event = "idle",
	multiple_configurations = { 
        "doomrocket_inventory",
        -- "ratlinggun",
        -- "halberd",
    },
    items_n = 1
}


-- local configs = InventoryConfigurations["ratlinggun"]
-- local items = configs.items
-- local items_n = configs.items_n
-- local index = 0
-- for i = 1, items_n, 1 do
--     index = index + 1
--     local item_category = items[i]
--     local item_category_n = item_category.count
--     local item_category_name = item_category.name
--     local item_index = math.random(1, item_category_n)
--     local item = item_category[item_index]
--     local item_unit_name = item.unit_name
--     local item_unit_template_name = item.unit_extension_template or "ai_inventory_item"
--     local item_flow_event = item.flow_event

--     mod:echo(item_category)
--     mod:echo(item_category_n)
--     mod:echo(item_category_name)
--     mod:echo(item_index)
--     mod:echo(item)
--     mod:echo(item_unit_name)
--     mod:echo(item_unit_template_name)
--     mod:echo(item_flow_event)
-- end

local new_configs = {
    doomrocket_inventory = InventoryConfigurations['doomrocket_inventory'],
    warlock_engineer =InventoryConfigurations['warlock_engineer']
}


for config_name, config in pairs(new_configs) do
	config.items_n = config.items and #config.items

	-- assert(AIInventoryTemplates[config_name] == nil, "Can't override configuration based templates")

	AIInventoryTemplates[config_name] = function ()
		return config_name
	end

	local multiple_configurations = config.multiple_configurations

	if multiple_configurations then
		config.config_lookup = {}

		for i = 1, #multiple_configurations do
			local config_name = multiple_configurations[i]
			config.config_lookup[config_name] = i
		end
	end
end


local num_invents = #NetworkLookup.ai_inventory
NetworkLookup.ai_inventory["doomrocket_inventory"] = num_invents + 1
NetworkLookup.ai_inventory[num_invents + 1] = "doomrocket_inventory"