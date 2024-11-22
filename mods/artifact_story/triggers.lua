minetest.register_node(":artifact:cutscene_trigger_drone", {
    drawtype = "airlike",
    walkable = false,
--    pointable = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {artifact_requires_constructor = 1},
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(1)
    end,
    on_timer = function(pos)
        if artifact.story.state >= artifact.story.state_post_drone then return end
        for obj in minetest.objects_inside_radius(pos, 2) do
            if obj:is_player() then artifact.cutscene_drone() end
        end
        return true
    end
})

minetest.register_node(":artifact:cutscene_trigger_blackrod", {
    drawtype = "airlike",
    walkable = false,
--    pointable = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {artifact_requires_constructor = 1},
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(1)
    end,
    on_timer = function(pos)
        if artifact.story.state >= artifact.story.state_blackrod then return end
        for obj in minetest.objects_inside_radius(pos, 2) do
            if obj:is_player() then artifact.cutscene_blackrod() end
        end
        return true
    end
})

minetest.register_node(":artifact:cutscene_trigger_teleport", {
    drawtype = "airlike",
    walkable = false,
--    pointable = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {artifact_requires_constructor = 1},
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(1)
    end,
    on_timer = function(pos)
        if artifact.story.state >= artifact.story.state_vix_room then return end
        for obj in minetest.objects_inside_radius(pos:offset(0,-1,0), 0.5) do
            if obj:is_player() and minetest.get_node(pos:offset(0,-1,0)).name == "artifact:teleporter_on" then
                artifact.story.set_state(artifact.story.state_vix_room)
                local fp = minetest.get_modpath("artifact_world").."/schems/region2.mts"
                minetest.place_schematic(vector.new(-1000, -1000, -1000), fp, "0", {["chest_with_everything:chest"] = "air"})
                minetest.add_entity(vector.new(-960,-932,-950), "artifact:vix_floating")
                minetest.get_meta(vector.new(-960,-936,-955)):set_string("open", "true")
                minetest.after(0, function() obj:set_pos(vector.new(-960, -934, -927)) end)
            end
        end
        return true
    end
})

minetest.register_node(":artifact:cutscene_trigger_vix", {
    drawtype = "airlike",
    walkable = false,
--    pointable = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {artifact_conductor = 1, artifact_power_sink = 1},
    artifact_on_power_event = function(pos, ev)
        if ev.type ~= "deactivate" or artifact.story.state >= artifact.story.state_vix then return end
        minetest.after(0.5, function()
            if artifact.is_powered(pos) then return end
            for obj in minetest.objects_inside_radius(vector.new(-960,-934,-950), 10) do
                local e = obj:get_luaentity()
                if e and e.name == "artifact:vix_floating" then
                    obj:remove()
                end
            end
            artifact.cutscene_vix()
        end)
    end
})

minetest.register_node(":artifact:cutscene_trigger_final", {
    drawtype = "airlike",
    walkable = false,
--    pointable = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {artifact_requires_constructor = 1},
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(1)
    end,
    on_timer = function(pos)
        if artifact.story.state >= artifact.story.state_final then return end
        for obj in minetest.objects_inside_radius(pos, 2) do
            if obj:is_player() then artifact.cutscene_final() end
        end
        return true
    end
})