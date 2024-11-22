
function artifact.dir_from_facedir(param2)
    local axis = math.floor(param2 /4)
    local out = vector.new(0,0,0)
    if axis == 0 then
        out.y = 1
    elseif axis == 5 then
        out.y = -1
    elseif axis == 1 then
        out.z = 1
    elseif axis == 2 then
        out.z = -1
    elseif axis == 3 then
        out.x = 1
    else
        out.x = -1
    end
    return out
end

function artifact.build_forcefield(pos, param2)
    local dir = artifact.dir_from_facedir(param2)
--    local rc = minetest.raycast(pos +dir, pos +(dir *100), false, true)
--    local target = rc:next()
--    if not target then
--        artifact.log{dir, minetest.get_node(pos), rc:next(), pos +dir, pos +(dir *100)}
--        return
--    end
--    target = target.under:round()
    local target
    local pos2 = pos +dir
    local i= 0
    while i < 100 do
        if minetest.get_node(pos2).name ~= "air" then
            target = pos2
            break
        end
        pos2 = pos2 +dir
        i = i +1
    end
    local node = minetest.get_node(target)
    local lnode = minetest.get_node(pos)
    if minetest.get_item_group(node.name, "artifact_forcefield_active") > 0 and artifact.dir_from_facedir(node.param2) == -dir then
        local vm = minetest.get_voxel_manip(pos, target)
        for i = 1, pos:distance(target) -1 do
            vm:set_node_at(pos:add(dir *i), {name = "artifact:forcefield"})
        end
        vm:write_to_map()
        minetest.set_node(target, {name = "artifact:forcefield_generator_running", param2 = node.param2})
        minetest.set_node(pos, {name = "artifact:forcefield_generator_running", param2 = lnode.param2})
    end
end

function artifact.unbuild_forcefield(pos, param2)
    local dir = artifact.dir_from_facedir(param2)
    local node = minetest.get_node(pos)
    if node.name == "artifact:forcefield_generator_running" then
        minetest.set_node(pos, {name = "artifact:forcefield_generator_active", param2 = node.param2})
    end
    node = minetest.get_node(pos:add(dir))
    local i = 1
    while node.name == "artifact:forcefield" do
        minetest.set_node(pos:add(dir *i), {name = "air"})
        i = i +1
        node = minetest.get_node(pos:add(dir *i))
    end
    if node.name == "artifact:forcefield_generator_running" then
        minetest.set_node(pos:add(dir *i), {name = "artifact:forcefield_generator_active", param2 = node.param2})
    end
end

minetest.register_node(":artifact:forcefield_generator", {
    tiles = {"artifact_forcefield_generator_off_top.png", "artifact_forcefield_generator_off_bottom.png", "artifact_forcefield_generator_off_side.png", "artifact_forcefield_generator_off_side.png", "artifact_forcefield_generator_off_side.png", "artifact_forcefield_generator_off_side.png"},
    groups = {artifact_power_sink = 1, artifact_conductor = 1},
    paramtype2 = "facedir",
    light_source = 1,
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.2}
    },
    artifact_on_power_event = function(pos, ev)
        if ev.type == "activate" then
            local param2 = minetest.get_node(pos).param2
            minetest.set_node(pos, {name = "artifact:forcefield_generator_active", param2 = param2})
            minetest.after(0, artifact.build_forcefield, pos, param2)
        end
    end
})

minetest.register_node(":artifact:forcefield_generator_active", {
    tiles = {"artifact_forcefield_generator_off_top.png", "artifact_forcefield_generator_off_bottom.png", "artifact_forcefield_generator_off_side.png"},
    groups = {artifact_power_sink = 1, artifact_conductor = 1, artifact_forcefield_active = 1},
    paramtype2 = "facedir",
    light_source = 8,
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.2}
    },
    artifact_on_power_event = function(pos, ev)
        if ev.type == "deactivate" then
            local param2 = minetest.get_node(pos).param2
            minetest.set_node(pos, {name = "artifact:forcefield_generator", param2 = param2})
            artifact.unbuild_forcefield(pos, param2)
        end
    end
})
minetest.register_node(":artifact:forcefield_generator_running", {
    tiles = {"artifact_forcefield_generator_on_top.png", "artifact_forcefield_generator_on_bottom.png", "artifact_forcefield_generator_on_side.png"},
    groups = {artifact_power_sink = 1, artifact_conductor = 1, artifact_forcefield_active = 1},
    paramtype2 = "facedir",
    light_source = 8,
    sounds = {
        footstep = {name = "artifact_step_stone", gain = 0.2}
    },
    artifact_on_power_event = function(pos, ev)
        if ev.type == "deactivate" then
            local param2 = minetest.get_node(pos).param2
            minetest.set_node(pos, {name = "artifact:forcefield_generator", param2 = param2})
            artifact.unbuild_forcefield(pos, param2)
        end
    end
})

minetest.register_node(":artifact:forcefield", {
    drawtype = "glasslike_framed",
    use_texture_alpha = "blend",
    light_source = 6,
    tiles = {"artifact_forcefield.png", "artifact_forcefield_detail.png"},
    visual_scale = 0.75,
    groups = {artifact_conductor = 1},
    sounds = {
        footstep = {name = "artifact_step_forcefield", gain = 0.2}
    },
    on_punch = function(pos)
        minetest.add_particlespawner{
                    pos = pos,
                    amount = 4,
                    glow = 8,
                    vel = {
                        min = vector.new(-1,-1,-1),
                        max = vector.new(1,1,1)
                    },
                    size_tween = {1, 0.3},
                    texture = "[fill:1x1:0,0:#0c3c7844",
                    exptime = 8,
                    
                }
    end
})
