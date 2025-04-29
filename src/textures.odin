package main

import rl "vendor:raylib"

car_light:    rl.Texture
car_dark:     rl.Texture
car_tex:     ^rl.Texture

buttons_tex:  rl.Texture

initTextures :: proc() {
    car_light = rl.LoadTexture("assets/images/car_light.png")
    car_dark  = rl.LoadTexture("assets/images/car_dark.png")
    car_tex   = &car_light

    buttons_tex = rl.LoadTexture("assets/images/buttons.png") 
}