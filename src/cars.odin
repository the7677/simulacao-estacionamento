package main

import "core:math/rand"

import rl "vendor:raylib"


Car :: struct {
    using sprite: Sprite
}

cars:       [6]^Car

newCar :: proc(color: Maybe(^rl.Color) = nil) -> ^Car {
    return new_clone(Car{sprite = {
            src      = {0, 0, 48, 128},
            dst      = RAMP_DST,
            origin   = {24, 0},
            color    = color.? or_else COLORS[rand.int_max(len(COLORS))]
        }
    })
}