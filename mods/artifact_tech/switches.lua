minetest.register_entity(":artifact:switch_display", {
    initial_properties = {
        visual = "mesh",
        mesh = "artifact_switch_linear.gltf",
        textures = {"artifact_switch_linear_off.png"},
        pointable = false
    },
    _timer = 0,
    _open = false,
    _mode = "linear",
    on_activate = function(e, data)
        data = minetest.deserialize(data) or {}
        e._open = data.open or false
        e._mode = data.mode or "linear"
        e.object:set_rotation(vector.dir_to_rotation(minetest.facedir_to_dir(minetest.get_node(e.object:get_pos()).param2) or vector.new(0,0,-1)))
        local m = minetest.get_meta(e.object:get_pos())
        if data.textures then
            e.object:set_properties{
                textures = data.textures
            }
        end
        if e._mode == "linear" then
            if m:get("open") == "true" then
                e.object:set_bone_override("lever", {
                    rotation = {
                        vec = vector.new(math.rad(-150),0,0), interpolation = 0
                    }
                })
            elseif m:get("powered") == "true" then
                e.object:set_properties{
                    textures = {"artifact_switch_linear_intermediate.png"}
                }
            end
        elseif e._mode == "angle_single" then
            local rot = m:get_int("rot")
            e.object:set_properties{
                mesh = "artifact_switch_angle_single.gltf",
                textures = {"artifact_switch_angle_single_off.png"}
            }
            e.object:set_bone_override("lever", {
                rotation = {
                    vec = vector.new(0,0,math.rad(rot == 0 and 1 or rot)), interpolation = 0
                }
            })
        end
    end,
    get_staticdata = function(e)
        return minetest.serialize{
            open = e._open,
            mode = e._mode,
            textures = e.object:get_properties().textures
        }
    end,
    on_step = function(e)
        local time = minetest.get_us_time()
        if time -e._timer > 1000000 then
            e.object:set_rotation(vector.dir_to_rotation(minetest.facedir_to_dir(minetest.get_node(e.object:get_pos()).param2) or vector.new(0,0,-1)))
            e._timer = time
        end
    end
})

minetest.register_node(":artifact:switch_linear", {
    drawtype = "airlike",
    collision_box = {
        type = "fixed",
        fixed = {3/16, 3/16, 1/2, -3/16, -3/16, -1/2},
    },
    selection_box = {
        type = "fixed",
        fixed = {3/16, 3/16, 1/2, -3/16, -3/16, -1/2},
    },
    tiles = {"blank.png"},
    sounds = {
        footstep = {name = "artifact_step_generic", gain = 0.2}
    },
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    pointable = true,
    groups = {artifact_conductor = 1},
    on_construct = function(pos)
        local obj = minetest.add_entity(pos, "artifact:switch_display", minetest.serialize{mode = "linear"})
        obj:set_texture_mod("^[hsl:0:0:-10")
        local powered, pos2 = artifact.is_powered(pos)
        if powered then minetest.registered_nodes["artifact:switch_linear"].artifact_on_power_event(pos, {type = "activate", prev = pos2}) end
        minetest.get_meta(pos):set_string("initialized", "true")
    end,
    on_destruct = function(pos)
        for obj in minetest.objects_inside_radius(pos, 0) do obj:remove() end
    end,
    artifact_can_add_energy = function(pos, param2, dir)
        return true
    end,
    artifact_on_add_energy = function(pos)
        
    end,
    on_rightclick = function(pos)
        local param2 = minetest.get_node(pos).param2
        local m = minetest.get_meta(pos)
        for obj in minetest.objects_inside_radius(pos, 0) do
            if m:get("open") == "true" then
                m:set_string("open", "false")
                obj:set_bone_override("lever", {
                    rotation = {
                        vec = vector.new(math.rad(1),0,0), interpolation = 0.2
                    }
                })
                if m:get("powered") == "true" then
                    obj:set_properties{
                        textures = {"artifact_switch_linear_intermediate.png"}
                    }
                    artifact.propagate_power_event(pos -minetest.facedir_to_dir(param2), {type = "deactivate", prev = pos})
                else
                    obj:set_properties{
                        textures = {"artifact_switch_linear_off.png"}
                    }
                end
            else
                m:set_string("open", "true")
                obj:set_bone_override("lever", {
                    rotation = {
                        vec = vector.new(math.rad(-150),0,0), interpolation = 0.2
                    }
                })
                if m:get("powered") == "true" then
                    obj:set_properties{
                        textures = {"artifact_switch_linear_on.png"}
                    }
                    artifact.propagate_power_event(pos -minetest.facedir_to_dir(param2), {type = "activate", prev = pos})
                else
                    obj:set_properties{
                        textures = {"artifact_switch_linear_off.png"}
                    }
                end
            end
        end
    end,
    artifact_on_power_event = function(pos, ev)
        local param2 = minetest.get_node(pos).param2
        local dir = pos:direction(ev.prev)
        local outdir = minetest.facedir_to_dir(param2)
        local m = minetest.get_meta(pos)
        if not (
            (dir.z == 1 and param2 == 0 or dir.z == -1 and param2 == 2)
            or (dir.x == 1 and param2 == 1 or dir.x == -1 and param2 == 3)
            or (dir.y == 1 and (param2 == 8 or param2 == 15) or dir.y == -1 and param2 == 19)
        ) then
            if ev.type == "deactivate" and m:get("powered") == "true" then
                if dir.z == -1 and param2 == 0 or dir.z == 1 and param2 == 2 then
                    artifact.propagate_power_event(ev.prev, {type = "activate", prev = pos})
                end
            end
            return
        end
        if ev.type == "activate" then
            m:set_string("powered", "true")
            for obj in minetest.objects_inside_radius(pos, 0) do
                if m:get("open") == "true" then
                    obj:set_properties{
                        textures = {"artifact_switch_linear_on.png"}
                    }
                    artifact.propagate_power_event(pos -minetest.facedir_to_dir(param2), {type = "activate", prev = pos}, 1)
                else
                    obj:set_properties{
                        textures = {"artifact_switch_linear_intermediate.png"}
                    }
                    artifact.propagate_power_event(pos -minetest.facedir_to_dir(param2), {type = "deactivate", prev = pos}, 1)
                end
            end
        elseif ev.type == "deactivate" then
            m:set_string("powered", "false")
            for obj in minetest.objects_inside_radius(pos, 0) do
                obj:set_properties{
                    textures = {"artifact_switch_linear_off.png"}
                }
            end
            artifact.propagate_power_event(pos -minetest.facedir_to_dir(param2), {type = "deactivate"}, 1)
        end
    end
})



minetest.register_node(":artifact:switch_angle_single", {
    drawtype = "airlike",
    collision_box = {
        type = "fixed",
        fixed = {3/16, 3/16, 1/2, -3/16, -3/16, -3/16},
    },
    selection_box = {
        type = "fixed",
        fixed = {3/16, 3/16, 1/2, -3/16, -3/16, -3/16},
    },
    tiles = {"blank.png"},
    sounds = {
        footstep = {name = "artifact_step_generic", gain = 0.2}
    },
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    pointable = true,
    groups = {artifact_conductor = 1},
    on_construct = function(pos)
        local obj = minetest.add_entity(pos, "artifact:switch_display", minetest.serialize{mode = "angle_single"})
        obj:set_texture_mod("^[hsl:0:0:-10")
        local powered, pos2 = artifact.is_powered(pos)
        if powered then minetest.registered_nodes["artifact:switch_angle_single"].artifact_on_power_event(pos, {type = "activate", prev = pos2}) end
        minetest.get_meta(pos):set_string("initialized", "true")
    end,
    on_destruct = function(pos)
        for obj in minetest.objects_inside_radius(pos, 0) do obj:remove() end
    end,
    artifact_can_add_energy = function(pos, param2, dir)
        return true
    end,
    artifact_on_add_energy = function(pos)
        
    end,
    on_rightclick = function(pos)
        local param2 = minetest.get_node(pos).param2
        local m = minetest.get_meta(pos)
        local rot = m:get_int("rot")
        rot = (rot +90) %360
        m:set_int("rot", rot)
        for obj in minetest.objects_inside_radius(pos, 0) do
            obj:set_bone_override("lever", {
                rotation = {
                    vec = vector.new(0,0,math.rad(rot == 0 and 1 or rot)), interpolation = 0.2
                }
            })
            if m:get("powered") == "true" then
                obj:set_properties{
                    textures = {"artifact_switch_angle_single_on.png"}
                }
                artifact.propagate_power_event(pos -minetest.facedir_to_dir(param2):rotate(vector.new(rot -90 +180,90,0):apply(math.rad)), {type = "deactivate", prev = pos})
                artifact.propagate_power_event(pos -minetest.facedir_to_dir(param2):rotate(vector.new(rot     +180,90,0):apply(math.rad)), {type = "activate", prev = pos})
            end
        end
    end,
    artifact_on_power_event = function(pos, ev)
        local param2 = minetest.get_node(pos).param2
        local dir = pos:direction(ev.prev)
        local m = minetest.get_meta(pos)
        if not (
            (dir.z == 1 and param2 == 0 or dir.z == -1 and param2 == 2)
            or (dir.x == 1 and param2 == 1 or dir.x == -1 and param2 == 3)
            or (dir.y == 1 and (param2 == 8 or param2 == 15) or dir.y == -1 and param2 == 19)
        ) then
            if ev.type == "deactivate" and m:get("powered") == "true" then
                if minetest.facedir_to_dir(param2):rotate(vector.new(rot,-90,0):apply(math.rad)) == dir then
                    artifact.propagate_power_event(ev.prev, {type = "activate", prev = pos})
                end
            end
            return
        end
        local rot = m:get_int("rot")
        if ev.type == "activate" then
            m:set_string("powered", "true")
            for obj in minetest.objects_inside_radius(pos, 0) do
                obj:set_properties{
                    textures = {"artifact_switch_angle_single_on.png"}
                }
            end
            artifact.propagate_power_event(pos -minetest.facedir_to_dir(param2):rotate(vector.new(rot +180,90,0):apply(math.rad)), {type = "activate", prev = pos}, 1)
        elseif ev.type == "deactivate" then
            m:set_string("powered", "false")
            for obj in minetest.objects_inside_radius(pos, 0) do
                obj:set_properties{
                    textures = {"artifact_switch_angle_single_off.png"}
                }
            end
            artifact.propagate_power_event(pos -minetest.facedir_to_dir(param2):rotate(vector.new(rot +180,90,0):apply(math.rad)), {type = "deactivate", prev = pos}, 1)
        end
    end
})