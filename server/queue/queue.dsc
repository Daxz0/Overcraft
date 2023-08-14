ov_queue:
    type: command
    name: queue
    description: Queues you up for a game.
    usage: /queue
    debug: false
    script:


        - define queue <server.flag[ov.queue.main]>
        - if !<server.has_flag[ov.queue.main]>:
            - narrate "<&4>Uh Oh! The queue currently does not exist.. Contact developers."
            - stop
        - if <[queue].contains[<player>]>:
            - narrate "<&c>You<&sq>re already in the queue! Run <&l>/dequeue<&c> to leave the queue."
            - stop
        - flag server ov.queue.main:->:<player>
        - define queue <server.flag[ov.queue.main]>
        - if <[queue].size> > 3:
