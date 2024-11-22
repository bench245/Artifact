local _hand = minetest.registered_items[""]
function artifact.register_hand(name, caps, realname)
    minetest.register_node(":artifact:hand_"..name, {
        description = "",
        paramtype = "light",
        drawtype = "mesh",
        mesh = "artifact_hand.gltf",
        tiles = {"artifact_"..(realname or name)..".png"},
        use_texture_alpha = "opaque",
        visual_scale = 1,
        wield_scale = vector.new(2,2,2),
        node_placement_prediction = "",
        on_construct = function(pos)
            minetest.remove_node(pos)
        end,
        drop = "",
        on_drop = function()
            return ""
        end,
        range = _hand.range,
        pointabilities = caps and caps.pointabilities or {},
        tool_capabilities = caps or {
            full_punch_interval = 0,
            max_drop_level = 0,
            groupcaps = {
                dig_immediate = {times = {0}, uses = 0, maxlevel = 5},
            },
            damage_groups = {fleshy=1},
        },
        groups = {not_in_creative_inventory = 1, dig_immediate = 1}
    })
end
artifact.register_hand("key")
artifact.register_hand("vix")