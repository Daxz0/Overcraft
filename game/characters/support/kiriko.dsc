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
                - run ov_kiriko_ofudaparticle_homing def.target:<player.flag[ov.match.supporttarget]>
                - wait 0.2
            - else:
                - run ov_kiriko_ofudaparticle_nothoming
                - wait 0.2
        - wait 2t

    secondary_fire:
        #kunai (no bloom or falloff)
        - ratelimit <player> 0.55s
        - playsound <player.location> sound:entity_player_attack_sweep volume:0.4
        - if <player.inventory.slot[2].equals[<item[ov_kiriko_kunai]>]>:
            - inventory set destination:<player.inventory> origin:<item[ov_kiriko_kunai_l]> slot:2
        - else:
            - if <player.inventory.slot[2].equals[<item[ov_kiriko_kunai_l]>]>:
                - inventory set destination:<player.inventory> origin:<item[ov_kiriko_kunai_r]> slot:2
            - else:
                - inventory set destination:<player.inventory> origin:<item[ov_kiriko_kunai_l]> slot:2
        #- ~push arrow origin:<player.eye_location> speed:1.5 no_rotate no_damage destination:<player.eye_location.ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air]> save:kunai script:ov_kiriko_kunaicollide
        #- remove <entry[kunai].pushed_entities>
        - run ov_kiriko_kunaiparticle

    ability_1:
    #suzu
        - shoot snowball[item=ov_kiriko_suzu] origin:<player.eye_location.down[0.9].right[0.2]> height:2 destination:<player.eye_location.ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air]> script:ov_kiriko_suzucollide


    ability_2:
    #swift step
        - if <player.flag[ov.match.supporttarget].is_spawned.if_null[false]>:
            - teleport <player> <player.flag[ov.match.supporttarget].location>
            - playsound <player.location> sound:block_anvil_place pitch:1.3 volume:0.7
            - playeffect effect:portal at:<player.location>

    ultimate:
    #kitsune rush
        - define fw:0
        - create fox fox <player.location> save:fox
        - define npc <entry[fox].created_npc>
        - define loc <player.location>
        - teleport <[npc]> <[loc]>
        - cast speed duration:10s <[npc]>
        - define beam <[npc].location.points_between[<[npc].location.forward_flat[12.5]>].distance[0.25]>
        - define total <list>
        - define structures <list>
        - foreach <[beam]> as:point:
            - define hit <[point].with_y[<[npc].location.y>].above[2].with_pitch[90].ray_trace[range=200]>
            - if <[hit].above[0.5].material.is_solid>:
                - stop
            - teleport <[npc]> <[hit].with_pitch[0].with_yaw[<player.location.yaw>]> relative
            - run ov_kiriko_fox_footstep def:<[npc]>
            - if <[loop_index].mod[2]>:
                - wait 1t
            # this line is for spawning the structures at a certain interval
            # nothing to do with tick stuff
            - if <[loop_index].mod[16].equals[0]>:
                #huge shoutout to Max^ for getting this to always point the correct direction
                - spawn item_display[item=ov_kiriko_kitsune_rush_structure] <[npc].location> save:structure
                - adjust <entry[structure].spawned_entity> scale:<location[4,4,4]>
                - define x_q <location[1,0,0].to_axis_angle_quaternion[<[npc].location.pitch.to_radians>]>
                - define yaw <[npc].location.yaw.to_radians.add[<util.pi>].mul[-1]>
                - define y_q <location[0,1,0].to_axis_angle_quaternion[<[yaw]>]>
                - define rotation <[x_q].mul[<[y_q]>]>
                - adjust <entry[structure].spawned_entity> left_rotation:<[rotation]>
                - define structures <[structures].include[<entry[structure].spawned_entity>]>
        - remove <[npc]>
        - wait 10.5s
        - foreach <[structures]> as:structure:
            - remove <[structure]>

ov_kiriko_fox_footstep:
    type: task
    debug: false
    definitions: fox
    script:
        - repeat 19:
            - define step_dist <util.random.decimal[0.2].to[0.5]>
            - playeffect effect:redstone offset:0 special_data:0.5|#33ffff at:<[fox].location.random_offset[0.2,0,0.2].right[<[step_dist]>].random_offset[0.1,0,0.1]>
            - playeffect effect:redstone offset:0 special_data:0.5|#33ffff at:<[fox].location.random_offset[0.2,0,0,2].left[<[step_dist]>].random_offset[0.1,0,0.1]>

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

ov_kiriko_kunaiparticle:
    type: task
    debug: false
    script:
        - define hand_pos <player.eye_location.below[0.2].right[0.2]>
        - define hit <[hand_pos].ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air;range=80].above[0.2].right[0.4]||null>
        - if <[hit]> != null:
            - foreach <[hand_pos].points_between[<[hit]>].distance[0.9]> as:point:
                - playeffect effect:redstone offset:0 special_data:0.5|#33ffff at:<[point]>
                - if <[loop_index].mod[4]> == 0:
                    - wait 1t
            - define target <[hit].find_entities[!item].within[0.1].exclude[<player>].if_null[null]>
            - if <[target].any.if_null[false]>:
                - define selected_target <[target].first>
                - define item <item[ov_kiriko_kunai]>
                - define damage <[selected_target].proc[ov_damage_task].context[<list_single[<[hand_pos]>].include[<[item]>]>]>
                - hurt <[damage]> <[selected_target]> source:<player>

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
            - define forwardlocation:<[onelocation].forward[<[fw]>]>
            - if <[forwardlocation].material.is_solid>:
                - foreach stop
            - if <[forwardlocation].find.living_entities.within[0.2].first.is_living.if_null[false]>:
                - heal <[forwardlocation].find.living_entities.within[0.2].first> 13
                - foreach stop
            - playeffect effect:redstone at:<[forwardlocation]> offset:0.0 quantity:5 visibility:100 special_data:0.5|<list[#33ffff].random>
            - if <[loop_index].mod[4]> == 0:
                - wait 1t

ov_kiriko_ofudaparticle_homing:
    type: task
    debug: false
    definitions: target
    script:
        - definemap data:
            location: <player.eye_location.forward[1.2].right[0.5].with_pitch[<player.location.pitch>].with_yaw[<player.location.yaw>]>
            radius: 0.3
            rotation: <util.random_decimal.mul[360]>
            points: 28
            arc: 360
        - define locations:<[data].proc[circlegen].parse[points_between[<player.location>].distance[0.15].get[1].to[3]].combine.reverse>
        - define fw:0
        - if <[target].location.if_null["NONE"].equals["NONE"]>:
            - stop
        - foreach <[locations]> as:onelocation:
            #20m/s, 1 block = 0.5m
            - if <[target].location.if_null["NONE"].equals["NONE"]>:
                - stop
            - define uvec:<[onelocation].sub[<[target].location.up[1]>].normalize>
            - define fw:<[fw].add[0.115]>
            - define forwardlocation:<[onelocation].sub[<[uvec].if_null[<location[0,0,0]>].mul[<[fw]>]>]>
            - if <[forwardlocation].material.is_solid>:
                - foreach stop
            - if <[forwardlocation].find.living_entities.within[0.2].first.is_living.if_null[false]>:
                - heal <[forwardlocation].find.living_entities.within[0.2].first> 13
                - foreach stop
            - playeffect effect:redstone at:<[forwardlocation]> offset:0.0 quantity:5 visibility:100 special_data:0.5|<list[#eeff00].random>
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
        headshotMul: 2.5
        maxDamage: 45
        minDamage: 45
        maxDistance: 9999
        minDistance: 1

ov_kiriko_kunai_l:
    type: item
    display name: <&f>Kunai
    material: arrow
    mechanisms:
        hides: all
        custom_model_data: 9238

    flags:
        secondary: ov_kiriko

ov_kiriko_kunai_r:
    type: item
    display name: <&f>Kunai
    material: arrow
    mechanisms:
        hides: all
        custom_model_data: 9239

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

ov_kiriko_kitsune_rush:
    type: item
    display name: <&f>Kitsune Rush
    material: paper
    mechanisms:
        hides: all
    flags:
        ability: true
        ultimate: ov_kiriko


ov_kiriko_kitsune_rush_structure:
    type: item
    material: stick
    mechanisms:
        hides: all
        custom_model_data: 2200