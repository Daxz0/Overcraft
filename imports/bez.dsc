## MADE BY MAX

quadratic_bezier_proc:
    type: procedure
    debug: false
    definitions: start_point|control_point|end_point|resolution|rotation
    script:
    - repeat <[resolution]> as:i:
        - define t <[i].div[<[resolution]>]>
        - define u <element[1].sub[<[t]>]>
        - define tt <[t].mul[<[t]>]>
        - define uu <[u].mul[<[u]>]>
        - define uua <[start_point].mul[<[uu]>]>
        - define uuc <[control_point].mul[<[u]>].mul[2].mul[<[t]>]>
        - define tte <[end_point].mul[<[tt]>]>
        - define points:->:<quaternion[<[rotation]||identity>].transform[<[uua].add[<[uuc]>].add[<[tte]>]>]>
    - determine <[points]||<list>>