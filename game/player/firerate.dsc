ov_firerate_handler:
    type: task
    debug: false
    definitions: rate|item
    script:
        - while <player.has_flag[ov.match.data.firing]>:

            - run <[item]>.primary_fire

            - if <[rate]> < 0.05:
                - if <[loop_index].mod[4]> == 0:
                    - wait <[rate]>
            - else:
                - wait <[rate]>
