<?php
function mystery($a, $b) {
    $c = strlen($a);
    $d = strlen($b);
    if ($c == 0) return $d;
    if ($d == 0) return $c;
    $e = array();
    for ($f = 0; $f <= $c; $f++) $e[$f][0] = $f;
    for ($g = 0; $g <= $d; $g++) $e[0][$g] = $g;
    for ($f = 1; $f <= $c; $f++) {
        for ($g = 1; $g <= $d; $g++) {
            $h = ($a[$f - 1] == $b[$g - 1]) ? 0 : 1;
            $e[$f][$g] = min(
                $e[$f - 1][$g] + 1,
                $e[$f][$g - 1] + 1,
                $e[$f - 1][$g - 1] + $h
            );
        }
    }
    return $e[$c][$d];
}
