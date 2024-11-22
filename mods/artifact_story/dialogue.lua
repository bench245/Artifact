local msgs = {}
function artifact.display_dialogue(msg, splash, time, sender)
    if sender then minetest.chat_send_all(sender..msg) end
    for _, p in pairs(minetest.get_connected_players()) do
        local w = minetest.get_player_window_information(p:get_player_name()).size.x
        local el = {
            p:hud_add{
                type = "image",
                position = {x=0,y=0},
                offset = {x=16,y=24},
                scale = {x=4,y=4},
                alignment = {x=1, y=1},
                text = splash,
                z_index = 10
            },
            p:hud_add{
                type = "image",
                position = {x=0,y=0},
                offset = {x=8,y=12},
                scale = {x=4,y=4},
                alignment = {x=1, y=1},
                text = "artifact_dialogue_bg_left.png"
            },
            p:hud_add{
                type = "image",
                position = {x=0,y=0},
                offset = {x=16 +(math.floor((w -32) /5) *5),y=12},
                scale = {x=4,y=4},
                alignment = {x=1, y=1},
                text = "artifact_dialogue_bg_right.png"
            }
        }
        local i = 0
        local str = ""
        for x in msg:gmatch("(%s*[^%s]+%s*)") do
            if (str..x):len() *8 < w -128 then
                str = str..x
            else
                el[#el +1] = p:hud_add{
                    type = "text",
                    text = str,
                    number = 0xffffff,
                    size = {x=1.5},
                    scale = {x=100, y=100},
                    alignment = {x=1, y=1},
                    position = {x=0, y=0},
                    offset = {x=64,y=24 +(24 *i)}
                    --style = 1
                }
                str = x
                i = i +1
            end
        end
        el[#el +1] = p:hud_add{
            type = "text",
            text = str,
            number = 0xffffff,
            size = {x=1.5},
            scale = {x=100, y=100},
            alignment = {x=1, y=1},
            position = {x=0, y=0},
            offset = {x=64,y=16 +(24 *i)}
            --style = 1
        }
        el[#el +1] = p:hud_add{
            type = "statbar",
            position = {x=0,y=0},
            offset = {x=16,y=12},
            scale = {x=4,y=4},
            alignment = {x=1, y=1},
            number = math.floor((w -32) /5),
            size = {x=10,y=64},
            text = "artifact_dialogue_bg_middle.png"
        }
        local job = minetest.after(time, function(p, el)
            for _, x in pairs(el) do
                p:hud_remove(x)
            end
        end, p, el)
        msgs[#msgs +1] = {job = job, p = p, el = el}
    end
end