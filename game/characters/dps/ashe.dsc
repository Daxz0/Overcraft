ov_ashe_data:
    type: data

    name: Ashe
    data_name: ashe
    primary_fire: ov_ashe_viper
    secondary_fire: ov_ashe_viper_ads

    ability_1: ov_ashe_dynamite
    ability_2: ov_ashe_coach_gun
    ultimate: ov_ashe_bob

    ammo: 12

ov_ashe:
    type: task
    debug: false
    script:
        - define characterName Ashe

    primary_fire:

        # Hitscan

        - ratelimit <player> 0.266

        - define loc <player.eye_location>

        - define spread 1.85
        - define range 40

        - define beam <proc[ov_bullet_spread_calc].context[<[range]>|<[spread]>|1]>

        - foreach <[beam]> as:b:

            - foreach <[b]> as:point:
                - define target <[point].find_entities[!item].within[0.3].exclude[<player>].if_null[null]>

                - if <[target].any>:
                    - define target <[target].first>
                    - if <[target].has_flag[dynamite]>:
                        - run ov_ashe_dynamite_explode def:<[target].location>
                        - remove <[target]>
                        - foreach stop
                    - define damage <proc[ov_damage_task].context[<[target]>|<[point]>|<item[ov_ashe_viper]>]>
                    - hurt <[damage]> <[target]> source:<player>
                    - foreach stop


            - playeffect effect:redstone offset:0 special_data:0.6|#d1d1d1 at:<[b]> visibility:10000 data:0

    secondary_fire:
        # Hitscan

        - ratelimit <player> 0.65

        - define loc <player.eye_location>

        - define spread 0
        - define range 50

        - define beam <proc[ov_bullet_spread_calc].context[<[range]>|<[spread]>|1]>

        - foreach <[beam]> as:b:

            - foreach <[b]> as:point:
                - define target <[point].find_entities[!item].within[0.3].exclude[<player>].if_null[null]>

                - if <[target].any>:
                    - define target <[target].first>
                    - if <[target].has_flag[dynamite]>:
                        - run ov_ashe_dynamite_explode def:<[target].location>
                        - remove <[target]>
                        - foreach stop
                    - define damage <proc[ov_damage_task].context[<[target]>|<[point]>|<item[ov_ashe_viper_ads]>]>
                    - hurt <[damage]> <[target]> source:<player>
                    - foreach stop


            - playeffect effect:redstone offset:0 special_data:0.6|#d1d1d1 at:<[b]> visibility:10000

    ability_1:
        #dynamite

        - define loc <player.eye_location>
        - define pitch <[loc].pitch>
        - define end_point_threshold 1.5
        - define control_point_threshold 0.7
        - define resolution 100
        - if <[pitch].abs> > 10:
            - define pitch 10
        - if <[pitch]> < 0:
            - define pitch 10
        - define start_point <location[0,0,0]>
        - define end_point <location[<[pitch].mul[<[end_point_threshold]>]>,0,0]>
        - define end_point_traced <location[<[loc].forward[<[pitch].mul[<[end_point_threshold]>]>].with_pitch[90].ray_trace[range=100;default=air].sub[<[loc].add[<[end_point]>]>].xyz>].with_x[<[pitch].mul[<[end_point_threshold]>]>].with_z[0]>
        - define control_point <location[<[pitch].mul[<[end_point_threshold]>].div[2]>,<[pitch].mul[<[control_point_threshold]>]>,0]>
        - define yaw_quat <location[0,1,0].to_axis_angle_quaternion[<[loc].yaw.add[90].to_radians.mul[-1]>]>
        - define points <[start_point].proc[quadratic_bezier_proc].context[<[control_point]>|<[end_point_traced]>|<[resolution]>|<[yaw_quat]>]>
        - spawn item_display[item=ov_ashe_dynamite;left_rotation=0,0,0.3,1;right_rotation=0,0,0.3,1] save:dynamite <player.location>
        - flag <entry[dynamite].spawned_entity> dynamite
        - foreach <[points]> as:point:
            - define point <[loc].add[<[point]>]>
            - teleport <entry[dynamite].spawned_entity> <[point]>
            - if <[point].find_blocks[!air].within[0.8].any>:
                - foreach stop
            - if <[loop_index].mod[<[points].size.div[25]>]> == 0:
                - wait 1t
        - wait 2s
        - if <entry[dynamite].spawned_entity.is_spawned>:
            - run ov_ashe_dynamite_explode def:<entry[dynamite].spawned_entity.location>
            - remove <entry[dynamite].spawned_entity>

    ability_2:
        #coach gun

        - inventory set slot:41 o:ov_ashe_coach_gun

        - wait 3t

        - adjust <player> velocity:<player.location.sub[<player.location.forward[1.125]>]>

        - define blast <player.location.above[0.8].left[0.2]>

        - define spread 4
        - define range 7

        - wait 2t

        - define beam <proc[ov_bullet_spread_calc].context[<[range]>|<[spread]>|5]>

        - foreach <[beam]> as:b:

            - foreach <[b]> as:point:
                - define target <[point].find_entities[!item].within[0.5].exclude[<player>].if_null[null]>

                - if <[target].any>:
                    - define target <[target].first>
                    - if <[target].has_flag[dynamite]>:
                        - run ov_ashe_dynamite_explode def:<[target].location>
                        - remove <[target]>
                        - foreach stop
                    - define damage <proc[ov_damage_task].context[<[target]>|<[point]>|<item[ov_ashe_coach_gun]>]>
                    - adjust <[target]> velocity:<[target].location.sub[<player.eye_location.backward[3]>].mul[0.5]>
                    - hurt <[damage]> <[target]> source:<player>
                    - foreach stop

            - playeffect effect:flame offset:0 data:0.03 at:<[b]> visibility:10000
        - wait 5t
        - inventory set slot:41 o:air


    ultimate:
        - define loc <player.location>
        - define hit <[loc].ray_trace[entities=*;range=500;ignore=<player>;fluids=true;nonsolids=true;return=block].if_null[null]>
        - spawn ov_bob <[loc]> save:bob
        - define bob <entry[bob].spawned_entity>
        - if <[hit]> == null:
            - adjust <[bob]> velocity:<[bob].location.sub[<player.location.backward_flat[1]>]>
            - adjust <[bob]> is_aware:false
            - stop
        - define beam <[bob].location.points_between[<[hit]>].distance[0.1]>
        - define vel <[bob].location.sub[<player.location.backward_flat[0.1]>].normalize>
        - foreach <[beam]> as:point:
            - if <[bob].location.above[2.1].find_blocks[!air].within[2].any>:
                - adjust <[bob]> is_aware:false
                - foreach stop
            - adjust <[bob]> velocity:<[vel].with_y[-0.1]>
            - define ent <[bob].location.find_entities.within[0.1].exclude[<player>|<[bob]>]>
            - if <[ent].any>:
                - adjust <[ent].first> velocity:<[bob].location.sub[<[bob].location.below[3]>].normalize>
                - hurt 120 <[ent].first>
                - adjust <[bob]> is_aware:false
                - foreach stop
            - wait 1t
        - adjust <[bob]> is_aware:false
        - run ov_remove_bob def:<[bob]>
        - while <[bob].is_spawned>:
            - define target <[bob].location.find_entities[living].within[40].exclude[<player>|<[bob]>|<server.flag[<player.flag[ov.match.team].if_null[<empty>]>].if_null[<empty>]>].first.if_null[null]>
            - adjust <[bob]> is_aware:false

            - if <[target]> == null:
                - while next

            - if <[target].is_spawned>:
                - if <[bob].can_see[<[target]>]>:
                    - look <[bob]> <[target].eye_location>
                    - define loc <[bob].eye_location>

                    - define spread 3
                    - define range 40

                    - define beam <proc[ov_bullet_spread_calc].context[<[range]>|<[spread]>|1|<[bob]>|<[bob].location.above[2].right[0.5]>]>

                    - foreach <[beam]> as:b:

                        - foreach <[b]> as:point:
                            - define ent <[point].find_entities[!item].within[0.3].exclude[<[bob]>].if_null[null]>

                            - if <[ent].any.if_null[false]> || <[ent].first.is_spawned.if_null[false]>:
                                - define ent <[ent].first>
                                - hurt 14 <[ent]> source:<player>
                                - foreach stop


                        - playeffect effect:redstone offset:0 special_data:0.6|#d1d1d1 at:<[b]> visibility:10000 data:0
            - wait 2t

ov_remove_bob:
    type: task
    debug: false
    definitions: bob
    script:
        - wait 10s
        - remove <[bob]>


ov_bob:
    type: entity
    entity_type: iron_golem
    debug: false
    mechanisms:
        max_health: 1000
        health: 1000

ov_ashe_dynamite_explode:
    type: task
    debug: false
    definitions: point
    script:
        - repeat 4:
            - wait 1t
            - define circ <location[0,0,0].points_around_x[radius=<[value]>;points=<[value].mul[8]>]>
            - define circls <list[]>
            - repeat 30:
                - define rotval <element[12].mul[<[value]>].to_radians>
                - define circls <[circls].include[<[circ].parse_tag[<[parse_value].rotate_around_y[<[rotval]>]>]>]>
            - define circls <[circls].parse_tag[<[point].relative[<[parse_value]>]>]>
            - foreach <[circls]> as:point:
                - if <util.random_chance[50]>:
                    - playeffect effect:redstone at:<[point]> offset:0.2 quantity:1 visibility:100 special_data:2|#fc3503
                - else:
                    - playeffect effect:redstone at:<[point]> offset:0.2 quantity:1 visibility:100 special_data:2|#fc9003
        - define targets <[point].find_entities[living].within[4]>

        - foreach <[targets]> as:target:
            - define distance <player.location.distance[<[point]>]>
            - if <[target]> == <player>:
                - hurt <proc[ov_damage_falloff_calc].context[<[distance]>|4|0|25|10]> <[target]> source:<player>
            - else:
                - hurt <proc[ov_damage_falloff_calc].context[<[distance]>|4|0|50|20]> <[target]> source:<player>
            - run ov_ashe_offthread_burn def:<[target]>

ov_ashe_offthread_knockback:
    type: task
    debug: false
    definitions: target
    script:
        - adjust <[target]> velocity:<[target].location.sub[<[target].location.forward_flat[2]>]>

ov_ashe_offthread_burn:
    type: task
    debug: false
    definitions: target
    script:
        - repeat 5:
            - hurt 20 <[target]> source:<player>
            - playsound <player.location> sound:block_campfire_crackle pitch:1.0
            - flag <player> ov.match.data.burning
            - wait 1s


ov_ashe_bob:
    type: item
    display name: <&f>Bob
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9214
    flags:
        ability: true
        ultimate: ov_ashe


ov_ashe_dynamite:
    type: item
    display name: <&f>Dynamite
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9212
    flags:
        ability: true
        ability_1: ov_ashe

ov_ashe_coach_gun:
    type: item
    display name: <&f>Coach Gun
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9213
    flags:
        ability: true
        ability_2: ov_ashe

        maxDamage: 6
        minDamage: 6

        spread: 4

        maxDistance: 5
        minDistance: 1

        headshotMul: 1




ov_ashe_viper:
    type: item
    display name: <&f>The Viper
    material: wooden_hoe
    mechanisms:
        hides: all

    flags:
        primary: ov_ashe

        maxDamage: 40
        minDamage: 12
        firerate: 0.266

        spread: 1.85

        maxDistance: 40
        minDistance: 20

        headshotMul: 2

ov_ashe_viper_ads:
    type: item
    display name: <&f>The Viper (ADS)
    material: wooden_hoe
    mechanisms:
        hides: all

    flags:
        secondary: ov_ashe
        scope: -0.9
        scopeTime: 1.092

        maxDamage: 75
        minDamage: 22.5

        spread: 0

        maxDistance: 50
        minDistance: 30

        headshotMul: 2