package main

parking: Sprite

ramp: ^Sprite
gate: ^Sprite

openGate:        enum { FIRST, SECOND }
gateMode:        enum { ENTRANCE, EXIT_FDC, EXIT } = .ENTRANCE
rotating:        bool
hasAvailableLot: bool = true
availableLot:    int
selectedLot:     int  = -1