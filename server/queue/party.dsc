party_tabcompletion_arg2:
    type: procedure
    definitions: first_arg
    debug: false
    script:
    - choose <[first_arg]>:
        - case create:
            - determine <empty>
        - case disband:
            - determine <empty>
        - case leave:
            - determine <empty>
        - case invite:
            - if <player.has_flag[party]>:
                - define party <player.flag[party]>
                - if <server.flag[ov_partys.<[party]>.owner]> == <player.uuid>:
                    - determine <server.online_players.filter[has_flag[party].not].exclude[<player.uuid>].parse[name]>
                - else:
                    - determine <empty>
            - else:
                - determine <empty>
        - case kick:
            - if <player.has_flag[party]>:
                - define party <player.flag[party]>
                - if <server.flag[ov_partys.<[party]>.owner]> == <player.uuid>:
                    - determine <server.flag[ov_partys.<[party]>.members].exclude[<player.uuid>].parse[as[player].name]>
                - else:
                    - determine <empty>
            - else:
                - determine <empty>
        - case info:
            - if !<server.flag[ov_partys].keys.is_truthy>:
                - determine <empty>
            - else:
                - determine <server.flag[ov_partys].keys>
        - case chat:
            - determine <empty>
        - default:
            - determine <empty>

party:
    type: command
    name: party
    description: Manages partys.
    usage: /party create <&lt>name<&gt> | disband | leave | invite <&lt>player<&gt> | kick <&lt>player<&gt> | chat | info (name)
    permission: ov.party
    aliases:
        - p
    data:
        define_party:
        - define party <player.flag[party]>
        - if !<server.has_flag[ov_partys.<[party]>]>:
            - narrate "<&4>Uh Oh! Your party doesn't exist! This shouldn't happen.. Contact developers."
            - stop
    tab completions:
        1: create|disband|leave|invite|kick|chat|info
        2: <proc[party_tabcompletion_arg2].context[<context.args.first>]>
        3: <empty>
    debug: false
    script:
    - if <context.source_type> != player:
        - narrate "<&[error]>This command must be ran by a player!"
        - stop
    - if <context.args.is_empty>:
        - narrate <&[error]>Invalid<&sp>usage!
        - narrate <&[base]><script.parsed_key[usage]>
        - stop
    - choose <context.args.first>:
        - case create:
            - define list <context.args>
            - if <player.has_flag[party]>:
                - narrate "<&[error]>You're already in a party!"
                - stop
            - if <[list].size> < 2:
                - define list:->:<player.name><&sq>s<&sp>Party
            - if <[list].size> > 2:
                - narrate "<&[error]>Too many arguments! Did you forget <&7><&dq><&[error]>quotes<&7><&dq> <&[error]>around your party's name?"
                - stop
            - define party <[list].get[2].proc[trim_alphanumeric]>
            - if <server.has_flag[ov_partys.<[party]>]>:
                - narrate "<&[error]>This party already exists!"
                - stop
            - flag server ov_partys.<[party]>.owner:<player.uuid>
            - flag server ov_partys.<[party]>.members:->:<player.uuid>
            - flag server ov_partys.<[party]>.creation:<util.time_now>
            - flag <player> party:<[party]>
            - narrate "<&[emphasis]>The party <&dq><[party]><&dq> has been created!"
        - case disband:
            - if !<player.has_flag[party]>:
                - narrate "<&[error]>You're not in a party!"
                - stop
            - if <context.args.size> != 1:
                - narrate "<&[error]>Invalid usage!"
                - narrate "<&[error]>Usage<&co> /party disband"
                - stop
            - inject party.data.define_party
            - if <server.flag[ov_partys.<[party]>.owner]> != <player.uuid>:
                - narrate "<&[error]>You're not your party's owner!"
                - stop
            - narrate targets:<server.flag[ov_partys.<[party]>.members].parse[as[player]]> "<&[warning]>The party has been disbanded."
            - flag <server.flag[ov_partys.<[party]>.members].parse[as[player]]> party:!
            - flag server ov_partys.<[party]>:!
        - case invite:
            - if !<player.has_flag[party]>:
                - define party <element[<player.name><&sq>s<&sp>Party].proc[trim_alphanumeric]>
                - if <server.has_flag[ov_partys.<[party]>]>:
                    - narrate "<&[error]>This party already exists!"
                    - stop
                - flag server ov_partys.<[party]>.owner:<player.uuid>
                - flag server ov_partys.<[party]>.members:->:<player.uuid>
                - flag server ov_partys.<[party]>.creation:<util.time_now>
                - flag <player> party:<[party]>
            - if <context.args.size> < 2:
                - narrate "<&[error]>Too few arguments! You must provide a player's name!"
                - stop
            - if <context.args.size> > 2:
                - narrate "<&[error]>Too many arguments!"
                - narrate "<&[error]>Usage<&co> /party invite <&lt>player<&gt>"
                - stop
            - inject party.data.define_party
            - if <server.flag[ov_partys.<[party]>.owner]> != <player.uuid>:
                - narrate "<&[error]>You're not your party's owner!"
                - stop
            - if <server.flag[ov_partys.<[party]>.members].size> >= 3:
                - narrate "<&[error]>You're party is full!"
                - stop
            - define invited <server.match_player[<context.args.get[2]>].if_null[null]>
            - if <[invited]> == null || <[invited].name> != <context.args.get[2]>:
                - narrate "<&[error]>Player not found! Are you sure you typed their name correctly?"
                - stop
            - if <[invited].has_flag[party]>:
                - narrate "<&[error]>This player is already in a party!"
                - stop
            - clickable usages:1 save:accept_invite for:<[invited]> until:1m:
                - if <[invited].has_flag[partys_denied_invites]>:
                    - if <[invited].flag[partys_denied_invites]> contains <[party]>:
                        - narrate "<&[error]>You already denied this invite."
                        - stop
                - narrate "<&[emphasis]>Invite accepted." targets:<[invited]>
                - narrate "<&[emphasis]><[invited].name> accepted the invite to your party."
                - narrate targets:<server.flag[ov_partys.<[party]>.members].parse[as[player]]> "<&[emphasis]><[invited].name> has joined the party."
                - flag <[invited]> party:<[party]>
                - flag server ov_partys.<[party]>.members:->:<[invited].uuid>
                - flag <[invited]> partys_accepted_invites:->:<[party]> expire:1m
            - clickable usages:1 save:deny_invite for:<[invited]> until:1m:
                - if <[invited].has_flag[partys_accepted_invites]>:
                    - if <[invited].flag[partys_accepted_invites]> contains <[party]>:
                        - narrate "<&[error]>You already denied this invite."
                        - stop
                - narrate "<&[emphasis]>Invite denied." targets:<[invited]>
                - narrate "<&[emphasis]><[invited].name> denied the invite to your party."
                - flag <[invited]> partys_denied_invites:->:<[party]> expire:1m
            - narrate "<&[warning]><player.name> has invited you to join their party!" targets:<[invited]>
            - narrate <&sp.repeat[13]><&2><element[Accept].on_hover[Click here to accept the invite.].on_click[<entry[accept_invite].command>]><&sp.repeat[27]><&4><element[Deny].on_hover[Click here to deny the invite.].on_click[<entry[deny_invite].command>]> targets:<[invited]>
        - case kick:
            - if !<player.has_flag[party]>:
                - narrate "<&[error]>You're not in a party!"
                - stop
            - if <context.args.size> < 2:
                - narrate "<&[error]>Too few arguments! You must provide a player's name!"
                - stop
            - if <context.args.size> > 2:
                - narrate "<&[error]>Too many arguments!"
                - narrate "<&[error]>Usage<&co> /party kick <&lt>player<&gt>"
                - stop
            - inject party.data.define_party
            - if <server.flag[ov_partys.<[party]>.owner]> != <player.uuid>:
                - narrate "<&[error]>You're not the party's owner!"
                - stop
            - define kicked <server.match_player[<context.args.get[2]>].if_null[null]>
            - if <[kicked]> == null || <[kicked].name> != <context.args.get[2]>:
                - narrate "<&[error]>Player not found! Are you sure you typed their name correctly?"
                - stop
            - if <[kicked]> == <player>:
                - narrate "<&[error]>You cannot kick yourself from the party!"
                - narrate "<&[error]>Consider <&dq>/party disband<&dq> instead."
                - stop
            - flag <[kicked]> party:!
            - flag server ov_partys.<[party]>.members:<-:<[kicked].uuid>
            - narrate <server.flag[ov_partys.<[party]>.members].parse[as[player]]> "<&[warning]><[kicked].name> has been kicked from the party."
            - narrate targets:<[kicked]> "<&c>You have been kicked from the party."
        - case chat:
            - if !<player.has_flag[party]>:
                - narrate "<&[error]>You're not in a party!"
                - stop
            - if <context.args.size> == 1:
                - narrate "<&[error]>Your message cannot be empty!"
                - stop
            - inject party.data.define_party
            - narrate <context.raw_args.after[<context.args.first>]> format:party_chat_format targets:<server.flag[ov_partys.<[party]>.members]>
        - case info:
            - if !<player.has_flag[party]>:
                - narrate "<&[error]>You're not in a party!"
                - stop
            - if <context.args.size> > 2:
                - narrate "<&[error]>Too many arguments! Did you forget <&7><&dq><&[error]>quotes<&7><&dq> <&[error]>around the party's name?"
                - stop
            - if <context.args.size> == 1:
                - inject party.data.define_party
            - else:
                - define party <context.args.get[2]>
                - if !<server.has_flag[ov_partys.<[party]>]>:
                    - narrate "<&[error]>This party doesn't exist!"
                    - stop
            - define __party <server.flag[ov_partys.<[party]>]>
            - define owner <[__party.owner].as[player]>
            - define members <[__party.members].parse[as[player]]>
            - narrate "<&7><&m><&sp.repeat[12]>[<&f> <[party]> <&7><&m>]<&sp.repeat[12]>"
            - narrate "<&7>Leader<&co> <&f><[owner].name>"
            - narrate "<&7>Members<&co> <&f><[members].size.on_hover[<[members].parse[name].deduplicate.separated_by[<n>]>]>"
        - case leave:
            - if !<player.has_flag[party]>:
                - narrate "<&[error]>You're not in a party!"
                - stop
            - inject party.data.define_party
            - if !<player.has_flag[party]>:
                - narrate "<&[error]>You're not in a party!"
                - stop
            - if <server.flag[ov_partys.<[party]>.owner]> == <player.uuid>:
                - narrate targets:<server.flag[ov_partys.<[party]>.members].parse[as[player]]> "<&[warning]>The party has been disbanded."
                - flag <server.flag[ov_partys.<[party]>.members].parse[as[player]]> party:!
                - flag server ov_partys.<[party]>:!
            - else:
                - flag <player> party:!
                - narrate "<&[warning]><player.name> has left the party." targets:<server.flag[ov_partys.<[party]>.members].parse[as[player]]>
                - narrate "<&e>You have left the party."
                - flag server ov_partys.<[party]>.members:<-:<player.uuid>
        - default:
            - narrate <&[error]>Invalid<&sp>usage!
            - narrate <&[base]><script.parsed_key[usage]>
            - stop

party_chat_format:
    type: format
    debug: false
    format: <&7><&l><&lb><&f><player.flag[party]><&7><&l><&rb> <&f><player.name><&co><[text]>

trim_alphanumeric:
    type: procedure
    definitions: def
    debug: false
    script:
    - determine <[def].trim_to_character_set[AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz123456789_-<&sq><&dq> ]>

party_cancel_damage:
    type: world
    debug: false
    events:
        on player tries to attack player:
            - define user <context.entity>
            - if <[user].flag[party].if_null[null]> == <player.flag[party].if_null[false]>:
                - determine cancelled
party_offline:
    type: world
    debug: false
    events:
        on player quits flagged:party:
            - define party <player.flag[party]>
            - if <server.flag[ov_partys.<[party]>.owner]> == <player.uuid>:
                - flag <server.flag[ov_partys.<[party]>.members].parse[as[player]]> party:!
                - flag server ov_partys.<[party]>:!
                - if <server.has_flag[ov_partys.<[party]>.members]>:
                    - narrate "<&[warning]>The party has been disbanded due to leader disconnecting." targets:<server.flag[ov_partys.<[party]>.members].parse[as[player]]>
            - else:
                - flag <player> party:!
                - flag server ov_partys.<[party]>.members:<-:<player.uuid>
                - if <server.has_flag[ov_partys.<[party]>.members]>:
                    - narrate "<&[warning]><player.name> has been removed from the party." targets:<server.flag[ov_partys.<[party]>.members].parse[as[player]]>