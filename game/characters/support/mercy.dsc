ov_mercy_data:
    type: data

    name: Mercy
    data_name: mercy
    primary_fire: ov_mercy_staff_heal
    secondary_fire: ov_mercy_staff_boost

    akimbo: true

    ability_1: ov_mercy_ga
    ability_2: ov_mercy_rez
    ultimate: ov_mercy_valkyrie

    ammo: 40

ov_mercy:
    type: task
    debug: false
    script:
        - define characterName Mercy

    primary_fire:
        #WIP

    ability_1:
        #WIP

    ability_2:
        #WIP
    
    ultimate:
        #WIP

ov_mercy_flightnpc_handler:
    type: world
    debug: false
    events:
        on delta time secondly every:3:
            - foreach <server.online_players_flagged[ov.match.character.name]> as:__player:
                - if <player.flag[ov.match.character.name]> == mercy:
                    - if !<player.has_flag[ov.match.character.flynpc].if_null[false]> || <player.flag[ov.match.character.flynpc]> == null:
                        - create silverfish[visible=false] fly_stand <player.location> save:fly_stand
                        - flag <player> ov.match.character.flynpc:<entry[fly_stand].created_npc>
                        - equip <entry[fly_stand].created_npc> saddle:saddle
                        - mount <player>|<entry[fly_stand].created_npc>
                    - if !<player.has_flag[ov.match.character.jumpheld].if_null[false]> || <player.flag[ov.match.character.jumpheld]> == null:
                        - flag <player> ov.match.character.jumpheld:false
                    - if !<player.flag[ov.match.character.jumpheld]>:
                        - cast slow_falling remove duration:1s <player.flag[ov.match.character.flynpc]>


ov_mercy_flight_handler:
    type: world
    debug: false
    events:
        on tick:
            - foreach <server.online_players_flagged[ov.match.character.name]> as:__player:
                - if <player.flag[ov.match.character.name]> == mercy:
                    - if <player.flag[ov.match.character.flynpc].is_on_ground>:
                        - cast slow_falling remove duration:1s <player.flag[ov.match.character.flynpc]>
        on player steers entity:
            - if <player.flag[ov.match.character.name]> == mercy:
                - if <context.jump>:
                    - flag <player> ov.match.character.jumpheld:true expire:2t
                    - if <player.flag[ov.match.character.flynpc].is_on_ground>:
                        - adjust <player.flag[ov.match.character.flynpc]> velocity:<player.flag[ov.match.character.flynpc].velocity.with_y[0.6]>
                    - else:
                        - cast slow_falling duration:1s <player.flag[ov.match.character.flynpc]>
                - else:
                    - cast slow_falling remove duration:1s <player.flag[ov.match.character.flynpc]>
                    - flag <player> ov.match.character.jumpheld:false
            #THANK YOU COLOSSAL
            - define velocity <location[0,0,0].with_pose[<player>].forward[<context.forward>].left[<context.sideways>].normalize>
            - define velocity <[velocity].mul[0.65].with_y[<player.flag[ov.match.character.flynpc].velocity.y>]>
            - adjust <player.flag[ov.match.character.flynpc]> velocity:<[velocity]>


        on player exits entity:
            - if <player.flag[ov.match.character.name]> == mercy:
                - remove <player.flag[ov.match.character.flynpc]>
                - flag <player> ov.match.character.flynpc:null

ov_mercy_staff:
    type: item
    display name: <&f>Caduceus Staff
    material: iron_hoe
    mechanisms:
        hides: all

    flags:
        primary: ov_mercy