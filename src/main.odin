package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:slice"

import rl "vendor:raylib"


SCREEN_WIDTH, SCREEN_HEIGHT :: 512, 512
SCREEN_CENTER :: rl.Vector2{SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2}

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

ramp:           ^Car
gate:           ^Car
openGate:        enum { FIRST, SECOND }
gateMode:        enum { ENTRANCE, EXIT_FDC, EXIT } = .ENTRANCE
rotating:        bool
hasAvailableLot: bool
availableLot:    int

pastLot: i32 = 0
parking: Sprite

getCurrentLot :: proc() -> i32 {
    return (i32(parking.rotation) %% 360) / 60
}

main :: proc() {
    rl.SetTraceLogLevel(.NONE)
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Simulação do Estacionamento")
    
    defer rl.CloseWindow()

    initTextures()

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
        /* 1 */     newButton(4,  {SCREEN_WIDTH - 74, 5}, btnNumber1Update, btnNumber1Press),
        /* 2 */     newButton(5,  {SCREEN_WIDTH - 37, 5}, btnNumber2Update, btnNumber2Press),
        /* 3 */     newButton(6,  {SCREEN_WIDTH - 74, 42}, btnNumber3Update, btnNumber3Press),
        /* 4 */     newButton(7,  {SCREEN_WIDTH - 37, 42}, btnNumber4Update, btnNumber4Press),
        /* 5 */     newButton(8,  {SCREEN_WIDTH - 74, 79}, btnNumber5Update, btnNumber5Press),
        /* 6 */     newButton(9,  {SCREEN_WIDTH - 37, 79}, btnNumber6Update, btnNumber6Press),
        /* Tema */  newButton(10, {SCREEN_WIDTH - 37, SCREEN_HEIGHT - 42}, nil, btnChangeTheme)
    )

    for !rl.WindowShouldClose() {
        /* Atualizações*/
        if slice.count(cars[:], nil) == 0 {
            gateMode = .EXIT
        }
        
        if rotating {
            parking.rotation += 60 * rl.GetFrameTime()

            // Encontrou vaga disponível
            if cars[getCurrentLot()] == nil {

                rotating = false
            }

            pastLot = getCurrentLot()
        }

        if gateMode == .ENTRANCE {
            if gate != nil {
                openGate = .FIRST
            } else {
                openGate = .SECOND
            }
        }

        for &btn in buttons {
            if btn.update != nil { btn->update() }

            if rl.IsMouseButtonPressed(.LEFT) && mouseInArea(btn) && btn.active && !rotating {
                if btn.press != nil { btn->press() }
            }
        }


        /* Render */
        rl.BeginDrawing()
            rl.ClearBackground(BACKGROUND_COLOR^)
            
            // Botões
            for &btn in buttons {
                drawButton(&btn)
            }

            // Estacionamento
            rl.DrawTexturePro(
                parking.tex, parking.src, parking.dst, parking.origin, math.mod(parking.rotation, 60), parking.color^
            )
            
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

            // Cancelas
            rl.DrawRectangle(192, 256, 5 if openGate == .FIRST else 128, 10, FOREGROUND_COLOR^)
            rl.DrawRectangle(192, 384, 5 if openGate == .SECOND else 128, 10, FOREGROUND_COLOR^)

            rl.DrawLineV({192, 256 - 18}, {192, SCREEN_HEIGHT}, FOREGROUND_COLOR^)
            rl.DrawLineV({320, 256 - 18}, {320, SCREEN_HEIGHT}, FOREGROUND_COLOR^)

            rl.DrawText(fmt.ctprintf("vaga %d", getCurrentLot() + 1), 240, 123+1, 2, FOREGROUND_COLOR^)

            rl.DrawText(" FDC ->", 60, 340, 20, FOREGROUND_COLOR^)
            rl.DrawText("Rampa ->", 60, 460, 20, FOREGROUND_COLOR^)

        rl.EndDrawing()
    }

}