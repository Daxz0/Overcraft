#

oc_map_loader:
    type: world
    debug: false
    events:
        on server start:
            - createworld overcraft_world

        on player joins:
            - teleport <player> <world[overcraft_world].spawn_location>