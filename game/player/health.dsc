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
            - define ohp <[player].flag[ov.match.data.ohp].if_null[0]>
            - define sh <[player].flag[ov.match.data.sh].if_null[0]>
            - define msh <[player].flag[ov.match.data.msh].if_null[0]>
            - define ar <[player].flag[ov.match.data.ar].if_null[0]>
            - define mar <[player].flag[ov.match.data.mar].if_null[0]>


            - if <[ar]> >= <[dmg]> && <[ar]> > 0:
                - flag <[player]> ov.match.data.ar:-:<[dmg]>
                - define dmg <[dmg].sub[<[dmg].mul[0.3]>]>

            - flag <[player]> ov.match.data.health:-:<[dmg]>

            - inject ov_health_handler.hurt_sound
            - inject ov_health_handler.hurt_overlay

        on player damages entity flagged:ov.match:
            - define target <context.entity>
            - define hp <[target].flag[ov.match.data.health].if_null[<[target].health>].round>
            - define mhp <[target].flag[ov.match.data.maxhealth].if_null[<[target].health_max>].round>
            - define ohp <[target].flag[ov.match.data.overhealth].if_null[0].round>

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
                - if !<[target].is_spawned> && <[target].flag[ov.match.displayed].is_spawned.if_null[false]>:
                    - remove <[target].flag[ov.match.displayed]>
                    - if <[target].is_player>:
                        - flag <[target]> ov.match.displayed:!
                    - stop

                - wait 5t

            - if <[target].has_flag[ov.match.displayed]> && <[target].flag[ov.match.displayed].is_spawned.if_null[false]>:
                - remove <[target].flag[ov.match.displayed]>
                - flag <[target]> ov.match.displayed:!


    hurt_overlay:
        - worldborder <[player]> warningdistance:<util.int_max.div[50]>
        - wait 5t
        - worldborder <[player]> warningdistance:0

    hurt_sound:
        - ratelimit <[player]> 1s
        - playsound sound:entity_player_hurt <[player].location>

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
            - worldborder <player> warningdistance:<util.int_max.div[10]>
            - repeat 10:
                - inject ov_health_handler.low_hp_check
                - playsound sound:entity_warden_heartbeat <player>
                - wait 10t
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


        #overhealth
        - define ohp <player.flag[ov.match.data.ohp].if_null[0]>

        #shield
        - define sh <player.flag[ov.match.data.sh].if_null[0]>
        - define msh <player.flag[ov.match.data.msh].if_null[0]>

        #armor??
        - define ar <player.flag[ov.match.data.ar].if_null[0]>

        - definemap progressbar:
            element: "❚"
            color: <white>
            barColor: <gray>
            size: <[mhp].div[10]>
            currentValue: <[hp]>
            maxValue: <[mhp]>

        - if <[ohp]> > 0:
            - definemap progressbar_ohp:
                element: "❚"
                color: <&a>
                barColor: <gray>
                size: <[ohp].div[10]>
                currentValue: <[ohp]>
                maxValue: <[ohp]>

        - if <[msh]> > 0:
            - definemap progressbar_sh:
                element: "❚"
                color: <&b>
                barColor: <gray>
                size: <[msh].div[10]>
                currentValue: <[sh]>
                maxValue: <[msh]>
        - if <[ar]> > 0:
            - definemap progressbar_ar:
                element: "❚"
                color: <&e>
                barColor: <gray>
                size: <[ar].div[10].if_null[0]>
                currentValue: <[ar]>
                maxValue: <[ar]>

        - actionbar "<&f><&l><[hp].add[<[ohp]>]> <&f>/ <[mhp]>    <[progressbar].proc[progressbar].if_null[<empty>]><[progressbar_ar].proc[progressbar].if_null[<empty>]><[progressbar_sh].proc[progressbar].if_null[<empty>]><[progressbar_ohp].proc[progressbar].if_null[<empty>]>"

ov_health_regeneration:
    type: task
    debug: false
    script:
        - define hp <player.flag[ov.match.data.health].round>
        - define mhp <player.flag[ov.match.data.maxhealth].round>
        - define ohp <player.flag[ov.match.data.ohp].if_null[0]>
        - define sh <player.flag[ov.match.data.sh].if_null[0]>
        - define msh <player.flag[ov.match.data.msh].if_null[0]>
        - define ar <player.flag[ov.match.data.ar].if_null[0]>

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

        - if <[msh]> > 0 && !<player.has_flag[ov.match.data.incombat]>:
            - if <[sh]> > <[msh]>:
                - flag <player> ov.match.data.shield:<[msh]>
            - if <[sh]> < 0:
                - flag <player> ov.match.data.shield:0
            - else:
                - flag <player> ov.match.data.sh:+:20

        - if <[chrole]> == support && !<player.has_flag[ov.match.data.incombat]>:
            - flag <player> ov.match.health:+:20

