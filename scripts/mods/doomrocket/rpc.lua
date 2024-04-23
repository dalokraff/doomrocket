local mod = get_mod("doomrocket")

mod:network_register("rpc_launch_rocket", function(sender, go_id, network_velocity, network_target_vector, attacker_unit_id)
	print(sender)

    local attacker_unit = Managers.state.unit_storage:unit(attacker_unit_id)
	local velocity = AiAnimUtils.velocity_network_scale(network_velocity)
    local target_vector = AiAnimUtils.velocity_network_scale(network_target_vector)

	local breed = Breeds['skaven_doomrocket']
	local inventory_template = breed.default_inventory_template
	local inventory_extension = ScriptUnit.extension(attacker_unit, "ai_inventory_system")
	local ratling_gun_unit = inventory_extension:get_unit(inventory_template)

	local projectile_unit = Managers.state.unit_storage:unit(go_id)

	mod.projectiles[projectile_unit] = ProjectileRocket:new(projectile_unit, attacker_unit, target_vector)

	Unit.set_mesh_visibility(ratling_gun_unit, "pRocket", false, "default")
end)

mod:hook(UnitSpawner, 'spawn_unit_from_game_object', function (func, self, go_id, owner_id, go_template)

	if go_template then
        if go_template.go_type == 'ai_unit_ratling_gunner' then
            go_template.go_type = 'ai_unit_doomrocket'
        end

    end

    return func(self, go_id, owner_id, go_template)
end)