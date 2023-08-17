#

ov_map_loader:
    type: world
    debug: false
    events:
        on server start:
            - createworld lijiang_gardens
            - createworld blizzard_world
            - createworld busan
            - createworld hub

        on player joins:
            - teleport <player> <world[hub].spawn_location>