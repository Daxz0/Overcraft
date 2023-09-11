support_target:
    type: world
    debug: false
    definitions: __player
    events:
        on tick every:3:
            - foreach <server.players> as:__player:
                - if !<player.world.exists>:
                    - foreach next
                - if <player.flag[ov.match.enablesupporttarget].if_null[false]>:
                    - define target <player.eye_location.ray_trace_target[ignore=<player>;blocks=!<player.flag[ov.match.sptarget.ignoreblock].if_null[false]>]||null>
                    - if <[target]> != null:
                        - if <[target].entity_type> == snowball || <[target].entity_type> == arrow:
                            - stop
                        - adjust <[target]> glowing:true
                        - flag <player> ov.match.supporttarget:<[target]>
                    - else:
                        - flag <player> ov.match.supporttarget:!
                    - foreach <player.world.entities> as:entity:
                        - if !<[entity].equals[<[target]>]>:
                            - adjust <[entity]> glowing:false