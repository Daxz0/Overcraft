ov_sojourn_data:
    type: data

    name: Sojourn
    data_name: sojourn
    primary_fire: ov_sojourn_railgun_rapid
    secondary_fire: ov_sojourn_railgun_blast

    ability_1: ov_sojourn_powerslide
    ability_2: ov_sojourn_disruptor
    ultimate: ov_sojourn_overclock

    ammo: 45

ov_sojourn:
    type: task
    debug: false
    script:
        - define characterName Sojourn

    primary_fire:
        # Hitscan
        - ratelimit <player> 0.071
        - repeat 3:
            - define hand_pos <player.eye_location.below[0.2].right[0.4]>
            - define hit <[hand_pos].ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air].above[0.2].right[0.4]||null>
            - if <[hit]> != null:
                - foreach <[hand_pos].points_between[<[hit]>].distance[0.9]> as:point:
                    - playeffect effect:redstone offset:0 special_data:0.4|#00aaee at:<[point]>
                - define target <[hit].find_entities[!item].within[1].exclude[<player>].if_null[null]>
                - if <[target].any>:
                    - flag <player> ov.match.character.charge:<player.flag[ov.match.character.charge].add[5].min[100]>
                    - hurt 9 <[target]> source:<player>
                - run ov_sojourn_railgun_display
            - wait 5t

    secondary_fire:
        # Single blast
        - if <player.flag[ov.match.character.charge]> > 0:
            - define hand_pos <player.eye_location.below[0.2].right[0.4]>
            - define hit <[hand_pos].ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air].above[0.2].right[0.4]||null>
            - if <[hit]> != null:
                - foreach <[hand_pos].points_between[<[hit]>].distance[0.9]> as:point:
                    - playeffect effect:redstone offset:0 special_data:0.4|#00bbee at:<[point]>
                    - playeffect effect:redstone offset:0 special_data:0.4|#00aadd visibility:10000 at:<[point].points_around_x[radius=0.5;points=50]>
                - define target <[hit].find_entities[!item].within[1].exclude[<player>].if_null[null]>
                - hurt <player.flag[ov.match.character.charge].add[30]> <[target]> source:player
                - flag <player> ov.match.character.charge:0
                - run ov_sojourn_railgun_display
            - if <player.flag[ov.match.character.overclocked]>:
                - wait 0.75s
                - flag <player> ov.match.character.charge:100
                - run ov_sojourn_railgun_display

    ability_1:
        # Powerslide
        - create silverfish[visible=false] powerslide_stand <player.location> save:powerslide_stand
        - create player <player.name> save:playerNPC
        - invisible <entry[powerslide_stand].created_npc> true
        - adjust <entry[powerslide_stand].created_npc> has_friction:false
        - flag <player> ov.match.character.jumpused:false
        - flag <player> ov.match.character.slide.queue:<queue>
        - flag <player> ov.match.character.jumpnpc:<entry[powerslide_stand].created_npc>
        - flag <player> ov.match.character.slidenpc:<entry[playerNPC].created_npc>
        - adjust <entry[powerslide_stand].created_npc> velocity:<player.eye_location.with_pitch[0].direction.vector.mul[1.01]>
        - mount <player>|<entry[powerslide_stand].created_npc>
        - cast invisibility <player> d:10s
        - run ov_sojourn_jump_detection
        - wait 16t
        - define player_location <player.location.add[0,0.2,0]>
        - wait 3t
        - define npc_velocity <entry[powerslide_stand].created_npc.velocity>
        - mount cancel <player>
        - remove <entry[powerslide_stand].created_npc>
        - if <player.flag[ov.match.character.jumpused]>:
            - adjust <player> velocity:<[npc_velocity]>
        - else:
            - teleport <player> <[player_location]>
        - flag <player> ov.match.character.jumpused:false
        - flag <player> ov.match.character.slide.queue:!
        - flag <player> ov.match.character.jumpnpc:!
        - cast invisibility <player> remove

    ability_2:
        # Disruptor
        - define start_point <player.eye_location.forward_flat[0.3]>
        - define end_point <[start_point].ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air]||null>
        - spawn snowball[item=ov_sojourn_disruptor] save:disruptor <[start_point]>
        - flag <entry[disruptor].spawned_entity> disruptor
        - ~push <entry[disruptor].spawned_entity> origin:<[start_point]> destination:<[end_point]> no_rotate
        - run ov_sojourn_disruptor_break def:<[end_point]>

    ultimate:
        # Overclock
        - flag <player> ov.match.character.overclocked:true
        - flag <player> ov.match.character.charge:100
        - run ov_sojourn_railgun_display
        - wait 8s
        - flag <player> ov.match.character.overclocked:false
        - bossbar auto <player.name>_charge color:white


ov_sojourn_jump_detection:
    type: task
    debug: false
    script:
        - while <player.has_flag[ov.match.character.jumpnpc].if_null[false]>:
            - teleport <player.flag[ov.match.character.slidenpc]> <player.flag[ov.match.character.jumpnpc].location>
            - look <player.flag[ov.match.character.slidenpc]> <player.eye_location.backward_flat[0.5]>
            - if <player.eye_location.find_blocks[!air].within[0.5].any>:
                - queue <queue[<player.flag[ov.match.character.slide.queue]>]> stop
                - remove <player.flag[ov.match.character.jumpnpc]>
                - teleport <player> <player.location.below[1]>
                - flag <player> ov.match.character.jumpnpc:!
                - flag <player> ov.match.character.slide.queue:!
                - stop
            - wait 1t

ov_sojourn_powerslide_jump_handler:
    type: world
    debug: false
    events:
        on player steers entity:
            - if <context.jump>:
                - if !<player.flag[ov.match.character.jumpused]>:
                    - adjust <player.flag[ov.match.character.jumpnpc]> velocity:<player.flag[ov.match.character.jumpnpc].velocity.with_pitch[0].mul[1.2].add[0,1.3,0]>
                    - flag <player> ov.match.character.jumpused:true

ov_sojourn_railgun_display:
    type: task
    debug: false
    script:
        - if <player.flag[ov.match.character.overclocked]> != true:
            - bossbar auto <player.name>_charge players:<player> progress:<player.flag[ov.match.character.charge].div[100]> title:RAILGUN color:white
        - else:
            - bossbar auto <player.name>_charge players:<player> progress:<player.flag[ov.match.character.charge].div[100]> title:RAILGUN color:blue

ov_sojourn_disruptor_break:
    type: task
    debug: false
    definitions: point
    script:
        - define orb <[point].to_ellipsoid[5,5,5]>
        - repeat 16:
            - playeffect effect:redstone offset:0 special_data:0.9|#0000ff visibility:10000 at:<[orb].shell>
            - playeffect effect:sonic_boom at:<[point]> visibility:10000
            #- cast slow duration:0.3s amplifier:2 <[orb].entities[player]>
            - hurt <[orb].entities[player]> cause:<player> 13.125
            - wait 0.25s

ov_sojourn_railgun_rapid:
    type: item
    display name: <&f>Railgun
    material: wooden_hoe
    mechanisms:
        hides: all

    flags:
        primary: ov_sojourn

        #TODO: adjust spread over time
        spread: 1

        #no falloff?
        maxDistance: 9999
        minDistance: 1

        maxDamage: 9
        minDamage: 9


        headshotMul: 2

ov_sojourn_railgun_blast:
    type: item
    display name: <&f>Railgun Alt Fire
    material: wooden_hoe
    mechanisms:
        hides: all

    flags:
        secondary: ov_sojourn
        ability: true

        spread: 0

        maxDistance: 60
        minDistance: 40

        maxDamage: 130
        minDamage: 30


        headshotMul: 1.5


ov_sojourn_overclock:
    type: item
    display name: <&f>Overclock
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9410
    flags:
        ability: true
        ultimate: ov_sojourn

ov_sojourn_powerslide:
    type: item
    display name: <&f>Powerslide
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9411
    flags:
        ability: true
        ability_1: ov_sojourn


ov_sojourn_disruptor:
    type: item
    display name: <&f>Disruptor
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9412
    flags:
        ability: true
        ability_2: ov_sojourn

        maxDamage: 0
        minDamage: 0

        spread: 0

        maxDistance: 5
        minDistance: 1

        headshotMul: 1