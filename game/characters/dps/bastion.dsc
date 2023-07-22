ov_bastion_data:
    type: data

    name: Bastion
    data_name: bastion
    primary_fire: ov_bastion_recon
    secondary_fire: ov_bastion_grenade

    ability_1: ov_bastion_reconfigure
    ultimate: ov_bastion_artillery

    ammo: 25

#TODO add damage resist 20%
ov_bastion:
    type: task
    debug: false
    script:
        - define characterName bastion

    primary_fire:
        - if <player.item_in_hand.script.name> == ov_bastion_recon:
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
        - if <player.item_in_hand.script.name> == ov_bastion_assault:
            #dont consume ammo
            - define loc <player.eye_location>

            - define spread 2
            - define range 50

            - define beam <proc[ov_bullet_spread_calc].context[<[range]>|<[spread]>|2]>

            - foreach <[beam]> as:b:

                - foreach <[b]> as:point:
                    - define target <[point].find_entities[!item].within[0.3].exclude[<player>].if_null[null]>

                    - if <[target].any>:
                        - define target <[target].first>
                        - define damage <proc[ov_damage_task].context[<[target]>|<[point]>|<item[ov_bastion_assault]>]>
                        - hurt <[damage]> <[target]> source:<player>
                        - foreach stop


                - playeffect effect:redstone offset:0 special_data:0.4|#d1d1d1 at:<[b]> visibility:10000
    secondary_fire:
        #grenade
        - shoot snowball origin:<player.eye_location.right[0.3].forward[1]> destination:<player.eye_location.right[0.3].forward[2]> speed:2 shooter:<player> spread:0 save:grenade
        - run ov_bastion_bounce def.entity:<entry[grenade].shot_entity>

    ability:1:
        #reconfigure
        - if !<player.has_flag[ov.match.character.configure]>:
            - inventory set slot:1 o:ov_bastion_assault
            - flag <player> ov.match.character.configure
            - cast slow d:-1t amplifier:1 no_icon hide_particles
        - else:
            - flag <player> ov.match.character.configure:!
            - inventory set slot:1 o:ov_bastion_recon
            - cast slow remove

ov_bastion_bounce:
    type: task
    debug: false
    definitions: entity|bounces
    script:
        - adjust <[entity]> item:ov_bastion_grenade
        - define location:<[entity].location>
        - while <[entity].is_truthy>:
            - define velocity:<[entity].velocity>
            - look <[entity]> <[location].add[<[velocity].mul[100]>]>
            - define location:<[entity].location>
            - wait 1t
            - playeffect effect:redstone at:<[location]> visibility:200 quantity:1 offset:0 special_data:0.8|#ffffff

        - if <[location].y> < -128:
            - stop

        - define bounces:++
        - if <[bounces]> >= 3 || <[location].find_entities[living].within[1].exclude[<player>].any>:
            - playeffect effect:explosion_large at:<[location]> visibility:200 quantity:20 offset:1.5
            - define targets <[location].find_entities[living].within[4]>
            - foreach <[targets]> as:target:
                - define distance <player.location.distance[<[location]>]>
                - if <[target]> == <player>:
                    - hurt <proc[ov_damage_falloff_calc].context[<[distance]>|4|0|50|15]> <[target]> source:<player>
                - else:
                    - hurt <proc[ov_damage_falloff_calc].context[<[distance]>|4|0|100|30]> <[target]> source:<player>
            - stop
        - playsound <[location]> sound:block_anvil_fall volume:1 pitch:1
        - playeffect effect:block_dust at:<[location]> visibility:100 offset:0.3 quantity:100 special_data:andesite

        - define hit <[location].backward[1].ray_trace[return=normal|raysize=0.5]||null>
        - define velocity_y <[velocity].y>

        - repeat 2 as:i:
            - repeat 2 as:j:
                - define hit:->:<[location].backward[1].rotate_pitch[<[i].mul[8].sub[12]>].rotate_yaw[<[j].mul[8].sub[12]>].ray_trace[return=normal]||null>
        - define hit <[hit].exclude[null]>
        - foreach <[hit]> as:i:
            - define list:->:<[hit].count[<[i]>]>
        - define highest:<[list].highest>


        - foreach <[list]> as:i:
            - if <[i]> == <[highest]>:
                - define hit:<[hit].get[<[i]>]>
                - foreach stop
            - else:
                - foreach next

        - if <[hit].x.abs> > 0:
            - define velocity <[velocity].rotate_around_z[180]>
            - define velocity <[velocity].with_y[<[velocity_y]>]>
            - define hit_location <[location].add[<[hit].mul[0.5]>]>
        - else if <[hit].z.abs> > 0:
            - define velocity <[velocity].rotate_around_x[180]>
            - define velocity <[velocity].with_y[<[velocity_y]>]>
            - define hit_location <[location].add[<[hit].mul[0.5]>]>
        - else if <[hit].y.abs> > 0:
            - define velocity <[velocity].with_y[<[velocity].y.mul[-1]>]>
            - define hit_location <[location]>

        - spawn snowball origin:<[hit_location]> save:grenade
        - define entity <entry[grenade].spawned_entity>
        - adjust <[entity]> velocity:<[velocity].mul[0.5]>
        - run ov_bastion_bounce def.entity:<[entity]> def.bounces:<[bounces]>
    ultimate:
        - create player <player.name> save:playerReplc
        - spawn <entry[playerReplc].created_npc> save:npc

        - flag <player> ov.match.character.artillery
        - cast invisibility <player> d:-1 no_icon hide_particles

ov_bastion_handler:
    type: world
    debug: false
    events:
        on player breaks block flagged:ov.match.character.artillery:
            - determine passively cancelled
        on player right clicks block flagged:ov.match.character.artillery:
            - determine passively cancelled
        on player damages entity flagged:ov.match.character.artillery:
            - determine passively cancelled

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

ov_bastion_assault:
    type: item
    display name: <&f>Assault
    material: iron_hoe
    mechanisms:
        hides: all

    flags:
        ability_1: ov_bastion

        maxDamage: 12
        minDamage: 3.6

        spread: 2

        maxDistance: 50
        minDistance: 30

        headshotMul: 2


ov_bastion_grenade:
    type: item
    display name: <&f>Tactical Grenade
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9220
    flags:
        ability: true
        secondary: ov_bastion

ov_bastion_reconfigure:
    type: item
    display name: <&f>Reconfigure
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9221
    flags:
        ability: true
        ability_1: ov_bastion

ov_bastion_artillery:
    type: item
    display name: <&f>Artillery
    material: copper_ingot
    mechanisms:
        hides: all
        custom_model_data: 9222
    flags:
        ability: true
        ultimate: ov_bastion