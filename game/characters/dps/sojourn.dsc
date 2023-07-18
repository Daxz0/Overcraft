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
                    - flag <player> ov.sojourn.charge:<player.flag[ov.sojourn.charge].add[5].min[100]>
                    - hurt 9 <[target]> source:<player>
                - run ov_sojourn_railgun_display
            - wait 5t

    secondary_fire:
        # Single blast
        - if <player.flag[ov.sojourn.charge]> > 0:
            - define hand_pos <player.eye_location.below[0.2].right[0.4]>
            - define hit <[hand_pos].ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air].above[0.2].right[0.4]||null>
            - if <[hit]> != null:
                - foreach <[hand_pos].points_between[<[hit]>].distance[0.9]> as:point:
                    - playeffect effect:redstone offset:0 special_data:0.4|#00bbee at:<[point]>
                    - playeffect effect:redstone offset:0 special_data:0.4|#00aadd visibility:10000 at:<[point].points_around_x[radius=0.5;points=50]>
                - define target <[hit].find_entities[!item].within[1].exclude[<player>].if_null[null]>
                - hurt <player.flag[ov.sojourn.charge].add[30]> <[target]> source:player
                - flag <player> ov.sojourn.charge:0
                - run ov_sojourn_railgun_display

    ability_1:
        #WIP

    ability_2:
        # Disruptor
        - define start_point <player.eye_location>
        - define end_point <[start_point].ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air]||null>
        - spawn snowball[item=ov_sojourn_disruptor] save:disruptor <[start_point]>
        - flag <entry[disruptor].spawned_entity> disruptor
        - ~push <entry[disruptor].spawned_entity> origin:<[start_point]> destination:<[end_point]> no_rotate
        - run ov_sojourn_disruptor_break def:<[end_point]>

    ultimate:
        #WIP

ov_sojourn_railgun_display:
    type: task
    debug: false
    script:
        - bossbar auto <player.name>_charge players:<player> progress:<player.flag[ov.sojourn.charge].div[100]> title:RAILGUN

ov_sojourn_disruptor_break:
    type: task
    debug: false
    definitions: point
    script:
        - repeat 9:
            - playeffect effect:sonic_boom at:<[point]> visibility:10000

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
        custom_model_data: 9999
    flags:
        ability: true
        ultimate: ov_sojourn

ov_sojourn_powerslide:
    type: item
    display name: <&f>Powerslide
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9999
    flags:
        ability: true
        ability_1: ov_sojourn


ov_sojourn_disruptor:
    type: item
    display name: <&f>Disruptor
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9999
    flags:
        ability: true
        ability_2: ov_sojourn

        maxDamage: 0
        minDamage: 0

        spread: 0

        maxDistance: 5
        minDistance: 1

        headshotMul: 1