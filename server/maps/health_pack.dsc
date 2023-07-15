ov_adder_health_pack:
    type: item
    display name: <&f>Health Pack Location Adder
    material: blaze_rod

ov_small_health_pack:
    type: item
    display name: <&f>Small Health Pack
    material: iron_ingot

    mechanisms:
        custom_model_data: 220

ov_large_health_pack:
    type: item
    display name: <&f>Large Health Pack
    material: iron_ingot

    mechanisms:
        custom_model_data: 221



ov_adder_health_pack_handler:
    type: world
    debug: false
    events:
        on player holds item item:ov_adder_health_pack:
            - foreach <server.flag[ov.map.small_pack_spawn]> as:point:
                - debugblock <[point]> color:green d:30s players:<player>
            - foreach <server.flag[ov.map.large_pack_spawn]> as:point:
                - debugblock <[point]> color:red d:30s players:<player>
            - wait 1t
            - flag <player> ov.item.adder_health_pack
        on player holds item flagged:ov.item.adder_health_pack:
            - flag <player> ov.item.adder_health_pack:!
            - debugblock clear players:<player>
        on player right clicks block with:ov_adder_health_pack:
            - if <server.flag[ov.map.small_pack_spawn].contains[<context.location>]>:
                - flag server ov.map.small_pack_spawn:<-:<context.location>
                - narrate "<&c>Removed flag."
            - else:
                - flag server ov.map.small_pack_spawn:->:<context.location>
                - narrate "<&a>Added flag."
            - debugblock clear players:<player>
            - foreach <server.flag[ov.map.small_pack_spawn]> as:point:
                - debugblock <[point]> color:green d:30s players:<player>
        on player left clicks block with:ov_adder_health_pack:
            - determine passively cancelled
            - if <server.flag[ov.map.large_pack_spawn].contains[<context.location>]>:
                - flag server ov.map.large_pack_spawn:<-:<context.location>
                - narrate "<&c>Removed flag."
            - else:
                - flag server ov.map.large_pack_spawn:->:<context.location>
                - narrate "<&a>Added flag."
            - debugblock clear players:<player>
            - foreach <server.flag[ov.map.large_pack_spawn]> as:point:
                - debugblock <[point]> color:red d:30s players:<player>

ov_spawn_health_packs:
    type: task
    debug: false
    script:
            - foreach <server.flag[ov.map.large_pack_spawn]> as:point:
                - remove <[point].flag[pack].if_null[<empty>]>
                - spawn item_display[item=ov_large_health_pack;pivot=center;scale=0.8,0.8,0.8,3;left_rotation=0,0.5,0,0.8] save:pack <[point].center.above[1]>
                - flag <[point]> pack:<entry[pack].spawned_entity>
            - foreach <server.flag[ov.map.small_pack_spawn]> as:point:
                - remove <[point].flag[pack].if_null[<empty>]>
                - spawn item_display[item=ov_small_health_pack;pivot=center;scale=1.3,1.3,1.3,3] save:pack <[point].center.above[1]>
                - flag <[point]> pack:<entry[pack].spawned_entity>


ov_health_pack_handler:
    type: world
    debug: false
    events:
        on player steps on light_blue_stained_glass flagged:ov.match:
            - define hp <player.flag[ov.match.data.health]>
            - define mhp <player.flag[ov.match.data.maxhealth]>
            - define point <context.location.center.add[-0.5,-0.5,-0.5]>
            - if <[hp]> >= <[mhp]>:
                - stop
            - if <server.flag[ov.map.small_pack_spawn].contains[<[point]>]> && !<context.location.has_flag[cd]>:
                - remove <[point].flag[pack]>
                - playsound sound:block_note_block_chime <player.location>
                - wait 3t
                - playsound sound:block_fire_extinguish <player.location>
                - flag <player> ov.match.data.health:+:75
                - flag <context.location> cd expire:10s
            - if <server.flag[ov.map.large_pack_spawn].contains[<[point]>]> && !<context.location.has_flag[cd]>:
                - playsound sound:block_note_block_chime <player.location>
                - wait 3t
                - playsound sound:block_fire_extinguish <player.location>
                - remove <[point].flag[pack]>
                - flag <player> ov.match.data.health:+:250
                - flag <context.location> cd expire:15s