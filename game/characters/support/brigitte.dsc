ov_brigitte_data:
    type: data

    name: Brigitte
    data_name: brigitte
    primary_fire: ov_brigitte_rocket_flail


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
        - ratelimit <player> 0.6s
        - define val 15
        - define loc <player.location>
        - wait 1t
        - repeat 10:
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
                    - hurt 35 <[point].find_entities[living].within[0.3]>
            - playeffect effect:redstone special_data:0.6|<list[#454545|#000000|#5c5c5c].random> at:<[whip].last> offset:0.2 quantity:40
            - wait 0.01
    secondary:
        #shield


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
