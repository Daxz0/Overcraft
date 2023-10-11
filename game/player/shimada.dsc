ow_shimada:
    type: world
    debug: false
    definitions: __player
    events:
        on player join:
            - if <player.flag[ov.match.character.name]> == kiriko:
                - adjust <player> send_climbable_materials:<server.vanilla_tagged_materials[climbable].include[<material[structure_void]>]>
        on player steps on block:
            - if <player.flag[ov.match.character.name]> == kiriko:
                - ratelimit <player> 1t
                - if <player.location.pitch> > 10:
                    # do not climb if not looking up
                    #TODO: don't require movement to check
                    - stop
                #TODO: DO NOT CLIMB STAIRS
                - if <context.new_location.forward_flat.material.is_solid> || <context.new_location.forward_flat.above.material.is_solid>:
                    - if <context.new_location.material.advanced_matches[*_slab]> || <context.new_location.material.advanced_matches[*_stairs]>:
                        - cast speed remove <player>
                        - stop
                    - define locs <list[<context.new_location>|<context.new_location.above>]>
                    - showfake <[locs]> structure_void d:8t
                - else:
                    - cast speed remove <player>