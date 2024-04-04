local mod = get_mod("doomrocket")

local math_abs = math.abs
local math_log = math.log
local math_ex = math.exp
local math_pow = math.pow

local function radians_to_quaternion(theta, ro, phi)
    local c1 =  math.cos(theta/2)
    local c2 = math.cos(ro/2)
    local c3 = math.cos(phi/2)
    local s1 = math.sin(theta/2)
    local s2 = math.sin(ro/2)
    local s3 = math.sin(phi/2)
    local x = (s1*s2*c3) + (c1*c2*s3)
    local y = (s1*c2*c3) + (c1*s2*s3)
    local z = (c1*s2*c3) - (s1*c2*s3)
    local w = (c1*c2*c3) - (s1*s2*s3)
    local rot = Quaternion.from_elements(x, y, z, w)
    return rot
end

local function sign(x)
    return x>0 and 1 or x<0 and -1 or 0
end

local magnitude = Vector3.length
local dot_product = Vector3.dot
local normalize = Vector3.normal
local vec_dsit = Vector3.distance

local velocity = Actor.velocity
local pos_actor = Actor.position
local rot_actor = Actor.rotation
local rotate_actor = Actor.teleport_rotation
local actor_add_vel = Actor.add_velocity

local move_particles = World.move_particles
local vector4_multi = Quaternion.multiply
local quat_look = Quaternion.look

local trigger_audio = WwiseWorld.trigger_event
local stop_audio = WwiseWorld.stop_event

local rotate_unit = Unit.set_local_rotation
local unit_delta_rotation = Unit.delta_rotation

local linear_sphere_sweep = stingray.PhysicsWorld.linear_sphere_sweep

ProjectileRocket = class(ProjectileRocket)

ProjectileRocket.init = function (self, unit, attacker_unit, target_pos)
    Managers.package:load("resource_packages/breeds/skaven_warpfire_thrower", "global")
    self.unit = unit
    local actor = Unit.actor(unit, 0)
    self.actor = actor
    self.target_z = target_pos.z
    self.target_y = target_pos.y
    self.target_x = target_pos.x
    self.attacker_unit = attacker_unit
    self.launch_z = Unit.local_position(self.attacker_unit, 0).z
    self.launch_y = Unit.local_position(self.attacker_unit, 0).y
    self.launch_x = Unit.local_position(self.attacker_unit, 0).x

    self.reached_apogee = false

    self.world = Unit.world(unit)
    local position = Actor.position(actor)
    local rotation = Actor.rotation(actor)
    self.exhaust_id = World.create_particles(self.world, "fx/chr_warp_fire_flamethrower_01", position, rotation, Vector3(0,0,1))

    self.physics_world = World.physics_world(self.world)

    self.wwise_world = Wwise.wwise_world(self.world)
    self.exhaust_sound_id = WwiseWorld.trigger_event(self.wwise_world, "Play_enemy_warpfire_thrower_shoot",  unit)

    self.time_pass = 0

end

ProjectileRocket.update = function (self, dt)
    if not Unit.alive(self.unit) then
        self:destroy()
    end

    local vel = velocity(self.actor)
    local speed = magnitude(vel)

    local new_direction = vel.x*vel.y*vel.z
    new_direction = new_direction/math.abs(new_direction)

    if not self.current_direction then
        self.current_direction = new_direction
    end

    self:guide_force(dt)
    self:straighten_rocket(vel)
    self:move_particles(self.actor)

    if speed < 3 then
        self:destroy()
    end

    self.time_pass = self.time_pass + dt
    self.current_direction = new_direction
    self.previous_speed = speed
end

ProjectileRocket.straighten_rocket = function(self, direction)
    local new_rotation = quat_look(direction)
    rotate_unit(self.unit, 0 , new_rotation)
    rotate_actor(self.actor, new_rotation)
end

ProjectileRocket.guide_force = function(self, dt)
    local pos = pos_actor(self.actor)
    local launch_pos = Vector3(self.launch_x, self.launch_y, self.launch_z)
    local dist_to_target = vec_dsit(Vector3(self.target_x, self.target_y, self.target_z), launch_pos)

    local dirac_delta = math_ex(-500*math_pow(self.time_pass,2)) * 0.1*dist_to_target*math.random()
    actor_add_vel(self.actor, Vector3(0,0,dirac_delta))
end


-- local math_log = math.log
-- local math_ex = math.exp
-- local math_pow = math.pow
-- local vec_dsit = Vector3.distance
-- local pos_actor = Actor.position
-- local actor_add_vel = Actor.add_velocity
-- mod:hook(ProjectileRocket, 'guide_force', function(func, self, dt)
--     local pos = pos_actor(self.actor)
--     local launch_pos = Vector3(self.launch_x, self.launch_y, self.launch_z)
--     local dist_to_target = vec_dsit(Vector3(self.target_x, self.target_y, self.target_z), launch_pos)

--     local dirac_delta = math_ex(-500*math_pow(self.time_pass,2)) * 0.1*dist_to_target*math.random()
--     actor_add_vel(self.actor, Vector3(0,0,dirac_delta))
--     if vec_dsit(Vector3(self.target_x, self.target_y, self.target_z), pos) < 2 then
--         if math.random() < 0.5 then
--             self.destroy()
--         end
--     end
-- end)

ProjectileRocket.move_particles = function(self, actor)
    local pos = pos_actor(actor)
    local rot = vector4_multi(rot_actor(actor), radians_to_quaternion(0,0, math.pi))
    move_particles(self.world, self.exhaust_id, pos, rot)
end

ProjectileRocket.update_sounds = function(self)
    if self.time_pass > 2 then
        local pos = pos_actor(self.actor)
        local rot = vector4_multi(rot_actor(self.actor), radians_to_quaternion(0,0, math.pi))
        WwiseWorld.stop_event(self.wwise_world, self.exhaust_sound_id)
        self.exhaust_sound_id = WwiseWorld.trigger_event(self.wwise_world, "Play_enemy_warpfire_thrower_shoot",  pos, rot)
    end

end

ProjectileRocket.rocket_explode = function(self)
    local actor = self.actor
    local position = Actor.position(actor)
    local rotation = Actor.rotation(actor)
    local attacker_unit_id = Managers.state.unit_storage:go_id(self.attacker_unit)
    local explosion_template_name = "doomrocket_explosion"
    local explosion_template_id = NetworkLookup.explosion_templates[explosion_template_name]
    local explosion_template = ExplosionTemplates[explosion_template_name]
    local damage_source = "buff"
    local damage_source_id = NetworkLookup.damage_sources[damage_source]
    local is_husk = true
    local power_level = 1000
    local world = self.world

    if Managers.player.is_server then
		Managers.state.network.network_transmit:send_rpc_clients("rpc_create_explosion", attacker_unit_id, false,
            position, rotation, explosion_template_id, 1, damage_source_id, power_level, false, attacker_unit_id)
        Managers.state.network.network_transmit:send_rpc_server("rpc_create_explosion", attacker_unit_id, false,
            position, rotation, explosion_template_id, 1, damage_source_id, power_level, false, attacker_unit_id)

        Managers.state.unit_spawner:mark_for_deletion(self.unit)
	else
		Managers.state.unit_spawner:mark_for_deletion(self.unit)
	end

    if self.exhaust_id then
        World.destroy_particles(world, self.exhaust_id)
    end
    WwiseWorld.stop_event(self.wwise_world, self.exhaust_sound_id)

    return
end

ProjectileRocket.destroy = function(self)
    if Unit.alive(self.unit) then
        self:rocket_explode()
    end

    mod.projectiles[self.unit] = nil
    self.unit = nil
    self.actor = nil
    self.exhaust_id = nil


    return
end
