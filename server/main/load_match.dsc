ov_start_match:
    type: task
    debug: false
    definitions: health
    script:

        - flag <player> ov.match.playing
        - flag <player> ov.match.data.health:<[health]>
        - flag <player> ov.match.data.maxhealth:<[health]>

ov_end_match:
    type: task
    debug: false
    script:
        - flag <player> ov.match.playing:!
        - wait 1t
        - flag <player> ov.match!
        - actionbar " "