package main

import "core:math/rand"

import rl "vendor:raylib"


cars: [6]^Sprite

newCar :: proc(color: Maybe(^rl.Color) = nil) -> ^Sprite {
    return new_clone(Sprite{
            src      = {0, 0, 48, 128},
            dst      = RAMP_DST,
            origin   = {24, 0},
            color    = color.? or_else COLORS[rand.int_max(len(COLORS))]
    })
}