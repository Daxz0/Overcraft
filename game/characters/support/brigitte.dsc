ov_brigitte_data:
    type: data

    name: Brigitte
    data_name: brigitte
    primary_fire: ov_brigitte_rocket_flail
    secondary_fire: ov_brigitte_shield


    ability_1: ov_brigitte_blink
    ability_2: ov_brigitte_recall
    ultimate: ov_brigitte_pulse_bomb

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
        - repeat 10:
            - define loc <player.location>
            - define val <[val].add[10]>
            - definemap data:
                location: <[loc].with_pitch[0].above[1].forward[<[val].div[40]>].right[3].left[<[value].div[25]>].with_yaw[<[loc].yaw.add[-<[val]>]>]>
                radius: 3
                rotation: <[value].mul[1.5]>
                points: 25
                arc: 180
            - define whip <[data].proc[circlegen].combine.reverse>
            - foreach <[whip]> as:point:
                - if <[loop_index]> > 10:
                    - playeffect effect:redstone special_data:0.8|<list[#454545|#000000|#5c5c5c].random> at:<[point]> offset:0
                    - hurt 35 <[point].find_entities[living].within[0.3]> source:<player>
            - playeffect effect:redstone special_data:0.6|<list[#454545|#000000|#5c5c5c].random> at:<[whip].last> offset:0.2 quantity:40
            - wait 0.01
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
            - define ent <[point].forward[1].find_entities[living].within[1].exclude[<player>|<player.flag[ov.match.character.shield.hitbox]>]>
            - if <[ent].any>:
                - foreach <[ent]> as:t:
                    - adjust <[t]> velocity:<[t].location.sub[<player.location.forward[1]>]>
                    - hurt 50 <[t]> source:<player>
            - if <[hit].above[0.5].material.is_solid>:
                - stop
            - teleport <[npc]> <[hit].with_pitch[0].with_yaw[<player.location.yaw>]> relative
            - if <[loop_index].mod[2]>:
                - wait 1t


    ability_2:
        #whip shot
        - define beam <player.eye_location.points_between[<player.eye_location.forward[15]>].distance[1]>
        - define beamC <player.eye_location.points_between[<player.eye_location.forward[15]>].distance[0.5]>


        - define hit <player.eye_location.ray_trace>


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
