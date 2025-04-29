package main

import "core:fmt"

import rl "vendor:raylib"


Button :: struct {
    action: proc(^Button),
    active: bool,
    using sprite: Sprite,
}

newButton :: proc(button: i32, pos: rl.Vector2, action: proc(^Button) = nil) -> Button {
    buttons := rl.LoadTexture("buttons.png")
    
    return {
        action = action,
        active = true,
        sprite = {
            tex   = buttons,
            src   = {f32(button % (buttons.width / 32)) * 32, f32(button / (buttons.width / 32)) * 32, 32, 32},
            dst   = {pos.x, pos.y, 32, 32},
            color = FOREGROUND_COLOR
        },
    }
}

drawButton :: proc(button: ^Button) {
    rl.DrawTexturePro(
        button.tex if button.active else {}, button.src, button.dst, button.origin, button.rotation, button.color^
    )
}

mouseInArea :: proc(button: Button) -> bool {
    mousePos := rl.GetMousePosition()

    return\
        mousePos.x > button.dst.x &&
        mousePos.x < button.dst.x + button.dst.width &&
        mousePos.y > button.dst.y &&
        mousePos.y < button.dst.y + button.dst.height
}

btnChangeTheme :: proc(^Button) {
    DARKMODE = !DARKMODE

    temp := FOREGROUND_COLOR^
    FOREGROUND_COLOR^ = BACKGROUND_COLOR^
    BACKGROUND_COLOR^ = temp

    car_tex = &car_dark if DARKMODE else &car_light
}

btnAdd :: proc(button: ^Button) {
    @static n: i32 = 0
    defer n += 1

    if len(cars) < 6 {
        append(&cars, newCar(n))
    }

    if len(cars) > 6 { panic("MAIS DE 6 CARROS") }
    
    button.active = len(cars) < 6
}