spawn_test_dummy:
    type: task
    debug: false
    script:
        - spawn iron_golem[has_ai=false;max_health=1200;health=1200] <player.cursor_on_solid.up[2]> save:dummy
        - spawn text_display save:t_d
        - teleport <entry[t_d].spawned_entity> <entry[dummy].spawned_entity.location.up[3]>
        - define text "Secondly damage: 0"
        - adjust <entry[t_d].spawned_entity> text:<[text]>
        - flag <entry[dummy].spawned_entity> ov.dummy:true
        - flag <entry[dummy].spawned_entity> ov.dummy.dmg:0
        - heal <entry[dummy].spawned_entity>
        - repeat 20:
            - define text "Secondly damage: <entry[dummy].spawned_entity.flag[ov.dummy.dmg].div[3].round_down_to_precision[4]>"
            - adjust <entry[t_d].spawned_entity> text:<[text]>
            - flag <entry[dummy].spawned_entity> ov.dummy.dmg:0
            - wait 3s
        - remove <entry[dummy].spawned_entity> if:<entry[dummy].spawned_entity.is_spawned>
        - remove <entry[t_d].spawned_entity>

test_dummy_handler:
    type: world
    debug: false
    events:
        on entity_flagged:ov.dummy damaged:
            - flag <context.entity> ov.dummy.dmg:+:<context.damage>
        on player right clicks entity:
            - if <context.entity.has_flag[ov.dummy]>:
                - kill <context.entity>