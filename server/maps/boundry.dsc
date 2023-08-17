oc_prevent_fallout:
    type: world
    debug: false
    events:
        after player steps on block flagged:ov.match:
            - stop if:<player.gamemode.equals[creative]>
            - if <context.location.world.name> == overcraft_world && !<player.has_flag[ov.match.dead]>:

                - if <context.location.y> <= 92:
                    - kill <player>
        after player steers entity:
            - stop if:<player.gamemode.equals[creative]>
            - if <player.location.world.name> == overcraft_world && !<player.has_flag[ov.match.dead]>:

                - if <player.location.y> <= 92:
                    - kill <player>