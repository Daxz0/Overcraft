#ily max

ov_walk_direction:
    type: task
    debug: false
    script:
        - ratelimit <script[ov_walk_direction]> 1t
        - define p_loc <location[<player.location.xyz>]>
        - define p_yaw <player.location.yaw.to_radians>
        - define cross <[p_loc].rotate_around_y[<[p_yaw]>].proc[cross_product].context[<[prev_loc].with_y[<[p_loc].y>].rotate_around_y[<[p_yaw]>]>]>
        - define cross_z <[cross].z>
        - define cross_x <[cross].x>
        - define output default
        - if <[cross_z]> < -2:
            - define output right
        - if <[cross_x]> < -2:
            - define output forward
        - if <[cross_z]> > 2:
            - define output left
        - if <[cross_x]> > 2:
            - define output backward

cross_product:
    type: procedure
    debug: false
    definitions: a|b
    script:
    - determine <[a].with_x[<[a].y.mul[<[b].z>].sub[<[a].z.mul[<[b].y>]>]>].with_y[<[a].z.mul[<[b].x>].sub[<[a].x.mul[<[b].z>]>]>].with_z[<[a].x.mul[<[b].y>].sub[<[a].y.mul[<[b].x>]>]>]>