
minetest.register_node(":artifact:power_source", {
    tiles = {"artifact_powered_lamp_off.png^[brighten"},
    groups = {artifact_power_source = 1, artifact_conductor = 1},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.2}
    },
    on_punch = function(pos)
        minetest.get_meta(pos):set_string("on", "true")
        artifact.propagate_power_event(pos, {type = "activate"})
    end,
    on_rightclick = function(pos)
        minetest.get_meta(pos):set_string("on", "false")
        artifact.propagate_power_event(pos, {type = "deactivate"})
    end,
    on_destruct = function(pos)
        for i, x in ipairs{pos:offset(-1,0,0), pos:offset(1,0,0), pos:offset(0,0,-1), pos:offset(0,0,1), pos:offset(0,-1,0), pos:offset(0,1,0)} do
            local n = minetest.get_node(x)
            local node = n.name
            if minetest.get_item_group(node, "artifact_wire_on") > 0 then artifact.propagate_power_event(x, {type = "deactivate"}) end
        end
    end,
    artifact_on_power_event = function(pos, ev)
        if ev.type == "deactivate" then artifact.propagate_power_event(pos, {type = "activate"}) end
    end
})

local function activate_terminal(pos, _, p)
    if p:get_meta():get_string("artifact_character") == "vix" and p:get_pos():distance(pos:offset(0,1,0)) <= 1 then
        artifact.propagate_power_event(pos, {type = "activate"})
        minetest.get_node_timer(pos):start(0.5)
    end
end
minetest.register_node(":artifact:power_terminal_off", {
    tiles = {"artifact_power_terminal_off.png"},
    groups = {artifact_conductor = 1},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.2}
    },
    pointable = true,
    on_punch = activate_terminal,
    on_rightclick = activate_terminal
})

minetest.register_node(":artifact:power_terminal_on", {
    tiles = {"artifact_power_terminal_on.png"},
    groups = {artifact_power_source = 1, artifact_conductor = 1},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.2}
    },
    pointable = true,
    on_punch = activate_terminal,
    on_rightclick = activate_terminal,
    on_timer = function(pos)
        local active = false
        for obj in minetest.objects_inside_radius(pos:offset(0,1,0), 1) do
            if (obj:is_player() and obj:get_meta():get_string("artifact_character") == "vix") or (obj:get_luaentity() or {})._character == "vix" then
                active = true
            end
        end
        if not active then
            artifact.propagate_power_event(pos, {type = "deactivate"})
        end
        return active
    end,
    artifact_on_power_event = function(pos, ev)
        if ev.type == "deactivate" and minetest.get_meta(pos):get_string("on") == "true" then artifact.propagate_power_event(pos, {type = "activate"}) end
    end
})


minetest.register_node(":artifact:capacitor", {
    paramtype2 = "facedir",
    light_source = 1,
    tiles = {"artifact_capacitor_off_top.png", "artifact_capacitor_off_bottom.png", "artifact_capacitor_off_side.png"},
    groups = {artifact_conductor = 1},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.2}
    },
    artifact_can_add_energy = function(pos, param2, face)
        return (pos +artifact.dir_from_facedir(param2) /2):distance(face) < 0.6
    end,
    artifact_on_add_energy = function(pos)
        artifact.propagate_power_event(pos, {type = "activate"})
        minetest.swap_node(pos, {name = "artifact:capacitor_active", param2 = minetest.get_node(pos).param2})
        minetest.get_node_timer(pos):start(5)
    end
})
minetest.register_node(":artifact:capacitor_active", {
    paramtype2 = "facedir",
    light_source = 8,
    tiles = {"artifact_capacitor_on_top.png", "artifact_capacitor_off_bottom.png", "artifact_capacitor_on_side.png"},
    groups = {artifact_power_source = 1, artifact_conductor = 1},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.2}
    },
    artifact_can_add_energy = function(pos, param2, face)
        return (pos +artifact.dir_from_facedir(param2) /2):distance(face) < 0.6
    end,
    artifact_on_add_energy = function(pos)
        minetest.get_node_timer(pos):start(math.min(20, 5 +minetest.get_node_timer(pos):get_timeout()))
    end,
    on_timer = function(pos, elapsed)
        artifact.propagate_power_event(pos, {type = "deactivate"})
        minetest.swap_node(pos, {name = "artifact:capacitor", param2 = minetest.get_node(pos).param2})
    end
})