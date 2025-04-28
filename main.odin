package main

import "core:fmt"
import "core:math"
import "core:math/rand"

import rl "vendor:raylib"


SCREEN_WIDTH, SCREEN_HEIGHT :: 512, 512
SCREEN_CENTER :: rl.Vector2{SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2}

BACKGROUND_COLOR :: rl.Color{236, 230, 223, 255}
FOREGROUND_COLOR :: rl.Color{42,  28,  49,  255}

BLUE_COLOR   :: rl.Color{77,  82,  138, 255}
GREEN_COLOR  :: rl.Color{73,  101, 65,  255}
PURPLE_COLOR :: rl.Color{110, 69,  104, 255}
RED_COLOR    :: rl.Color{159, 76,  61,  255}
YELLOW_COLOR :: rl.Color{235, 172, 77,  255}

COLORS       := []rl.Color{
    BLUE_COLOR, GREEN_COLOR, PURPLE_COLOR, RED_COLOR, YELLOW_COLOR
}

Sprite :: struct {
    tex:      rl.Texture2D,
    src:      rl.Rectangle,
    dst:      rl.Rectangle,
    origin:   rl.Vector2,
    rotation: f32,
    color:    rl.Color
}

Car :: struct {
    number: u8,
    using sprite: Sprite
}

cars: [dynamic]Car
ramp: ^Car
gate: ^Car

newCar :: proc(number: u8, texture: rl.Texture, color: Maybe(rl.Color) = nil) -> Car {
    return {number = number, sprite = {
            tex      = texture,
            src      = {0, 0, 48, 128},
            dst      = {256, 128, 48, 128},
            origin   = {24, 0},
            rotation = {},
            color    = color.? if color != nil else COLORS[rand.int_max(5)]
        }
    }
}

main :: proc() {
    rl.SetTraceLogLevel(.NONE)
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Simulação do Estacionamento")
    rl.SetTargetFPS(120)

    car_light := rl.LoadTexture("car_light.png")
    car_dark  := rl.LoadTexture("car_dark.png")

    parking := Sprite{
        tex      = rl.LoadTexture("parking.png"),
        src      = {0, 0, 256, 256},
        dst      = {SCREEN_CENTER.x, SCREEN_CENTER.y - 128, 256, 256},
        origin   = {128, 128},
        rotation = 0,
        color    = FOREGROUND_COLOR
    }

    append(&cars, newCar(0, car_dark), newCar(1, car_light), newCar(2, car_light), newCar(3, car_light))

    buttons := rl.LoadTexture("buttons.png")

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
            rl.ClearBackground(BACKGROUND_COLOR)
            rl.DrawTexturePro(
                parking.tex, parking.src, parking.dst, parking.origin, math.mod(parking.rotation, 60), parking.color
            )
            rl.DrawTexture(buttons, 0, 0, FOREGROUND_COLOR)

            for &car in cars {
                rl.DrawTexturePro(car.tex, car.src, car.dst, car.origin, car.rotation, car.color)
                car.rotation = parking.rotation + f32(60 * car.number)
            }
            
            parking.rotation += 100 * rl.GetFrameTime()

            rl.DrawLineV({192, 256 - 18}, {192, SCREEN_HEIGHT}, FOREGROUND_COLOR)
            rl.DrawLineV({320, 256 - 18}, {320, SCREEN_HEIGHT}, FOREGROUND_COLOR)

            rl.DrawText("  FDC ->", 60, 340, 20, FOREGROUND_COLOR)
            rl.DrawText("Rampa ->", 60, 460, 20, FOREGROUND_COLOR)

        rl.EndDrawing()
    }
    
}