local mod = get_mod("doomrocket")
mod:dofile("scripts/mods/doomrocket/breeds/skaven_doomrocket_inventory")

local function INVENTORY_UNIT(owner_unit)
	local breed = Unit.get_data(owner_unit, "breed")
	local inventory_template = breed.default_inventory_template
	local inventory_extension = ScriptUnit.extension(owner_unit, "ai_inventory_system")
	local inventory_unit = inventory_extension:get_unit(inventory_template)

	return inventory_unit
end

local function INVENTORY_UNIT_VS(owner_unit)
	local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	local inventory_unit = inventory_extension:get_weapon_unit()

	return inventory_unit
end

local function IS_HUSK_UNIT(owner_unit)
	local is_network_unit = NetworkUnit.is_network_unit(owner_unit)
	local is_husk = is_network_unit and NetworkUnit.is_husk_unit(owner_unit)

	return is_husk
end

local function IS_UNIT_1P(owner_unit)
	return not IS_HUSK_UNIT(owner_unit)
end

local function IS_UNIT_3P(owner_unit)
	return IS_HUSK_UNIT(owner_unit)
end


Breeds.skaven_doomrocket = table.clone(Breeds.skaven_ratling_gunner)
Breeds.skaven_doomrocket.aim_template = "doomrocket"
Breeds.skaven_doomrocket.behavior = "skaven_doomrocket"
Breeds.skaven_doomrocket.threat_value = 7
Breeds.skaven_doomrocket.rocket_capacity = 3
Breeds.skaven_doomrocket.default_inventory_template = "doomrocket_inventory"

BreedActions.skaven_doomrocket = table.clone(BreedActions.skaven_ratling_gunner)
BreedActions.skaven_doomrocket.fire_rocket = table.clone(BreedActions.skaven_doomrocket.shoot_ratling_gun)
BreedActions.skaven_doomrocket.shoot_ratling_gun = nil
BreedActions.skaven_doomrocket.fire_rocket.light_weight_projectile_template_name = "doomrocket"

BreedActions.skaven_doomrocket.switch_weapons = {
    switch_animation = "idle",
    switch_weapon_index = 2,
    cooldown = -1,
    switching_done_time = 0.2
}


Dismemberments["skaven_doomrocket"] = table.clone(Dismemberments["skaven_ratling_gunner"])

LightWeightProjectiles["doomrocket"] = {
    projectile_speed = 80,
		light_weight_projectile_effect = "doomrocket",
		damage_profile = "ratling_gunner",
		projectile_max_range = 50,
		hit_effect = "ratling_gunner",
		impact_push_speed = 1.5,
		spread = math.degrees_to_radians(7),
		attack_power_level = {
			20,
			40,
			120,
			200,
			250,
			250,
			250,
			250
		}
}
LightWeightProjectileEffects["doomrocket"] = {
    ratling_gun_bullet = {
		vfx = {
			{
				particle_name = "fx/chr_warp_fire_flamethrower_01",
				kill_policy = "destroy"
			},
			{
				particle_name = "fx/warp_lightning_bolt_impact",
				kill_policy = "stop"
			},
			{
				particle_name = "fx/wpnfx_skaven_ratlinggun_muzzlefx",
				link = "p_fx",
				unit_function = INVENTORY_UNIT
			}
		},
		sfx = {
			{
				looping_sound_event_name = "Play_weapon_warpbullet_flyby_proximity",
				looping_sound_stop_event_name = "Stop_weapon_warpbullet_flyby_proximity"
			}
		}
	}
}

-- local world = Managers.world:world("level_world")
-- -- local wwise_world = Wwise.wwise_world(world)
-- local player = Managers.player:local_player()
-- local player_unit = player.player_unit
-- local position = Unit.local_position(player_unit, 0)
-- local rotation = Unit.local_rotation(player_unit, 0)
-- -- WwiseWorld.trigger_event(wwise_world, "Play_enemy_warpfire_thrower_shoot", position, rotation)
-- Managers.state.unit_spawner:spawn_local_unit("units/bombadier/Backpack", position, rotation)

-- local function is_available(type, name)
-- 	printf("%s.%s : available? => %s", name, type, Application.can_get(type, name))
-- end
-- is_available("unit", "units/bombadier/Backpack")