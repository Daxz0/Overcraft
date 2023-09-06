spawn_test_dummy:
    type: task
    debug: false
    script:
        - spawn iron_golem save:dummy
        - spawn text_display save:t_d
        - adjust <entry[dummy].spawned_entity> has_ai:false
        - adjust <entry[dummy].spawned_entity> max_health:900
        - adjust <entry[dummy].spawned_entity> health:900
        - teleport <entry[t_d].spawned_entity> <entry[dummy].spawned_entity.location.up[3]>
        - define text "Secondly damage: 0"
        - adjust <entry[t_d].spawned_entity> text:<[text]>
        - flag <entry[dummy].spawned_entity> ov.dummy:true
        - flag <entry[dummy].spawned_entity> ov.dummy.dmg:0
        - heal <entry[dummy].spawned_entity>
        - repeat 10:
            - define text "Secondly damage: <entry[dummy].spawned_entity.flag[ov.dummy.dmg].div[3].round_down_to_precision[4]>"
            - adjust <entry[t_d].spawned_entity> text:<[text]>
            - flag <entry[dummy].spawned_entity> ov.dummy.dmg:0
            - wait 3s
        - kill <entry[dummy].spawned_entity>
        - remove <entry[t_d].spawned_entity>

test_dummy_handler:
    type: world
    debug: false
    events:
        on entity damaged:
            - if <context.entity.has_flag[ov.dummy]>:
                - narrate "Ouch! <context.damage> damage!"
                - narrate <context.entity.flag[ov.dummy.dmg].add[<context.damage>]>
                - flag <context.entity> ov.dummy.dmg:<context.entity.flag[ov.dummy.dmg].add[<context.damage>]>
                - narrate <context.entity.flag[ov.dummy.dmg].add[<context.damage>]>
        on player right clicks entity:
            - if <context.entity.has_flag[ov.dummy]>:
                - kill <context.entity>