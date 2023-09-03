ov_firerate_handler:
    type: task
    debug: false
    definitions: rate|item
    script:
        - while <player.has_flag[ov.match.data.firing]>:
            - if <player.has_flag[firing_cd]>:
                - while next
            - flag <player> firing_cd expire:<[rate]>
            - run <[item]>.primary_fire
            # - if <[rate]> < 0.05:
            #     - wait 0.05
            # - else:
            #     - wait <[rate]>
            # # - narrate <[loop_index]>
