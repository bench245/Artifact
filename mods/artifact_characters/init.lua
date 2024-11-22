local pl = artifact.players

include "hand.lua"

include "sidekick.lua"

minetest.create_detached_inventory("artifact_hotbars")
artifact.hotbars = minetest.get_inventory{type="detached", name="artifact_hotbars"}
artifact.hotbars:set_size("key", 4)
artifact.hotbars:set_size("vix", 4)
artifact.hotbars:set_stack("key", 1, ItemStack(artifact.story.state < artifact.story.state_blackrod and "artifact:sword" or "artifact:blackrod"))
if artifact.story.state >= artifact.story.state_vix then
    artifact.hotbars:set_stack("key", 4, ItemStack("artifact:swap"))
    artifact.hotbars:set_stack("vix", 4, ItemStack("artifact:swap"))
end

function artifact.set_to_key(e)
    e:set_properties{
        visual = "mesh",
        mesh = "artifact_character.gltf",
        visual_size = vector.new(1,1,1) *0.88,
        textures = {"artifact_key.png"},
        eye_height = 1.6,
        shaded = false,
        --collide_with_objects = false
    }
end

function artifact.set_to_vix(e)
    e:set_properties{
        visual = "mesh",
        mesh = "artifact_character.gltf",
        visual_size = vector.new(1,1,1) *0.8,
        textures = {"artifact_vix.png"},
        eye_height = 1.5,
        shaded = false,
        --collide_with_objects = false
    }
end

function artifact.swap_character(p)
    if artifact.story.state < artifact.story.state_vix then return end
    local pd = pl[p:get_player_name()]
    if pd.in_cutscene then return end
    local m = p:get_meta()
    local inv = p:get_inventory()
    local chr = m:get("artifact_character") or "key"
    local obj = artifact.sidekick.obj
    if not obj then
        artifact.display_dialogue((chr == "vix" and "Key" or "Vix").." is too far away.", "artifact_generic_splash.png", 5, "[ ! ] ")
        return
    end
    local pos = p:get_pos()
    local yaw = p:get_look_horizontal()
    local pitch = p:get_look_vertical()
    local brot = p:get_bone_override("root").rotation.vec
    local hrot = p:get_bone_override("Head").rotation.vec
    local hp = p:get_hp()
    p:set_pos(obj:get_pos())
    local r = obj:get_rotation()
    p:set_look_horizontal(r.y)
    local hr = obj:get_bone_override("Head").rotation.vec
    p:set_look_vertical(hr.x)
    p:set_bone_override("Head", {
        rotation = {
            vec = obj:get_bone_override("Head").rotation.vec, interpolation = 0, absolute = true
        }
    })
    p:set_bone_override("root", {
        rotation = {
            vec = obj:get_bone_override("root").rotation.vec, interpolation = 0, absolute = true
        }
    })
    --pl[p:get_player_name()].yaw = obj:get_bone_override("root").rotation.vec.x
    p:set_hp(obj:get_hp())
    
    obj:set_pos(pos)
    obj:set_rotation(vector.new(0,yaw,0))
    obj:set_bone_override("root", {
        rotation = {
            vec = brot, interpolation = 0, absolute = true
        }
    })
    obj:set_bone_override("Head", {
        rotation = {
            vec = hrot, interpolation = 0, absolute = true
        }
    })
    obj:set_hp(hp)
    
    obj:get_luaentity()._character = chr
    
    if chr == "vix" then
        m:set_string("artifact_character", "key")
        pd.character = "key"
        inv:set_stack("hand", 1, ItemStack("artifact:hand_key"))
        inv:set_stack("main", 1, artifact.hotbars:get_stack("key", 1))
        artifact.set_to_key(p)
        artifact.set_to_vix(obj)
    else
        m:set_string("artifact_character", "vix")
        pd.character = "vix"
        inv:set_stack("hand", 1, ItemStack("artifact:hand_vix"))
        inv:set_stack("main", 1, artifact.hotbars:get_stack("vix", 1))
        artifact.set_to_vix(p)
        artifact.set_to_key(obj)
    end
    artifact.play_sound{name = "artifact_swap_character", gain = 0.4}
end

minetest.register_craftitem(":artifact:swap", {
    inventory_image = "artifact_swap.png",
    stack_max = 1,
    on_use = function(s, p)
        artifact.swap_character(p)
        return s
    end
})

minetest.hud_replace_builtin("health", {
    type = "statbar",
    position = {x=0.5,y=1},
    offset = {x=-27 *5,y=-96},
    scale = {x=4,y=4},
    alignment = {x=-1, y=-1},
    size = {x=27,y=27},
    text = "artifact_hud_heart_alt.png",
    text2 = "artifact_hud_heart_bg_alt.png"
})

minetest.register_on_joinplayer(function(p)
    local m = p:get_meta()
    local inv = p:get_inventory()
    inv:set_size("hand", 1)
    if m:get_string("artifact_character") == "vix" then
        pl[p:get_player_name()].character = "vix"
        artifact.set_to_vix(p)
        inv:set_stack("main", 4, ItemStack("artifact:swap"))
        inv:set_stack("hand", 1, ItemStack("artifact:hand_vix"))
    else
        pl[p:get_player_name()].character = "key"
        artifact.set_to_key(p)
        inv:set_stack("main", 1, artifact.hotbars:get_stack("key", 1))
        inv:set_stack("main", 4, ItemStack("artifact:swap"))
        inv:set_stack("hand", 1, ItemStack("artifact:hand_key"))
    end
    local slots = m:get("artifact_hotbar") or 4
    p:hud_set_hotbar_itemcount(slots)
    local list = ""
    for i = 0, slots do
        list = list..":"..(22*i)..",0=artifact_hud_hotbar.png"
    end
    p:hud_set_hotbar_image("[combine:"..(22*slots).."x22"..list)
    p:hud_set_hotbar_selected_image("artifact_hud_hotbar_selected.png")
    p:set_sky{
        type = "plain",
        base_color = "#000",
        clouds = false,
        sky_color = {
            dawn_horizon = "#000"
        }
    }
    p:set_sun{
        visible = false
    }
    p:set_moon{
        visible = false
    }
    p:set_stars{
        visible = false
    }
    p:set_clouds{
        density = 0
    }
    p:hud_set_flags{
        chat = false
    }
    p:set_lighting{
        bloom = {
            --intensity = 0.1,
            strength_factor = 1.5,
            radius = 2
        }
    }
    local mn = m:get("artifact_moving_node")
    if mn then
        artifact.grab_node(p:get_pos(), {name = mn}, p)
    end
    if artifact.story.state < artifact.story.state_start then
        p:set_pos(artifact.poi.region1)
        minetest.after(0, artifact.cutscene_start)
    end
    if not artifact.debug then
        p:set_inventory_formspec("")
    end
    local function abm_thing()
        for node, x in pairs(minetest.find_nodes_in_area(p:get_pos():offset(-50,-50,-50), p:get_pos():offset(50,50,50), {"artifact:3door", "artifact:3door_b", "artifact:switch_linear", "artifact:switch_angle_single", "group:artifact_requires_constructor"}, true)) do
            local construct = minetest.registered_nodes[node].on_construct
            for _, y in ipairs(x) do
                local m = minetest.get_meta(y)
                if not m:contains("initialized") then
                    m:set_string("initialized", "true")
                    construct(y)
                end
            end
        end
        minetest.after(10, abm_thing)
    end
    minetest.after(0, abm_thing)
end)

minetest.register_on_chat_message(function(name, msg)
    artifact.display_dialogue("<"..name.."> "..msg, "artifact_generic_splash.png", math.max(3, msg:len() *0.04))
end)

function minetest.show_death_screen() end

minetest.register_on_dieplayer(function(p)
    p:respawn()
end)

minetest.register_on_respawnplayer(function(p)
    p:set_hp(20)
    return true
end)

local last_boostjump = 0
local last_time = 0
minetest.register_globalstep(function()
    local time = minetest.get_us_time()
    for _, p in pairs(minetest.get_connected_players()) do
        local m = pl[p:get_player_name()]
        
        local pitch = p:get_look_vertical()
        local yaw = p:get_look_horizontal()

        local c = p:get_player_control()
        local moving = c.up or c.down or c.left or c.right
        
        if moving then
            m.moving = true
            if c.aux1 and c.up then
                if p:get_animation().y ~= 2 then p:set_animation({x=1, y=2}, 1.5, 0.2, true) end
                p:set_physics_override{
                    speed = 1.5
                }
            else
                if p:get_animation().y ~= 1 then p:set_animation({x=0, y=1}, 1.5, 0.2, true) end
                p:set_physics_override{
                    speed = 1
                }
            end
        else
            m.moving = false
            if p:get_animation().y ~= 0 then p:set_animation({x=0, y=0}) end
        end
        
        if not m.rot then m.rot = 0 end
        if moving then
            local fac = 0
            if c.left then fac = 30 elseif c.right then fac = -30 end
            m.rot = yaw +math.rad(fac)
        elseif math.abs(yaw -m.rot) > math.rad(40) then
            m.rot = m.rot +(yaw -(m.yaw or 0))
        end
        m.rot = m.rot %math.rad(360)
        m.yaw = yaw
        
        p:set_bone_override("Head", {
            rotation = {vec = vector.new(math.min(math.max(pitch, math.rad(-60)), math.rad(60)),-(yaw -m.rot),0), interpolation = 0.1, absolute = true}
        })
        
        p:set_bone_override("root", {
            rotation = {vec = vector.new(0,yaw -m.rot,0), interpolation = 0.1, absolute = true}
        })
        
        --if artifact.story.state == artifact.story.state_vix then
            if minetest.get_node(p:get_pos()).name == "artifact:kill_node" then
                p:set_pos()
            end
        --end
        
        if m.moving_node then
            local obj = artifact.node_display
            if obj then
                local target
                local dir
                if m.character == "vix" then
                    local sk = artifact.sidekick.obj
                    local rot = sk:get_rotation()
                    rot.x = -sk:get_bone_override("Head").rotation.vec.x
                    dir = vector.new(0, 0, 1.5):rotate(rot)
                    target = sk:get_pos():offset(0,2,0) +dir
                else
                    dir = p:get_look_dir():multiply(1.5)
                    target = p:get_pos():offset(0,2,0) +dir
                end
                target.x = math.round(target.x)
                target.y = math.floor(target.y)
                target.z = math.round(target.z)
                local node = minetest.get_node(target)
                if node.name ~= "air" then
                    local neighbors = minetest.find_nodes_in_area(target:offset(-1,-1,-1), target:offset(1,1,1), "air")
                    table.sort(neighbors, function(a, b)
                        return target:distance(a) < target:distance(b)
                    end)
                    target = neighbors[1] or target
                end
                obj:move_to(target)
            end
        elseif artifact.story.state >= artifact.story.state_blackrod and c.sneak and c.jump and time -last_boostjump > 2 *1000000 and m.character ~= "vix" then
            p:add_velocity(-p:get_velocity())
            if minetest.get_node(p:get_pos():offset(0, -1, 0)).name == "air" then
                local dir = p:get_look_dir() *5
                dir.y = 0
                p:add_velocity(dir)
            end
            p:add_velocity(vector.new(0,10,0))
            last_boostjump = time
        end
        
        if time -last_time >= 10 *1000000 then
            local hp = p:get_hp()
            if hp < p:get_properties().hp_max then
                p:set_hp(hp +1)
            end
            last_time = time
        end
    end
end)

include "blackrod.lua"

include "vix.lua"