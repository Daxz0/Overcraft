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
            - run ov_sojourn_primary_fire
            - wait 2t

    secondary_fire:
        # Single blast
        - if <player.flag[ov.match.character.charge].if_null[0]> > 0:
            - define hand_pos <player.eye_location.below[0.2]>
            - define hit <[hand_pos].ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air].above[0.2].right[0.4]||null>
            - if <[hit]> != null:
                - foreach <[hand_pos].points_between[<[hit]>].distance[0.9]> as:point:
                    - playeffect effect:redstone offset:0 special_data:0.4|#00bbee at:<[point]>
                    - definemap data:
                        location: <[point].with_pitch[<player.location.pitch.add[90]>].with_yaw[<player.location.yaw>]>
                        radius: 0.5
                        rotation: 0
                        points: 10
                        arc: 360
                    - define locations:->:<[data].proc[circlegen].parse[points_between[<player.location>].distance[0.15].get[1].to[3]].combine.reverse>
                    - foreach <[locations]> as:point:
                        - playeffect effect:redstone offset:0 special_data:0.6|#00aadd visibility:10000 at:<[point]>
                    - define locations <[point]>
                    - if <[loop_index].mod[5]> == 0:
                        - wait 1t
                - define target <[hit].find_entities[living].within[1].exclude[<player>].if_null[null]>
                - hurt <player.flag[ov.match.character.charge].add[30]> <[target]> source:player
                - flag <player> ov.match.character.charge:0
                - run ov_sojourn_railgun_display
            - if <player.has_flag[ov.match.character.overclocked]>:
                - wait 0.75s
                - flag <player> ov.match.character.charge:100
                - run ov_sojourn_railgun_display

    ability_1:
        # Powerslide
        - create silverfish[visible=false] <empty> <player.location> save:powerslide_stand
        - create player <player.name> save:playerNPC <player.location>
        - invisible <entry[powerslide_stand].created_npc> true
        - adjust <entry[powerslide_stand].created_npc> has_friction:false
        - flag <player> ov.match.character.slide.queue:<queue>
        - flag <player> ov.match.character.jumpnpc:<entry[powerslide_stand].created_npc>
        - flag <player> ov.match.character.slidenpc:<entry[playerNPC].created_npc>
        - define entry <player.location>
        - flag <player> ov.match.character.jumpused:<[entry]>
        - wait 1t
        - if <[entry].distance[<player.location>]> < 0.2:
            - adjust <entry[powerslide_stand].created_npc> velocity:<player.eye_location.with_pitch[0].direction.vector.mul[1.01]>
        - else:
            - adjust <entry[powerslide_stand].created_npc> velocity:<player.location.sub[<[entry]>].mul[3]>
        - mount <player>|<entry[powerslide_stand].created_npc>
        - cast invisibility <player> d:10s no_icon hide_particles
        - run ov_sojourn_jump_detection
        - wait 16t
        - define player_location <player.location.add[0,0.2,0]>
        - wait 3t
        - define npc_velocity <entry[powerslide_stand].created_npc.velocity>
        - mount cancel <player>
        - if <player.flag[ov.match.character.jumpused].if_null[false]>:
            - adjust <player> velocity:<[npc_velocity]>
        - else:
            - teleport <player> <[player_location]>
        - flag <player> ov.match.character.jumpused:!
        - flag <player> ov.match.character.slide.queue:!
        - flag <player> ov.match.character.jumpnpc:!
        - remove <player.flag[ov.match.character.slidenpc]>
        - remove <entry[powerslide_stand].created_npc>
        - cast invisibility <player> remove

    ability_2:
        # Disruptor
        - define start_point <player.eye_location.forward_flat[0.3]>
        - define end_point <[start_point].ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air]||null>
        - spawn snowball[item=ov_sojourn_disruptor_model] save:disruptor <[start_point]>
        - flag <entry[disruptor].spawned_entity> disruptor
        - ~push <entry[disruptor].spawned_entity> origin:<[start_point]> destination:<[end_point]> no_rotate
        - run ov_sojourn_disruptor_break def:<[end_point]>

    ultimate:
        # Overclock
        - flag <player> ov.match.character.overclocked
        - flag <player> ov.match.character.charge:100
        - run ov_sojourn_railgun_display
        - wait 8s
        - flag <player> ov.match.character.overclocked:!
        - bossbar auto <player.uuid>_charge color:white

ov_sojourn_primary_fire:
    type: task
    debug: false
    script:
        - define hand_pos <player.eye_location.below[0.2].right[0.2]>
        - define hit <[hand_pos].ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air;range=80].above[0.2].right[0.4]||null>
        - if <[hit]> != null:
            - foreach <[hand_pos].points_between[<[hit]>].distance[1.2]> as:point:
                - playeffect effect:redstone offset:0 special_data:0.5|#00aaee at:<[point]>
                - define target <[point].find_entities[living].within[1].exclude[<player>].if_null[null]>
                - if <[target].any.if_null[false]>:
                    - flag <player> ov.match.character.charge:<player.flag[ov.match.character.charge].add[5].min[100].if_null[1]>
                    - hurt 9 <[target]> source:<player>
                - wait 1t
            - run ov_sojourn_railgun_display

ov_sojourn_jump_detection:
    type: task
    debug: false
    script:
        - while <player.has_flag[ov.match.character.jumpnpc].if_null[false]>:
            - teleport <player.flag[ov.match.character.slidenpc]> <player.flag[ov.match.character.jumpnpc].location>
            - look <player.flag[ov.match.character.slidenpc]> <player.eye_location.with_pitch[<player.flag[ov.match.character.jumpused].if_null[<player.location>].pitch>].with_yaw[<player.flag[ov.match.character.jumpused].if_null[<player.location>].yaw>].left[0.5]>
            - sleep npc:<player.flag[ov.match.character.slidenpc]>
            - if <player.eye_location.find_blocks[!air].within[0.5].any>:
                - queue <queue[<player.flag[ov.match.character.slide.queue]>]> stop
                - remove <player.flag[ov.match.character.jumpnpc]>
                - teleport <player> <player.location.below[1]>
                - flag <player> ov.match.character.jumpnpc:!
                - flag <player> ov.match.character.slide.queue:!
                - remove <player.flag[ov.match.character.slidenpc]>
                - stop
            - wait 1t
        - remove <player.flag[ov.match.character.slidenpc]>

ov_sojourn_powerslide_jump_handler:
    type: world
    debug: false
    events:
        on player steers entity:
            - if <context.jump>:
                - if <player.has_flag[ov.match.character.jumpused]>:
                    - adjust <player.flag[ov.match.character.jumpnpc]> velocity:<player.flag[ov.match.character.jumpnpc].velocity.add[0,0.8,0]>
                    - flag <player> ov.match.character.jumpused:!

ov_sojourn_railgun_display:
    type: task
    debug: false
    script:
        - if !<player.has_flag[ov.match.character.overclocked]>:
            - bossbar auto <player.uuid>_charge players:<player> progress:<player.flag[ov.match.character.charge].div[100]> title:<&f><&l><player.flag[ov.match.character.charge]><&f>/100 color:white
        - else:
            - bossbar auto <player.uuid>_charge players:<player> progress:<player.flag[ov.match.character.charge].div[100]> title:<&b><&l><player.flag[ov.match.character.charge]><&b>/100 color:blue

ov_sojourn_disruptor_break:
    type: task
    debug: false
    definitions: point
    script:
        - repeat 16:
            - define circ <location[0,0,0].points_around_x[radius=3;points=40]>
            - define circls <list[]>
            - repeat 30:
                - define rotval <element[12].mul[<[value]>].to_radians>
                - define circls <[circls].include[<[circ].parse_tag[<[parse_value].rotate_around_y[<[rotval]>]>]>]>
            - define circls <[circls].parse_tag[<[point].relative[<[parse_value]>]>]>
            - playeffect effect:redstone offset:0.1 special_data:1|#0000ff visibility:10000 at:<[circls]>
            - playeffect effect:sonic_boom at:<[point]> visibility:10000 offset:0.01
            #- cast slow duration:0.3s amplifier:2 <[orb].entities[player]>
            - hurt 13.125 <[point].find_entities[living].within[3]> source:<player>
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
        custom_model_data: 9227
    flags:
        ability: true
        ultimate: ov_sojourn

ov_sojourn_powerslide:
    type: item
    display name: <&f>Powerslide
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9224
    flags:
        ability: true
        ability_1: ov_sojourn


ov_sojourn_disruptor:
    type: item
    display name: <&f>Disruptor
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9225
    flags:
        ability: true
        ability_2: ov_sojourn

        maxDamage: 0
        minDamage: 0

        spread: 0

        maxDistance: 5
        minDistance: 1

        headshotMul: 1

ov_sojourn_disruptor_model:
    type: item
    display name: <&f>Disruptor
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9226