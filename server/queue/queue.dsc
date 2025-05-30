ov_queue:
    type: command
    name: queue
    description: Queues you up for a game.
    usage: /queue
    debug: false
    script:
        - define queue <server.flag[ov.queue.main]>
        - define worlds <list[lijiang_gardens|blizzard_world|busan]>
        - if <[queue].contains[<player.uuid>]>:
            - narrate "<&c>You<&sq>re already in the queue! Run <&l>/dequeue<&c> to leave the queue."
            - stop
        - if <player.has_flag[party]>:
            - define party <player.flag[party]>
            - if <server.flag[ov_partys.<[party]>.owner]> != <player.uuid>:
                - narrate "<&c>You are not the party leader."
                - stop
            - foreach <server.flag[ov_partys.<[party]>.members]> as:p:
                - flag server ov.queue.main:->:<[p]>
            - flag <server.flag[ov_partys.<[party]>.members].parse_tag[<player[<[parse_value]>]>]> ov.queued
        - else:
            - flag server ov.queue.main:->:<player.uuid>
            - flag <player> ov.queued
        - define queue <server.flag[ov.queue.main]>
        # - announce to_console <[queue]>
        - if <[queue].size> >= 6:
            - define final full
            - foreach <[worlds].random> as:w:
                - if !<[w].has_flag[in_match].if_null[false]>:
                    - define final <[w]>
                    - foreach stop
            - if <[final]> == full:
                - stop
            - else:
                - define t1 <list>
                - define t2 <list>
                - define pl <list[<[t1]><[t2]>].combine>
                - foreach <[queue].parse_tag[<player[<[parse_value]>]>]> as:p:
                    - if <[t1].size> >= 3 && <[t2].size> >= 3:
                        # queue is complete, teams are created go from here
                        - define pl <list[<[t1]><[t2]>].combine>
                        - foreach stop
                    - else:
                        - if <[p].has_flag[party].if_null[false]>:
                            - define party <player.flag[party]>
                            - define party <server.flag[ov_partys.<[party]>.members].parse_tag[<player[<[parse_value]>]>]>
                            - define size <[party].size.if_null[<util.int_max>]>
                            - announce <[p].name>,<[size]>

                            # checking if adding party members to team will exceed the limit

                            - if <[t1].size.add[<[size]>]> <= 3:
                                - foreach <[party]> as:c:
                                    - if <[party].contains[<[c]>]>:
                                        - foreach next
                                    - define t1:->:<[c]>
                                    - flag server ov.queue.main:<-:<[c].uuid>
                            - else if <[t2].size.add[<[size]>]> <= 3:
                                - foreach <[party]> as:c:
                                    - if <[party].contains[<[c]>]>:
                                        - foreach next
                                    - define t2:->:<[c]>
                                    - flag server ov.queue.main:<-:<[c].uuid>
                        - else:
                            - if <[t1].size.add[1]> <= 3:
                                - define t1:->:<[p]>
                                - flag server ov.queue.main:<-:<[p].uuid>
                            - else if <[t2].size.add[1]> <= 3:
                                - define t2:->:<[p]>
                                - flag server ov.queue.main:<-:<[p].uuid>
                - define pl <list[<[t1]><[t2]>].combine>
                - if <[pl].size> < 6:
                    - stop
                - flag <[pl]> ov.queued:!
                - flag <world[<[final]>]> players:<[pl]>
                - title "title: <&f><&l>Match Found..." targets:<[pl]> stay:2s
                - wait 3s
                - teleport <[pl]> <world[<[final]>].spawn_location>

force_queue:
    type: task
    script:
        - foreach <server.online_players> as:__player:
            - execute queue as_player

ov_dequeue:
    type: command
    name: dequeue
    description: Queues you up for a game.
    usage: /dequeue
    debug: false
    script:
        - define queue <server.flag[ov.queue.main]>
        - if !<[queue].contains[<player.uuid>]>:
            - narrate "<&c>You<&sq>re not in the queue! Run <&l>/queue<&c> to join the queue."
            - stop
        - if <player.has_flag[party]>:
            - define party <player.flag[party]>
            - if <server.flag[ov_partys.<[party]>.owner]> != <player.uuid>:
                - narrate "<&c>You are not the party leader."
                - stop
            - foreach <server.flag[ov_partys.<[party]>.members]> as:p:
                - flag server ov.queue.main:<-:<[p]>
            - narrate "<&a>Your party has been removed from the queue!"
            - flag <server.flag[ov_partys.<[party]>.members].parse_tag[<player[<[parse_value]>]>]> ov.queued:!
        - else:
            - flag server ov.queue.main:<-:<player.uuid>
            - narrate "<&a>You have been removed from the queue!"
            - flag <player> ov.queued:!
        - define queue <server.flag[ov.queue.main]>
        # - announce to_console <[queue]>

ov_queue_timer:
    type: world
    debug: false
    events:
        on delta time secondly:
            - foreach <server.online_players_flagged[ov.queued]> as:__player:
                - flag <player> ov.queued:++
                - actionbar "<&9><&l>[  <&f><&l>Quick Play    <&a><duration[<player.flag[ov.queued]>].formatted><&9><&l>  ]"
        on player quits flagged:ov.queued priority:-10:
            - if <player.has_flag[party]>:
                - define party <player.flag[party]>
                - flag server ov.queue.main:<-:<server.flag[ov_partys.<[party]>.members].parse_tag[<player[<[parse_value]>]>]>
                - if <server.has_flag[ov_partys.<[party]>.members]>:
                    - flag <server.flag[ov_partys.<[party]>.members].parse_tag[<player[<[parse_value]>]>]> ov.queued:!
                    - narrate targets:<server.flag[ov_partys.<[party]>.members].parse_tag[<player[<[parse_value]>]>]> "<&e>Your whole party has been dequeued due to <player.name> disconnecting."
            - else:
                - flag server ov.queue.main:<-:<player.uuid>
                - flag <player> ov.queued:!
            - define queue <server.flag[ov.queue.main]>
            # - announce to_console <[queue]>