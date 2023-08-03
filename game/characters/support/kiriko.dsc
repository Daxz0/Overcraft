ov_kiriko_data:
    type: data

    name: Kiriko
    data_name: kiriko
    primary_fire: ov_kiriko_ofuda
    secondary_fire: ov_kiriko_kunai


    ability_1: ov_kiriko_suzu
    ability_2: ov_kiriko_swift_step
    ultimate: ov_kiriko_kitsune_rush

    ammo: 40

ov_kiriko:
    type: task
    debug: false
    script:
        - define characterName Kiriko

    primary_fire:
        #ofuda
        - ratelimit <player> 0.2s
        - repeat 2:
            - if 1 == 1:
                - flag player usingofuda:true expire:15s
                - playsound <player.location> <player> sound:entity_player_attack_nodamage volume:2
                - if <player.flag[ov.match.supporttarget].is_spawned.if_null[false]>:
                    - push snowball[item=paper] origin:<player.eye_location> speed:1.5 no_damage ignore_collision destination:<player.flag[ov.match.supporttarget].location.up[1]> no_rotate script:ov_kiriko_ofudacollide
                - else:
                    - push snowball[item=paper] origin:<player.eye_location> speed:1.5 no_rotate no_damage destination:<player.eye_location.ray_trace[entities=!snowball;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air]>
            - wait 0.2

    secondary_fire:
        #kunai (no bloom or falloff)
        - ratelimit <player> 0.55s
        - ~push arrow origin:<player.eye_location> speed:1.5 no_rotate no_damage destination:<player.eye_location.ray_trace[entities=*;ignore=<player>;fluids=true;nonsolids=true;return=precise;default=air]> save:kunai script:ov_kiriko_kunaicollide
        - remove <entry[kunai].pushed_entities>

    ability_1:
    #suzu


    ability_2:
    #swift step


ov_kiriko_ofudacollide:
    type: task
    debug: false
    script:
        - stop

ov_kiriko_kunaicollide:
    type: task
    debug: false
    script:
        - stop


ov_kiriko_handler:
    type: world
    debug: false
    events:
        on delta time secondly every:1:
            - foreach <server.online_players> as:__player:
                - if <player.flag[ov.match.character.name]> == kiriko:
                    - flag <player> ov.match.sptarget.enable:true
                    - flag <player> ov.match.sptarget.ignoreblock:true

ov_kiriko_ofuda:
    type: item
    display name: <&f>Ofuda
    material: paper
    mechanisms:
        hides: all

    flags:
        primary: ov_kiriko

ov_kiriko_kunai:
    type: item
    display name: <&f>Kunai
    material: arrow
    mechanisms:
        hides: all

    flags:
        secondary: ov_kiriko