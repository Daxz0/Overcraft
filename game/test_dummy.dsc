spawn_test_dummy:
    type: task
    debug: false
    script:
        - spawn iron_golem save:dummy
        - adjust <entry[dummy].spawned_entity> has_ai:false
        - adjust <entry[dummy].spawned_entity> max_health:900
        - adjust <entry[dummy].spawned_entity> health:900
        - flag <entry[dummy].spawned_entity> ov.dummy:true
        - flag <entry[dummy].spawned_entity> ov.dummy.dmg:0
        - wait 100s
        - kill <entry[dummy].spawned_entity>

test_dummy_handler:
    type: world
    debug: false
    events:
        on entity damaged:
            - if <context.entity.has_flag[ov.dummy]>:
                - narrate "Ouch! <context.damage> damage!"
                - narrate "Secondly damage: <context.entity.flag[ov.dummy.dmg]>"
                - flag <context.entity> ov.dummy.dmg:<context.entity.flag[ov.dummy.dmg].add[<context.damage>]>
                - wait 1s
                - flag <context.entity> ov.dummy.dmg:<context.entity.flag[ov.dummy.dmg].sub[<context.damage>]>