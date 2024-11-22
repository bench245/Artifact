artifact.scenes = {}
local scenes = artifact.scenes
local pl = artifact.players

function artifact.enter_modal(p)
    local m = pl[p:get_player_name()]
    m.in_cutscene = true
    m.props = p:get_properties()
    m.pos = p:get_pos()
    m.flags = p:hud_get_flags()
    m.lh = p:get_look_horizontal()
    m.lv = p:get_look_vertical()
    p:hud_set_flags{
        hotbar = false,
        healthbar = false,
        crosshair = false,
        wielditem = false,
        breathbar = false,
        minimap = false,
        basic_debug = false
    }
    p:set_properties{
        visual = "sprite",
        textures = {"blank.png"},
        pointable = false
    }
end

function artifact.exit_modal(p)
    local m = pl[p:get_player_name()]
    p:hud_set_flags(m.flags)
    p:set_pos(m.pos)
    p:set_properties(m.props)
    p:set_look_horizontal(m.lh)
    p:set_look_vertical(m.lv)
    m.in_cutscene = false
end

function artifact.fade_in(p, time)
    time = time or 2000
end

function artifact.fade_out(p, time)
    time = time or 2000
end

function artifact.play_cutscene(players, scn)
    if type(players) ~= "table" then players = {players} end
    if type(scn) == "table" then
        scenes[scn.name] = scn
    else
        scenes[scn] = artifact.load_scene(scn)
        scn = scenes[scn]
    end
    scn.players = players
    local camera = minetest.add_entity(scn.origin, "artifact:camera")
    scn._camera = camera
    scn._entities = {}
    camera:set_pos(scn.camera.pos[1].v)
    camera:set_rotation(scn.camera.rotation[1].v)
    for _, p in pairs(players) do
        artifact.enter_modal(p)
        p:set_attach(camera)
        p:set_look_horizontal(camera:get_yaw() + math.rad(180))
        p:set_look_vertical(camera:get_rotation().x)
    end
    for _, x in pairs(scn.entities) do
        scn._entities[x.id] = minetest.add_entity(x.pos[1].v, x.type)
        local e = scn._entities[x.id]
        local prev
        local prev2
        for i, frame in ipairs(x.pos) do
            local k = tonumber(frame.k)
            local v = vector.new(frame.v[1], frame.v[2], frame.v[3])
            if not prev then goto continue end
            minetest.after(prev, function(prev, prev2)
                e:set_velocity(prev2:direction(v):multiply(prev2:distance(v) /(k -prev)))
            end, prev, prev2)
            ::continue::
            prev = k
            prev2 = v
        end
        minetest.after(prev, function()
            scn._entities[x.id]:set_velocity(vector.zero())
        end)
        if x.bones then
            for bone, data in pairs(x.bones) do
                local prev
                local prevr
                local prevp
                for i, frame in ipairs(data.frames or {}) do
                    local k = tonumber(frame.k)
                    local r = vector.new(frame.r[1], frame.r[2], frame.r[3])
                    local pos = vector.new(frame.pos[1], frame.pos[2], frame.pos[3])
                    if not prev then goto continue end
                    minetest.after(prev, function(prev)
                        e:set_bone_override(bone, {
                            rotation = {vec = r:apply(math.rad), interpolation = k -prev, absolute = true},
                            position = {vec = pos, interpolation = k -prev, absolute = true}
                        })
                    end, prev)
                    ::continue::
                    prev = k
                end
            end
        end
        
        local prev
        local prev2
        for i, frame in ipairs(scn.camera.pos) do
            local k = tonumber(frame.k)
            local v = vector.new(frame.v[1], frame.v[2], frame.v[3])
            if not prev then goto continue end
            minetest.after(prev, function(prev, prev2)
                camera:set_velocity(prev2:direction(v):multiply(prev2:distance(v) /(k -prev)))
            end, prev, prev2)
            ::continue::
            prev = k
            prev2 = v
        end
        minetest.after(prev, function()
            camera:set_velocity(vector.zero())
        end)
        prev = nil
        prev2 = nil
        for i, frame in ipairs(scn.camera.rotation) do
            local k = tonumber(frame.k)
            local r = vector.new(frame.v[1], frame.v[2], frame.v[3])
            if not prev then goto continue end
            minetest.after(prev, function(prev, prev2)
                camera:set_rotation(prev2)
                scn._camera_vel = (r -prev2) /((k -prev) *48)
            end, prev, prev2)
            ::continue::
            prev = k
            prev2 = r
        end
        minetest.after(prev, function()
            scn._camera_vel = nil
        end)
        prev = nil
        for i, frame in ipairs(scn.fx or {}) do
            local k = tonumber(frame.k)
            minetest.after(k, frame.fn, scn, prev or k)
            ::continue::
            prev = k
        end
    end
    minetest.after(scn.duration, function()
        for _, p in pairs(players) do
            p:set_detach()
            artifact.exit_modal(p)
        end
        for _, x in pairs(scn._entities) do
            x:remove()
        end
        camera:remove()
        scenes[scn.name] = nil
    end)
end

minetest.register_entity(":artifact:camera", {
    initial_properties = {
        visual = "sprite",
        textures = {"blank.png"},
        pointable = false,
        static_save = false
    }
})

minetest.register_globalstep(function()
    for _, x in pairs(scenes) do
        local rot = x._camera:get_rotation() or vector.zero()
        if x._camera_vel then
            rot = rot +x._camera_vel
            x._camera:set_rotation(rot)
        end
        for _, p in ipairs(x.players) do
            p:set_look_vertical(rot.x)
            p:set_look_horizontal(rot.y + math.rad(180))
        end
    end
end)