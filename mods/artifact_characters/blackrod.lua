artifact.node_display = nil

minetest.register_node(":artifact:sword", {
    drawtype = "mesh",
    mesh = "artifact_sword.obj",
    inventory_image = "artifact_sword_inv.png",
    wield_image = "artifact_sword_inv.png",
    tiles = {"artifact_sword.png"},
    wield_scale = vector.new(1, 1, 1),
    node_placement_prediction = "",
    stack_max = 1,
    light_source = 1,
    tool_capabilities = {
        full_punch_interval = 0,
        max_drop_level = 0,
        groupcaps = {
            artifact_movable = {times = {0}, uses = 0, maxlevel = 5},
        },
        damage_groups = {fleshy=1},
        pointabilities = {
            nodes = {
                ["group:artifact_movable"] = true,
            }
        }
    },
    on_place = function(s, p, pt)
        if pt.under then
            local node = minetest.get_node(pt.under)
            local def = minetest.registered_nodes[node.name]
            if def._has_on_rightclick then
                def.on_rightclick(pt.under, node, p, pt)
                return
            end
        end
    end,
--    on_secondary_use = blackrod_rightclick,
    on_use = function(s, p, pt)
        if pt.under then
            local node = minetest.get_node(pt.under)
            local def = minetest.registered_nodes[node.name]
            if def._has_on_punch then
                def.on_punch(pt.under, node, p, pt)
            end
        end
        
    end,
})

function artifact.charge_blackrod()
    local p = minetest.get_connected_players()[1]
    if p:get_meta():get_string("artifact_character") ~= "vix" then p:get_inventory():set_stack("main", 1, ItemStack("artifact:blackrod_charged")) end
    artifact.hotbars:set_stack("key", 1, ItemStack("artifact:blackrod_charged"))
end

function artifact.uncharge_blackrod()
    local p = minetest.get_connected_players()[1]
    if p:get_meta():get_string("artifact_character") ~= "vix" then p:get_inventory():set_stack("main", 1, ItemStack("artifact:blackrod")) end
    artifact.hotbars:set_stack("key", 1, ItemStack("artifact:blackrod"))
end

local function blackrod_rightclick(s, p, pt)
    local m = p:get_meta()
    if m:get("artifact_moving_node") then
        artifact.drop_node(p)
    else
        if pt.under then
            local node = minetest.get_node(pt.under)
            local def = minetest.registered_nodes[node.name]
            if def._has_on_rightclick then
                def.on_rightclick(pt.under, node, p, pt)
                return
            end
        end
    end
end
minetest.register_node(":artifact:blackrod", {
    drawtype = "mesh",
    mesh = "artifact_blackrod.obj",
    inventory_image = "artifact_blackrod_inv.png",
    wield_image = "artifact_blackrod_inv.png",
    tiles = {"artifact_blackrod.png"},
    wield_scale = vector.new(1, 1, 1),
    node_placement_prediction = "",
    stack_max = 1,
    light_source = 1,
    tool_capabilities = {
        full_punch_interval = 0,
        max_drop_level = 0,
        groupcaps = {
            artifact_movable = {times = {0}, uses = 0, maxlevel = 5},
        },
        damage_groups = {fleshy=1},
        pointabilities = {
            nodes = {
                ["group:artifact_movable"] = true,
            }
        }
    },
    on_place = blackrod_rightclick,
    on_secondary_use = blackrod_rightclick,
    on_use = function(s, p, pt)
        local m = p:get_meta()
        if m:get("artifact_moving_node") then
            artifact.drop_node(p)
            return
        end
        if pt.under then
            local node = minetest.get_node(pt.under)
            local def = minetest.registered_nodes[node.name]
            if def._has_on_punch then
                def.on_punch(pt.under, node, p, pt)
            end
            if minetest.get_item_group(node.name, "artifact_movable") > 0 then
                minetest.registered_nodes[node.name].artifact_on_grab(pt.under, node, p)
            end
        end
        
    end,
})
minetest.register_node(":artifact:blackrod_charged", {
    drawtype = "mesh",
    mesh = "artifact_blackrod.obj",
    inventory_image = "artifact_blackrod_charged_inv.png",
    wield_image = "artifact_blackrod_charged_inv.png",
    tiles = {"artifact_blackrod.png"},
    wield_scale = vector.new(1, 1, 1),
    node_placement_prediction = "",
    stack_max = 1,
    light_source = 1,
    tool_capabilities = {
        full_punch_interval = 0,
        max_drop_level = 0,
        groupcaps = {
            artifact_movable = {times = {0}, uses = 0, maxlevel = 5},
        },
        damage_groups = {fleshy=1},
        pointabilities = {
            nodes = {
                ["group:artifact_movable"] = true,
            }
        }
    },
    on_place = blackrod_rightclick,
    on_secondary_use = blackrod_rightclick,
    on_use = function(s, p, pt)
        local m = p:get_meta()
        if m:get("artifact_moving_node") then
            artifact.drop_node(p)
            return
        end
        if pt.under then
            local node = minetest.get_node(pt.under)
            local def = minetest.registered_nodes[node.name]
            if def._has_on_punch then
                def.on_punch(pt.under, node, p, pt)
            end
            if def.artifact_on_add_energy then
                artifact.uncharge_blackrod()
                def.artifact_on_add_energy(pt.under)
            end
            if minetest.get_item_group(node.name, "artifact_movable") > 0 then
                minetest.registered_nodes[node.name].artifact_on_grab(pt.under, node, p)
            end
        end
        
    end,
})

minetest.register_entity(":artifact:node_display", {
    initial_properties = {
        visual = "item",
        wield_item = "",
        visual_size = vector.new(2/3, 2/3, 2/3),
        static_save = false
    },
    on_activate = function(e)
        artifact.node_display = e.object
    end,
    on_deactivate = function(e)
        artifact.node_display = nil
    end
})

function artifact.grab_node(pos, node, p)
    local m = p:get_meta()
    if m:get_string("artifact_character") ~= "vix" then
        m:set_string("artifact_moving_node", node.name)
        artifact.players[p:get_player_name()].moving_node = true
        local display = minetest.add_entity(pos, "artifact:node_display")
        display:set_properties{
            wield_item = node.name
        }
    end
end

function artifact.drop_node(p)
    local m = p:get_meta()
    local node = m:get("artifact_moving_node")
    if node and m:get_string("artifact_character") ~= "vix" then
        m:set_string("artifact_moving_node", "")
        artifact.players[p:get_player_name()].moving_node = nil
        local pos
        if artifact.node_display then
            pos = artifact.node_display:get_pos()
            if minetest.get_node(pos).name ~= "air" then return end
            artifact.node_display:remove()
            artifact.node_display = nil
        else
            pos = p:get_pos()
            if minetest.get_node(pos).name ~= "air" then return end
        end
        minetest.set_node(pos:offset(0,0.1,0), {name = node})
    end
end