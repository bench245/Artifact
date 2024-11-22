
minetest.register_entity(":artifact:3door_slice_collider", {
    initial_properties = {
        visual = "sprite",
        textures = {"blank.png"},
        collisionbox = { -0.5, -0.5, -1/8, 0.5, 2.5, 1/8 },
        physical = true,
        pointable = false,
        static_save = false
    },
    on_activate = function(e)
        minetest.after(0, function() if not e.object:get_attach() then e.object:remove() end end)
    end,
    on_step = function(e)
        if not e.object:get_attach() then e.object:remove() end
    end
})

minetest.register_entity(":artifact:3door_slice", {
    initial_properties = {
        visual = "mesh",
        mesh = "artifact_3door_1.obj",
        textures = {"artifact_stone.png"},
        visual_size = vector.new(10,10,10),
        collisionbox = { -0.5, -0.5, -1/8, 0.5, 2.5, 1/8 },
        pointable = false,
    },
    _state = "closed",
    _animating = false,
    on_activate = function(e, data, dtime)
        local d = minetest.deserialize(data)
        e._pos = d.pos
        e._anchor = d.anchor or e._pos
        e._timer = d.timer
        e._rot = d.rot
        if minetest.get_meta(e._anchor):get_string("open") == "true" then
            e.object:set_pos(vector.offset(e._pos, 0,3,0))
        else
            e.object:set_pos(e._pos)
        end
        if not minetest.get_node(e._anchor).name:find "artifact:3door" then return e.object:remove() end
        if d.timer == 0 then
            e.object:set_properties{
                textures = {"artifact_3door_1.png"},
                glow = minetest.get_artificial_light(minetest.get_node(e._pos).param1)
            }
        elseif d.timer == 0.5 then
            e.object:set_properties{
                textures = {"artifact_3door_2.png"},
                glow = minetest.get_artificial_light(minetest.get_node(e._pos).param1)
            }
        elseif d.timer == 1 then
            e.object:set_properties{
                textures = {"artifact_3door_3.png"},
                glow = minetest.get_artificial_light(minetest.get_node(e._pos).param1)
            }
        end
        local cb = minetest.add_entity(d.pos, "artifact:3door_slice_collider")
        cb:set_attach(e.object)
        if e._rot then
            e.object:set_rotation(vector.new(0,math.rad(90),0))
            cb:set_properties{
                collisionbox = { -1/8, -0.5, -0.5, 1/8, 2.5, 0.5 },
            }
        end
        e.object:set_velocity(vector.zero())
    end,
    on_deactivate = function(e, rm)
        if rm then
            for _, x in pairs(e.object:get_children()) do
                x:remove()
            end
        end
    end,
    get_staticdata = function(e)
        return minetest.serialize{pos = e._pos, timer = e._timer, rot = e._rot, anchor = e._anchor}
    end,
    _open = function(e, force)
        if not force and e._state == "open" then return end
        e._state = "open"
        if e._animating then return end
        e._animating = true
        if e._timer == 0 then
            artifact.play_sound{name = "artifact_3door_open", gain = 1, pos = e._pos, range = 32}
        end
        local c = e.object:get_children()
        if #c < 1 then
            local cb = minetest.add_entity(d.pos, "artifact:3door_slice_collider")
            cb:set_attach(e.object)
            if e._rot then
                e.object:set_rotation(vector.new(0,math.rad(90),0))
                cb:set_properties{
                    collisionbox = { -1/8, -0.5, -0.5, 1/8, 2.5, 0.5 },
                }
            end
        end
        minetest.after(e._timer, function()
            e.object:set_velocity(vector.new(0,3,0))
            minetest.after(1, function()
                e.object:set_velocity(vector.zero())
                e.object:set_pos(vector.offset(e._pos, 0, 3, 0))
                e._animating = false
                artifact.play_sound{name = "artifact_3door_hit", gain = 0.2, pos = vector.offset(e._pos, 0, 3, 0), range = 32}
                if e._state ~= "open" then e:_close(true) end
            end)
        end)
    end,
    _close = function(e, force)
        if not force and e._state == "closed" then return end
        e._state = "closed"
        if e._animating then return end
        e._animating = true
        if e._timer == 0 then
            artifact.play_sound{name = "artifact_3door_open", gain = 1, pos = vector.offset(e._pos, 0, 3, 0), range = 32}
        end
        minetest.after(e._timer, function()
            e.object:set_velocity(vector.new(0,-3,0))
            minetest.after(1, function()
                e.object:set_velocity(vector.zero())
                e.object:set_pos(e._pos)
                e._animating = false
                artifact.play_sound{name = "artifact_3door_hit", gain = 0.2, pos = e._pos, range = 32}
                if e._state ~= "closed" then e:_open(true) end
            end)
        end)
    end
})

minetest.register_node(":artifact:3door", {
    drawtype = "airlike",
    walkable = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {artifact_conductor = 1, artifact_sink = 1, dig_immediate = 1},
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(0.5)
        minetest.add_entity(pos:offset(-1,0,0), "artifact:3door_slice", minetest.serialize{pos = pos:offset(-1,0,0), timer = 0, anchor = pos})
        minetest.add_entity(pos, "artifact:3door_slice", minetest.serialize{pos = pos, timer = 0.5, anchor = pos})
        minetest.add_entity(pos:offset( 1,0,0), "artifact:3door_slice", minetest.serialize{pos = pos:offset( 1,0,0), timer = 1, anchor = pos})
        local m = minetest.get_meta(pos)
        m:set_string("initialized", "true")
        if artifact.is_powered(pos) then
            m:set_string("on", "true")
        end
    end,
    on_destruct = function(pos)
        for x in minetest.objects_in_area(pos:offset(-1,-1,0), pos:offset(1,5,0)) do
            local e = x:get_luaentity()
            if e and e.name == "artifact:3door_slice" then
                for _, y in pairs(x:get_children()) do
                    y:remove()
                end
                x:remove()
            end
        end
    end,
    on_timer = function(pos)
        local m = minetest.get_meta(pos)
        local open = false
        if m:get_string("always_on") ~= "true" and m:get_string("on") ~= "true" then return true end
        for x in minetest.objects_inside_radius(pos, 4) do
            if x:is_player() or x:get_luaentity().name == "artifact:sidekick" then open = true end
        end
        if open then
            if m:get("open") ~= "true" then
                m:set_string("open", "true")
                for x in minetest.objects_in_area(pos:offset(-1,-1,0), pos:offset(1,5,0)) do
                    local e = x:get_luaentity()
                    if e and e.name == "artifact:3door_slice" then
                        e:_open()
                    elseif e and e.name == "artifact:3door_slice_collider" then
                        if not e.object:get_attach() then e.object:remove() end
                    end
                end
            end
        else
            if m:get("open") ~= "false" then
                m:set_string("open", "false")
                for x in minetest.objects_in_area(pos:offset(-1,-1,0), pos:offset(1,5,0)) do
                    local e = x:get_luaentity()
                    if e and e.name == "artifact:3door_slice" then
                        e:_close()
                    end
                end
            end
        end
        return true
    end,
    artifact_on_power_event = function(pos, ev)
        local m = minetest.get_meta(pos)
        if ev.type == "deactivate" then
            m:set_string("on", "false")
        elseif ev.type == "activate" then
            m:set_string("on", "true")
        end
    end
})

minetest.register_node(":artifact:3door_b", {
    drawtype = "airlike",
    walkable = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {artifact_conductor = 1, artifact_sink = 1, dig_immediate = 1},
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(0.5)
        minetest.add_entity(pos:offset(0,0,-1), "artifact:3door_slice", minetest.serialize{pos = pos:offset(0,0,-1), timer = 0, anchor = pos, rot = true})
        minetest.add_entity(pos, "artifact:3door_slice", minetest.serialize{pos = pos, timer = 0.5, rot = true})
        minetest.add_entity(pos:offset(0,0, 1), "artifact:3door_slice", minetest.serialize{pos = pos:offset(0,0, 1), timer = 1, anchor = pos, rot = true})
        local m = minetest.get_meta(pos)
        m:set_string("initialized", "true")
        if artifact.is_powered(pos) then
            m:set_string("on", "true")
        end
    end,
    on_destruct = function(pos)
        for x in minetest.objects_in_area(pos:offset(0,-1,-1), pos:offset(0,5,1)) do
            local e = x:get_luaentity()
            if e and e.name == "artifact:3door_slice" then
                for _, y in pairs(x:get_children()) do
                    y:remove()
                end
                x:remove()
            end
        end
    end,
    on_timer = function(pos)
        local m = minetest.get_meta(pos)
        local open = false
        if m:get_string("always_on") ~= "true" and m:get_string("on") ~= "true" then return true end
        for x in minetest.objects_inside_radius(pos, 4) do
            if x:is_player() or x:get_luaentity().name == "artifact:sidekick" then open = true end
        end
        if open then
            if m:get("open") ~= "true" then
                m:set_string("open", "true")
                for x in minetest.objects_in_area(pos:offset(0,-1,-1), pos:offset(0,5,1)) do
                    local e = x:get_luaentity()
                    if e and e.name == "artifact:3door_slice" then
                        e:_open()
                    end
                end
            end
        else
            if m:get("open") ~= "false" then
                m:set_string("open", "false")
                for x in minetest.objects_in_area(pos:offset(0,-1,-1), pos:offset(0,5,1)) do
                    local e = x:get_luaentity()
                    if e and e.name == "artifact:3door_slice" then
                        e:_close()
                    end
                end
            end
        end
        return true
    end,
    artifact_on_power_event = function(pos, ev)
        local m = minetest.get_meta(pos)
        if ev.type == "deactivate" then
            m:set_string("on", "false")
        elseif ev.type == "activate" then
            m:set_string("on", "true")
        end
    end
})