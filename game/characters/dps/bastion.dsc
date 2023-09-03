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
        - stop if:<player.has_flag[ov.match.character.artillery]>
        - if <player.item_in_hand.script.name> == ov_bastion_recon:

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
        - stop if:<player.has_flag[ov.match.character.artillery]>
        - shoot snowball origin:<player.eye_location.right[0.3].forward[1]> destination:<player.eye_location.right[0.3].forward[2]> speed:2 shooter:<player> spread:0 save:grenade
        - run ov_bastion_bounce def.entity:<entry[grenade].shot_entity>

    ability_1:
        #reconfigure
        - stop if:<player.has_flag[ov.match.character.artillery]>
        - if !<player.has_flag[ov.match.character.configure]>:
            - inventory set slot:1 o:ov_bastion_assault
            - cast slow d:-1t amplifier:2 no_icon hide_particles
            - spawn silverfish[visible=false;invulnerable=true] <player.location> save:stand
            - flag <player> ov.match.character.configure:<entry[stand].spawned_entity>

            - mount <player>|<entry[stand].spawned_entity>
            - repeat 6 from:0:
                - bossbar auto <player.uuid>_configure players:<player> progress:<element[6].sub[<[value]>].div[6]> "title:<&f><&l><element[6].sub[<[value]>]><&f>/6 seconds" color:white
                - if !<player.has_flag[ov.match.character.configure]>:
                    - repeat stop
                - wait 1s

            - if <player.has_flag[ov.match.character.configure]>:
                - remove <player.flag[ov.match.character.configure]>
                - flag <player> ov.match.character.configure:!
                - inventory set slot:1 o:ov_bastion_recon
                - cast slow remove
                - bossbar remove <player.uuid>_configure

        - else:
            - bossbar remove <player.uuid>_configure
            - remove <player.flag[ov.match.character.configure]>
            - flag <player> ov.match.character.configure:!
            - inventory set slot:1 o:ov_bastion_recon
            - cast slow remove
    ultimate:
        #artillery
        - define loc <player.location>
        - create player <player.name> save:npc <[loc]>
        - cast invisibility d:8s <player> no_icon hide_particles
        - flag <player> ov.match.character.artillery
        - spawn armor_stand[gravity=false;visible=false] <[loc].above[3]> save:stand
        - mount <player>|<entry[stand].spawned_entity>
        - repeat 8 from:0:
            - bossbar auto <player.uuid>_artillery players:<player> progress:<element[8].sub[<[value]>].div[8]> "title:<&f><&l><element[8].sub[<[value]>]><&f>/8 seconds" color:white
            - if !<player.has_flag[ov.match.character.artillery]> || <player.flag[ov.match.character.artillery.count].if_null[0]> >= 3:
                - repeat stop
            - wait 1s
        - bossbar remove <player.uuid>_artillery
        - flag <player> ov.match.character.artillery:!
        - teleport <player> <[loc]>
        - cast invisibility remove
        - remove <entry[stand].spawned_entity>
        - remove <entry[npc].created_npc>


ov_bastion_handler:
    type: world
    debug: false
    events:
        on player steers entity flagged:ov.match.character.configure:
            - if <context.dismount>:
                - determine cancelled
            - define forward <context.forward>
            - define side <context.sideways.div[10]>
            - define stand <player.vehicle>
            - define location <player.vehicle.location.with_pitch[<[stand].location.pitch>].forward[<[forward].div[10]>].with_y[<player.vehicle.location.y>]>
            - if <[location].material.name> != air:
                - define location <[location].above[0.25]>
            - if <[side]> != 0:
                - define side <[side].mul[-1]>
                - define location <[location].right[<[side]>]>
            - teleport <player.vehicle> <[location].with_pitch[0].with_yaw[<player.location.yaw>]>
        on player steers entity flagged:ov.match.character.artillery:
            - if <player.flag[ov.match.character.artillery.count].if_null[0]> >= 3:
                - stop
            - if <context.dismount>:
                - determine cancelled
            - define forward <context.forward>
            - define side <context.sideways.div[2]>
            - define stand <player.vehicle>
            - define location <player.vehicle.location.with_pitch[<[stand].location.pitch>].forward[<[forward].div[2]>].with_y[<player.vehicle.location.y>]>
            - if <[side]> != 0:
                - define side <[side].mul[-1]>
                - define location <[location].right[<[side]>]>
            - define hit <player.vehicle.location.with_pitch[90].ray_trace[range=50].above[1.5].if_null[<player.vehicle.location>]>
            - define strike <player.eye_location.ray_trace[range=100]>
            - if !<player.has_flag[ov.match.character.artillery.cd]>:
                - playeffect effect:redstone at:<[strike].points_between[<[strike].above[5]>].distance[0.1]> special_data:0.8|#3474eb offset:0
                - playeffect effect:redstone at:<[strike].points_around_y[radius=2;points=25]> special_data:0.7|#70a2ff offset:0.1 quantity:10
                - playeffect effect:redstone at:<[strike].points_around_y[radius=3;points=35]> special_data:0.7|#70a2ff offset:0.1 quantity:10
                - playeffect effect:redstone at:<[strike].points_around_y[radius=5;points=55]> special_data:0.7|#70a2ff offset:0.1 quantity:10
                - flag <player> ov.match.character.artillery.cd:<[strike]> expire:5t
            - teleport <player.vehicle> <[location].with_pitch[0].with_yaw[<player.location.yaw>].with_y[<[hit].y.if_null[<player.vehicle.location.y>]>]>
        on player left clicks block flagged:ov.match.character.artillery.cd:
            - define strike <player.flag[ov.match.character.artillery.cd]>
            - flag <player> ov.match.character.artillery.count:++
            - repeat 10:
                - playeffect effect:redstone at:<[strike].points_between[<[strike].above[5]>].distance[0.1]> special_data:1.5|#3474eb offset:0 visibility:10000
                - playeffect effect:redstone at:<[strike].points_around_y[radius=2;points=25]> special_data:1.5|#144eba quantity:1 offset:0 visibility:10000
                - playeffect effect:redstone at:<[strike].points_around_y[radius=3;points=35]> special_data:1.5|#144eba quantity:1 offset:0 visibility:10000
                - playeffect effect:redstone at:<[strike].points_around_y[radius=5;points=55]> special_data:1.5|#144eba quantity:1 offset:0 visibility:10000
                - wait 0.13s
            - hurt 550 <[strike].find_entities[living].within[1]> source:<player>
            - hurt 200 <[strike].find_entities[living].within[3]> source:<player>
            - hurt 30 <[strike].find_entities[living].within[5]> source:<player>
        on player damaged flagged:ov.match.character.artillery:
            - determine passively cancelled



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
        firerate: 0.2

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
        primary: ov_bastion

        maxDamage: 12
        minDamage: 3.6
        firerate: 0.08

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