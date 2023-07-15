ov_tracer_data:
    type: data

    name: Tracer
    primary_fire: ov_tracer_pistols

    ability_1: ov_tracer_blink
    ability_2: air
    ultimate: air

    ammo: 40

ov_tracer:
    type: task
    debug: false
    script:
        - define characterName Tracer

    primary_fire:

        # Hitscan

        - ratelimit <player> 0.048

        - define loc <player.eye_location>

        - define spread 3.6
        - define range 20

        - define beam <proc[ov_bullet_spread_calc].context[<[range]>|<[spread]>|4]>

        - foreach <[beam]> as:b:

            - foreach <[b]> as:point:
                - define target <[point].find_entities[!item].within[0.3].exclude[<player>].if_null[null]>

                - if <[target].any>:
                    - define target <[target].first>
                    - if <[target].has_flag[dynamite]>:
                        - run ov_ashe_dynamite_explode def:<[target].location>
                        - remove <[target]>
                        - foreach stop
                    - define damage <proc[ov_damage_task].context[<[target]>|<[point]>|<item[ov_tracer_pistols]>]>
                    - hurt <[damage]> <[target]> source:<player>
                    - foreach stop


            - playeffect effect:redstone offset:0 special_data:0.4|#d1d1d1 at:<[b]> visibility:10000

    ability_1:
        #blink
        - define hit <player.eye_location.with_pitch[0].ray_trace[range=7;fluids=false;nonsolids=true;return=block].if_null[null]>
        - if <[hit]> == null:
            - define hit <player.eye_location.forward_flat[7].with_pitch[90].ray_trace[range=20;fluids=true;nonsolids=false;return=block].above[1]>


        - define beam <player.eye_location.points_between[<[hit]>].distance[0.5]>
        # - adjust <player> velocity:<player.location.sub[<player.location.backward_flat[0.5]>]>

        - foreach <[beam]> as:point:
            - if <[point].material> matches *_slab || <[point].material> matches *_stair :
                - if <[loop_index]> <= 1:
                    - teleport <player> <[point].above[0.5]>
                - else:
                    - teleport <player> <[beam].get[<[loop_index].sub[3]>].above[0.5]>
                - stop
            - if <[point].material.is_solid>:
                - if <[loop_index]> <= 1:
                    - teleport <player> <[point].with_y[<[hit].y>]>
                - else:
                    - teleport <player> <[beam].get[<[loop_index].sub[3]>].with_y[<[hit].y>]>
                - stop
        - teleport <player> <[beam].get[<[beam].size.sub[3]>].with_y[<[hit].y>]>




ov_tracer_pistols:
    type: item
    display name: <&f>Pulse Pistols
    material: iron_hoe
    mechanisms:
        hides: all

    flags:
        primary: ov_tracer

        maxDamage: 5.5
        minDamage: 1.5

        spread: 3.6
        akimbo: true

        maxDistance: 20
        minDistance: 13

        headshotMul: 2

ov_tracer_blink:
    type: item
    display name: <&f>Blink
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9216
    flags:
        ability: true
        ability_1: ov_tracer