ov_brigitte_data:
    type: data

    name: Brigitte
    data_name: brigitte
    primary_fire: ov_brigitte_rocket_flail
    secondary_fire: ov_brigitte_shield

    ability_1: ov_brigitte_repair_pack
    ability_2: ov_brigitte_whip_shot
    ultimate: ov_brigitte_rally

    ammo: 40

ov_brigitte:
    type: task
    debug: false
    script:
        - define characterName Brigitte

    primary_fire:
        #whip
        - stop if:<player.has_flag[ov.match.character.shield]>
        - ratelimit <player> 0.6s
        - define val 15
        - define loc <player.location>
        - define heal false
        - repeat 10:
            - define loc <player.location>
            - define val <[val].add[10]>
            - define stop false
            - definemap data:
                location: <[loc].with_pitch[0].above[1].forward[<[val].div[40]>].right[3].left[<[value].div[25]>].with_yaw[<[loc].yaw.add[-<[val]>]>]>
                radius: 3
                rotation: <[value].mul[1.5]>
                points: 25
                arc: 180
            - define whip <[data].proc[circlegen].combine.reverse>
            - foreach <[whip]> as:point:
                - if <[point].material.is_solid>:
                    - define stop true
                    - foreach stop
                - if <[loop_index]> > 10:
                    - playeffect effect:redstone special_data:0.8|<list[#454545|#000000|#5c5c5c].random> at:<[point]> offset:0
                    - define target <[point].find_entities[living].within[0.3]>
                    - if <[target].any>:
                        - hurt 35 <[target]> source:<player>
                        - define heal true
            - if !<[stop]>:
                - playeffect effect:redstone special_data:0.6|<list[#454545|#000000|#5c5c5c].random> at:<[whip].last> offset:0.2 quantity:40
            - wait 0.01
        - define targets <player.location.find_entities[living].within[10].exclude[<player>]>
        - repeat 5:
            - foreach <[targets]> as:p:
                - if <server.flag[<player.flag[ov.match.team].if_null[<empty>]>].contains[<[p]>].if_null[<list>]>:
                    - flag <[p]> ov.match.data.health:+:15
            - wait 1s
    # secondary:
    secondary_fire:
        - if <player.has_flag[ov.match.character.shield]>:
            - teleport <player> <player.flag[ov.match.character.shield.npc].location>
            - remove <player.flag[ov.match.character.shield.npc]>
            - remove <player.flag[ov.match.character.shield.hitbox]>
            - remove <player.flag[ov.match.character.shield.cam]>
            - cast invisibility remove
            - flag <player> ov.match.character.shield:!
            - stop
        - create player <player.name> <player.location> save:npc
        - define npc <entry[npc].created_npc>
        - define dist 2
        - cast invisibility <player> d:-1t hide_particles no_icon
        - spawn armor_stand[gravity=false;visible=false] <[npc].location.below[0.5].backward[<[dist]>]> save:cam
        - define cam <entry[cam].spawned_entity>
        - if <player.has_flag[ov.character.rally]>:
            - spawn slime[size=5;has_ai=false;visible=false;max_health=750;health=750] save:shieldHitbox
        - else:
            - spawn slime[size=5;has_ai=false;visible=false;max_health=300;health=300] save:shieldHitbox
        - define hitbox <entry[shieldHitbox].spawned_entity>
        - flag <[hitbox]> shieldHitbox:<player>
        - mount <player>|<[cam]>
        - equip <[npc]> hand:ov_brigitte_shield
        - flag <player> ov.match.character.shield.health:300
        - flag <player> ov.match.character.shield.npc:<[npc]>
        - flag <player> ov.match.character.shield.cam:<[cam]>
        - flag <player> ov.match.character.shield.hitbox:<[hitbox]>
        - while <player.flag[ov.match.character.shield.health].if_null[0]> > 0 && <player.has_flag[ov.match.character.shield]>:
            - define beam <player.eye_location.points_between[<player.eye_location.backward_flat[<[dist]>]>].distance[0.5].reverse>
            - foreach <[beam]> as:point:
                - if <[point].material.name> == air:
                    - define hit <[point].distance[<player.eye_location>]>
                    - foreach stop
                - else:
                    - define hit -0.3
            - define locy <[npc].location.below[0.5].backward[<[hit]>]>
            - teleport <[cam]> <[locy]>
            - teleport <[hitbox]> <[npc].location.forward_flat[1]>
            - look <[npc]> yaw:<player.location.yaw> pitch:0
            # - teleport <[npc]> <[npc].location.with_yaw[<player.location.yaw>]>
            - wait 1t
        - if <player.has_flag[ov.match.character.shield]>:
            - teleport <player> <player.flag[ov.match.character.shield.npc].location>
            - remove <player.flag[ov.match.character.shield.npc]>
            - remove <player.flag[ov.match.character.shield.hitbox]>
            - remove <player.flag[ov.match.character.shield.cam]>
            - mount <player> cancel
            - flag <player> ov.match.character.shield:!
            - cast invisibility remove
            # - remove <[npc]>

    bash:
        - ratelimit <player> 1t
        - define npc <player.flag[ov.match.character.shield.npc]>
        - define beam <[npc].location.points_between[<[npc].location.forward_flat[12]>].distance[0.5]>
        - define total <list>
        - foreach <[beam]> as:point:
            - define hit <[point].with_y[<[npc].location.y>].above[2].with_pitch[90].ray_trace[range=200]>
            - define ent <[point].find_entities[living].within[0.5].exclude[<player>|<player.flag[ov.match.character.shield.hitbox]>]>
            - if <[ent].any>:
                - foreach <[ent]> as:t:
                    - adjust <[t]> velocity:<[t].location.sub[<player.location.forward[-1.5]>]>
                    - hurt 50 <[t]> source:<player>
                - foreach stop
            - if <[hit].above[0.5].material.is_solid>:
                - stop
            - teleport <[npc]> <[hit].with_pitch[0].with_yaw[<player.location.yaw>]> relative
            - if <[loop_index].mod[2]>:
                - wait 1t

    ability_1:
        #heal pack
        - define target <player.eye_location.forward[0.2].ray_trace_target[range=25;entities=*;fluids=false;nonsolids=false;ignore=<player>].if_null[null]>
        - if <[target]> == null:
            - stop
        - if <[target].is_living>:
            - run ov_brigitte_pack def:<[target]>


    ability_2:
        #whip shot
        - define final <player.eye_location.forward[10]>
        - define beam <player.eye_location.above[-0.3].right[0.3].points_between[<[final]>].distance[0.5]>
        - define beamC <player.eye_location.above[-0.3].right[0.3].points_between[<[final]>].distance[0.25]>

        - define pitch <player.location.pitch>
        - foreach <[beamC]> as:point:
            - if <[point].material.is_solid>:
                - foreach stop
            - if <[loop_index].mod[2]> == 0:
                - playeffect at:<[beam].get[<[loop_index].div[2]>]> effect:redstone special_data:1|#454545 offset:0
            - else:
                - playeffect at:<[point]> effect:redstone special_data:0.6|#5c5c5c offset:0
            - if <[loop_index].mod[5]> == 0:
                - define ent <[point].find_entities[living].within[1].exclude[<player>]>
                - if <[ent].any>:
                    - foreach <[ent]> as:t:
                        - adjust <[t]> velocity:<[t].location.sub[<player.location.forward[0.5]>]>
                        - hurt 70 <[t]> source:<player>
                    - foreach stop
                - definemap data:
                    location: <[point].forward[0.5].with_pitch[<[pitch]>]>
                    radius: 0.5
                    rotation: 0
                    points: 10
                    arc: 180
                - define chain <[data].proc[circlegen].combine.reverse>
                - playeffect at:<[chain]> effect:redstone special_data:0.45|#5c5c5c offset:0
                - wait 1t
        - definemap data:
            location: <[beamC].last.forward[0.5].with_pitch[<[pitch]>]>
            radius: 0.5
            rotation: 0
            points: 10
            arc: 180
        - define chain <[data].proc[circlegen].combine.reverse>
        - repeat 5:
            - playeffect at:<[chain]> effect:redstone special_data:1|#5c5c5c offset:0
            - wait 1t
        - define beam <player.eye_location.above[-0.3].right[0.3].points_between[<[final]>].distance[0.5]>
        - define beamC <player.eye_location.above[-0.3].right[0.3].points_between[<[final]>].distance[0.25]>
        - define beamC <[beamC].reverse>
        - define beam <[beam].reverse>
        - foreach <[beamC]> as:point:
            - if <[loop_index].mod[2]> == 0:
                - playeffect at:<[beam].get[<[loop_index].div[2]>]> effect:redstone special_data:1|#454545 offset:0
            - else:
                - playeffect at:<[point]> effect:redstone special_data:0.6|#5c5c5c offset:0
            - if <[loop_index].mod[5]> == 0:
                - definemap data:
                    location: <[point].forward[0.5].with_pitch[<[pitch]>]>
                    radius: 0.5
                    rotation: 0
                    points: 10
                    arc: 180
                - define chain <[data].proc[circlegen].combine.reverse>
                - playeffect at:<[chain]> effect:redstone special_data:0.45|#5c5c5c offset:0
                - wait 1t
    ultimate:
        #rally

        - flag <player> ov.match.character.rally expire:10s
        - flag <player> ov.match.data.ar:100
        - cast speed amplifier:0 <player> hide_particles no_icon duration:10s

        - repeat 7:
            - define targets <player.location.find_entities[living].within[8].exclude[<player>]>
            - foreach <[targets]> as:p:
                - if <server.flag[<player.flag[ov.match.team]>].contains[<[p]>]>:
                    - if <[p].flag[ov.match.data.ohp]> > 100:
                        - flag <[p]> ov.match.data.ohp:100 expire:30s
                        - repeat stop
                    - flag <[p]> ov.match.data.ohp:+:15 expire:30s
            - wait 0.5s


ov_brigitte_handler:
    type: world
    debug: false
    events:
        on player right clicks entity flagged:ov.match.character.shield:
            - run ov_brigitte.bash
        on player steers entity flagged:ov.match.character.shield:
            - if <context.dismount>:
                - determine cancelled
            - define forward <context.forward>
            - define side <context.sideways.div[5]>
            - define up <context.jump>
            - define stand <player.flag[ov.match.character.shield.npc]>
            - define location <[stand].location.with_pitch[<[stand].location.pitch>].forward[<[forward].div[5]>].with_y[<[stand].location.y>]>
            - if <[side]> != 0:
                - define side <[side].mul[-1]>
                - define location <[location].right[<[side]>]>
            - define hit <[location].with_y[<[stand].location.y>].above[2].with_pitch[90].ray_trace[range=200]>
            - if <[hit].above[0.5].material.is_solid>:
                - stop
            - teleport <[stand]> <[hit].with_pitch[0].with_yaw[<player.location.yaw>]> relative


ov_brigitte_rocket_flail:
    type: item
    display name: <&f>Rocket Flail
    material: netherite_shovel
    mechanisms:
        hides: all

    flags:
        primary: ov_brigitte

        maxDamage: 35
        minDamage: 35

        spread: 0

        maxDistance: 0
        minDistance: 0

        headshotMul: 1

ov_brigitte_shield:
    type: item
    display name: <&f>Barrier Shield
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9228
    flags:
        secondary: ov_brigitte
        ability: true
        shield: 300

ov_brigitte_whip_shot:
    type: item
    display name: <&f>Whip Shot
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9229
    flags:
        ability_2: ov_brigitte
        ability: true

ov_brigitte_repair_pack:
    type: item
    display name: <&f>Repair Pack
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9230
    flags:
        ability_1: ov_brigitte
        ability: true
ov_brigitte_rally:
    type: item
    display name: <&f>Rally
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9231
    flags:
        ultimate: ov_brigitte
        ability: true

ov_brigitte_pack:
    type: task
    debug: false
    definitions: target
    script:
        # - define beam <player.eye_location.right[0.4].below[0.3].points_between[<[target].location.above[0.3].random_offset[0.5]>].distance[0.3]>

        # - foreach <[beam]> as:p:
        #     - playeffect effect:redstone at:<[p]> offset:0.05 quantity:2 special_data:0.4|#ffee00

        #     - if <[loop_index].mod[2]> == 0:
        #         - wait 1t

        - define for 1
        - define p <player.eye_location.right[0.4].below[0.3]>
        - while <[p].distance[<[target].location>].if_null[0]> > 0.9:
            # - narrate <[p].distance[<[target].location>]>
            - define beam <[p].points_between[<[target].location.above[1].random_offset[0.5]>].distance[0.3]>
            - if <[for]> > <[beam].size>:
                - define for <[beam].size>
            - define p <[beam].get[<[for]>]>
            - playeffect effect:redstone at:<[p]> offset:0.1 quantity:3 special_data:0.7|#ffee00
            - define for <[for].add[1]>
            - wait 1t
        - flag <[target]> ov.match.data.health:+:25
        - run ov_brigitte_heal def:<[target]>
        - repeat 40:
            - define beam <[p].points_between[<[target].location.above[1].random_offset[0.5]>].distance[0.3]>
            - if <[for]> > <[beam].size>:
                - define for <[beam].size>
            - define p <[beam].get[<[for]>]>
            - playeffect effect:redstone at:<[p]> offset:0.15 quantity:5 special_data:0.7|#ffee00
            - define for <[for].add[1]>
            - wait 1t



ov_brigitte_heal:
    type: task
    debug: false
    definitions: target
    script:
        - repeat 2:
            - flag <[target]> ov.match.data.health:+:100
            - wait 1s