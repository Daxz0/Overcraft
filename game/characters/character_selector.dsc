ov_character_selector_ui:
    type: inventory
    title: <&4><&o><&l>SELECT YOUR CHARACTER
    gui: true
    inventory: chest
    debug: false
    size: 54
    definitions:
        p: ui_pane
    slots:
        - [p] [p] [p] [p] [p] [p] [p] [p] [p]
        - [p] [p] [p] [p] [p] [p] [p] [p] [p]
        - [p] [p] [ov_tank_icon] [p] [ov_damage_icon] [p] [ov_support_icon] [p] [p]
        - [p] [p] [p] [p] [p] [p] [p] [p] [p]
        - [p] [p] [p] [p] [p] [p] [p] [p] [p]
        - [p] [p] [p] [p] [p] [p] [p] [p] [p]

ov_character_selector_ui_dps:
    type: inventory
    debug: false
    title: <&4><&o><&l>SELECT YOUR CHARACTER
    gui: true
    inventory: chest
    size: 54
    definitions:
        p: ui_pane
    procedural items:
        - define list <list[ashe|tracer|bastion|sojourn].alphabetical>
        - define determin <list>
        - foreach <[list]> as:item:
            - define determin:->:ov_<[item]>_icon
        - determine <[determin]>
    slots:
        - [p] [p] [p] [p] [p] [p] [p] [p] [p]
        - [p] [] [] [] [] [] [] [] [p]
        - [p] [] [] [] [] [] [] [] [p]
        - [p] [] [] [] [] [] [] [] [p]
        - [p] [] [] [] [] [] [] [] [p]
        - [p] [p] [p] [p] [p] [p] [p] [p] [p]

ov_character_selector_ui_support:
    type: inventory
    debug: false
    title: <&4><&o><&l>SELECT YOUR CHARACTER
    gui: true
    inventory: chest
    size: 54
    definitions:
        p: ui_pane
    procedural items:
        - define list <list[brigitte].alphabetical>
        - define determin <list>
        - foreach <[list]> as:item:
            - define determin:->:ov_<[item]>_icon
        - determine <[determin]>
    slots:
        - [p] [p] [p] [p] [p] [p] [p] [p] [p]
        - [p] [] [] [] [] [] [] [] [p]
        - [p] [] [] [] [] [] [] [] [p]
        - [p] [] [] [] [] [] [] [] [p]
        - [p] [] [] [] [] [] [] [] [p]
        - [p] [p] [p] [p] [p] [p] [p] [p] [p]

ov_character_selector_ui_handler:
    type: world
    debug: false
    events:
        on player clicks ov_*_icon in ov_character_selector_ui_*:
            - define data <script[<context.item.flag[data]>]>
            - flag <player> ov.match.character.name:<[data].data_key[data_name]>
            - define primary <[data].data_key[primary_fire].if_null[air]>
            - define secondary <[data].data_key[secondary_fire].if_null[air]>
            - define ability1 <[data].data_key[ability_1].if_null[air]>
            - define ability2 <[data].data_key[ability_2].if_null[air]>
            - define ult <[data].data_key[ultimate].if_null[air]>
            - define akimbo <[data].data_key[akimbo].if_true[<[primary]>].if_false[air].if_null[air]>

            - bossbar remove <player.uuid>_charge

            - inventory set o:<[primary]> slot:1
            - inventory set o:<[secondary]> slot:2
            - inventory set o:<[ability1]> slot:4
            - inventory set o:<[ability2]> slot:6
            - inventory set o:<[ult]> slot:8
            - inventory set o:<[akimbo]> slot:41


ov_tank_icon:
    type: item
    material: orange_stained_glass_pane
    display name: <&f><&l>TANK 🛡
    flags:
        click: tank

ov_support_icon:
    type: item
    material: orange_stained_glass_pane
    display name: <&f><&l>SUPPORT ➕
    flags:
        click: support

ov_damage_icon:
    type: item
    material: orange_stained_glass_pane
    display name: <&f><&l>DAMAGE ✐
    flags:
        click: dps


ov_ashe_icon:
    type: item
    material: light_blue_stained_glass_pane
    display name: <&f>Ashe
    flags:
        data: ov_ashe_data

ov_tracer_icon:
    type: item
    material: light_blue_stained_glass_pane
    display name: <&f>Tracer
    flags:
        data: ov_tracer_data

ov_bastion_icon:
    type: item
    material: light_blue_stained_glass_pane
    display name: <&f>Bastion
    flags:
        data: ov_bastion_data

ov_sojourn_icon:
    type: item
    material: light_blue_stained_glass_pane
    display name: <&f>Sojourn
    flags:
        data: ov_sojourn_data


ov_brigitte_icon:
    type: item
    material: light_blue_stained_glass_pane
    display name: <&f>Brigitte
    flags:
        data: ov_brigitte_data