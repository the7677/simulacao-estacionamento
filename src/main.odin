package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:slice"
import "core:os"

import rl "vendor:raylib"


SCREEN_WIDTH, SCREEN_HEIGHT :: 512, 512

SCREEN_CENTER :: rl.Vector2{SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2}

RAMP_DST    :: rl.Rectangle{SCREEN_CENTER.x, 384, 48, 128}
GATE_DST    :: rl.Rectangle{SCREEN_CENTER.x, 256, 48, 128}
PARKING_DST :: rl.Rectangle{SCREEN_CENTER.x, 128, 48, 128}

PARKING_SPEED :: 60

Sprite :: struct {
    tex:      rl.Texture2D,
    src:      rl.Rectangle,
    dst:      rl.Rectangle,
    origin:   rl.Vector2,
    rotation: f32,
    color:    ^rl.Color
}

getCurrentLot :: #force_inline proc() -> int {
    return (int(parking.rotation) %% 360) / 60
}

main :: proc() {
    rl.SetTraceLogLevel(.NONE)
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Simulação do Estacionamento")
    defer rl.CloseWindow()

    initTextures()

    // Estacionamnto
    parking = {
        tex      = rl.LoadTexture("assets/images/parking.png"),
        src      = {0, 0, 256, 256},
        dst      = {SCREEN_CENTER.x, 128, 256, 256},
        origin   = {128, 128},
        rotation = 0,
        color    = FOREGROUND_COLOR
    }

    append(&buttons,
        // Apelido            N    X                  Y                    Função de Update  Função de Ação
        /* Novo */  newButton(1,  {5,                 5},                  btnAddUpdate,     btnAddPress),
        /* Cima */  newButton(2,  {5,                 74},                 btnUpUpdate,      btnUpPress),
        /* Baixo */ newButton(3,  {5,                 111},                btnDownUpdate,    btnDownPress),
        /* 1 */     newButton(4,  {SCREEN_WIDTH - 74, 5},                  btnNumber1Update, btnNumber1Press),
        /* 2 */     newButton(5,  {SCREEN_WIDTH - 37, 5},                  btnNumber2Update, btnNumber2Press),
        /* 3 */     newButton(6,  {SCREEN_WIDTH - 74, 42},                 btnNumber3Update, btnNumber3Press),
        /* 4 */     newButton(7,  {SCREEN_WIDTH - 37, 42},                 btnNumber4Update, btnNumber4Press),
        /* 5 */     newButton(8,  {SCREEN_WIDTH - 74, 79},                 btnNumber5Update, btnNumber5Press),
        /* 6 */     newButton(9,  {SCREEN_WIDTH - 37, 79},                 btnNumber6Update, btnNumber6Press),
        /* Tema */  newButton(10, {SCREEN_WIDTH - 37, SCREEN_HEIGHT - 42}, nil,              btnChangeTheme)
    )

    for !rl.WindowShouldClose() {
        /* Atualizações*/
        if slice.count(cars[:], nil) == 0 {
            gateMode = .EXIT
        }

        // Verificando se há vaga livre, somente se nenhum carro estiver saindo
        availableLot, hasAvailableLot = slice.linear_search(cars[:], nil)
        if gateMode != .EXIT && selectedLot == -1 && hasAvailableLot && cars[getCurrentLot()] != nil {
            rotating = true
        }

        switch gateMode {
            case .ENTRANCE:
                if gate != nil {
                    openGate = .FIRST
                } else {
                    openGate = .SECOND
                }
            case .EXIT:
                if gate != nil {
                    openGate = .SECOND
                    gateMode = .EXIT_FDC
                } else {
                    openGate = .FIRST
                }
            case .EXIT_FDC:
                if gate != nil {
                    openGate = .SECOND
                } else {
                    gateMode = .ENTRANCE
                }
        }

        if rotating {
            openGate = .FIRST
            parking.rotation += PARKING_SPEED * rl.GetFrameTime()

            // Encontrou vaga disponível
            if selectedLot == -1 && getCurrentLot() == availableLot {
                rotating = false
            }

            // ou

            // Indo até vaga selecionada
            if selectedLot != -1 && getCurrentLot() == selectedLot {
                rotating = false
                gateMode = .EXIT
                selectedLot = -1
            }
        }

        for &btn in buttons {
            if btn.update != nil { btn->update() }

            if rl.IsMouseButtonPressed(.LEFT) && mouseInArea(btn) && btn.active && !rotating {
                if btn.press != nil { btn->press() }
            }
        }

        /* Debug */

        /* Render */
        rl.BeginDrawing()
            rl.ClearBackground(BACKGROUND_COLOR^)
            
            // Botões
            for &btn in buttons {
                drawButton(&btn)
            }

            // Estacionamento
            rl.DrawTexturePro(parking.tex, parking.src, parking.dst, parking.origin, math.mod(parking.rotation, 60), parking.color^)
            
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
            rl.DrawRectangleRec({SCREEN_CENTER.x - 64, 258, 5 if openGate == .FIRST else 128, 10}, FOREGROUND_COLOR^)
            rl.DrawRectangleRec({SCREEN_CENTER.x - 64, 384, 5 if openGate == .SECOND else 128, 10}, FOREGROUND_COLOR^)

            rl.DrawLineV({SCREEN_CENTER.x - 64, 256 - 18}, {SCREEN_CENTER.x - 64, SCREEN_HEIGHT}, FOREGROUND_COLOR^)
            rl.DrawLineV({SCREEN_CENTER.x + 64, 256 - 18}, {SCREEN_CENTER.x + 64, SCREEN_HEIGHT}, FOREGROUND_COLOR^)

            rl.DrawText(fmt.ctprintf("vaga %d", getCurrentLot() + 1), i32(SCREEN_CENTER.x - 16), 123+1, 2, FOREGROUND_COLOR^)

            rl.DrawText(" FDC ->", 60, 340, 20, FOREGROUND_COLOR^)
            rl.DrawText("Rampa ->", 60, 460, 20, FOREGROUND_COLOR^)

        rl.EndDrawing()
    }
}