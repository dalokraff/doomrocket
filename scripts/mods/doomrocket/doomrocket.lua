local mod = get_mod("doomrocket")
-- Your mod code goes here.
-- https://vmf-docs.verminti.de


Managers.package:load("resource_packages/breeds/skaven_ratling_gunner", "global")
-- Managers.package:load("resource_packages/breeds/skaven_warpfire_thrower", "global")

mod:dofile("scripts/mods/doomrocket/breeds/skaven_doomrocket")
mod:dofile("scripts/mods/doomrocket/interactions/doom_rocket_interaction")
mod:dofile("scripts/mods/doomrocket/extensions/projectile_rocket")
mod:dofile("scripts/mods/doomrocket/extensions/anim_emitter")
local threat_values = {}

for breed_name, data in pairs(Breeds) do
	threat_values[breed_name] = override_threat_value or data.threat_value or 0

	if not data.threat_value then
		ferror("missing threat in breed %s", breed_name)
	end
end
ConflictDirector.calculate_threat_value = function (self)
	local threat_value = 0
	local i = 0
	local activated_per_breed = Managers.state.performance:activated_per_breed()

	for breed_name, amount in pairs(activated_per_breed) do
		threat_value = threat_value + threat_values[breed_name] * amount
		i = i + amount
	end

	self.delay_horde = self.delay_horde_threat_value < threat_value
	self.delay_mini_patrol = self.delay_mini_patrol_threat_value < threat_value
	self.delay_specials = self.delay_specials_threat_value < threat_value
	self.threat_value = threat_value
	self.num_aggroed = i
end

mod:dofile("scripts/mods/doomrocket/behavior/nodes/skaven_doomrocket/generated/bt_selector_skaven_doomrocket")
mod:dofile("scripts/mods/doomrocket/behavior/nodes/skaven_doomrocket/bt_doomrocket_launch_action")
mod:dofile("scripts/mods/doomrocket/behavior/nodes/skaven_doomrocket/bt_doomrocket_reload_action")
mod:dofile("scripts/mods/doomrocket/behavior/nodes/skaven_doomrocket/trees/skaven/skaven_doomrocket_behavior")
mod:dofile("scripts/mods/doomrocket/extensions/doomrocket_aim_template")
mod:dofile("scripts/mods/doomrocket/utils/hooks")
-- -- mod:dofile("scripts/managers/conflict_director/conflict_director")




--setup rocket explosion template
ExplosionTemplates["doomrocket_explosion"] = {
	explosion = {
		radius = 7.5,
		alert_enemies = true,
		max_damage_radius = 5,
		always_hurt_players = true,
		alert_enemies_radius = 15,
		sound_event_name = "Play_enemy_combat_warpfire_backpack_explode",
		damage_profile = "warpfire_thrower_explosion",
		effect_name = "fx/chr_warp_fire_explosion_01",
		damage_type = "grenade",
		catapult_force = 15,
		catapult_players = true,
		player_push_speed = 20,
		difficulty_power_level = {
			easy = {
				power_level_glance = 200,
				power_level = 400
			},
			normal = {
				power_level_glance = 200,
				power_level = 200
			},
			hard = {
				power_level_glance = 400,
				power_level = 400
			},
			harder = {
				power_level_glance = 600,
				power_level = 600
			},
			hardest = {
				power_level_glance = 800,
				power_level = 800
			},
			cataclysm = {
				power_level_glance = 600,
				power_level = 1200
			},
			cataclysm_2 = {
				power_level_glance = 800,
				power_level = 1600
			},
			cataclysm_3 = {
				power_level_glance = 400,
				power_level = 800
			}
		},
		camera_effect = {
			near_distance = 5,
			near_scale = 1,
			shake_name = "frag_grenade_explosion",
			far_scale = 0.25,
			far_distance = 30
		},
	}
}

-- ExplosionTemplates["doomrocket_explosion"].explosion["damage_type"] = "kinetic"
ExplosionTemplates["doomrocket_explosion"].name = "doomrocket_explosion"

local num_explosions = #NetworkLookup.explosion_templates
NetworkLookup.explosion_templates[num_explosions + 1] = "doomrocket_explosion"
NetworkLookup.explosion_templates["doomrocket_explosion"] = num_explosions + 1




-- local function create_lookups(lookup, hashtable)
-- 	local i = #lookup

-- 	for key, _ in pairs(hashtable) do
-- 		i = i + 1
-- 		lookup[i] = key
-- 	end

-- 	return lookup
-- end
-- NetworkLookup.breeds = create_lookups({}, Breeds)

local num_breeeds = #NetworkLookup.breeds
NetworkLookup.breeds[num_breeeds + 1] = "skaven_doomrocket"
NetworkLookup.breeds["skaven_doomrocket"] = num_breeeds + 1

-- for k,v in pairs(NetworkLookup.breeds) do
-- 	mod:echo(k.."	"..tostring(v))
-- end

local num_dam = #NetworkLookup.damage_sources + 1
NetworkLookup.damage_sources["skaven_doomrocket"] = num_dam
NetworkLookup.damage_sources[num_dam] = "skaven_doomrocket"


local spawn_mod = get_mod("CreatureSpawner")

-- local add_spawn_catagory = {
--     beastmen_nu_gor = {
--         "misc",
--     },
--     beastmen_slaangor_standard = {
--         "misc",
--     },
-- }
-- table.merge(spawn_mod.unit_categories, table)
new_breed_names = {
    'skaven_doomrocket',
}

if spawn_mod then
	for i,breed_name in ipairs(new_breed_names) do
		table.insert(spawn_mod["all_units"], breed_name)
	end
end
mod:echo("done")

for bt_name, bt_node in pairs(BreedBehaviors) do
    bt_node[1] = "BTSelector_" .. bt_name
    bt_node.name = bt_name .. "_GENERATED"
end

local num_acitons = #NetworkLookup.bt_action_names
NetworkLookup.bt_action_names["fire_rocket"] = num_acitons
NetworkLookup.bt_action_names[num_acitons] = "fire_rocket"

local husk_num = #NetworkLookup.husks
NetworkLookup.husks[husk_num + 1] = "units/rocket/SM_Rocket"
NetworkLookup.husks["units/rocket/SM_Rocket"] = husk_num + 1

local num_anims = #NetworkLookup.anims
NetworkLookup.anims[num_anims + 1] = "doomrocket_reload"
NetworkLookup.anims["doomrocket_reload"] = num_anims + 1


mod.anim_emitters = {}
mod.projectiles = {}

function mod.update(dt)
    for projectile_unit,projectile in pairs(mod.projectiles) do
		projectile:update(dt)
	end

	for unit,anim_emitter in pairs(mod.anim_emitters) do
		anim_emitter:update(unit, dt)
	end
end



BEAST_ARMOR = {
    {
        target = 0,
        source = 0,
   }
}

mod:dofile("scripts/settings/breeds")


mod:dofile("scripts/mods/doomrocket/utils/action_sweep_rewrite")

mod.doom = false
mod:command("doom", "", function()
    if mod.doom then
		mod.doom = false
		for horde_name, horde_data in pairs(HordeCompositionsPacing) do
			for value, more_data in pairs(horde_data[1]) do
				if value == "breeds" then
					local num_breeeds = #more_data
					more_data[num_breeeds+1] = nil
					more_data[num_breeeds+2] = nil
				end
			end
		end

	else
		mod.doom = true
		for horde_name, horde_data in pairs(HordeCompositionsPacing) do
			for value, more_data in pairs(horde_data[1]) do
				if value == "breeds" then
					local num_breeeds = #more_data
					more_data[num_breeeds+1] = "skaven_doomrocket"
					more_data[num_breeeds+2] = {
						1,
						3
					}
				end
			end
		end
	end
	mod:chat_broadcast("Doom:	"..tostring(mod.doom))
end)
