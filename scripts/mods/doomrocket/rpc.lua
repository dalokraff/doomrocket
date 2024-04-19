local mod = get_mod("doomrocket")

mod:network_register("rpc_launch_rocket", function(sender, attacker_unit_id, launchpad_unit_id, network_velocity, network_position, network_rotation, network_target_vector)

    -- local launchpad_unit = Managers.state.unit_storage:unit(launchpad_unit_id)
    -- Unit.set_mesh_visibility(launchpad_unit, "pRocket", false, "default")

    local attacker_unit = Managers.state.unit_storage:unit(attacker_unit_id)

    local position = AiAnimUtils.position_network_scale(network_position)
	local rotation = AiAnimUtils.rotation_network_scale(network_rotation)
	local velocity = AiAnimUtils.velocity_network_scale(network_velocity)
    local target_vector = AiAnimUtils.velocity_network_scale(network_target_vector)

	local unit_name = "units/rocket/SM_Rocket"

	local unit_template_name = nil
	local extension_init_data = {
	}

	local projectile_unit = Managers.state.unit_spawner:spawn_network_unit(unit_name, unit_template_name, extension_init_data, position, rotation)
	mod.projectiles[projectile_unit] = ProjectileRocket:new(projectile_unit, attacker_unit, target_vector)

	local actor = Unit.actor(projectile_unit, 0)
	Actor.add_velocity(actor, velocity)
end)