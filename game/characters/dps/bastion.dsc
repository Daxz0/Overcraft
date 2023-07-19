ov_bastion_data:
    type: data

    name: Bastion
    data_name: bastion
    primary_fire: ov_bastion_recon

    ability_1: ov_bastion_assault
    ability_2: ov_bastion_grenade
    ultimate: ov_bastion_artillery

    ammo: 25

ov_bastion:
    type: task
    debug: false
    script:
        - define characterName bastion

    primary_fire:
        - ratelimit <player> 0.2

        - define loc <player.eye_location>

        - define spread 0
        - define range 50

        - define beam <proc[ov_bullet_spread_calc].context[<[range]>|<[spread]>|1]>

        - foreach <[beam]> as:b:

            - foreach <[b]> as:point:
                - define target <[point].find_entities[!item].within[0.3].exclude[<player>].if_null[null]>

                - if <[target].any>:
                    - define target <[target].first>
                    - define damage <proc[ov_damage_task].context[<[target]>|<[point]>|<item[ov_bastion_recon]>]>
                    - hurt <[damage]> <[target]> source:<player>
                    - foreach stop


            - playeffect effect:redstone offset:0 special_data:0.4|#d1d1d1 at:<[b]> visibility:10000


ov_bastion_recon:
    type: item
    display name: <&f>Recon
    material: iron_hoe
    mechanisms:
        hides: all

    flags:
        primary: ov_bastion

        maxDamage: 25
        minDamage: 7.5

        spread: 0

        maxDistance: 50
        minDistance: 30

        headshotMul: 2