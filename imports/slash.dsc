## MADE BY 0tick

ring_proc:
    type: procedure
    debug: false
    definitions: radius|points
    script:
    - define list <list>
    - define angles <list>
    - define i 0
    - define angle_interval <element[360].div[<[points]>]>
    - while <[i]> < 360:
        - define i:+:<[angle_interval]>
        - define angles:->:<[i]>

    - foreach <[angles]> as:angle:
        - definemap offsets:
                forward: <[radius].mul[<[angle].to_radians.cos>]>
                right: <[radius].mul[<[angle].to_radians.sin>]>
        - define list:->:<[offsets]>

    - determine <[list]>

slash_util_ring_proc:
    type: procedure
    debug: false
    definitions: radius|points
    script:
    - define list <list>
    - define angles <list>
    - define i 0
    - define angle_interval <element[360].div[<[points]>]>
    - while <[i]> < 360:
        - define i:+:<[angle_interval]>
        - define angles:->:<[i]>

    - foreach <[angles]> as:angle:
        - definemap offsets:
                forward: <[radius].mul[<[angle].to_radians.cos>]>
                right: <[radius].mul[<[angle].to_radians.sin>]>
        - define list:->:<[offsets]>

    - determine <[list]>

circlegen:
    type: procedure
    debug: false
    definitions: data
    script:
    - foreach location|radius|rotation|points|arc as:def:
        - define <[def]> <[data.<[def]>]>
    - foreach arc|points as:def:
        - if <[<[def]>]> < 0:
            - stop
    - if <[rotation]> < 0:
        - define <[rotation]> <element[180].add[<[rotation]>]>
    - define list <list>
    - define i <[arc].div[-2].add[90]>
    - while <[i]> <= <[arc].div[2].add[90]>:
        - define relative_horizontal_offset <[radius].mul[<[arc].div[2].sub[<[i]>].to_radians.sin>]>
        - define horizontal_offset <[relative_horizontal_offset].mul[<[rotation].to_radians.cos>]>
        - define forward_offset <[radius].mul[<[arc].div[2].sub[<[i]>].to_radians.cos>]>
        - define vertical_offset <[rotation].to_radians.sin.mul[<[relative_horizontal_offset]>]>
        - define list:->:<[location].forward[<[forward_offset]>].right[<[horizontal_offset]>].up[<[vertical_offset]>]>
        - define i:+:<[arc].div[<[points]>]>
    - determine <[list]>

slash_get_entities_in_locations_proc:
    type: procedure
    debug: false
    definitions: data
    script:
    - define locations <[data].proc[circlegen]>
    - define entities <list>
    - foreach <[locations]> as:location:
        - define entities:|:<[location].points_between[<player.location>].distance[0.2].parse_tag[<[parse_value].find.living_entities.within[1]>].combine>
    - determine <[entities].deduplicate>

tickcore_run_slash:
    type: task
    debug: false
    definitions: data|entity|color|speed|index|choice|damage
    script:
    - define locations <[data].proc[circlegen].parse[points_between[<[entity].location>].distance[0.15].get[1].to[3]].combine>
    - foreach <[locations]> as:a:
        - playeffect effect:redstone at:<[a]> quantity:15 offset:0 special_data:3|<[color]> visibility:10000
        - if <[choice]> == 1:
            - if <[loop_index].mod[<[speed]>]> == 0:
                - wait 1t
        - else:
            - wait <[speed]>

