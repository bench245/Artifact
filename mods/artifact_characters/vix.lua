
function artifact.add_energy(pos, face)
    local n = minetest.get_node(pos)
    local node = n.name
    local def = minetest.registered_nodes[node]
    if face and def.artifact_can_add_energy then
        if not def.artifact_can_add_energy(pos, n.param2, face) then return end
    end
    if def.artifact_on_add_energy then def.artifact_on_add_energy(pos) end
end

minetest.register_entity(":artifact:energy_burst", {
    initial_properties = {
        visual = "mesh",
        mesh = "artifact_energy_burst.obj",
        textures = {"artifact_energy_burst.png"},
        static_save = false,
        pointable = false,
        visual_size = vector.new(10,10,10),
        glow = 12,
        physical = true,
        collide_with_objects = true,
        collisionbox = {-0.1, -0.1, -0.3, 0.1, 0.1, 0.1}
    },
    _trail = nil,
    on_activate = function(e)
        e._trail = minetest.add_particlespawner{
            time = 0,
            pos = {
                min = vector.new(-0.2,-0.2,0.4),
                max = vector.new(0.2,0.2,0.8)
            },
            attached = e.object,
            vel = 0,
            amount = 50,
            texture = {
                name = "artifact_energy_burst_trail.png",
                alpha_tween = {
                    1, 0.8, 0.6, 0
                }
            },
            glow = 8
        }
    end,
    on_deactivate = function(e)
        minetest.delete_particlespawner(e._trail)
    end,
    on_step = function(e, dtime, c)
        if c.collides and c.collisions[1] then
            local collision = c.collisions[1]
            if collision.type == "node" then
                artifact.add_energy(collision.node_pos, e.object:get_pos())
                e.object:remove()
            elseif collision.type == "object" then
                local obj = collision.object
                e.object:remove()
                local entity = obj:get_luaentity()
                if obj:is_player() then
                    if artifact.story.state >= artifact.story.state_blackrod then
                        local m = obj:get_meta()
                        if m:get_string("artifact_character") ~= "vix" then
                            artifact.charge_blackrod()
                        end
                    end
                    return
                elseif not entity._artifact_enemy then
                    if artifact.story.state >= artifact.story.state_blackrod then
                        if entity.name == "artifact:sidekick" then
                            if minetest.get_connected_players()[1]:get_meta():get_string("artifact_character") == "vix" then
                                artifact.charge_blackrod()
                            end
                        end
                    end
                    return
                end
                if entity._artifact_on_add_energy then entity:_artifact_on_add_energy() end
            end
        end
    end
})

local last_burst = 0
minetest.override_item("", {
    on_use = function(s, p, pt)
        if pt.under then
            local node = minetest.get_node(pt.under)
            local def = minetest.registered_nodes[node.name]
            if def._has_on_punch then
                def.on_punch(pt.under, node, p, pt)
                return
            end
        end
        if p:get_meta():get_string("artifact_character") == "vix" then
            local time = minetest.get_us_time()
            if time -last_burst > 1 *1000000 then
                last_burst = time
                artifact.play_sound{name = "artifact_energy_burst_shot"}
                local dir = p:get_look_dir()
                local rot = dir:dir_to_rotation()
                local shot = minetest.add_entity(p:get_pos() +vector.new(0.2,1.3,0.5):rotate(vector.new(0,p:get_look_horizontal(),0)), "artifact:energy_burst")
                shot:set_rotation(rot)
                shot:set_velocity(dir *10)
            end
        end
    end
})