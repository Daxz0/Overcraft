ov_actionbar_game:
    type: world
    debug: false
    events:

        on tick every:5:
            - foreach <server.online_players_flagged[ov.match.playing]> as:__player:
                - inject ov_health_regeneration
                - inject ov_health_display