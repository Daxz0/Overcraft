ov_junkrat_data:
    type: data

    name: Junkrat
    data_name: junkrat
    primary_fire: ov_junkrat_launcher
    secondary_fire: ov_junkrat_mine_activate

    ability_1: ov_ashe_dynamite
    ability_2: ov_ashe_coach_gun
    ultimate: ov_ashe_bob

    ammo: 12

ov_junkrat:
    type: task
    debug: false
    script:
        - define characterName Junkrat

    primary_fire:

        # Proj

        - define loc <player.eye_location>




ov_junkrat_launcher:
    type: item
    display name: <&f>Frag Launcher
    material: wooden_hoe
    mechanisms:
        hides: all

    flags:
        primary: ov_junkrat

        maxDamage: 80
        minDamage: 10
        firerate: 0.667

        spread: 0

        maxDistance: 0
        minDistance: 0

        headshotMul: 2