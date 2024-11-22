minetest = core
artifact = {
    players = {},
    poi = {
        region1 = vector.new(84, 237, 136),
        droneroom = vector.new(74,195,98),
        blackrod = vector.new(74, 170, 119),
        vix = vector.new(-960,-934,-950),
        final = vector.new(-794,-934,-944)
    },
    debug = false
}

artifact.db = minetest.get_mod_storage()

function include(file)
    return dofile(minetest.get_modpath(minetest.get_current_modname()).."/"..file)
end

function artifact.log(item)
    minetest.log(minetest.serialize(item))
end

local _register_node = minetest.register_node
function minetest.register_node(name, def)
    def.pointable = def.pointable == nil and "blocking" or def.pointable
    def.on_drop = function(s)
        return s
    end
    if name:find "^:artifact:" then
        if def.on_punch then def._has_on_punch = true end
        if def.on_rightclick then def._has_on_rightclick = true end
        if not def.groups then
            def.groups = {solid = 1}
        elseif not def.groups.nonsolid then
            def.groups.solid = 1
        end
    end
    return _register_node(name, def)
end

local _register_craftitem = minetest.register_craftitem
function minetest.register_craftitem(name, def)
    def.on_drop = function(s)
        return s
    end
    return _register_craftitem(name, def)
end

function artifact.play_sound(def)
    def.max_hear_distance = def.range
    local spec = {name = def.name}
    --def.gain = nil
    if def.pos then
        for x in minetest.objects_inside_radius(def.pos, def.range or 32) do
            if x:is_player() and x:get_player_name() ~= def.exclude_player and not (def.to_player and x:get_player_name() ~= def.to_player) then
                def.to_player = x:get_player_name()
                def.gain = (def.gain or 1) *((def.range or 32) /x:get_pos():distance(def.pos)^2)
                minetest.sound_play(def.name, def)
            end
        end
    else
        minetest.sound_play(def.name, def)
    end
end

minetest.register_on_joinplayer(function(p)
    artifact.players[p:get_player_name()] = {}
    if artifact.debug then
    local n = p:get_player_name()
        if n == "singleplayer" then
            minetest.set_player_privs(n, {privs = true, shout = true, interact = true, give = true, fast = true, fly = true, noclip = true, server = true, debug = true, teleport = true, bring = true, settime = true, creative = true})
            --minetest.set_node(p:get_pos(), {name = "chest_with_everything:chest"})
        end
    end
end)

minetest.register_on_leaveplayer(function(p)
    artifact.players[p:get_player_name()] = nil
end)