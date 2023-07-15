oc_prevent_fallout:
    type: world
    debug: false
    events:
        after player steps on block:
            - stop if:<player.gamemode.equals[creative]>
            - if <context.location.world.name> == overcraft_world && !<player.has_flag[ov.match.dead]>:

                - if <context.location.y> <= 92:
                    - kill <player>