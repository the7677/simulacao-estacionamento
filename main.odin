package main

import "core:fmt"
import "core:math"
import "core:math/rand"

import rl "vendor:raylib"


SCREEN_WIDTH, SCREEN_HEIGHT :: 512, 512
SCREEN_CENTER :: rl.Vector2{SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2}

DARKMODE := false

BACKGROUND_COLOR := new_clone(rl.Color{236, 230, 223, 255})
FOREGROUND_COLOR := new_clone(rl.Color{42,  28,  49,  255})

BLUE_COLOR   := new_clone(rl.Color{77,  82,  138, 255})
GREEN_COLOR  := new_clone(rl.Color{73,  101, 65,  255})
PURPLE_COLOR := new_clone(rl.Color{110, 69,  104, 255})
RED_COLOR    := new_clone(rl.Color{159, 76,  61,  255})
YELLOW_COLOR := new_clone(rl.Color{235, 172, 77,  255})

COLORS       := []^rl.Color{
    BLUE_COLOR, GREEN_COLOR, PURPLE_COLOR, RED_COLOR, YELLOW_COLOR
}

Sprite :: struct {
    tex:      rl.Texture2D,
    src:      rl.Rectangle,
    dst:      rl.Rectangle,
    origin:   rl.Vector2,
    rotation: f32,
    color:    ^rl.Color
}

Car :: struct {
    number: u8,
    using sprite: Sprite
}

btns: [dynamic]Button
cars: [dynamic]Car
ramp: ^Car
gate: ^Car
gateState: enum { FIRST, SECOND }
car_light, car_dark: rl.Texture
car_tex: ^rl.Texture

newCar :: proc(number: u8, color: Maybe(^rl.Color) = nil) -> Car {
    return {number = number, sprite = {
            src      = {0, 0, 48, 128},
            dst      = {256, 128, 48, 128},
            origin   = {24, 0},
            color    = color.? or_else COLORS[rand.int_max(5)]
        }
    }
}

main :: proc() {
    rl.SetTraceLogLevel(.NONE)
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Simulação do Estacionamento")
    rl.SetTargetFPS(120)
    
    defer rl.CloseWindow()

    car_light = rl.LoadTexture("car_light.png")
    car_dark  = rl.LoadTexture("car_dark.png")
    car_tex   = new_clone(car_light)

    parking := Sprite{
        tex      = rl.LoadTexture("parking.png"),
        src      = {0, 0, 256, 256},
        dst      = {SCREEN_CENTER.x, SCREEN_CENTER.y - 128, 256, 256},
        origin   = {128, 128},
        rotation = 0,
        color    = FOREGROUND_COLOR
    }

    append(&cars, newCar(0), newCar(1), newCar(2), newCar(3))

    btn_newcar := newButton(1, {5, 5})
    append(&btns,
        /* Novo */  newButton(1, {5, 5}),
        /* Cima */  newButton(2, {5, 10 + 64}),
        /* Baixo */ newButton(3, {5, 15 + 96}),
        /* 1 */     newButton(4, {SCREEN_WIDTH - 10 - 64, 5}),
        /* 2 */     newButton(5, {SCREEN_WIDTH - 5 - 32, 5}),
        /* 3 */     newButton(6, {SCREEN_WIDTH - 10 - 64, 10 + 32}),
        /* 4 */     newButton(7, {SCREEN_WIDTH - 5 - 32, 10 + 32}),
        /* 5 */     newButton(8, {SCREEN_WIDTH - 10 - 64, 15 + 64}),
        /* 6 */     newButton(9, {SCREEN_WIDTH - 5 - 32, 15 + 64}),
        /* Tema */  newButton(10, {SCREEN_WIDTH - 5 - 32, SCREEN_HEIGHT - 5 - 32}, changeTheme)
    )

    for !rl.WindowShouldClose() {

        /* Atualizações*/
        parking.rotation += 100 * rl.GetFrameTime()

        if rl.IsMouseButtonPressed(.LEFT) {
            for &btn in btns {
                if mouseInArea(btn) {
                    if btn.action != nil { btn->action() }
                }
            }
        }

        /* Render */
        rl.BeginDrawing()
            rl.ClearBackground(BACKGROUND_COLOR^)

            // Estacionamento
            rl.DrawTexturePro(
                parking.tex, parking.src, parking.dst, parking.origin, math.mod(parking.rotation, 60), parking.color^
            )
            
            // Botões
            for &btn in btns {
                drawButton(&btn)
            }
            
            // Carros
            for &car in cars {
                car.rotation = parking.rotation + f32(60 * car.number)
                rl.DrawTexturePro(car_tex^, car.src, car.dst, car.origin, car.rotation, car.color^)
            }

            rl.DrawLineV({192, 256 - 18}, {192, SCREEN_HEIGHT}, FOREGROUND_COLOR^)
            rl.DrawLineV({320, 256 - 18}, {320, SCREEN_HEIGHT}, FOREGROUND_COLOR^)

            rl.DrawText("  FDC ->", 60, 340, 20, FOREGROUND_COLOR^)
            rl.DrawText("Rampa ->", 60, 460, 20, FOREGROUND_COLOR^)

        rl.EndDrawing()
    }

}