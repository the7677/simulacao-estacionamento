package main

import "core:fmt"
import "core:slice"

import rl "vendor:raylib"


Button :: struct {
    update: proc(^Button),
    press: proc(^Button),
    active: bool,
    using sprite: Sprite,
}

buttons:    [dynamic]Button

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
        button.tex if button.active && !rotating else {}, button.src, button.dst, button.origin, button.rotation, button.color^
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
    ramp = newCar()
}


btnUpUpdate :: proc(button: ^Button) {
    button.active = (ramp != nil && gate == nil && openGate == .SECOND) ||
                    (gate != nil && cars[getCurrentLot()] == nil && openGate == .FIRST)
}

btnUpPress :: proc(button: ^Button) {
    switch {
        case ramp != nil && gate == nil:
            ramp.dst = GATE_DST
            
            gate = ramp
            ramp = nil
        case gate != nil:
            gate.dst = PARKING_DST
            
            cars[getCurrentLot()] = gate
            gate = nil

            availableLot, hasAvailableLot = slice.linear_search(cars[:], nil)
            if hasAvailableLot { rotating = true }
    }
}

btnDownUpdate :: proc(button: ^Button) {
    button.active = (ramp != nil) ||
                    (gate != nil && ramp == nil && openGate == .SECOND) ||
                    (cars[getCurrentLot()] != nil && gate == nil && openGate == .FIRST)
}

btnDownPress :: proc(button: ^Button) {
    switch {
        case ramp != nil:
            free(ramp)
            ramp = nil
        case gate != nil:
            gate.dst = RAMP_DST

            ramp = gate
            gate = nil
        case cars[getCurrentLot()] != nil:
            cars[getCurrentLot()].dst = GATE_DST

            gate = cars[getCurrentLot()]
            cars[getCurrentLot()] = nil
    }
}

btnNumberUpdate :: proc(button: ^Button, number: i32) {
    // button.active = cars[number] != nil && getCurrentLot() != number
}

btnNumber1Update :: proc(button: ^Button) { btnNumberUpdate(button, 0) }
btnNumber2Update :: proc(button: ^Button) { btnNumberUpdate(button, 1) }
btnNumber3Update :: proc(button: ^Button) { btnNumberUpdate(button, 2) }
btnNumber4Update :: proc(button: ^Button) { btnNumberUpdate(button, 3) }
btnNumber5Update :: proc(button: ^Button) { btnNumberUpdate(button, 4) }
btnNumber6Update :: proc(button: ^Button) { btnNumberUpdate(button, 5) }

btnNumberPress :: proc(button: ^Button, number: i32) {

}

btnNumber1Press :: proc(button: ^Button) { btnNumberPress(button, 0) }
btnNumber2Press :: proc(button: ^Button) { btnNumberPress(button, 1) }
btnNumber3Press :: proc(button: ^Button) { btnNumberPress(button, 2) }
btnNumber4Press :: proc(button: ^Button) { btnNumberPress(button, 3) }
btnNumber5Press :: proc(button: ^Button) { btnNumberPress(button, 4) }
btnNumber6Press :: proc(button: ^Button) { btnNumberPress(button, 5) }