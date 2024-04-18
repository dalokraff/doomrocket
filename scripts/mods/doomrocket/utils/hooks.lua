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

    -- mod:echo(enemy_package_loader.breed_loaded_on_all_peers[breed_name])

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

		self:_post_spawn_unit(unit, go_id, breed, d[2]:unbox(), d[4], d[5], d[7], d[6])
	else
		unit = self:_spawn_unit(d[1], d[2]:unbox(), d[3]:unbox(), d[4], d[5], d[6], d[7], d[8], d[10])
        -- if Unit.has_data(unit, "breed") then
        --     for k,v in pairs(Unit.get_data(unit, "breed")) do
        --         mod:echo(tostring(k)..":     "..tostring(v))
        --     end
        -- end
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

mod:hook(BTSpawningAction, "leave", function(func, self, unit, blackboard, ...)
    local name = blackboard.breed.name

    if name == "skaven_doomrocket" then
		if mod.anim_emitters[unit] then
			mod.anim_emitters[unit]:set_blackboard(blackboard)
		end
    end

    return func(self, unit, blackboard, ...)
end)

mod:hook(UnitSpawner, "spawn_local_unit", function(func, self, unit_name, position, rotation, material)

	local unit = func(self, unit_name, position, rotation, material)

	if unit_name == "units/beings/enemies/skaven_ratlinggunner/chr_skaven_ratlinggunner" then
		for animaiton_event, details in pairs(new_animations) do
			Unit.set_data(unit, animaiton_event, "timing", details.timing)
			Unit.set_data(unit, animaiton_event, "emitted_event", details.emitted_event)
		end

		mod.anim_emitters[unit] = AnimEmitter:new(unit)

        Unit.set_mesh_visibility(unit, 0, false, "default")--far tank LOD
        Unit.set_mesh_visibility(unit, 4, false, "default") --far belt LOD
        Unit.set_mesh_visibility(unit, 5, false, "default") -- medium tank LOD

        Unit.set_mesh_visibility(unit, 9, false, "default") --medium belt LOD
        Unit.set_mesh_visibility(unit, 11, false, "default")--close tank LOD gunner
        Unit.set_mesh_visibility(unit, 12, false, "default")--close tank glow LOD gunner
        Unit.set_mesh_visibility(unit, 16, false, "default")--close belt LOD gunner
	end

	return unit
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

    local breed = unit_get_data(unit, "breed")
	if breed then
		if breed.name == "skaven_doomrocket" then
			local swap_tisch = alt_events[event]
			if swap_tisch then
				set_animation_state_machine(unit, swap_tisch.machine)
				event = swap_tisch.event
				mod.anim_emitters[unit]:update_animation(unit, event)
			elseif not has_animation_event(unit, event) then
				set_animation_state_machine(unit, "units/beings/enemies/skaven_ratlinggunner/chr_skaven_ratlinggunner")
			end
		end
	end

	-- if not Unit.has_animation_event(unit, event) then
	-- 	return
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