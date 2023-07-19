ov_health_handler:
    type: world
    debug: false
    events:
        on player damaged flagged:ov.match:
            - determine passively cancelled

            - define dmg <context.damage>
            - define player <context.entity>
            - define hp <[player].flag[ov.match.data.health]>
            - define mhp <[player].flag[ov.match.data.maxhealth]>
            - flag <[player]> ov.match.data.health:-:<[dmg]>

            - run ov_health_handler.hurt_sound
            - run ov_health_handler.hurt_overlay

        on player damages entity:
            - define target <context.entity>
            - define hp <[target].flag[ov.match.data.health].if_null[<[target].health>].round>
            - define mhp <[target].flag[ov.match.data.maxhealth].if_null[<[target].health_max>].round>

            - definemap progressbar:
                element: "❚"
                color: <&c>
                barColor: <gray>
                size: <[mhp].div[10]>
                currentValue: <[hp]>
                maxValue: <[mhp]>

            - if !<[target].has_flag[ov.match.displayed]>:
                - spawn text_display[text=<[progressbar].proc[progressbar]>;pivot=center] <[target].eye_location.above[0.8]> save:text
                - attach <entry[text].spawned_entity> to:<[target]>
                - flag <[target]> ov.match.displayed:<entry[text].spawned_entity>
            - else:
                - adjust <[target].flag[ov.match.displayed]> text:<[progressbar].proc[progressbar]>

            - repeat 25:
                - if !<[target].is_spawned> && <[target].flag[ov.match.displayed].is_spawned>:
                    - remove <[target].flag[ov.match.displayed]>
                    - if <[target].is_player>:
                        - flag <[target]> ov.match.displayed:!
                    - stop

                - wait 5t

            - if <[target].has_flag[ov.match.displayed]>:
                - remove <[target].flag[ov.match.displayed]>
                - flag <[target]> ov.match.displayed:!


    hurt_overlay:
        - worldborder <player> warningdistance:<util.int_max.div[50]>
        - wait 5t
        - worldborder <player> warningdistance:0

    hurt_sound:
        - ratelimit <player> 1s
        - playsound sound:entity_player_hurt <player.location>

    low_hp:
        - ratelimit <player> 30s
        - while <player.has_flag[ov.match.data.lowhp]>:
            - worldborder <player> warningdistance:<util.int_max.div[15]>
            - playsound sound:entity_warden_heartbeat <player>
            - wait 1s
            - playsound sound:entity_warden_heartbeat <player>
            - worldborder <player> warningdistance:<util.int_max.div[10]>
            - wait 2s
            - playsound sound:entity_warden_heartbeat <player>
            - worldborder <player> warningdistance:<util.int_max.div[15]>
            - wait 1s
            - playsound sound:entity_player_breath <player> pitch:0.8
            - wait 5t
            - worldborder <player> warningdistance:<util.int_max.div[10]>
            - repeat 10:
                - inject ov_health_handler.low_hp_check
                - playsound sound:entity_warden_heartbeat <player>
                - wait 10t
            - playsound sound:entity_player_breath <player> pitch:0.8
            - worldborder <player> warningdistance:<util.int_max>

            - repeat 10:
                - playsound sound:entity_warden_heartbeat <player>
                - wait 1s
        - worldborder <player> warningdistance:0
    low_hp_check:
        - if !<player.has_flag[ov.match.data.lowhp]>:
            - stop


ov_health_display:
    type: task
    debug: false
    script:

        - define hp <player.flag[ov.match.data.health].round>
        - define mhp <player.flag[ov.match.data.maxhealth].round>

        - definemap progressbar:
            element: "❚"
            color: <white>
            barColor: <gray>
            size: <[mhp].div[10]>
            currentValue: <[hp]>
            maxValue: <[mhp]>
        - actionbar "<&f><&l><[hp]> <&f>/ <[mhp]>    <[progressbar].proc[progressbar]>"

ov_health_regeneration:
    type: task
    debug: false
    script:
        - define hp <player.flag[ov.match.data.health]>
        - define mhp <player.flag[ov.match.data.maxhealth]>

        - define chrole <player.flag[ov.match.data.role].if_null[nulled]>


        - if <[hp]> > <[mhp]>:
            - flag <player> ov.match.data.health:<[mhp]>
        - if <[hp]> < 0:
            - flag <player> ov.match.data.health:0
        - if <[hp]> < <[mhp].div[5]> && <[hp]> > 0 && !<player.has_flag[ov.match.data.lowhp]>:
            - flag <player> ov.match.data.lowhp
            - run ov_health_handler.low_hp
        - else:
            - flag <player> ov.match.data.lowhp:!
        - if <[chrole]> == support && !<player.has_flag[ov.match.data.incombat]>:
            - flag <player> ov.match.health:+:20

