# ov_character_hotbar:
#     type: world
#     debug: false
#     events:


ov_weapon_handle:
    type: world
    debug: false
    events:
        on player right clicks block with:item_flagged:primary:
            - determine passively cancelled
            - run <context.item.flag[primary]>.primary_fire

        on player right clicks block with:item_flagged:secondary:
            - determine passively cancelled
            - if <player.has_flag[ov.match.data.scoped]>:
                - stop
            - run <context.item.flag[secondary]>.secondary_fire

        on player holds item item:item_flagged:ability:
            - define item <player.inventory.slot[<context.new_slot>]>
            - determine passively cancelled

            - if <[item].has_flag[ability_1]>:
                - run <[item].flag[ability_1]>.ability_1
            - if <[item].has_flag[ability_2]>:
                - run <[item].flag[ability_2]>.ability_2
            - if <[item].has_flag[ultimate]>:
                - run <[item].flag[ultimate]>.ultimate


        after player holds item item:item_flagged:scope:
            - adjust <player> fov_multiplier:<player.item_in_hand.flag[scope]>
            - flag <player> ov.match.data.scoped expire:<player.item_in_hand.flag[scopeTime]>
        on player holds item item:item_flagged:!scope:
            - adjust <player> fov_multiplier:0
        on player holds item item:item_flagged:akimbo:
            - inventory set o:<player.item_in_hand> slot:41
        on player holds item item:item_flagged:!akimbo:
            - inventory set o:air slot:41

        on player scrolls their hotbar:
            - define list <list[1|2|4|6|8]>
            - if !<[list].contains[<context.new_slot>]>:
                - determine passively cancelled

ov_cooldown:
    type: item
    display name: <&f>On Cooldown
    material: gray_stained_glass_pane
    mechanisms:
        hides: all

ov_cooldown_countdown:
    type: task
    debug: false
    definitions: slot|item|cooldown
    script:
        - inventory set slot:<[slot]> o:ov_cooldown
        - wait <[cooldown]>
        - inventory set slot:<[slot]> o:<[item]>




ov_damage_falloff_calc:
    type: procedure
    debug: false
    definitions: distance|max|min|high|low
    script:
        #min/max is for distance
        #low/high is for dmg

        - define normalize <[distance].sub[<[min]>].div[<[max].sub[<[min]>]>]>

        - define dmgCalc <[normalize].mul[<[low]>].add[<element[1].sub[<[normalize]>].mul[<[high]>]>].div[1.5].round>

        - if <[dmgCalc]> > <[high]>:
            - define dmgCalc <[high]>
        - else if <[dmgCalc]> < <[low]>:
            - define dmgCalc <[low]>

        - determine <[dmgCalc]>

ov_degree_to_radian:
    type: procedure
    debug: false
    definitions: degree
    script:
        - define radian <[degree].mul[<util.pi.div[180]>]>

        - determine <[radian]>

ov_bullet_spread_calc:
    type: procedure
    debug: false
    definitions: range|spread|num_segments|ent|otherLoc
    script:
        - if !<[ent].exists>:
            - define ent <player>
        - if !<[otherLoc].exists>:
            - define p_l <[ent].eye_location.forward[<[range]>]>
            - define p_l_e <[ent].eye_location.forward[1]>
        - else:
            - define p_l <[otherLoc].forward[<[range]>]>
            - define p_l_e <[otherLoc].forward[1]>

        - define spread_max <[spread]>
        - define spread_min 0.001
        - define angle_incr <util.pi.mul[2].div[<[num_segments]>]>
        - define yaw_quat <location[0,1,0].to_axis_angle_quaternion[<[p_l].yaw.add[180].to_radians.mul[-1]>]>
        - define pitch_quat <location[1,0,0].to_axis_angle_quaternion[<[p_l].pitch.mul[-1].to_radians>]>
        - define orient <[yaw_quat].mul[<[pitch_quat]>]>
        - repeat <[num_segments]>:
            - define p_l <[ent].eye_location.forward[<[range]>]>
            - define p_l_e <[ent].eye_location.forward[1]>
            - if <[otherLoc].exists>:
                - define p_l <[otherLoc].forward[<[range]>]>
                - define p_l_e <[otherLoc].forward[1]>
            - define base <util.random.decimal[<[spread_min]>].to[<[spread_max]>]>
            - define angle <util.random.decimal[<[num_segments].mul[-1]>].to[<[num_segments]>].mul[<[angle_incr]>]>
            - define x <[base].mul[<[angle].cos>]>
            - define y <[base].mul[<[angle].sin>]>
            - define vert <[p_l].add[<[orient].transform[<location[<[x]>,<[y]>,0]>]>]>
            - define list:->:<[vert].points_between[<[p_l_e]>].distance[0.1]>
        - determine <[list]>

ov_item_stats:
    type: task
    debug: false
    script:
        - define max <[item].flag[maxDistance]>
        - define min <[item].flag[minDistance]>
        - define high <[item].flag[maxDamage]>
        - define low <[item].flag[minDamage]>


ov_damage_task:
    type: procedure
    debug: false
    definitions: target|point|item
    script:
        #looks for <[point]>
        #target is well target
        #item is weapon
        - if !<[target].is_spawned>:
            - determine 0
        - define dist <player.location.distance[<[target].location>]>
        - inject ov_item_stats


        - if <[target].eye_location.y.sub[<[point].y>]> < 0.3:
            - define damage <proc[ov_damage_falloff_calc].context[<[dist]>|<[max]>|<[min]>|<[high]>|<[low]>].mul[2]>
        - else:
            - define damage <proc[ov_damage_falloff_calc].context[<[dist]>|<[max]>|<[min]>|<[high]>|<[low]>]>
        - determine <[damage]>


ov_character_hotbar_data:
    type: task
    debug: false
    script:
        - define primary_fire 1
        - define secondary_fire 2

        - define ability_1 4
        - define ability_2 6

        - define ultimate 8