local mod = get_mod("doomrocket")

local new_packages = {
    "resource_packages/breeds/skaven_doomrocket",
}
local pacakge_tisch = {}

for k,v in ipairs(new_packages) do
    pacakge_tisch[v] = v
end

mod:hook(PackageManager, "load",
         function(func, self, package_name, reference_name, callback,
                  asynchronous, prioritize)
    if package_name ~= pacakge_tisch[package_name]then
        func(self, package_name, reference_name, callback, asynchronous,
             prioritize)
    end

end)

mod:hook(PackageManager, "unload",
         function(func, self, package_name, reference_name)
    if package_name ~= pacakge_tisch[package_name] then
        func(self, package_name, reference_name)
    end

end)

mod:hook(PackageManager, "has_loaded",
         function(func, self, package, reference_name)
    if package == pacakge_tisch[package] then
        return true
    end

    return func(self, package, reference_name)
end)



-- mod:hook(MatchmakingManager, "update", function(func, self, dt, ...)

--     for k,v in pairs(BLACKBOARDS) do
--         if v.breed.name == "skaven_doomrocket" then

--             for i,j in pairs(v) do
--                 if v.action then
--                     mod:echo(v.action.name)
--                 end
--             end
--         end
--     end

--     func(self, dt, ...)
-- end)

-- mod:hook(UnitSpawner,"spawn_network_unit", function (func, self, unit_name, unit_template_name, extension_init_data, position, rotation, material)
--     mod:echo(unit_template_name)
--     -- for k,v in pairs(extension_init_data) do
--     --     print(tostring(k).." = {")
--     --     for i,j in pairs(v) do
--     --         print("     "..i..   " = "..tostring(j)..",")
--     --     end
--     --     print("}")
--     -- end
--     return func(self, unit_name, unit_template_name, extension_init_data, position, rotation, material)
-- end)

-- local player = Managers.player:local_player()
-- local player_unit = player.player_unit
-- local position = Unit.local_position(player_unit, 0) + Vector3(0,0,1)
-- -- local unit_name = "units/weapons/enemy/wpn_skaven_ratlinggun/wpn_skaven_ratlinggun"
-- local unit_name = "units/weapons/enemy/wpn_skaven_set/wpn_skaven_halberd_41"
-- local unit = Managers.state.unit_spawner:spawn_local_unit(unit_name, position)

-- local data = Unit.has_node(unit, "weapon")
-- mod:echo(data)
-- mod:hook(WwiseWorld, "trigger_event", function(func, self, event_name, ...)
--     mod:echo(event_name)
--     return func(self, event_name)
-- end)


--this stuff probably needs to be in it's own mod or reworked to be more dynamic

local new_breeds = {
    "skaven_doomrocket",
}
local breeds_to_force_spawn = {}
for k,v in ipairs(new_breeds) do
    breeds_to_force_spawn[v] = v
end

mod:hook(ConflictDirector, "update_spawn_queue", function(func, self, t)
	local enemy_package_loader = self.enemy_package_loader

	enemy_package_loader:update_breeds_loading_status()

	if self.spawn_queue_size == 0 then
		return
	end

	local first_spawn_index = self.first_spawn_index
	local spawn_queue = self.spawn_queue
	local d = spawn_queue[first_spawn_index]
	local breed = d[1]
	local breed_name = breed.name

	while not enemy_package_loader.breed_loaded_on_all_peers[breed_name] and (breed_name ~= breeds_to_force_spawn[breed_name]) do
		first_spawn_index = first_spawn_index + 1

		if first_spawn_index == self.first_spawn_index + self.spawn_queue_size then
			return
		end

		d = spawn_queue[first_spawn_index]
		breed = d[1]
		breed_name = breed.name
	end

	local unit = not script_data.disable_breed_freeze_opt and self.breed_freezer:try_unfreeze_breed(breed, d)

	if unit then
		local breed = BLACKBOARDS[unit].breed
		local go_id = Managers.state.unit_storage:go_id(unit)

		self:_post_spawn_unit(unit, go_id, breed, d[2]:unbox(), d[4], d[5], d[7], d[6], d[10])
	else
		unit = self:_spawn_unit(d[1], d[2]:unbox(), d[3]:unbox(), d[4], d[5], d[6], d[7], d[8], d[10])
	end

	self.num_queued_spawn_by_breed[breed_name] = self.num_queued_spawn_by_breed[breed_name] - 1

	local unit_data = d[9]

	if unit_data then
		unit_data[1] = unit
	end

	if first_spawn_index ~= self.first_spawn_index then
		local swapee = self.spawn_queue[first_spawn_index]

		self.spawn_queue[first_spawn_index] = self.spawn_queue[self.first_spawn_index]
		self.spawn_queue[self.first_spawn_index] = swapee
	end

	self.spawn_queue_size = self.spawn_queue_size - 1
	self.first_spawn_index = self.first_spawn_index + 1

	if self.spawn_queue_size == 0 then
		self.first_spawn_index = 1
	end
end)


local breed_to_breed_stats = {}
for i,breed in ipairs(new_breeds) do
    breed_to_breed_stats[breed] = "skaven_ratling_gunner"
end
--some reason have to hook whole stats function
mod:hook(StatisticsDatabase,"modify_stat_by_amount", function (func, self, id, ...)
    local stat = self.statistics[id]
	local arg_n = select("#", ...)

	for i = 1, arg_n - 1, 1 do
		local arg_value = select(i, ...)
        -- mod:echo(arg_value)
        if breed_to_breed_stats[arg_value] then
            arg_value = breed_to_breed_stats[arg_value]
        end
		stat = stat[arg_value]
	end



    if stat == nil then
        stat = self.statistics[id]
    end
	local increment_value = select(arg_n, ...)
	local old_value = stat.value or 0
	stat.value = old_value + increment_value

	if stat.persistent_value then
		stat.dirty = increment_value ~= 0
		stat.persistent_value = stat.persistent_value + increment_value
	end

	local event_manager = Managers.state.event

	if event_manager then
		event_manager:trigger("event_stat_modified_by", id, ...)
	end
end)

mod:hook(StatisticsDatabase,"increment_stat", function (func, self, id, ...)
    local stat = self.statistics[id]
	local arg_n = select("#", ...)

	for i = 1, arg_n, 1 do
		local arg_value = select(i, ...)
        -- mod:echo(arg_value)
        if breed_to_breed_stats[arg_value] then
            arg_value = breed_to_breed_stats[arg_value]
        end
		stat = stat[arg_value]
	end

	stat.value = stat.value + 1

	if stat.persistent_value then
		stat.dirty = true
		stat.persistent_value = stat.persistent_value + 1
	end

	local event_manager = Managers.state.event

	if event_manager then
		event_manager:trigger("event_stat_incremented", id, ...)
	end
end)



local new_animations = {
	doomrocket_reload_start = {
		timing = 0.5,
		emitted_event = "anim_cb_attack_windup_start_finished"
	},
}

mod:hook(UnitSpawner, "create_unit_extensions", function(func, self, world, unit, unit_template_name, extension_init_data)

	if extension_init_data then
		if extension_init_data.locomotion_system then
			if extension_init_data.locomotion_system.breed then
				if extension_init_data.locomotion_system.breed.name == "skaven_doomrocket" then
					mod:echo(extension_init_data.locomotion_system.breed.name)
					if Unit.alive(unit) then
						for animaiton_event, details in pairs(new_animations) do
							Unit.set_data(unit, animaiton_event, "timing", details.timing)
							Unit.set_data(unit, animaiton_event, "emitted_event", details.emitted_event)
						end

						mod.anim_emitters[unit] = AnimEmitter:new(unit, blackboard)

						Unit.set_mesh_visibility(unit, 0, false, "default")--far tank LOD
						Unit.set_mesh_visibility(unit, 4, false, "default") --far belt LOD
						Unit.set_mesh_visibility(unit, 5, false, "default") -- medium tank LOD

						Unit.set_mesh_visibility(unit, 9, false, "default") --medium belt LOD
						Unit.set_mesh_visibility(unit, 11, false, "default")--close tank LOD gunner
						Unit.set_mesh_visibility(unit, 12, false, "default")--close tank glow LOD gunner
						Unit.set_mesh_visibility(unit, 16, false, "default")--close belt LOD gunner
					end
				end
			end
		end
	end

	return func(self, world, unit, unit_template_name, extension_init_data)
end)


local alt_events = {
	-- doomrocket_reload = "units/bombadier/bombadier"
	wind_up_start = {
		machine = "units/bombadier/bombadier",
		event = "doomrocket_reload_start",
	},
	wind_up_loop = {
		machine = "units/bombadier/bombadier",
		event = "doomrocket_reload_loop",
	},
}
-- mod:hook(Unit, "animation_event", function(func, unit, event, ...)

--     if not Unit.has_animation_event(unit, event) then
-- 		local unit_name = Unit.get_data(unit, "breed")
-- 		mod:echo(unit_name)
-- 		if unit_name == "units/beings/enemies/skaven_ratlinggunner/chr_skaven_ratlinggunner" then
-- 			if alt_events[event] then
-- 				Unit.set_animation_state_machine(unit, alt_events[event])
-- 			else
-- 				Unit.set_animation_state_machine(unit, "units/beings/enemies/skaven_ratlinggunner/chr_skaven_ratlinggunner")
-- 			end
-- 		end
-- 	end



--     return func(unit, event, ...)
-- end)

local set_animation_state_machine = Unit.set_animation_state_machine
local has_animation_event = Unit.has_animation_event
local unit_get_data = Unit.get_data

mod:hook(Unit, "animation_event", function(func, unit, event, ...)
	-- disabled until animations are done
    -- local breed = unit_get_data(unit, "breed")
	-- if breed then
	-- 	if breed.name == "skaven_doomrocket" then
	-- 		local swap_tisch = alt_events[event]
	-- 		if swap_tisch then
	-- 			set_animation_state_machine(unit, swap_tisch.machine)
	-- 			event = swap_tisch.event
	-- 			if mod.anim_emitters[unit] then
	-- 				mod.anim_emitters[unit]:update_animation(unit, event)
	-- 			end
	-- 		elseif not has_animation_event(unit, event) then
	-- 			set_animation_state_machine(unit, "units/beings/enemies/skaven_ratlinggunner/chr_skaven_ratlinggunner")
	-- 		end
	-- 	end
	-- end

    return func(unit, event, ...)
end)


mod:hook(AIInventoryExtension, "_setup_configuration", function (func, self, unit, start_n, inventory_configuration, item_extension_init_data)
	local result = func(self, unit, start_n, inventory_configuration, item_extension_init_data)

	local outfit_units = self.inventory_item_outfit_units

	for i, outfit_unit in ipairs(outfit_units) do
		if Unit.get_data(outfit_unit, "unit_name") == "units/beings/enemies/skaven_plague_monk/chr_skaven_plague_monk" then
			Unit.disable_animation_state_machine(outfit_unit)
		end
	end

	return result
end)

-- these functions are needed so the client can properly spawn in the custom breed with right breed data set
local unit_go_sync_functions = require("scripts/mods/doomrocket/utils/game_object_initializers_extractors")
mod:hook(UnitSpawner, 'set_gameobject_initializer_data', function(func, self, initializer_function_table, extraction_function_table, gameobject_context)
	initializer_function_table = unit_go_sync_functions.initializers
	extraction_function_table = unit_go_sync_functions.extractors
	return func(self, initializer_function_table, extraction_function_table, gameobject_context)
end)

mod:hook(UnitSpawner, 'set_gameobject_to_unit_creator_function', function(func, self, function_table)
	function_table = unit_go_sync_functions.unit_from_gameobject_creator_func
	return func(self, function_table)
end)


--stops a crash but needs to be revisted as it borks other things
-- mod:hook(Unit, 'animation_set_constraint_target', function(func, self, index, value)

-- 	-- print(index)
-- 	-- print(value)

-- 	local result = func(self, index, value)

-- 	-- return func(self, index, value)
-- 	return
-- end)

mod:hook(_G, 'require', function(func, file_name, ...)
	if file_name == "scripts/network/unit_extension_templates" then
		file_name = "scripts/mods/doomrocket/utils/unit_extension_templates"
	end
	return func(file_name, ...)
end)

-- print(Network.config_hash('global'))



-- local function get_network_options()
-- 	local network_options = {
-- 		config_file_name = "scripts/mods/doomrocket/utils/doomrocket", -- MODIFIED
-- 		ip_address = Network.default_network_address(),
-- 		lobby_port = GameSettingsDevelopment.network_port,
-- 		map = "None",
-- 		max_members = 4,
-- 		project_hash = "bulldozer",
-- 		query_port = script_data.query_port or script_data.settings.query_port,
-- 		server_port = script_data.server_port or script_data.settings.server_port or 27015,
-- 		steam_port = script_data.steam_port or script_data.settings.steam_port,
-- 	}
-- 	return network_options
-- end

-- mod:hook_origin(LobbyManager, "setup_network_options", function(self, increment_lobby_port)
-- 	local network_options = get_network_options()
-- 	local lobby_port = script_data.server_port or script_data.settings.server_port or network_options.lobby_port
-- 	lobby_port = lobby_port + self._lobby_port_increment
-- 	if increment_lobby_port then
-- 		self._lobby_port_increment = self._lobby_port_increment + 1
-- 	end
-- 	network_options.lobby_port = lobby_port
-- 	self._network_options = network_options
-- end)

mod:hook(PickupUnitExtension, 'init', function(func, self, extension_init_context, unit, extension_init_data)

	local interaction_type = Unit.get_data(unit, "interaction_data", "interaction_type")
	local result = func(self, extension_init_context, unit, extension_init_data)
	if interaction_type == "doom_rocket" then
		Unit.set_data(unit, "interaction_data", "interaction_type", "doom_rocket")
	end
	return result
end)


--for running projectile_rocket cleanup code only when rocket is marked for deletion
mod:hook(GrowQueue, 'pop_first', function(func, self)

	local unit = func(self)
	if unit then
		local prj_rckt = mod.projectiles[unit]
		if prj_rckt then
			prj_rckt:destroy()
		end
	end

	return unit
end)

-- Fatshark added a
-- assert(self.is_server, "[HealthTriggerSystem] Clients should not hold health trigger extensions")
-- line for some reason, no idea why. This just origin hooks it so it don't do that
mod:hook(HealthTriggerSystem,'extensions_ready', function (func, self, world, unit, extension_name)

	local extension = self.unit_extensions[unit]

	extension.health_extension = ScriptUnit.extension(unit, "health_system")

	assert(extension.health_extension)

	extension.last_health_percent = extension.health_extension:current_health_percent()
	extension.last_health_tick_percent = extension.health_extension:current_health_percent()
	extension.dialogue_input = ScriptUnit.extension_input(unit, "dialogue_system")
	extension.tick_time = 0
end)