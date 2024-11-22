artifact.sidekick = {
    obj = nil,
}

minetest.register_entity(":artifact:sidekick", {
    initial_properties = {
        visual = "mesh",
        mesh = "artifact_character.gltf",
        visual_size = vector.new(1,1,1) *0.8,
        textures = {"artifact_vix.png"},
        eye_height = 1.5,
        physical = true,
        collisionbox = {-0.3, 0, -0.3, 0.3, 1.75, 0.3},
        shaded = false,
        backface_culling = false,
        collide_with_objects = false,
        hp_max = 20
    },
    _walking = false,
    _dist = 0,
    _character = "vix",
    on_activate = function(e)
        if artifact.sidekick.obj then return e.object:remove() end
        artifact.sidekick.obj = e.object
        if minetest.get_connected_players()[1]:get_meta():get_string("artifact_character") == "vix" then
            artifact.set_to_key(e.object)
            e._character = "key"
        end
        e.object:set_acceleration(vector.new(0,-9.81,0))
        e.object:set_armor_groups{immortal = 1}
    end,
    on_deactivate = function(e, rm)
        artifact.sidekick.obj = nil
        artifact.db:set_string("artifact_sidekick_pos", e.object:get_pos():to_string())
        artifact.sidekick.rot = e.object:get_rotation()
    end,
    on_step = function(e, dtime, collision)
        local p = minetest.get_connected_players()[1]
        if not p then return end
        local obj = e.object
        local dist = p:get_pos():distance(obj:get_pos())
        if dist > math.huge then
            local path = minetest.find_path(obj:get_pos():offset(0,0.5,0):round(),p:get_pos():offset(0,0.5,0):round(),5,1,3)
            if not path then
                minetest.log(minetest.serialize(path))
                return
            end
            local dir = obj:get_pos():direction(path[2]) *(dist > 10 and 4 or 2)
            obj:set_yaw(dir:dir_to_rotation().y)
            dir.y = obj:get_velocity().y
            obj:set_velocity(dir)
            if not e._walking then
                obj:set_animation({x=0, y=1}, 1.5, 0.2, true)
            end
            e._walking = true
            for _, x in ipairs(path) do
                minetest.add_particle{
                    pos = x,
                    velocity = vector.new(math.random() - 0.5,math.random() - 0.5,math.random() - 0.5) / 2,
                    expirationtime = 0.5,
                    node = {name = "artifact:powered_lamp_on"}
                }
            end
        else
            if e._walking then
                obj:set_animation({x=0,y=0})
            end
            e._walking = false
            obj:set_velocity(vector.new(0, obj:get_velocity().y, 0))
        end
        
        
    end
})
