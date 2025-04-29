package main

import rl "vendor:raylib"

BACKGROUND_COLOR := new_clone(rl.Color{236, 230, 223, 255})
FOREGROUND_COLOR := new_clone(rl.Color{42,  28,  49,  255})

BLUE_COLOR   := new_clone(rl.Color{77,  82,  138, 255})
CYAN_COLOR   := new_clone(rl.Color{176, 214, 217, 255})
GREEN_COLOR  := new_clone(rl.Color{73,  101, 65,  255})
ORANGE_COLOR := new_clone(rl.Color{208, 118,  62, 255})
PURPLE_COLOR := new_clone(rl.Color{110, 69,  104, 255})
RED_COLOR    := new_clone(rl.Color{159, 76,  61,  255})
YELLOW_COLOR := new_clone(rl.Color{235, 172, 77,  255})
COLORS       := []^rl.Color{
    BLUE_COLOR, CYAN_COLOR, GREEN_COLOR, PURPLE_COLOR, RED_COLOR, YELLOW_COLOR
}