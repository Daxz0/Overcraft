ov_kiriko_data:
    type: data

    name: Kiriko
    data_name: kiriko
    primary_fire: ov_kiriko_ofuda
    secondary_fire: ov_kiriko_kunai


    ability_1: ov_kiriko_suzu
    ability_2: ov_kiriko_swift_step
    ultimate: ov_kiriko_kitsune_rush

    ammo: 40

ov_kiriko:
    type: task
    debug: false
    script:
        - define characterName Kiriko

    primary_fire:
        #ofuda
        - ratelimit <player> 0.2s
        - repeat 2:
            - flag <player> ov.match.character.last_right_click:<util.time_now>
            - playsound <player.location> <player> sound:entity_player_attack_nodamage volume:2
            - run ov_kiriko_ofudacast_visual
            - if <player.flag[ov.match.supporttarget].is_spawned.if_null[false]>:
                - run ov_kiriko_ofudaparticle_homing
                - wait 0.2
            - else:
                - run ov_kiriko_ofudaparticle_nothoming
                - wait 0.2
        - wait 2t

    secondary_fire:
        #kunai (no bloom or falloff)
        - ratelimit <player> 0.55s
        - ~push arrow origin:<player.eye_location> speed:1.5 no_rotate no_damage destination:<player.eye_location.ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air]> save:kunai script:ov_kiriko_kunaicollide
        - remove <entry[kunai].pushed_entities>

    ability_1:
    #suzu
        - shoot snowball[item=ov_kiriko_suzu] origin:<player.eye_location.down[0.9].right[0.2]> height:2 destination:<player.eye_location.ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air]> script:ov_kiriko_suzucollide


    ability_2:
    #swift step
        - if <player.flag[ov.match.supporttarget].is_spawned.if_null[false]>:
            - teleport <player> <player.flag[ov.match.supporttarget].location>
            - playsound <player.location> sound:block_anvil_place pitch:1.3 volume:0.7
            - playeffect effect:portal at:<player.location>


ov_kiriko_ofuda_handanim_handler:
    type: world
    debug: false
    events:
        on tick:
            - foreach <server.online_players> as:__player:
                - if <player.flag[ov.match.character.name]> == kiriko:
                    - define since_last_click:<util.time_now.duration_since[<player.flag[ov.match.character.last_right_click].if_null[0]>].in_seconds.if_null[99]>
                    - if <[since_last_click]> < 0.6:
                        - inventory set o:ov_kiriko_ofuda_cast slot:1
                    - else:
                        - inventory set o:ov_kiriko_ofuda slot:1


ov_kiriko_ofudaparticle_nothoming:
    type: task
    debug: false
    script:
        - definemap data:
            location: <player.eye_location.forward[1.2].right[0.5].down[0.2].with_pitch[<player.location.pitch>].with_yaw[<player.location.yaw>]>
            radius: 0.3
            rotation: <util.random_decimal.mul[360]>
            points: 28
            arc: 360
        - define locations <[data].proc[circlegen].parse[points_between[<player.location>].distance[0.15].get[1].to[3]].combine.reverse>
        - define fw:0
        - foreach <[locations]> as:onelocation:
            #14m/s, 1 block = 0.5m
            - define fw:<[fw].add[0.0805]>
            - playeffect effect:redstone at:<[onelocation].forward[<[fw]>]> offset:0.0 quantity:5 visibility:100 special_data:0.5|<list[#33ffff].random>
            - if <[loop_index].mod[4]> == 0:
                - wait 1t

ov_kiriko_ofudaparticle_homing:
    type: task
    debug: false
    script:
        - definemap data:
            location: <player.eye_location.forward[1.2].right[0.5].with_pitch[<player.location.pitch>].with_yaw[<player.location.yaw>]>
            radius: 0.3
            rotation: <util.random_decimal.mul[360]>
            points: 28
            arc: 360
        - define locations:<[data].proc[circlegen].parse[points_between[<player.location>].distance[0.15].get[1].to[3]].combine.reverse>
        - define fw:0
        - if <player.flag[ov.match.supporttarget].location.if_null["NONE"].equals["NONE"]>:
            - stop
        - foreach <[locations]> as:onelocation:
            #20m/s, 1 block = 0.5m
            - if <player.flag[ov.match.supporttarget].location.if_null["NONE"].equals["NONE"]>:
                - stop
            - define uvec:<[onelocation].sub[<player.flag[ov.match.supporttarget].location.up[1]>].normalize>
            - define fw:<[fw].add[0.115]>
            - playeffect effect:redstone at:<[onelocation].sub[<[uvec].if_null[<location[0,0,0]>].mul[<[fw]>]>]> offset:0.0 quantity:5 visibility:100 special_data:0.5|<list[#eeff00].random>
            - if <[loop_index].mod[4]> == 0:
                - wait 1t

ov_kiriko_ofudacast_visual:
    type: task
    debug: false
    script:
        - stop
        #- inventory set o:ov_kiriko_ofuda_cast slot:1
        #- wait 0.21s
        #- inventory set o:ov_kiriko_ofuda slot:1

ov_kiriko_ofudacollide:
    type: task
    debug: false
    script:
        - stop

ov_kiriko_kunaicollide:
    type: task
    debug: false
    script:
        - stop

ov_kiriko_suzucollide:
    type: task
    debug: false
    script:
        - narrate <[location]>
        - playsound <[location]> sound:block_glass_break pitch:2
        - spawn area_effect_cloud <[location]> save:aec_suzu
        - adjust <entry[aec_suzu].spawned_entity> particle_color:white
        - wait 0.85s
        - remove <entry[aec_suzu].spawned_entity>


ov_kiriko_handler:
    type: world
    debug: false
    events:
        on delta time secondly every:1:
            - foreach <server.online_players> as:__player:
                - if <player.flag[ov.match.character.name]> == kiriko:
                    - flag <player> ov.match.sptarget.enable:true
                    - flag <player> ov.match.sptarget.ignoreblock:true

ov_kiriko_ofuda:
    type: item
    display name: <&f>Ofuda
    material: paper
    mechanisms:
        hides: all
        custom_model_data: 9232

    flags:
        primary: ov_kiriko

ov_kiriko_ofuda_cast:
    type: item
    display name: <&f>Ofuda
    material: paper
    mechanisms:
        hides: all
        custom_model_data: 9234
    
    flags:
        primary: ov_kiriko

ov_kiriko_kunai:
    type: item
    display name: <&f>Kunai
    material: arrow
    mechanisms:
        hides: all

    flags:
        secondary: ov_kiriko


ov_kiriko_suzu:
    type: item
    display name: <&f>Suzu
    material: paper
    mechanisms:
        hides: all
        custom_model_data: 9233

    flags:
        ability: true
        ability_1: ov_kiriko


ov_kiriko_swift_step:
    type: item
    display name: <&f>Swift Step
    material: paper
    mechanisms:
        hides: all

    flags:
        ability: true
        ability_2: ov_kiriko