local j = -1
local function i()
    j = j +1
    return j
end
artifact.story = {
    state = artifact.db:get_int("story_state"),
    set_state = function(state)
        artifact.story.state = state
        artifact.db:set_int("story_state", state)
    end,
    state_uninitialized = i(),
    state_start = i(),
    state_post_drone = i(),
    state_blackrod = i(),
    state_vix_room = i(),
    state_vix = i(),
    state_boss_door = i(),
    state_final = i(),
    state_end = i()
}

include "dialogue.lua"

minetest.register_node(":artifact:kill_node", {
    drawtype = "airlike",
    walkable = false,
--    pointable = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {},
})


minetest.register_entity(":artifact:vix_floating", {
    initial_properties = {
        visual = "mesh",
        mesh = "artifact_vix_floating.gltf",
        textures = {"artifact_vix.png"},
    },
    on_activate = function(e)
        e.object:set_animation({x=0,y=8}, 1, 0, true)
    end
})


minetest.register_entity(":artifact:cutscene_start", {
    initial_properties = {
        visual = "mesh",
        mesh = "artifact_cutscene_start.gltf",
        textures = {"artifact_key.png", "artifact_sword.png"},
        static_save = false
    }
})
function artifact.cutscene_start()
    artifact.play_cutscene(minetest.get_connected_players(), {
        name = "start",
        duration = 40,
        origin = artifact.poi.region1,
        entities = {
            {
                id = "main",
                type = "artifact:cutscene_start",
                pos = {
                    {k = "0", v = artifact.poi.region1:offset(4.5,-1.5,-1)}
                }
            }
        },
        camera = {
            pos = {
                {k = "0", v = vector.new(84,237,140)}
            },
            rotation = {
                {k = "0", v = -vector.new(2.5, -5.7, 6):direction(vector.new(9.1, -7.5, -2)):dir_to_rotation():offset(0,math.rad(90),0)}
            }
        },
        fx = {
            {k = "0", fn = function(scn)
                local obj = scn._entities.main
                obj:set_rotation(vector.new(0,math.rad(90),0))
                obj:set_animation({x=0, y=40}, 1, 0, false)
            end},
            {k = "15", fn = function(scn)
                artifact.display_dialogue("[ Thinking ] Well, that was an unfortunate turn of events.", "artifact_key_splash.png", 6, "Key: ")
            end},
            {k = "23", fn = function(scn)
                artifact.display_dialogue("[ Thinking ] It's a good thing going deeper was what I wanted to do in the first place...", "artifact_key_splash.png", 6, "Key: ")
            end},
            {k = "31", fn = function(scn)
                artifact.display_dialogue("[ Thinking ] I guess you could consider this a shortcut:", "artifact_key_splash.png", 4, "Key: ")
            end},
            {k = "35", fn = function(scn)
                artifact.display_dialogue("[ Thinking ] Whatever's haunting this place, it's more likely down than up.", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "45", fn = function(scn)
                artifact.display_dialogue("Tip: You can sprint by holding aux1.", "artifact_generic_splash.png", 5, "[ ! ] ")
            end},
        }
    })
    --minetest.after(40, function()
        artifact.story.set_state(artifact.story.state_start)
    --end)
end

minetest.register_entity(":artifact:cutscene_drone", {
    initial_properties = {
        visual = "mesh",
        mesh = "artifact_cutscene_start.gltf",
        textures = {"artifact_key.png", "artifact_sword.png"},
        static_save = false
    }
})
function artifact.cutscene_drone()
    artifact.story.set_state(artifact.story.state_post_drone)
    minetest.get_connected_players()[1]:set_pos(artifact.poi.droneroom)
    minetest.get_meta(vector.new(74,198,111)):set_string("always_on", "true")
    minetest.get_meta(vector.new(61,198,98)):set_string("always_on", "true")
    artifact.play_cutscene(minetest.get_connected_players(), {
        name = "drone",
        duration = 10,
        origin = artifact.poi.region1,
        entities = {
            {
                id = "main",
                type = "artifact:cutscene_start",
                pos = {
                    {k = "0", v = artifact.poi.droneroom:offset(4.5,-1.5,-1)}
                }
            }
        },
        camera = {
            pos = {
                {k = "0", v = artifact.poi.droneroom:offset(4.5,2.5,1)}
            },
            rotation = {
                {k = "0", v = -vector.new(2.5, -5.7, 6):direction(vector.new(9.1, -7.5, -2)):dir_to_rotation():offset(0,math.rad(90),0)}
            }
        },
        fx = {
            {k = "0", fn = function(scn)
                local obj = scn._entities.main
                obj:set_rotation(vector.new(0,math.rad(90),0))
                obj:set_animation({x=0, y=40}, 1, 0, false)
            end},
        }
    })
end

minetest.register_entity(":artifact:cutscene_blackrod", {
    initial_properties = {
        visual = "mesh",
        mesh = "artifact_cutscene_blackrod.gltf",
        textures = {"artifact_key.png", "artifact_sword.png", "artifact_blackrod.png"},
        static_save = false
    }
})
function artifact.cutscene_blackrod()
    artifact.story.set_state(artifact.story.state_blackrod)
    local p = minetest.get_connected_players()[1]
    p:set_pos(artifact.poi.blackrod:offset(0,0,3))
    artifact.hotbars:set_stack("key", 1, ItemStack("artifact:blackrod"))
    p:get_inventory():set_stack("main", 1, artifact.hotbars:get_stack("key", 1))
    minetest.get_meta(vector.new(74,170,106)):set_string("always_on", "true")
    artifact.log{
        -artifact.poi.blackrod:offset(4,3,5):direction(artifact.poi.blackrod:offset(0,-0.5,8)):dir_to_rotation():offset(0,math.rad(90),0),
        -artifact.poi.blackrod:offset(4,3,-3):direction(artifact.poi.blackrod:offset(0,-0.5,2)):dir_to_rotation():offset(0,math.rad(90),0)
    }
    minetest.set_node(vector.new(74, 170, 119), {name="artifact:powered_lamp_on"})
    artifact.play_cutscene(minetest.get_connected_players(), {
        name = "blackrod",
        duration = 30,
        origin = artifact.poi.region1,
        entities = {
            {
                id = "main",
                type = "artifact:cutscene_blackrod",
                pos = {
                    {k = "0", v = artifact.poi.blackrod}
                }
            }
        },
        camera = {
            pos = {
                {k = "0", v = artifact.poi.blackrod:offset(-4,3,3)},
                {k = "8", v = artifact.poi.blackrod:offset(-4,3,-1)},
                {k = "9", v = artifact.poi.blackrod:offset(-4,3,-2)}
            },
            rotation = {
                {k = "0", v = -artifact.poi.blackrod:offset(-4,3,5):direction(artifact.poi.blackrod:offset(0,-0.5,8)):dir_to_rotation():offset(0,math.rad(-90),0)},
                {k = "1", v = -artifact.poi.blackrod:offset(-4,3,5):direction(artifact.poi.blackrod:offset(0,-0.5,8)):dir_to_rotation():offset(0,math.rad(-90),0)},
                {k = "9", v = -artifact.poi.blackrod:offset(-4,3,-1):direction(artifact.poi.blackrod:offset(0,-0.5,2)):dir_to_rotation():offset(0,math.rad(-90),0)}
            }
        },
        fx = {
            {k = "0", fn = function(scn)
                local obj = scn._entities.main
                --obj:set_rotation(vector.new(0,math.rad(90),0))
                obj:set_animation({x=0, y=40}, 1, 0, false)
            end},
            {k = "13.5", fn = function(scn)
                artifact.display_dialogue("[ Thinking ] Nice.", "artifact_key_splash.png", 3, "Key: ")
            end},
            {k = "17.5", fn = function(scn)
                artifact.display_dialogue("[ Thinking ] I wonder how this ended up here. You'd think that dungeon masters would be more careful with their magic items.", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "24.5", fn = function(scn)
                artifact.display_dialogue("[ Thinking ] Maybe this blackrod can do other things besides denting walls...", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "30", fn = function(scn)
                artifact.display_dialogue("Tip: The blackrod can move certain wires, which are indicated by a lighter-colored center.", "artifact_generic_splash.png", 5, "[ ! ] ")
            end},
            {k = "40", fn = function(scn)
                artifact.display_dialogue("Tip: Key can use the blackrod to double-jump by sneaking while jumping.", "artifact_generic_splash.png", 5, "[ ! ] ")
            end},
        }
    })
end

minetest.register_entity(":artifact:cutscene_vix", {
    initial_properties = {
        visual = "mesh",
        mesh = "artifact_cutscene_vix.gltf",
        textures = {"artifact_vix.png", "artifact_key.png", "artifact_blackrod.png"},
        glow = 8,
        static_save = false
    }
})
function artifact.cutscene_vix()
    artifact.story.set_state(artifact.story.state_vix)
    minetest.get_meta(vector.new(-943,-934,-944)):set_string("always_on", "true")
    minetest.registered_nodes["artifact:3door_b"].on_construct(vector.new(-854,-934,-944))
    artifact.play_cutscene(minetest.get_connected_players(), {
        name = "vix",
        duration = 167,
        origin = artifact.poi.region1,
        entities = {
            {
                id = "main",
                type = "artifact:cutscene_vix",
                pos = {
                    {k = "0", v = artifact.poi.vix}
                }
            }
        },
        camera = {
            pos = {
                {k = "0", v = artifact.poi.vix:offset(-6,3,4)},
                {k = "40", v = artifact.poi.vix:offset(-6,3,4)},
            },
            rotation = {
                {k = "0", v = -artifact.poi.vix:offset(-6,3,4):direction(artifact.poi.vix:offset(0,2,3)):dir_to_rotation():offset(0,math.rad(0),0)},
                {k = "40", v = -artifact.poi.vix:offset(-6,3,4):direction(artifact.poi.vix:offset(0,2,3)):dir_to_rotation():offset(0,math.rad(0),0)},
                {k = "44", v = -artifact.poi.vix:offset(-6,3,4):direction(artifact.poi.vix:offset(0,2,0)):dir_to_rotation():offset(0,math.rad(90),0)},
            }
        },
        fx = {
            {k = "0", fn = function(scn)
                local obj = scn._entities.main
                --obj:set_rotation(vector.new(0,math.rad(90),0))
                obj:set_animation({x=0, y=167}, 1, 0, false)
            end},
            {k = "8", fn = function(scn)
                artifact.display_dialogue("Are you all right?", "artifact_key_splash.png", 3, "Key: ")
            end},
            {k = "13", fn = function(scn)
                artifact.display_dialogue("...I think so.", "artifact_vix_splash.png", 3, "Vix: ")
            end},
            {k = "18", fn = function(scn)
                artifact.display_dialogue("What are you doing all the way down here?", "artifact_vix_splash.png", 5, "Vix: ")
            end},
            {k = "24", fn = function(scn)
                artifact.display_dialogue("Some stories were going around about something evil living down here, and I didn't exactly have anything better to do, so I thought I'd see if I could do something about it.", "artifact_key_splash.png", 8, "Key: ")
            end},
            {k = "33", fn = function(scn)
                artifact.display_dialogue("What are _you_ doing all the way down here?", "artifact_key_splash.png", 3, "Key: ")
            end},
            {k = "40", fn = function(scn)
                artifact.display_dialogue("I... don't remember...", "artifact_vix_splash.png", 3, "Vix: ")
            end},
            {k = "44", fn = function(scn)
                artifact.display_dialogue("Unconscious?", "artifact_key_splash.png", 3, "Key: ")
            end},
            {k = "48", fn = function(scn)
                artifact.display_dialogue("Not like that. I don't even remember who I am... I remember my name... and my favorite color... but...", "artifact_vix_splash.png", 5, "Vix: ")
            end},
            {k = "54", fn = function(scn)
                artifact.display_dialogue("I guess since you were locked in a forcefield, it would make sense if your memory was wiped as well...", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "60", fn = function(scn)
                artifact.display_dialogue("I think I'm some sort of experiment... I remember that I can channel energy, and I know how to do that, but a lot of other things are blank.", "artifact_vix_splash.png", 6, "Vix: ")
            end},
            {k = "67", fn = function(scn)
                artifact.display_dialogue("You can channel energy?", "artifact_key_splash.png", 3, "Key: ")
            end},
            {k = "71", fn = function(scn)
                artifact.play_sound{name = "artifact_energy_burst_shot"}
                local dir = vector.new(1,0.3,1.3):normalize()
                local rot = dir:dir_to_rotation()
                local shot = minetest.add_entity(artifact.poi.vix:offset(0,1,1), "artifact:energy_burst")
                shot:set_rotation(rot)
                shot:set_velocity(dir *10)
            end},
            {k = "73", fn = function(scn)
                artifact.display_dialogue("Wow. That would explain it. I haven't heard of anyone being able to do that sort of thing without magic items.", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "79", fn = function(scn)
                artifact.display_dialogue("We probably ought to join forces, since whatever's down here seems to be tougher than I expected.", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "85", fn = function(scn)
                artifact.display_dialogue("...And again, it's not as if either of us has any better options.", "artifact_key_splash.png", 4, "Key: ")
            end},
            {k = "90", fn = function(scn)
                artifact.display_dialogue("All right...", "artifact_vix_splash.png", 3, "Vix: ")
            end},
            {k = "96", fn = function(scn)
                artifact.display_dialogue("...What __is__ your name, by the way? (Mine's Key.)", "artifact_key_splash.png", 4, "Key: ")
            end},
            {k = "101", fn = function(scn)
                artifact.display_dialogue("...Vix.", "artifact_vix_splash.png", 3, "Vix: ")
            end},
            {k = "105", fn = function(scn)
                artifact.display_dialogue("Nice.", "artifact_key_splash.png", 3, "Key: ")
            end},
            {k = "110", fn = function(scn)
                artifact.display_dialogue("So, do you remember anything else about this place?", "artifact_key_splash.png", 3, "Key: ")
            end},
            {k = "114", fn = function(scn)
                artifact.display_dialogue("I know how some of the technology works. I remember I can actually serve as a power source for a few mechanisms.", "artifact_vix_splash.png", 5, "Vix: ")
            end},
            {k = "120", fn = function(scn)
                artifact.display_dialogue("Great. I was able to figue out the forcefield generator, but it looks like the main power cables are getting more and more damaged. I wasn't sure what what we were going to do if we ran into, say, a giant chasm and didn't have any way across.", "artifact_key_splash.png", 9, "Key: ")
            end},
            {k = "130", fn = function(scn)
                artifact.display_dialogue("I remember that staff you have, too... I can charge it with my energy bursts, in case you have to activate something I can't reach. I think you can also use it to levitate people, but I don't know how that works.", "artifact_vix_splash.png", 9, "Vix: ")
            end},
            {k = "140", fn = function(scn)
                artifact.display_dialogue("Neat. You must have had someone training you; you don't remember anything about who it was?", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "146", fn = function(scn)
                artifact.display_dialogue("I know I did, but I don't remember any of the details.", "artifact_vix_splash.png", 4, "Vix: ")
            end},
            {k = "151", fn = function(scn)
                artifact.display_dialogue("Anything at all about whatever lives here?", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "157", fn = function(scn)
                artifact.display_dialogue("Nothing, sorry.", "artifact_vix_splash.png", 3, "Vix: ")
            end},
            {k = "161", fn = function(scn)
                artifact.display_dialogue("Not surprising, really. It was worth a shot, though.", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "175", fn = function(scn)
                artifact.display_dialogue("Tip: You can switch between Key and Vix using the item in the ourth slot of your hotbar.", "artifact_generic_splash.png", 5, "[ ! ] ")
            end},
            {k = "185", fn = function(scn)
                artifact.display_dialogue("Tip: Vix can power cerain nodes by firing energy bursts at them.", "artifact_generic_splash.png", 5, "[ ! ] ")
            end},
            {k = "195", fn = function(scn)
                artifact.display_dialogue("Tip: Vix can power other nodes by standing on them and punching them.", "artifact_generic_splash.png", 5, "[ ! ] ")
            end},
        }
    })
    minetest.after(167, function()
        minetest.add_entity(artifact.poi.vix:offset(0,2,0), "artifact:sidekick")
    end)
end

minetest.register_entity(":artifact:cutscene_final", {
    initial_properties = {
        visual = "mesh",
        mesh = "artifact_cutscene_final.gltf",
        textures = {"artifact_boss.png", "artifact_key.png", "artifact_blackrod.png", "artifact_vix.png"},
        glow = 6,
        static_save = false
    }
})
function artifact.cutscene_final()
    artifact.story.set_state(artifact.story.state_end)
    artifact.play_cutscene(minetest.get_connected_players(), {
        name = "final",
        duration = 180,
        origin = artifact.poi.region1,
        entities = {
            {
                id = "main",
                type = "artifact:cutscene_final",
                pos = {
                    {k = "0", v = artifact.poi.final}
                }
            }
        },
        camera = {
            pos = {
                {k = "0", v = artifact.poi.final:offset(-16,3,0)},
                {k = "4", v = artifact.poi.final:offset(-10,3,0)},
                {k = "5", v = artifact.poi.final:offset(-8,3,0)},
                {k = "15", v = artifact.poi.final:offset(-8,3,0)},
                {k = "15.1", v = artifact.poi.final:offset(-8,3,8)},
            },
            rotation = {
                {k = "0", v = -artifact.poi.final:offset(-8,3,0):direction(artifact.poi.final:offset(0,3.5,0)):dir_to_rotation():offset(0,math.rad(0),0)},
                {k = "15", v = -artifact.poi.final:offset(-8,3,0):direction(artifact.poi.final:offset(0,3.5,0)):dir_to_rotation():offset(0,math.rad(0),0)},
                {k = "15.1", v = -artifact.poi.final:offset(-8,3,8):direction(artifact.poi.final:offset(-8,2,0)):dir_to_rotation():offset(0,math.rad(190),0)},
            }
        },
        fx = {
            {k = "0", fn = function(scn)
                local obj = scn._entities.main
                obj:set_rotation(vector.new(0,math.rad(90),0))
                obj:set_animation({x=0, y=180}, 1, 0, false)
            end},
            {k = "5", fn = function(scn)
                artifact.display_dialogue("Finally.", "artifact_boss_splash.png", 3, "???: ")
            end},
            {k = "9", fn = function(scn)
                artifact.display_dialogue("I was beginning to think you got lost.", "artifact_boss_splash.png", 3, "???: ")
            end},
            {k = "13", fn = function(scn)
                artifact.display_dialogue("What, you knew we were coming?", "artifact_key_splash.png", 3, "Key: ")
            end},
            {k = "17", fn = function(scn)
                artifact.display_dialogue("I live five miles underground. Did you really think all those stories about me started circulating without my knowledge?", "artifact_boss_splash.png", 5, "???: ")
            end},
            {k = "23", fn = function(scn)
                artifact.display_dialogue("...Actually, that is exactly what I thought.", "artifact_key_splash.png", 3, "Key: ")
            end},
            {k = "27", fn = function(scn)
                artifact.display_dialogue("Wait... You deliberately advertised your own secret operation?", "artifact_vix_splash.png", 4, "Vix: ")
            end},
            {k = "32", fn = function(scn)
                artifact.display_dialogue("Naturally. What better way to lure adventurers?", "artifact_boss_splash.png", 3, "???: ")
            end},
            {k = "36", fn = function(scn)
                artifact.display_dialogue("So you're saying that all this time, I wasn't hunting you... you were hunting me?", "artifact_key_splash.png", 4, "Key: ")
            end},
            {k = "41", fn = function(scn)
                artifact.display_dialogue("That about sums it up.", "artifact_boss_splash.png", 3, "???: ")
            end},
            {k = "45", fn = function(scn)
                artifact.display_dialogue("...Why, though? I've got plenty of motivation in the fact that you're, you know, evil, but... aren't you supposed to __not__ want vengeful adventurers bursting into your throne room at all hours?", "artifact_key_splash.png", 9, "Key: ")
            end},
            {k = "55", fn = function(scn)
                artifact.display_dialogue("[ Laughs ]", "artifact_boss_splash.png", 2, "???: ")
            end},
            {k = "57", fn = function(scn)
                artifact.display_dialogue("Life is full of mysteries, isn't it?", "artifact_boss_splash.png", 3, "???: ")
            end},
            {k = "61", fn = function(scn)
                artifact.display_dialogue("Anyway, where were we? Ah, yes. You came here to kill me, and I came here to kill you.", "artifact_boss_splash.png", 5, "???: ")
            end},
            {k = "67", fn = function(scn)
                artifact.display_dialogue("Let's get down to business, shall we?", "artifact_boss_splash.png", 3, "???: ")
            end},
            {k = "71", fn = function(scn)
                artifact.display_dialogue("I guess it was too much to hope for that he would go through his entire evil plan for us...", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "77", fn = function(scn)
                artifact.display_dialogue("Clearly.", "artifact_boss_splash.png", 2, "???: ")
            end},
            {k = "80", fn = function(scn)
                artifact.display_dialogue("You're on.", "artifact_key_splash.png", 2, "Key: ")
            end},
            
            

            {k = "85", fn = function(scn)
                artifact.display_dialogue("Figures.", "artifact_key_splash.png", 2, "Key: ")
            end},
            {k = "88", fn = function(scn)
                artifact.display_dialogue("You fight well. If this had been a story, you might have defeated me.", "artifact_boss_splash.png", 4, "???: ")
            end},
            {k = "93", fn = function(scn)
                artifact.display_dialogue("Unfortunately for you, this is reality. And in reality, the forces of evil never pick a fair fight if they can help it.", "artifact_boss_splash.png", 5, "???: ")
            end},
            {k = "99", fn = function(scn)
                artifact.display_dialogue("It's been fun playing with you.", "artifact_boss_splash.png", 3, "???: ")
            end},
            {k = "103", fn = function(scn)
                artifact.display_dialogue("I'll be seeing you.", "artifact_boss_splash.png", 3, "???: ")
            end},
            {k = "107", fn = function(scn)
                artifact.display_dialogue("Eh. Well, whatever scheme you're hoping to pull off, you can count on us to do everything we can to put stop to it.", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "113", fn = function(scn)
                artifact.display_dialogue("Excellent.", "artifact_boss_splash.png", 3, "???: ")
            end},
            {k = "117", fn = function(scn)
                artifact.display_dialogue("Well, I guess that's that.", "artifact_key_splash.png", 3, "Key: ")
            end},
            {k = "121", fn = function(scn)
                artifact.display_dialogue("We should probably head back to the surface. If he's going to be like that, there's not a lot more we can do here.", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "127", fn = function(scn)
                artifact.display_dialogue("I suppose...", "artifact_vix_splash.png", 3, "Vix: ")
            end},
            {k = "131", fn = function(scn)
                artifact.display_dialogue("Something the matter?", "artifact_key_splash.png", 3, "Key: ")
            end},
            {k = "135", fn = function(scn)
                artifact.display_dialogue("Why did he choose to fight us?", "artifact_vix_splash.png", 3, "Vix: ")
            end},
            {k = "139", fn = function(scn)
                artifact.display_dialogue("Because he thinks fighting adventurers is fun?", "artifact_key_splash.png", 3, "Key: ")
            end},
            {k = "143", fn = function(scn)
                artifact.display_dialogue("Maybe. He just doesn't seem like he would fight us unless he would gain some sort of advantage. What worries me is that I can't guess what that could be.", "artifact_vix_splash.png", 8, "Vix: ")
            end},
            {k = "152", fn = function(scn)
                artifact.display_dialogue("...Well, there's not much we can do about it even if he did.", "artifact_key_splash.png", 5, "Key: ")
            end},
            {k = "158", fn = function(scn)
                artifact.display_dialogue("I suppose.", "artifact_vix_splash.png", 3, "Vix: ")
            end},
        }
    })
end
--+ Key: Figures.
--    + ???: You fight well. If this had been a story, you might have defeated me.
--    + ???: Unfortunately for you, this is reality. And in reality, the forces of evil never pick a fair fight if they can help it.
--    + ???: It's been fun playing with you.
--    + ???: I'll be seeing you.
--    + Key: Eh. Well, whatever scheme you're hoping to pull off, you can count on us to do everything we can to put stop to it.
--    + ???: Excellent.
--    + Key: Well, I guess that's that.
--    [ He turns toward Vix as he looks around the room ]
--    + Key: We should probably head back to the surface. If he's going to be like that, there's not a lot more we can do here.
--    + Vix: I suppose...
--    + Key: Something the matter?
--    + Vix: Why did he choose to fight us?
--    + Key: Because he thinks fighting adventurers is fun?
--    + Vix: Maybe. He just doesn't seem like he would fight us unless he would gain some sort of advantage. What worries me is that I can't guess what that could be.
--    + Key: ...Well, there's not much we can do about it even if he did.
--    + Vix: I suppose.

include "triggers.lua"

if artifact.debug then
    minetest.register_chatcommand("play", {
        func = function(name, scn)
            artifact["cutscene_"..scn]()
        end
    })
    
    minetest.register_chatcommand("state", {
        func = function(name, scn)
            artifact.story.set_state(artifact.story["state_"..scn])
        end
    })
end
--
--minetest.register_chatcommand("/", {
--    func = function(name, msg)
--        local c = msg:match "^[^%s]+"
--        msg = msg:gsub("^[^%s]+", "")
--        artifact.display_dialogue(msg, "artifact_"..c.."_splash.png", 10, "[ Vix ] ")
--    end
--})