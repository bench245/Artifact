
include "network.lua"

include "power.lua"

minetest.register_node(":artifact:powered_lamp_off", {
    tiles = {"artifact_powered_lamp_off.png"},
    light_source = 1,
    groups = {artifact_conductor = 1, artifact_power_sink = 1},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.2}
    },
})

minetest.register_node(":artifact:powered_lamp_on", {
    tiles = {"artifact_powered_lamp_on.png"},
    light_source = 12,
    groups = {artifact_conductor = 1, artifact_power_sink = 1},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.2}
    },
})

include "doors.lua"

include "forcefields.lua"

local tpsb = {type = "fixed", fixed = {
    {
       -0.5 -1/4,-0.5,-0.5 -1/4,
        0.5 +1/4, 0,   0.5 +1/4
    },
    {
       -1.0 +1/4,-0.5,-0.5,
       -1.5 +1/4,-1/4, 0.5
    },
    {
        1.0 -1/4,-0.5,-0.5,
        1.5 -1/4,-1/4, 0.5
    },
    {
       -0.5,-0.5,-1.0 +1/4,
        0.5,-1/4,-1.5 +1/4
    },
    {
       -0.5,-0.5, 1.0 -1/4,
        0.5,-1/4, 1.5 -1/4
    }
}}

minetest.register_node(":artifact:teleporter_off", {
    drawtype = "mesh",
    mesh = "artifact_teleporter.obj",
    selection_box = tpsb,
    collision_box = tpsb,
    tiles = {"artifact_teleporter_off.png"},
    light_source = 4,
    groups = {artifact_conductor = 1, artifact_power_sink = 1},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.2}
    },
})

minetest.register_node(":artifact:teleporter_on", {
    drawtype = "mesh",
    mesh = "artifact_teleporter.obj",
    selection_box = tpsb,
    collision_box = tpsb,
    tiles = {"artifact_teleporter_on.png"},
    light_source = 12,
    groups = {artifact_conductor = 1, artifact_power_sink = 1},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.2}
    }
})