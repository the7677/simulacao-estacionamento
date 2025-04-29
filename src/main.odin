package main

import "core:fmt"
import "core:math"
import "core:math/rand"

import rl "vendor:raylib"


SCREEN_WIDTH, SCREEN_HEIGHT :: 512, 512
SCREEN_CENTER :: rl.Vector2{SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2}

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

RAMP_DST    :: rl.Rectangle{SCREEN_CENTER.x, SCREEN_CENTER.y + 128, 48, 128}
GATE_DST    :: rl.Rectangle{SCREEN_CENTER.x, SCREEN_CENTER.y, 48, 128}
PARKING_DST :: rl.Rectangle{SCREEN_CENTER.x, 128, 48, 128}

PARKING_SPEED :: 100

Sprite :: struct {
    tex:      rl.Texture2D,
    src:      rl.Rectangle,
    dst:      rl.Rectangle,
    origin:   rl.Vector2,
    rotation: f32,
    color:    ^rl.Color
}

Car :: struct {
    using sprite: Sprite
}

buttons:    [dynamic]Button
cars:       [6]^Car
ramp:      ^Car
gate:      ^Car
gateState:  enum { FIRST, SECOND }
inEvent:    bool

car_light,
car_dark,
buttons_tex:  rl.Texture
car_tex:     ^rl.Texture

parking: Sprite

newCar :: proc(color: Maybe(^rl.Color) = nil) -> ^Car {
    return new_clone(Car{sprite = {
            src      = {0, 0, 48, 128},
            dst      = RAMP_DST,
            origin   = {24, 0},
            color    = color.? or_else COLORS[rand.int_max(len(COLORS))]
        }
    })
}

getCurrentLot :: proc() -> i32 {
    return (i32(parking.rotation + 30) %% 360) / 60
}

main :: proc() {
    rl.SetTraceLogLevel(.NONE)
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Simulação do Estacionamento")
    rl.SetTargetFPS(120)
    
    defer rl.CloseWindow()

    car_light = rl.LoadTexture("assets/images/car_light.png")
    car_dark  = rl.LoadTexture("assets/images/car_dark.png")
    car_tex   = &car_light

    buttons_tex = rl.LoadTexture("assets/images/buttons.png") 

    // Estacionamnto
    parking = Sprite{
        tex      = rl.LoadTexture("assets/images/parking.png"),
        src      = {0, 0, 256, 256},
        dst      = {SCREEN_CENTER.x, SCREEN_CENTER.y - 128, 256, 256},
        origin   = {128, 128},
        rotation = 0,
        color    = FOREGROUND_COLOR
    }

    append(&buttons,
        /* Novo */  newButton(1,  {5, 5}, btnAddUpdate, btnAddPress),
        /* Cima */  newButton(2,  {5, 10 + 64}, btnUpUpdate, btnUpPress),
        /* Baixo */ newButton(3,  {5, 15 + 96}, btnDownUpdate, btnDownPress),
        /* 1 */     newButton(4,  {SCREEN_WIDTH - 74, 5}),
        /* 2 */     newButton(5,  {SCREEN_WIDTH - 37, 5}),
        /* 3 */     newButton(6,  {SCREEN_WIDTH - 74, 10 + 32}),
        /* 4 */     newButton(7,  {SCREEN_WIDTH - 37, 10 + 32}),
        /* 5 */     newButton(8,  {SCREEN_WIDTH - 74, 15 + 64}),
        /* 6 */     newButton(9,  {SCREEN_WIDTH - 37, 15 + 64}),
        /* Tema */  newButton(10, {SCREEN_WIDTH - 37, SCREEN_HEIGHT - 5 - 37}, nil, btnChangeTheme)
    )

    for !rl.WindowShouldClose() {
        /* Atualizações*/
        for &btn in buttons {
            if btn.update != nil { btn->update() }

            if rl.IsMouseButtonPressed(.LEFT) && mouseInArea(btn) && btn.active && !inEvent {
                if btn.press != nil { btn->press() }
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
            for &btn in buttons {
                drawButton(&btn)
            }
            
            // Carros
            if ramp != nil {
                rl.DrawTexturePro(car_tex^, ramp.src, ramp.dst, ramp.origin, ramp.rotation, ramp.color^)
            }

            if gate != nil {
                rl.DrawTexturePro(car_tex^, gate.src, gate.dst, gate.origin, gate.rotation, gate.color^)
            }

            for &car, i in cars {
                if car != nil {
                    car.rotation = parking.rotation - f32(60 * i)
                    rl.DrawTexturePro(car_tex^, car.src, car.dst, car.origin, car.rotation, car.color^)
                }
            }

            rl.DrawLineV({192, 256 - 18}, {192, SCREEN_HEIGHT}, FOREGROUND_COLOR^)
            rl.DrawLineV({320, 256 - 18}, {320, SCREEN_HEIGHT}, FOREGROUND_COLOR^)

            rl.DrawText(fmt.ctprintf("vaga %d", getCurrentLot() + 1), 240, 123+1, 2, FOREGROUND_COLOR^)

            rl.DrawText(" FDC ->", 60, 340, 20, FOREGROUND_COLOR^)
            rl.DrawText("Rampa ->", 60, 460, 20, FOREGROUND_COLOR^)

        rl.EndDrawing()
    }

}