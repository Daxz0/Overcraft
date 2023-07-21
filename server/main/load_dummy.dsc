spawn_dummy:
    type: command
    name: dummy
    description: Spawns a dummy
    permissions: op
    usage: /dummy
    debug: false
    script:
        - spawn husk[has_ai=false] <server.flag[dummy_spot].center.above[0.5]> save:husk
        - adjust <entry[husk].spawned_entity> max_health:200
        - adjust <entry[husk].spawned_entity> health:200