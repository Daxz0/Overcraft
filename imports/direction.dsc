ov_walk_direction:
    type: procedure
    debug: false
    script:
        - ratelimit <script[ov_walk_direction]> 1t
        - define p_loc <location[<player.location.xyz>]>
        - define p_yaw <player.location.yaw.to_radians>
        - define prev_loc <player.flag[prev_loc]||<[p_loc]>>
        - flag <player> prev_loc:<[p_loc]>
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
        - determine <[output]>

# ov_test:
#     type: world
#     debug: false
#     events:
#         after player walks:
#             - narrate <proc[ov_walk_direction]>