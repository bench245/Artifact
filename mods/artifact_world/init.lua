
minetest.override_item("air", {
    sunlight_propagates = false,
    --light_source = 10
})

minetest.override_item("", {
    tool_capabilities = {
        groupcaps = {
            dig_immediate = {times = {0}, uses = 0, maxlevel = 5},
        },
    }
})

function artifact.slabify(node)
    local def = minetest.registered_nodes[node]
    minetest.register_node(":"..node.."_slab", {
        tiles = def.tiles,
        sounds = def.sounds,
        drawtype = "nodebox",
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
        },
        paramtype = "light",
        paramtype2 = "facedir"
    })
end

function artifact.stairify(node)
    local def = minetest.registered_nodes[node]
    minetest.register_node(":"..node.."_stair", {
        tiles = def.tiles,
        sounds = def.sounds,
        drawtype = "nodebox",
        node_box = {
            type = "fixed",
            fixed = {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, {-0.5, -0.5, 0, 0.5, 0.5, 0.5}}
        },
        paramtype = "light",
        paramtype2 = "facedir"
    })
    minetest.register_node(":"..node.."_stair_inner", {
        tiles = def.tiles,
        sounds = def.sounds,
        drawtype = "nodebox",
        node_box = {
            type = "fixed",
            fixed = {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, {-0.5, -0.5, 0, 0.5, 0.5, 0.5}, {-0.5, -0.5, -0.5, 0, 0.5, 0.5}}
        },
        paramtype = "light",
        paramtype2 = "facedir"
    })
    minetest.register_node(":"..node.."_stair_outer", {
        tiles = def.tiles,
        sounds = def.sounds,
        drawtype = "nodebox",
        node_box = {
            type = "fixed",
            fixed = {{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, {-0.5, -0.5, 0.5, 0, 0.5, 0}}
        },
        paramtype = "light",
        paramtype2 = "facedir"
    })
end

minetest.register_node(":artifact:stone", {
    tiles = {{name = "artifact_stone.png", align_style = "world"}},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.3}
    }
})
artifact.slabify("artifact:stone")
artifact.stairify("artifact:stone")

minetest.register_node(":artifact:stone_tiles", {
    tiles = {{name = "artifact_stone_tiles.png", align_style = "world"}},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.3}
    }
})
artifact.slabify("artifact:stone_tiles")
artifact.stairify("artifact:stone_tiles")

minetest.register_node(":artifact:stone_bricks", {
    tiles = {{name = "artifact_stone_bricks.png", align_style = "world"}},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.3}
    }
})
artifact.slabify("artifact:stone_bricks")
artifact.stairify("artifact:stone_bricks")


minetest.register_node(":artifact:stone_bricks_cracked", {
    tiles = {{name = "artifact_stone_bricks_4x.png^artifact_stone_bricks_cracks.png", align_style = "world", scale = 4}},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.3}
    }
})

minetest.register_node(":artifact:stone_bricks_mossy", {
    tiles = {{name = "artifact_stone_bricks_4x.png^artifact_stone_bricks_moss.png", align_style = "world", scale = 4}},
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.3}
    }
})


minetest.register_node(":artifact:stone_chiseled", {
    tiles = {"artifact_stone_chiseled.png"}
})

minetest.register_node(":artifact:ladder", {
    drawtype = "mesh",
    mesh = "artifact_ladder.obj",
    collision_box = {type = "fixed", fixed = {-1/2, -1/2, 1/2, 1/2, 1/2, 3/8}},
    selection_box = {type = "fixed", fixed = {-1/2, -1/2, 1/2, 1/2, 1/2, 3/8}},
    paramtype = "light",
    paramtype2 = "4dir",
    walkable = false,
    climbable = true,
    tiles = {"artifact_ladder.png"}
})
minetest.register_node(":artifact:ladder_start", {
    drawtype = "mesh",
    mesh = "artifact_ladder_start.obj",
    collision_box = {type = "fixed", fixed = {-1/2, -1/2, 1/2, 1/2, 1/2, 3/8}},
    selection_box = {type = "fixed", fixed = {-1/2, -1/2, 1/2, 1/2, 1/2, 3/8}},
    paramtype = "light",
    paramtype2 = "4dir",
    walkable = false,
    climbable = true,
    tiles = {"artifact_ladder.png"}
})



--
minetest.register_abm{
    label = "artifact_forcefield_particles",
    nodenames = {"artifact:teleporter_on"},--{"artifact:forcefield", "artifact:powered_lamp_on", "artifact:power_terminal_on"},
    interval = 2,
    chance = 1,
    action = function(pos, node)
        local n = node.name
        if n == "artifact:teleporter_on" then
            minetest.add_particlespawner{
                time = 2,
                vertical = true,
                pos = {
                    min = pos:offset(-0.2,0,-0.2),
                    max = pos:offset(0.2,0,0.2),
                },
                amount = 40,
                glow = 8,
                vel = {
                    min = vector.new(0,3,0),
                    max = vector.new(0,5,0),
                    bias = 0.5
                },
                radius = vector.new(0.4,0,0.4),
                --size_tween = {1, 0.3},
                texture = {
                    name = "artifact_teleporter_particle.png",
                    scale = {x=1/4,y=1},
                    alpha_tween = {1,0}
                },
                exptime = 1,
                
            }
        elseif n == "artifact:forcefield" then
            minetest.add_particlespawner{
                pos = pos,
                amount = 1,
                glow = 8,
                vel = {
                    min = vector.new(-1,-1,-1),
                    max = vector.new(1,1,1),
                    bias = -1
                },
                size_tween = {1, 0.3},
                texture = "[fill:1x1:0,0:#0c3c7844",
                exptime = 4,
                
            }
        elseif n == "artifact:powered_lamp_on" or n == "artifact:power_terminal_on" then
            minetest.add_particlespawner{
                pos = {
                    min = pos:offset(-0.5,-0.5,-0.5),
                    max = pos:offset(0.5,0.5,0.5)
                },
                amount = 3,
                glow = 8,
                vel = 0,
                attract = {
                    kind = "point",
                    strength = -0.1,
                    origin = pos
                },
                radius = 0.4,
                size_tween = {0.8, 0.05},
                texture = "[fill:1x1:0,0:#98c8e9",
                exptime = 4,
                
            }
        end
    end
}
--]]

--minetest.register_lbm{
--    name = ":artifact:constructors",
--    nodenames = {"artifact:3door", "artifact:3door_b"},
--    action = function(pos, node)
--        if not minetest.get_meta(pos):contains("open") then
--            minetest.registered_nodes[node.name].on_construct(pos)
--        end
--    end
--}

if not artifact.db:contains("initialized") then
    artifact.db:set_string("initialized", "true")
    minetest.after(0, function()
        local fp = minetest.get_modpath("artifact_world").."/schems/region1.mts"
        --local r1 = minetest.read_schematic(fp, {})
        minetest.place_schematic(vector.new(0, 0, 0), fp, "0", {["chest_with_everything:chest"] = "air"})
        minetest.get_meta(vector.new(108,232,84)):set_string("always_on", "true")
    end)
end

