anti_third_person_item:
    type: item
    display name: <&f>
    material: iron_ingot
    mechanisms:
        hides: all
        custom_model_data: 222


anti_third_person_handler:
    type: task
    debug: false
    script:
        - define offset -0.12,0.6,0.1
        - define sneakOffset -0.12,0.5,0.1
        - define loc <player.eye_location.relative[<[offset]>]>
        - fakespawn item_display[item=anti_third_person_item;translation=<[offset]>;scale=3,3,3] <[loc]> save:display players:<player> d:-1
        - fakespawn item_display[item=anti_third_person_item;translation=<[offset]>;scale=2.3,2.3,2.3] <[loc]> save:display1 players:<player> d:-1
        - fakespawn item_display[item=anti_third_person_item;translation=<[offset]>;scale=1.5,1.5,1.5] <[loc]> save:display2 players:<player>
        - fakespawn item_display[item=anti_third_person_item;translation=<[offset]>;scale=1,1,3] <[loc]> save:display3 players:<player>
        - fakespawn item_display[item=anti_third_person_item;translation=<[offset]>;scale=0.6,0.6,0.6 <[loc]> save:display4 players:<player>
        - wait 1t
        - define display:->:<entry[display].faked_entity>
        - define display:->:<entry[display1].faked_entity>
        - define display:->:<entry[display2].faked_entity>
        - define display:->:<entry[display3].faked_entity>
        - define display:->:<entry[display4].faked_entity>
        - foreach <[display]> as:ent:
            - mount <[ent]>|<player>
            - look <[ent]> pitch:0 yaw:0
        - while <player.has_flag[ov.match.anti_third_person]>:
            - define yaw <player.location.yaw.add[0].to_radians>
            - define pitch <player.location.pitch.to_radians>
            - foreach <[display]> as:ent:
                - adjust <[ent]> interpolation_duration:<duration[1t]>
                - adjust <[ent]> interpolation_start:<duration[0t]>
            - if <player.is_sneaking>:
                - define translation <player.eye_location.relative[<[sneakOffset]>].sub[<player.eye_location>]>
            - else:
                - define translation <player.eye_location.relative[<[offset]>].sub[<player.eye_location>]>

            - define firstRotation <location[0,-1,0].to_axis_angle_quaternion[<[yaw]>]>
            - define secondRotation <location[1,0,0].to_axis_angle_quaternion[<[pitch]>]>
            - define finalRotation <[firstRotation].mul[<[secondRotation]>]>
            - foreach <[display]> as:ent:
                - adjust <[ent]> left_rotation:<[finalRotation]>
                - adjust <[ent]> translation:<[translation]>
            - wait 0.02t
        - remove <[display]>