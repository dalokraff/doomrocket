AimTemplates.doomrocket = {
	owner = {
		init = function (unit, data)
			local blackboard = BLACKBOARDS[unit]
			data.blackboard = blackboard
			data.constraint_target = Unit.animation_find_constraint_target(unit, "aim_target")
		end,
		update = function (unit, t, dt, data)
			local unit_position = POSITION_LOOKUP[unit]
			local aim_target = nil
			local attack_pattern_data = data.blackboard.attack_pattern_data

			if attack_pattern_data and attack_pattern_data.shoot_direction_box then
				local shoot_direction = attack_pattern_data.shoot_direction_box:unbox()
				aim_target = unit_position + Vector3.normalize(shoot_direction) * 5
			else
				local look_direction = Quaternion.forward(Unit.local_rotation(unit, 0))
				aim_target = unit_position + look_direction * 5
			end

			if not Unit.has_animation_event(unit, "doomrocket_reload_start") then
                Unit.animation_set_constraint_target(unit, data.constraint_target, aim_target)
            end

			local game = Managers.state.network:game()
			local go_id = Managers.state.unit_storage:go_id(unit)

			if game and go_id then
				GameSession.set_game_object_field(game, go_id, "aim_target", aim_target)
			end
		end,
		leave = function (unit, data)
			return
		end
	},
	husk = {
		init = function (unit, data)
			data.constraint_target = Unit.animation_find_constraint_target(unit, "aim_target")
		end,
		update = function (unit, t, dt, data)
			local game = Managers.state.network:game()
			local go_id = Managers.state.unit_storage:go_id(unit)

			if game and go_id then
				local aim_target = GameSession.game_object_field(game, go_id, "aim_target")

				if not Unit.has_animation_event(unit, "doomrocket_reload_start") then
                    Unit.animation_set_constraint_target(unit, data.constraint_target, aim_target)
                end
			else
				local look_direction = Quaternion.forward(Unit.local_rotation(unit, 0))
				local aim_target = POSITION_LOOKUP[unit] + look_direction * 5

				if not Unit.has_animation_event(unit, "doomrocket_reload_start") then
                    Unit.animation_set_constraint_target(unit, data.constraint_target, aim_target)
                end
			end
		end,
		leave = function (unit, data)
			return
		end
	}
}