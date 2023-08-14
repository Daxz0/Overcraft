camera:
    type: entity
    entity_type: armor_stand
    mechanisms:
        gravity: false
        visible: false

ov_death_handler:
    type: world
    debug: false
    events:
        on player dies flagged:ov.match:
            - determine passively cancelled
            - flag <player> ov.match.dead expire:5s
            - ~run ov_death_ragdoll
            - adjust <player> gamemode:adventure
            - teleport <player> <player.location.world.spawn_location>

ov_death_ragdoll:
    type: task
    debug: false
    script:
        - create player <player.name> save:createPlayer
        - spawn <entry[createPlayer].created_npc> save:ragdoll
        - flag <player> ov.match.corpse:<entry[ragdoll].spawned_entity> expire:5s

        - define vel <player.velocity.mul[10].with_y[<player.velocity.y>].xyz>
        - spawn camera <proc[ov_ragdoll_find_best]> save:cam
        - repeat 100:
            - if !<entry[ragdoll].spawned_entity.is_on_ground>:
                - adjust <entry[ragdoll].spawned_entity> velocity:<[vel]>
            - adjust <player> spectator_target:<entry[cam].spawned_entity>
            - sleep npc:<entry[ragdoll].spawned_entity>
            - teleport <entry[cam].spawned_entity> <proc[ov_ragdoll_find_best]>
            - wait 1t
        - adjust <player> spectator_target
        - flag <player> ov.match.corpse:!
        - remove <entry[ragdoll].spawned_entity>
        - remove <entry[cam].spawned_entity>


ov_ragdoll_find_best:
    type: procedure
    debug: false
    script:
        - define corpse <player.flag[ov.match.corpse]>
        - define circ <[corpse].location.above[1].points_around_y[radius=1;points=10]>

        - define best 0
        - define bestLoc 0
        - define bestBeam 0

        - foreach <[circ]> as:point:
            - define ray <[point].face[<[corpse].location.above[1]>].ray_trace[return=block;nonsolids=false;range=500].if_null[0]>
            - if <[ray].distance[<[point]>].if_null[0]> > <[best]>:
                - define best <[ray].distance[<[point]>]>
                - define bestLoc <[ray]>
                - define bestBeam <[point].points_between[<[bestLoc]>].distance[1]>
        - if <[bestBeam].size> < 5:
            - define final <[bestBeam].last.below[0.7].face[<[corpse].eye_location>]> save:cam
        - else:
            - define final <[bestBeam].get[5].below[0.7].face[<[corpse].eye_location>]> save:cam

        - determine <[final]>