ov_tracer_data:
    type: data

    name: Tracer
    data_name: tracer
    primary_fire: ov_tracer_pistols

    akimbo: true

    ability_1: ov_tracer_blink
    ability_2: ov_tracer_recall
    ultimate: ov_tracer_pulse_bomb

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

        - define beam <proc[ov_bullet_spread_calc].context[<[range]>|<[spread]>|2]>

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
        - define prev_loc <player.location>
        - wait 1t
        - inject ov_walk_direction
        - choose <[output]>:
            - case forward:
                - define beam <player.eye_location.points_between[<player.eye_location.forward_flat[7]>].distance[0.5]>
                - foreach <[beam]> as:point:
                    - define hit <[point].with_y[<player.location.y>].above[2.5].with_pitch[90].ray_trace[range=200]>
                    - if <[point].above[1].material.is_solid>:
                        - stop
                    - teleport <player> <[hit].with_pitch[<player.location.pitch>].with_yaw[<player.location.yaw>]> relative
            - case left:
                - define beam <player.eye_location.points_between[<player.eye_location.left[7]>].distance[0.5]>
                - foreach <[beam]> as:point:
                    - define hit <[point].with_y[<player.location.y>].above[2.5].with_pitch[90].ray_trace[range=200]>
                    - if <[point].above[1].material.is_solid>:
                        - stop
                    - teleport <player> <[hit].with_pitch[<player.location.pitch>].with_yaw[<player.location.yaw>]> relative
            - case right:
                - define beam <player.eye_location.points_between[<player.eye_location.right[7]>].distance[0.5]>
                - foreach <[beam]> as:point:
                    - define hit <[point].with_y[<player.location.y>].above[2.5].with_pitch[90].ray_trace[range=200]>
                    - if <[point].above[1].material.is_solid>:
                        - stop
                    - teleport <player> <[hit].with_pitch[<player.location.pitch>].with_yaw[<player.location.yaw>]> relative
            - case backward:
                - define beam <player.eye_location.points_between[<player.eye_location.backward_flat[7]>].distance[0.5]>
                - foreach <[beam]> as:point:
                    - define hit <[point].with_y[<player.location.y>].above[2.5].with_pitch[90].ray_trace[range=200]>
                    - if <[point].above[1].material.is_solid>:
                        - stop
                    - teleport <player> <[hit].with_pitch[<player.location.pitch>].with_yaw[<player.location.yaw>]> relative

            - default:
                - define beam <player.eye_location.points_between[<player.eye_location.forward_flat[7]>].distance[0.5]>
                - foreach <[beam]> as:point:
                    - define hit <[point].with_y[<player.location.y>].above[2.5].with_pitch[90].ray_trace[range=200]>
                    - if <[point].above[1].material.is_solid>:
                        - stop
                    - teleport <player> <[hit].with_pitch[<player.location.pitch>].with_yaw[<player.location.yaw>]> relative

    ability_2:
        #recall
        - teleport <player> <player.flag[ov.match.character.recall.loc]>
        - flag <player> ov.match.data.health:<player.flag[ov.match.character.recall.hp]>
    ultimate:
        #pulse bomb
        - define loc <player.eye_location>
        - define pitch <[loc].pitch>
        - define end_point_threshold 1.5
        - define control_point_threshold 0.2
        - define resolution 100
        - define abs 5
        - if <[pitch].abs> > <[abs]>:
            - define pitch <[abs]>
        - if <[pitch]> < 0:
            - define pitch <[abs]>
        - define start_point <location[0,0,0]>
        - define end_point <location[<[pitch].mul[<[end_point_threshold]>]>,0,0]>
        - define end_point_traced <location[<[loc].forward[<[pitch].mul[<[end_point_threshold]>]>].with_pitch[90].ray_trace[range=100;default=air].sub[<[loc].add[<[end_point]>]>].xyz>].with_x[<[pitch].mul[<[end_point_threshold]>]>].with_z[0]>
        - define control_point <location[<[pitch].mul[<[end_point_threshold]>].div[2]>,<[pitch].mul[<[control_point_threshold]>]>,0]>
        - define yaw_quat <location[0,1,0].to_axis_angle_quaternion[<[loc].yaw.add[90].to_radians.mul[-1]>]>
        - define points <[start_point].proc[quadratic_bezier_proc].context[<[control_point]>|<[end_point_traced]>|<[resolution]>|<[yaw_quat]>]>
        - spawn item_display[item=ov_tracer_pulse_bomb;pivot=vertical;left_rotation=0.3,0.3,0.3,1] save:bomb <player.location>
        - foreach <[points]> as:point:
            - define point <[loc].add[<[point]>]>
            - teleport <entry[bomb].spawned_entity> <[point]>
            - if <[point].find_blocks[!air].within[0.8].any> || <[point].find_entities[living].within[0.1].exclude[<player>].any>:
                - define targets <[point].find_entities[living].within[3]>
                - repeat 3 as:index:
                    - definemap data:
                        location: <[point].with_pitch[<player.location.pitch.add[90]>].with_yaw[<player.location.yaw>]>
                        radius: <element[3].sub[<[index]>]>
                        rotation: 0
                        points: 360
                        arc: 360
                    - define locations:->:<[data].proc[circlegen].parse[points_between[<player.location>].distance[0.15].get[1].to[3]].combine.reverse>
                - definemap data:
                    location: <[point].with_pitch[<player.location.pitch.add[90]>].with_yaw[<player.location.yaw>]>
                    radius: 3
                    rotation: 0
                    points: 360
                    arc: 360
                - define locations:->:<[data].proc[circlegen].parse[points_between[<player.location>].distance[0.15].get[1].to[3]].combine.reverse>
                - remove <entry[bomb].spawned_entity>
                - foreach <[locations]> as:pointy:
                    - playeffect effect:redstone at:<[pointy]> offset:0.2 quantity:2 visibility:100 special_data:0.5|<list[#347deb|#69a5ff|#4f95ff].random>
                    - wait 0.2
                - foreach <[targets]> as:target:
                    - define distance <[target].location.distance[<[point]>]>
                    - if <[target]> == <player>:
                        - hurt <proc[ov_damage_falloff_calc].context[<[distance]>|3|0|175|35]> <[target]> source:<player>
                    - else:
                        - hurt <proc[ov_damage_falloff_calc].context[<[distance]>|3|0|350|70]> <[target]> source:<player>
                - foreach stop
            - if <[loop_index].mod[<[points].size.div[25]>]> == 0:
                - wait 1t


ov_tracer_recall_handler:
    type: world
    debug: false
    events:
        on delta time secondly every:3:
            - foreach <server.online_players_flagged[ov.match.character.name]> as:__player:
                - if <player.flag[ov.match.character.name]> == tracer:
                    - flag <player> ov.match.character.recall.loc:<player.location> expire:3s
                    - flag <player> ov.match.character.recall.hp:<player.flag[ov.match.data.health]> expire:3s



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

ov_tracer_recall:
    type: item
    display name: <&f>Recall
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9217
    flags:
        ability: true
        ability_2: ov_tracer

ov_tracer_pulse_bomb:
    type: item
    display name: <&f>Pulse Bomb
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9218
    flags:
        ability: true
        ultimate: ov_tracer
