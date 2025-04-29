package main

import "core:fmt"

import rl "vendor:raylib"


Button :: struct {
    update: proc(^Button),
    press: proc(^Button),
    active: bool,
    using sprite: Sprite,
}

newButton :: proc(button: i32, pos: rl.Vector2, update: proc(^Button) = nil, press: proc(^Button) = nil) -> Button {
    return {
        update = update,
        press = press,
        active = true,
        sprite = {
            tex   = buttons_tex,
            src   = {f32(button % (buttons_tex.width / 32)) * 32, f32(button / (buttons_tex.width / 32)) * 32, 32, 32},
            dst   = {pos.x, pos.y, 32, 32},
            color = FOREGROUND_COLOR
        },
    }
}

drawButton :: proc(button: ^Button) {
    rl.DrawTexturePro(
        button.tex if button.active && !inEvent else {}, button.src, button.dst, button.origin, button.rotation, button.color^
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
    temp := FOREGROUND_COLOR^
    FOREGROUND_COLOR^ = BACKGROUND_COLOR^
    BACKGROUND_COLOR^ = temp

    car_tex = &car_dark if car_tex == &car_light else &car_light
}

btnAddUpdate :: proc(button: ^Button) {
    if len(cars) > 6 { panic("MAIS DE 6 CARROS") }
    button.active = ramp == nil
}

btnAddPress :: proc(button: ^Button) {
    ramp = new_clone(newCar())
}


btnUpUpdate :: proc(button: ^Button) {
    button.active = ramp != nil && gate == nil
}

btnUpPress :: proc(button: ^Button) {
    if ramp != nil {
        ramp.dst = GATE_DST
    
        gate = ramp
        ramp = nil
    }
}

btnDownUpdate :: proc(button: ^Button) {
    button.active = ramp != nil || gate != nil
}

btnDownPress :: proc(button: ^Button) {
    if ramp != nil {
        free(ramp)
        ramp = nil
    } else if gate != nil {
        gate.dst = RAMP_DST

        ramp = gate
        gate = nil
    }
}