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
mod:dofile("scripts/mods/doomrocket/extensions/death_reactions")
mod:dofile("scripts/mods/doomrocket/utils/hooks")
-- -- mod:dofile("scripts/managers/conflict_director/conflict_director")




--setup rocket explosion template
ExplosionTemplates["doomrocket_explosion"] = {
	explosion = {
		radius =  6,
		alert_enemies = true,
		max_damage_radius = 1.5,
		always_hurt_players = true,
		alert_enemies_radius = 15,
		sound_event_name = "Play_enemy_combat_warpfire_backpack_explode",
		damage_profile = "warpfire_thrower_explosion",
		effect_name = "fx/chr_warp_fire_explosion_01",
		damage_type = "grenade",
		catapult_force = 10,
		catapult_players = true,
		dont_rotate_fx = true,
		allow_friendly_fire_override = true,
		player_push_speed = 15,
		difficulty_power_level = {
			easy = {
				power_level_glance = 400,
				power_level = 800
			},
			normal = {
				power_level_glance = 400,
				power_level = 800
			},
			hard = {
				power_level_glance = 400,
				power_level = 800
			},
			harder = {
				power_level_glance = 400,
				power_level = 800
			},
			hardest = {
				power_level_glance = 400,
				power_level = 800
			},
			cataclysm = {
				power_level_glance = 400,
				power_level = 800
			},
			cataclysm_2 = {
				power_level_glance = 400,
				power_level = 800
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


local spawn_mod = get_mod("CreatureSpawner")
new_breed_names = {
    'chaos_bulwark',
}
if spawn_mod then
	for i,breed_name in ipairs(new_breed_names) do
		table.insert(spawn_mod["all_units"], breed_name)
	end
end


-- "units/beings/enemies/chaos_warrior/chr_chaos_warrior"
-- "units/beings/enemies/chaos_warrior_bulwark/chr_chaos_warrior_bulwark"
-- "resource_packages/breeds/chaos_zombie"

-- Managers.package:load("resource_packages/breeds/chaos_zombie", "global")

-- local world = Managers.world:world("level_world")
-- local player = Managers.player:local_player()
-- local player_unit = player.player_unit
-- local position = Unit.local_position(player_unit, 0)
-- local rotation = Unit.local_rotation(player_unit, 0)
-- local unit_1 = Managers.state.unit_spawner:spawn_local_unit("units/beings/enemies/chaos_warrior_bulwark/chr_chaos_warrior_bulwark", position, rotation)
-- local unit_2 = Managers.state.unit_spawner:spawn_local_unit("units/beings/enemies/chaos_warrior/chr_chaos_warrior", position, rotation)
-- Unit.disable_animation_state_machine(unit_2)
-- local bones_1 = Unit.bones(unit_1)
-- local bones_2 = Unit.bones(unit_2)
-- AttachmentNodeLinking.cw_to_cw = {}
-- for index, bone in ipairs(bones_1) do
-- 	AttachmentNodeLinking.cw_to_cw[index] = {
-- 		target = bone,
-- 		source = bones_2[index]
-- 	}
-- end
-- Unit.set_unit_visibility(unit_1, false)
-- AttachmentUtils.link(world, unit_1, unit_2, AttachmentNodeLinking.cw_to_cw)

-- local num_mesh = Unit.num_meshes(unit_1)
-- print(num_mesh)
-- Unit.set_mesh_visibility(unit_2, 1, false, "default") -- close lod of right shoulder shield thingy
-- Unit.set_mesh_visibility(unit_2, 2, false, "default") -- lod of left shoulder fly
-- Unit.set_mesh_visibility(unit_2, 3, false, "default") -- lod of left shoulder fly
-- Unit.set_mesh_visibility(unit_2, 4, false, "default") -- far lod of nurgle chest symbol
-- Unit.set_mesh_visibility(unit_2, 5, false, "default") -- close lod of nurgle chest symbol
-- -- Unit.set_mesh_visibility(unit_2, 6, false, "default")
-- -- Unit.set_mesh_visibility(unit_2, 7, false, "default")
-- -- Unit.set_mesh_visibility(unit_2, 8, false, "default")
-- -- Unit.set_mesh_visibility(unit_2, 9, false, "default")
-- -- Unit.set_mesh_visibility(unit_2, 10, false, "default")
-- -- Unit.set_mesh_visibility(unit_2, 11, false, "default")
-- Unit.set_mesh_visibility(unit_2, 12, false, "default") --  lod of mushrooms
-- -- Unit.set_mesh_visibility(unit_2, 13, false, "default")
-- -- Unit.set_mesh_visibility(unit_2, 14, false, "default")
-- -- Unit.set_mesh_visibility(unit_2, 15, false, "default")
-- -- Unit.set_mesh_visibility(unit_2, 17, false, "default")
-- -- Unit.set_mesh_visibility(unit_2, 18, false, "default")
-- Unit.set_mesh_visibility(unit_2, 0, false, "default") -- far lod of right shoulder shield thingy

-- local hat_unit = Managers.state.unit_spawner:spawn_local_unit("units/beings/enemies/addons/chaos_marauder/moc_helmet_04/moc_helmet_04_b", position, rotation)
-- AttachmentUtils.link(world, unit_1, hat_unit, AttachmentNodeLinking.ai_helmet)
-- Unit.set_local_scale(hat_unit,0,  Vector3(1.25, 1.25, 1.25))

-- local hat_unit = Managers.state.unit_spawner:spawn_local_unit( "units/beings/critters/chr_critter_nurgling/chr_critter_nurgling_horn_04", position, rotation)
-- AttachmentUtils.link(world, unit_1, hat_unit, AttachmentNodeLinking.ai_helmet)
-- Unit.set_local_scale(hat_unit, 0,  Vector3(1.25, 1.25, 1.25))

-- Unit.set_local_scale(unit_1, 0,  Vector3(0.75, 0.75, 0.75))



-- mod:command('cw_anim', '', function(state)
-- 	local world = Managers.world:world("level_world")
-- 	local player = Managers.player:local_player()
-- 	local player_unit = player.player_unit
-- 	local position = Unit.local_position(player_unit, 0)
-- 	local rotation = Unit.local_rotation(player_unit, 0)
-- 	local unit_1 = Managers.state.unit_spawner:spawn_local_unit("units/beings/enemies/skaven_rat_ogre/chr_skaven_rat_ogre", position, rotation)
-- 	BLACKBOARDS[unit_1] = {
-- 		attacks_done = 0,

-- 	}
-- 	mod.unit = unit_1
-- 	Unit.animation_set_state(unit_1, state)
-- end)

-- mod:hook(ScriptUnit, 'extension', function(func, unit, system_name)
-- 	if system_name == "ai_system" then
-- 		if mod.unit == unit then
-- 			return_val = {
-- 				blackboard = function(self)
-- 					return BLACKBOARDS[mod.unit]
-- 				end
-- 			}
-- 			return return_val
-- 		end
-- 	end

-- 	return func(unit, system_name)
-- end)



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

mod:dofile("scripts/settings/breeds")


mod:dofile("scripts/mods/doomrocket/utils/action_sweep_rewrite")

mod.doom = false
mod:command("doom", "", function()
	if mod.doom then
		for setting_name, settings in pairs(SpecialsSettings) do
			if settings.breeds then
				for index, breed_name in ipairs(settings.breeds) do
					if breed_name == "skaven_doomrocket" then
						settings.breeds[index] = nil
					end
				end
			end
			if settings.difficulty_overrides then
				for diff, diff_settings in pairs(settings.difficulty_overrides) do
					for index, breed_name in ipairs(diff_settings) do
						if breed_name == "skaven_doomrocket" then
							diff_settings.breeds[index] = nil
						end
					end
				end
			end
		end
		mod.doom = false
	else
		for setting_name, settings in pairs(SpecialsSettings) do
			if settings.breeds then
				settings.breeds[#settings.breeds + 1] = "skaven_doomrocket"
			end
			if settings.difficulty_overrides then
				for diff, diff_settings in pairs(settings.difficulty_overrides) do
					if diff_settings.breeds then
						diff_settings.breeds[#diff_settings.breeds + 1] = "skaven_doomrocket"
					end
				end
			end
		end
		mod.doom = true
	end
	mod:chat_broadcast("Doom:	"..tostring(mod.doom))
end)
