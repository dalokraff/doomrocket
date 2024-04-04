local mod = get_mod("doomrocket")

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

local magnitude = Vector3.length
local dot_product = Vector3.dot
local normalize = Vector3.normal

local velocity = Actor.velocity
local pos_actor = Actor.position
local rot_actor = Actor.rotation
local rotate_actor = Actor.teleport_rotation

local move_particles = World.move_particles
local vector4_multi = Quaternion.multiply
local quat_look = Quaternion.look

local trigger_audio = WwiseWorld.trigger_event
local stop_audio = WwiseWorld.stop_event

local rotate_unit = Unit.set_local_rotation
local unit_delta_rotation = Unit.delta_rotation

local linear_sphere_sweep = stingray.PhysicsWorld.linear_sphere_sweep

ProjectileRocket = class(ProjectileRocket)

ProjectileRocket.init = function (self, unit, attacker_unit, position, rotation)
    Managers.package:load("resource_packages/breeds/skaven_warpfire_thrower", "global")
    self.unit = unit
    local actor = Unit.actor(unit, 0)
    self.actor = actor

    self.attacker_unit = attacker_unit
    -- local vel = velocity(actor)
    -- local current_direction = vel.x*vel.y*math.abs(vel.z)

    -- mod:echo(vel.x)
    -- mod:echo(vel.y)
    -- mod:echo(vel.z)
    -- mod:echo(current_direction)
    -- mod:echo("+++++++")

    -- self.current_direction = current_direction/math.abs(current_direction)

    self.reached_apogee = false

    self.world = Unit.world(unit)
    local position = Actor.position(actor)
    local rotation = Actor.rotation(actor)
    self.exhaust_id = World.create_particles(self.world, "fx/chr_warp_fire_flamethrower_01", position, rotation, Vector3(0,0,1))

    self.physics_world = World.physics_world(self.world)

    self.wwise_world = Wwise.wwise_world(self.world)
    self.exhaust_sound_id = WwiseWorld.trigger_event(self.wwise_world, "Play_enemy_warpfire_thrower_shoot",  unit)

    -- World.link_particles(self.world, exhaust_id, unit, 0, Matrix4x4.identity(), "destroy")

    self.time_pass = 0

end

ProjectileRocket.update = function (self, dt)
    -- if not Unit.alive(self.unit) then
    --     self:destroy()
    -- end

    local vel = velocity(self.actor)
    local speed = magnitude(vel)

    local new_direction = vel.x*vel.y*vel.z
    new_direction = new_direction/math.abs(new_direction)

    if not self.current_direction then
        self.current_direction = new_direction
    end

    -- if self.exhaust_id then
    --     self:move_particles(self.actor)
    -- end

    self:move_particles(self.actor)

    -- mod:echo(new_direction)
    -- mod:echo(self.current_direction)
    -- if new_direction ~= self.current_direction then
    --     -- self:destroy()
    --     if self.reached_apogee then
    --         if new_direction ~= self.current_direction then
    --             self:destroy()
    --         end
    --     end

    --     self.reached_apogee = true

    --     -- if self.exhaust_id then
    --     --     World.destroy_particles(world, self.exhaust_id)
    --     --     self.exhaust_id = nil
    --     -- end


    -- end
    mod:echo(speed)
    if speed < 4 then
        self:destroy()
    end

    -- local collisions = linear_sphere_sweep(self.physics_world, pos_actor(self.actor), pos_actor(self.actor) + Vector3(0,0,0.1),
    --                         0.3, 10, "collision_filter", "filter_melee_sweep", "report_initial_overlap")
    -- if collisions then
    --     for k,v in pairs(collisions) do
    --         if type(v) == "table" then
    --             if v.distance > 1 then
    --                 self:destroy()
    --             end
    --         end
    --     end
    -- end


    if speed < 1 then

        self:destroy()

    end

    -- self:update_sounds(self.time_pass, self.actor)

    -- self.time_pass = self.time_pass + dt
    self.current_direction = new_direction
    self.previous_speed = speed
    self.previous_velocity = vel
end

ProjectileRocket.straighten_rocket = function(self, unit, actor, direction)
    local new_rotation = quat_look(direction)
    rotate_unit(unit, 0 , new_rotation)
    rotate_actor(actor, new_rotation)
end

ProjectileRocket.move_particles = function(self, actor)
    local pos = pos_actor(actor)
    local rot = vector4_multi(rot_actor(actor), radians_to_quaternion(0,0, math.pi))
    move_particles(self.world, self.exhaust_id, pos, rot)
end

ProjectileRocket.update_sounds = function(self, time, actor)
    if time > 0.1 then
        local pos = pos_actor(actor)
        local rot = vector4_multi(rot_actor(actor), radians_to_quaternion(0,0, math.pi))
        stop_audio(self.wwise_world, self.exhaust_sound_id)
        self.exhaust_sound_id = trigger_audio(self.wwise_world, "Play_enemy_warpfire_thrower_shoot",  pos, rot)
    end

end

-- ProjectileRocket.check_for_player = function(self, actor)


-- end

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

    self:rocket_explode()

    mod.projectiles[self.unit] = nil
    self.unit = nil
    self.actor = nil
    self.exhaust_id = nil


    return
end
