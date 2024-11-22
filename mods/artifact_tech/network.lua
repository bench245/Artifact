
function artifact.update_wire(pos, n, rm)
    local type = {"", "single_h", ""}
    local neighbors = 0
    for i, x in pairs{pos:offset(-1,0,0), pos:offset(1,0,0), pos:offset(0,0,-1), pos:offset(0,0,1), pos:offset(0,-1,0), pos:offset(0,1,0)} do
        local n = minetest.get_node(x)
        local node = n.name
        if minetest.get_item_group(node, "artifact_wire") < 1 then goto continue end
        local rot = minetest.fourdir_to_dir(n.param2 or 0)
        neighbors = neighbors +1
        ::continue::
    end
end

function artifact.update_wires(pos, rm)
    artifact.update_wire(pos, minetest.get_node(pos), rm)
    for i, x in pairs{pos:offset(-1,0,0), pos:offset(1,0,0), pos:offset(0,0,-1), pos:offset(0,0,1), pos:offset(0,-1,0), pos:offset(0,1,0)} do
        local n = minetest.get_node(x)
        local node = n.name
        local rot = minetest.fourdir_to_dir(n.param2 or 0)
        if minetest.get_item_group(node, "artifact_wire") < 1 then goto continue end
        artifact.update_wire(x, n, rm)
        ::continue::
    end
end

function artifact.is_powered(pos)
    for i, x in ipairs{pos:offset(-1,0,0), pos:offset(1,0,0), pos:offset(0,0,-1), pos:offset(0,0,1), pos:offset(0,-1,0), pos:offset(0,1,0)} do
        local n = minetest.get_node(x)
        local node = n.name
        if minetest.get_item_group(node, "artifact_wire_on") > 0 or minetest.get_item_group(node, "artifact_power_source") > 0 then return true, x end
    end
end

--local wire_nodebox = {
--    type = "connected",
--    fixed = {1/8, -1/2, 1/8, -1/8, -3/8, -1/8},
--    connect_top = {},
--    connect_bottom = {},
--    connect_front = {1/8, -1/2, 1/8, -1/8, -3/8, -1/2},
--    connect_left = {1/8, -1/2, 1/8, -1/2, -3/8, -1/8},
--    connect_back = {1/8, -1/2, 1/2, -1/8, -3/8, -1/8},
--    connect_right = {1/2, -1/2, 1/8, -1/8, -3/8, -1/8}
--}
local wire_nodebox = {
    type = "connected",
    disconnected = {1/8, 1/8, 1/8, -1/8, -1/8, -1/8},
    connect_top = {1/8, 1/2, 1/8, -1/8, -1/8, -1/8},
    connect_bottom = {1/8, 1/8, 1/8, -1/8, -1/2, -1/8},
    connect_front = {1/8, 1/8, 1/8, -1/8, -1/8, -1/2},
    connect_left = {1/8, 1/8, 1/8, -1/2, -1/8, -1/8},
    connect_back = {1/8, 1/8, 1/2, -1/8, -1/8, -1/8},
    connect_right = {1/2, 1/8, 1/8, -1/8, -1/8, -1/8}
}
function artifact.register_wire(name, box)
    local _name = (name == "" and "" or "_")..name
    minetest.register_node(":artifact:wire".._name.."_on", {
        drawtype = "nodebox",
        node_box = box,
        mesh = "artifact_wire".._name..".obj",
        collision_box = box,
        selection_box = box,
        tiles = {"artifact_wire".._name.."_on.png"},
        groups = {artifact_wire = 1, artifact_wire_on = 1, artifact_conductor = 1},
        connects_to = {"group:artifact_conductor"},
        sunlight_propagates = true,
        walkable = false,
        paramtype = "light",
        paramtype2 = "4dir",
        drop = "",
        sounds = {
            footstep = {name = "artifact_step_generic", gain = 0.2}
        },
        on_construct = artifact.update_wires,
        on_destruct = function(pos)
            minetest.after(0, function()
                for i, x in ipairs{pos:offset(-1,0,0), pos:offset(1,0,0), pos:offset(0,0,-1), pos:offset(0,0,1), pos:offset(0,-1,0), pos:offset(0,1,0)} do
                    local n = minetest.get_node(x)
                    local node = n.name
                    if minetest.get_item_group(node, "artifact_wire_on") > 0 then artifact.propagate_power_event(x, {type = "deactivate"}) end
                end
            end)
            artifact.update_wires(pos, true)
        end
    })
    minetest.register_node(":artifact:wire".._name.."_movable_on", {
        drawtype = "nodebox",
        node_box = box,
        mesh = "artifact_wire".._name..".obj",
        collision_box = box,
        selection_box = box,
        tiles = {"artifact_wire".._name.."_on_movable.png"},
        groups = {artifact_wire = 1, artifact_wire_on = 1, artifact_conductor = 1, artifact_movable = 1},
        connects_to = {"group:artifact_conductor"},
        sunlight_propagates = true,
        walkable = false,
        pointable = true,
        paramtype = "light",
        paramtype2 = "4dir",
        drop = "",
        sounds = {
            footstep = {name = "artifact_step_generic", gain = 0.2}
        },
        artifact_on_grab = function(pos, node, p)
            node.name = node.name:gsub("_movable_on$", "_movable_off")
            artifact.grab_node(pos, node, p)
            minetest.remove_node(pos)
        end,
        on_construct = artifact.update_wires,
        on_destruct = function(pos)
            minetest.after(0, function()
                for i, x in ipairs{pos:offset(-1,0,0), pos:offset(1,0,0), pos:offset(0,0,-1), pos:offset(0,0,1), pos:offset(0,-1,0), pos:offset(0,1,0)} do
                    local n = minetest.get_node(x)
                    local node = n.name
                    if minetest.get_item_group(node, "artifact_wire_on") > 0 then artifact.propagate_power_event(x, {type = "deactivate"}) end
                end
            end)
            artifact.update_wires(pos, true)
        end
    })
    
    minetest.register_node(":artifact:wire".._name.."_off", {
        drawtype = "nodebox",
        node_box = box,
        mesh = "artifact_wire".._name..".obj",
        collision_box = box,
        selection_box = box,
        tiles = {"artifact_wire".._name.."_off.png"},
        groups = {artifact_wire = 1, artifact_conductor = 1},
        connects_to = {"group:artifact_conductor"},
        sunlight_propagates = true,
        walkable = false,
        paramtype = "light",
        paramtype2 = "4dir",
        drop = "",
        sounds = {
            footstep = {name = "artifact_step_generic", gain = 0.2}
        },
        on_construct = function(pos)
            if artifact.is_powered(pos) then artifact.propagate_power_event(pos, {type = "activate"}) end
            artifact.update_wires(pos)
        end,
        on_destruct = function(pos)
            artifact.update_wires(pos, true)
        end
    })
    minetest.register_node(":artifact:wire".._name.."_movable_off", {
        drawtype = "nodebox",
        node_box = box,
        mesh = "artifact_wire".._name..".obj",
        collision_box = box,
        selection_box = box,
        tiles = {"artifact_wire".._name.."_off_movable.png"},
        groups = {artifact_wire = 1, artifact_conductor = 1, artifact_movable = 1},
        connects_to = {"group:artifact_conductor"},
        sunlight_propagates = true,
        walkable = false,
        pointable = true,
        paramtype = "light",
        paramtype2 = "4dir",
        drop = "",
        sounds = {
            footstep = {name = "artifact_step_generic", gain = 0.2}
        },
        artifact_on_grab = function(pos, node, p)
            artifact.grab_node(pos, node, p)
            minetest.remove_node(pos)
        end,
        on_construct = function(pos)
            if artifact.is_powered(pos) then artifact.propagate_power_event(pos, {type = "activate"}) end
            artifact.update_wires(pos)
        end,
        on_destruct = function(pos)
            artifact.update_wires(pos, true)
        end
    })
end
artifact.register_wire("", wire_nodebox)--{type = "fixed", fixed = {1/8, -1/2, 1/8, -1/8, -3/8, -1/8}})
--artifact.register_wire("single_h", {type = "fixed", fixed = {1/8, -1/2, 1/8, -1/8, -3/8, -1/2}})
--artifact.register_wire("line", {type = "fixed", fixed = {1/8, -1/2, 1/2, -1/8, -3/8, -1/2}})

minetest.register_node(":artifact:invisible_conductor", {
    drawtype = "airlike",
    walkable = false,
--    pointable = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {artifact_conductor = 1, artifact_wire = 1}
})

minetest.register_node(":artifact:invisible_insulator", {
    drawtype = "airlike",
    walkable = false,
--    pointable = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {}
})

minetest.register_node(":artifact:invisible_power_source", {
    drawtype = "airlike",
    walkable = false,
--    pointable = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {artifact_power_source = 1}
})

minetest.register_node(":artifact:stone_bricks_conductor", {
    tiles = {"artifact_stone_bricks.png"},
    groups = {artifact_conductor = 1, artifact_wire = 1}
})
minetest.register_node(":artifact:stone_bricks_outlet", {
    tiles = {"artifact_stone_bricks.png", "artifact_stone_bricks.png", "artifact_stone_bricks.png^artifact_outlet.png", "artifact_stone_bricks.png", "artifact_stone_bricks.png", "artifact_stone_bricks.png"},
    groups = {artifact_conductor = 1, artifact_conductor_input_limited = 1, artifact_wire = 1},
    paramtype2 = "4dir"
})


include "switches.lua"

local visited = {}
function artifact.propagate_power_event(pos, ev, num)
    local n = minetest.get_node(pos)
    local node = n.name
    local def = minetest.registered_nodes[node]
    local conduction = minetest.get_item_group(node, "artifact_conductor")
    if not num then
        num = 0
        visited = {}
    end
    num = num +1
    local hpos = minetest.hash_node_position(pos)
    if conduction < 1 or visited[hpos] then return end
    visited[hpos] = true
    
--    if def.artifact_can_receive_power_event then
--        if not def.artifact_can_receive_power_event(pos, ev, n.param2, pos:direction(ev.prev)) then return end
--    end
--    if minetest.get_item_group(node, "artifact_conductor_input_limited") == 1 and math.abs(minetest.dir_to_fourdir(pos:direction(ev.prev)) -(n.param2 %4) -1) ~= 0 then return end
    
    if ev.type == "activate" and node:match "_off$" then
        minetest.swap_node(pos, {name = node:gsub("_off$", "_on"), param2 = n.param2})
    elseif ev.type == "deactivate" and node:match "_on$" then
        minetest.swap_node(pos, {name = node:gsub("_on$", "_off"), param2 = n.param2})
    end
    if def.artifact_on_power_event then
        def.artifact_on_power_event(pos, ev)
    end
    local prev = ev.prev or pos
    ev.prev = pos
    if num == 1 or minetest.get_item_group(node, "artifact_wire") > 0 then
        for _, x in pairs{pos:offset(-1,0,0), pos:offset(1,0,0), pos:offset(0,0,-1), pos:offset(0,0,1), pos:offset(0,-1,0), pos:offset(0,1,0)} do
            if x == prev then goto continue end
            if num > 100 then
                minetest.after(0, function() artifact.propagate_power_event(x, {type = ev.type, prev = pos}, 1) end)
            else
                artifact.propagate_power_event(x, {type = ev.type, prev = pos}, num)
            end
            ::continue::
        end
    end
end