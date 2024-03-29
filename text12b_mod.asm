    ifconst bs_mask
        ifconst FASTFETCH ; using DPC+
KERNELBANK = 1
        else
KERNELBANK = (bs_mask + 1)
        endif
    endif


textkernel
	lda TextColor
	sta COLUP0
	sta COLUP1 
    lda #11
    tax
    clc
    ifconst extendedtxt
        adc temp1
    else
        adc TextIndex
    endif
    tay
TextPointersLoop
    lda (TextDataPtr),y  
    sta scorepointers,x
    dey
    dex
    bpl TextPointersLoop

    ldx scorepointers+0
    lda left_text,x
    ldx scorepointers+1
    ora right_text,x
	ldy #2
	
firstbreak
    ; Text line 1 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty VBLANK              ; 3     (3)
    sta GRP0                ; 3     (6)

    ldx scorepointers+2     ; 3     (9)
    lda left_text,x         ; 4     (13)
    ldx scorepointers+3     ; 3     (16)
    ora right_text,x        ; 4     (20)
    sta GRP1                ; 3     (23*)
    
    ldx scorepointers+4     ; 3     (26)
    lda left_text,x         ; 4     (30)
    ldx scorepointers+5     ; 3     (33)
    ora right_text,x        ; 4     (37)
    sta GRP0                ; 3     (40)
    
    ldx scorepointers+6     ; 3     (43) 3 in A
    lda left_text,x         ; 4     (47)
    ldx scorepointers+7     ; 3     (50)
    ora right_text,x        ; 4     (54)
    
    ldy #0                  ; 2     (56)
    
    ;line 2
    sta WSYNC               ; 3     (0)
    sty VBLANK              ; 3     (3)
    tay                     ; 2     (5) 3 in Y

    ldx scorepointers+8     ; 3     (8) 4
    lda left_text,x         ; 4     (12)
    ldx scorepointers+9     ; 3     (15)
    ora right_text,x        ; 4     (19)
    sta stack1              ; 3     (22)

    ldx scorepointers+10    ; 3     (25*) 5 in A
    lda left_text,x         ; 4     (29)
    ldx scorepointers+11    ; 3     (32)
    ora right_text,x        ; 4     (36)
    
    ldx stack1              ; 3     (39) 4 in X
    ifnconst noscoretxt
        sleep 5             ; 7     (46)
    else
        sleep 2
    endif
    sty GRP1                ; 3     (49) 3 -> [GRP1] ; 2 -> GRP0
    stx GRP0                ; 3     (52) 4 -> [GRP0] ; 3 -> GRP1
    sta GRP1                ; 3     (55) 5 -> [GRP1] ; 4 -> GRP0
    sta GRP0                ; 3     (58) 5 -> GRP1

    ldy #2                  ; 2     (60)
    ldx scorepointers+0     ; 3     (63)
    lda left_text+1,x       ; 4     (67)
    ldx scorepointers+1     ; 3     (70)
    ora right_text+1,x      ; 4     (74)
;    sleep 4
    
    ; Text line 2 / 5
endl1 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty VBLANK              ; 3     (3)
    sta GRP0                ; 3     (6)

    ldx scorepointers+2     ; 3     (9)
    lda left_text+1,x         ; 4     (13)
    ldx scorepointers+3     ; 3     (16)
    ora right_text+1,x        ; 4     (20)
    sta GRP1                ; 3     (23*)
    
    ldx scorepointers+4     ; 3     (26)
    lda left_text+1,x         ; 4     (30)
    ldx scorepointers+5     ; 3     (33)
    ora right_text+1,x        ; 4     (37)
    sta GRP0                ; 3     (40)
    
    ldx scorepointers+6     ; 3     (43) 3 in A
    lda left_text+1,x         ; 4     (47)
    ldx scorepointers+7     ; 3     (50)
    ora right_text+1,x        ; 4     (54)
    
    ldy #0                  ; 2     (56)
    
    ;line 2
    sta WSYNC               ; 3     (0)
    sty VBLANK              ; 3     (3)
    tay                     ; 2     (5) 3 in Y

    ldx scorepointers+8     ; 3     (8) 4
    lda left_text+1,x         ; 4     (12)
    ldx scorepointers+9     ; 3     (15)
    ora right_text+1,x        ; 4     (19)
    sta stack1              ; 3     (22)

    ldx scorepointers+10    ; 3     (25*) 5 in A
    lda left_text+1,x         ; 4     (29)
    ldx scorepointers+11    ; 3     (32)
    ora right_text+1,x        ; 4     (36)
    
    ldx stack1              ; 3     (39) 4 in X
    ifnconst noscoretxt
        sleep 5             ; 7     (46)
    else
        sleep 2
    endif
    sty GRP1                ; 3     (49) 3 -> [GRP1] ; 2 -> GRP0
    stx GRP0                ; 3     (52) 4 -> [GRP0] ; 3 -> GRP1
    sta GRP1                ; 3     (55) 5 -> [GRP1] ; 4 -> GRP0
    sta GRP0                ; 3     (58) 5 -> GRP1

    ldy #2                  ; 2     (56)
    ldx scorepointers+0     ; 3     (59)
    lda left_text+2,x         ; 4     (63)
    ldx scorepointers+1     ; 3     (66)
    ora right_text+2,x        ; 4     (70)
;    sleep 4

    ; Text line 3 / 5
endl2 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty VBLANK              ; 3     (3)
    sta GRP0                ; 3     (6)

    ldx scorepointers+2     ; 3     (9)
    lda left_text+2,x         ; 4     (13)
    ldx scorepointers+3     ; 3     (16)
    ora right_text+2,x        ; 4     (20)
    sta GRP1                ; 3     (23*)
    
    ldx scorepointers+4     ; 3     (26)
    lda left_text+2,x         ; 4     (30)
    ldx scorepointers+5     ; 3     (33)
    ora right_text+2,x        ; 4     (37)
    sta GRP0                ; 3     (40)
    
    ldx scorepointers+6     ; 3     (43) 3 in A
    lda left_text+2,x         ; 4     (47)
    ldx scorepointers+7     ; 3     (50)
    ora right_text+2,x        ; 4     (54)
    
    ldy #0                  ; 2     (56)
    
    ;line 2
    sta WSYNC               ; 3     (0)
    sty VBLANK              ; 3     (3)
    tay                     ; 2     (5) 3 in Y

    ldx scorepointers+8     ; 3     (8) 4
    lda left_text+2,x         ; 4     (12)
    ldx scorepointers+9     ; 3     (15)
    ora right_text+2,x        ; 4     (19)
    sta stack1              ; 3     (22)

    ldx scorepointers+10    ; 3     (25*) 5 in A
    lda left_text+2,x         ; 4     (29)
    ldx scorepointers+11    ; 3     (32)
    ora right_text+2,x        ; 4     (36)
    
    ldx stack1              ; 3     (39) 4 in X
     ifnconst noscoretxt
        sleep 5             ; 7     (46)
    else
        sleep 2
    endif
    sty GRP1                ; 3     (45) 3 -> [GRP1] ; 2 -> GRP0
    stx GRP0                ; 3     (48) 4 -> [GRP0] ; 3 -> GRP1
    sta GRP1                ; 3     (51) 5 -> [GRP1] ; 4 -> GRP0
    sta GRP0                ; 3     (54) 5 -> GRP1

    ldy #2                  ; 2     (56)
    ldx scorepointers+0     ; 3     (59)
    lda left_text+3,x         ; 4     (63)
    ldx scorepointers+1     ; 3     (66)
    ora right_text+3,x        ; 4     (70)
;    sleep 2

    ; Text line 4 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty VBLANK              ; 3     (3)
    sta GRP0                ; 3     (6)

    ldx scorepointers+2     ; 3     (9)
    lda left_text+3,x         ; 4     (13)
    ldx scorepointers+3     ; 3     (16)
    ora right_text+3,x        ; 4     (20)
    sta GRP1                ; 3     (23*)
    
    ldx scorepointers+4     ; 3     (26)
    lda left_text+3,x         ; 4     (30)
    ldx scorepointers+5     ; 3     (33)
    ora right_text+3,x        ; 4     (37)
    sta GRP0                ; 3     (40)
    
    ldx scorepointers+6     ; 3     (43) 3 in A
    lda left_text+3,x         ; 4     (47)
    ldx scorepointers+7     ; 3     (50)
    ora right_text+3,x        ; 4     (54)
    
    ldy #0                  ; 2     (56)
    
    ;line 2
    sta WSYNC               ; 3     (0)
    sty VBLANK              ; 3     (3)
    tay                     ; 2     (5) 3 in Y

    ldx scorepointers+8     ; 3     (8) 4
    lda left_text+3,x         ; 4     (12)
    ldx scorepointers+9     ; 3     (15)
    ora right_text+3,x        ; 4     (19)
    sta stack1              ; 3     (22)

    ldx scorepointers+10    ; 3     (25*) 5 in A
    lda left_text+3,x         ; 4     (29)
    ldx scorepointers+11    ; 3     (32)
    ora right_text+3,x        ; 4     (36)
    
    ldx stack1              ; 3     (39) 4 in X
    ifnconst noscoretxt
        sleep 5             ; 7     (46)
    else
        sleep 2
    endif
    sty GRP1                ; 3     (45) 3 -> [GRP1] ; 2 -> GRP0
    stx GRP0                ; 3     (48) 4 -> [GRP0] ; 3 -> GRP1
    sta GRP1                ; 3     (51) 5 -> [GRP1] ; 4 -> GRP0
    sta GRP0                ; 3     (54) 5 -> GRP1

    ldy #2                  ; 2     (56)
    ldx scorepointers+0     ; 3     (59)
    lda left_text+4,x         ; 4     (63)
    ldx scorepointers+1     ; 3     (66)
    ora right_text+4,x        ; 4     (70)
;    sleep 2

    ; Text line 5 / 5
 
    ;line 1
    sta WSYNC               ; 3     (0)
    sty VBLANK              ; 3     (3)
    sta GRP0                ; 3     (6)

    ldx scorepointers+2     ; 3     (9)
    lda left_text+4,x         ; 4     (13)
    ldx scorepointers+3     ; 3     (16)
    ora right_text+4,x        ; 4     (20)
    sta GRP1                ; 3     (23*)
    
    ldx scorepointers+4     ; 3     (26)
    lda left_text+4,x         ; 4     (30)
    ldx scorepointers+5     ; 3     (33)
    ora right_text+4,x        ; 4     (37)
    sta GRP0                ; 3     (40)
    
    ldx scorepointers+6     ; 3     (43) 3 in A
    lda left_text+4,x         ; 4     (47)
    ldx scorepointers+7     ; 3     (50)
    ora right_text+4,x        ; 4     (54)
    
    ldy #0                  ; 2     (56)
    
    ;line 2
    sta WSYNC               ; 3     (0)
    sty VBLANK              ; 3     (3)
    tay                     ; 2     (5) 3 in Y

    ldx scorepointers+8     ; 3     (8) 4
    lda left_text+4,x         ; 4     (12)
    ldx scorepointers+9     ; 3     (15)
    ora right_text+4,x        ; 4     (19)
    sta stack1              ; 3     (22)

    ldx scorepointers+10    ; 3     (25*) 5 in A
    lda left_text+4,x         ; 4     (29)
    ldx scorepointers+11    ; 3     (32)
    ora right_text+4,x        ; 4     (36)
    
    ldx stack1              ; 3     (39) 4 in X
    ifnconst noscoretxt
        sleep 5             ; 7     (46)
    else
        sleep 2
    endif
    sty GRP1                ; 3     (45) 3 -> [GRP1] ; 2 -> GRP0
    stx GRP0                ; 3     (48) 4 -> [GRP0] ; 3 -> GRP1
    sta GRP1                ; 3     (51) 5 -> [GRP1] ; 4 -> GRP0
    sta GRP0                ; 3     (54) 5 -> GRP1
    
    lda #0
    sta GRP0
    sta GRP1
    sta GRP0
    sta NUSIZ0
    sta NUSIZ1
    sta VDELP0
    sta VDELP1

    ifconst textbank
        sta temp7
        lda #>(posttextkernel-1)
        pha
        lda #<(posttextkernel-1)
        pha
        lda temp7
        pha ; *** save A
        txa
        pha ; *** save X
        ldx #KERNELBANK
        jmp BS_jsr
    else
        jmp posttextkernel
    endif

   if >. != >[.+text_data_height]
	align 256
   endif

text_data

left_text

__A = * - text_data ; baseline (0)
    .byte %00100000 
    .byte %01010000
    .byte %01110000
    .byte %01010000
    .byte %01010000
    
__B = * - text_data
    .byte %01100000
    .byte %01010000
    .byte %01100000
    .byte %01010000
    .byte %01100000    
    
__C = * - text_data
    .byte %00110000
    .byte %01000000
    .byte %01000000
    .byte %01000000
    .byte %00110000    
    
__D = * - text_data
    .byte %01100000
    .byte %01010000
    .byte %01010000
    .byte %01010000
    .byte %01100000
    
__E = * - text_data
    .byte %01110000
    .byte %01000000
    .byte %01100000
    .byte %01000000
    .byte %01110000

__G = * - text_data
    .byte %00110000
    .byte %01000000
    .byte %01010000
    .byte %01010000
    .byte %00100000
    
__I = * - text_data
    .byte %01110000
    .byte %00100000
    .byte %00100000
    .byte %00100000
    .byte %01110000
    
__M = * - text_data
    .byte %01010000
    .byte %01110000
    .byte %01110000
    .byte %01010000
    .byte %01010000
    
__N = * - text_data
    .byte %01100000
    .byte %01010000
    .byte %01010000
    .byte %01010000
    .byte %01010000

__O = * - text_data
    .byte %00100000
    .byte %01010000
    .byte %01010000
    .byte %01010000
    .byte %00100000

__P = * - text_data
    .byte %01100000
    .byte %01010000
    .byte %01100000
    .byte %01000000
    .byte %01000000
    
__R = * - text_data
    .byte %01100000
    .byte %01010000
    .byte %01100000
    .byte %01010000
    .byte %01010000
    
__S = * - text_data
    .byte %00110000
    .byte %01000000
    .byte %00100000
    .byte %00010000
    .byte %01100000
    
__T = * - text_data
    .byte %01110000
    .byte %00100000
    .byte %00100000
    .byte %00100000
    .byte %00100000
    
__U = * - text_data
    .byte %01010000
    .byte %01010000
    .byte %01010000
    .byte %01010000
    .byte %01110000
    
__V = * - text_data
    .byte %01010000
    .byte %01010000
    .byte %01010000
    .byte %01010000
    .byte %00100000
    
__Y = * - text_data
    .byte %01010000
    .byte %01010000
    .byte %00100000
    .byte %00100000
    .byte %00100000
    
_sp = * - text_data
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

_pd = * - text_data
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00100000
 
_ex = * - text_data
    .byte %00100000
    .byte %00100000
    .byte %00100000
    .byte %00000000
    .byte %00100000


text_data_height = * - text_data

   if >. != >[.+text_data_height]
	align 256
   endif

right_text

; A
    .byte %00000010 
    .byte %00000101
    .byte %00000111
    .byte %00000101
    .byte %00000101

    
; B
    .byte %00000110
    .byte %00000101
    .byte %00000110
    .byte %00000101
    .byte %00000110    
    
; C
    .byte %00000011
    .byte %00000100
    .byte %00000100
    .byte %00000100
    .byte %00000011    
    
; D
    .byte %00000110
    .byte %00000101
    .byte %00000101
    .byte %00000101
    .byte %00000110
    
; E
    .byte %00000111
    .byte %00000100
    .byte %00000110
    .byte %00000100
    .byte %00000111

; G
    .byte %00000011
    .byte %00000100
    .byte %00000101
    .byte %00000101
    .byte %00000010
    
; I
    .byte %00000111
    .byte %00000010
    .byte %00000010
    .byte %00000010
    .byte %00000111
    
; M
    .byte %00000101
    .byte %00000111
    .byte %00000111
    .byte %00000101
    .byte %00000101
    
; N
    .byte %00000110
    .byte %00000101
    .byte %00000101
    .byte %00000101
    .byte %00000101

; O
    .byte %00000010
    .byte %00000101
    .byte %00000101
    .byte %00000101
    .byte %00000010

; P
    .byte %00000110
    .byte %00000101
    .byte %00000110
    .byte %00000100
    .byte %00000100
    
; R
    .byte %00000110
    .byte %00000101
    .byte %00000110
    .byte %00000101
    .byte %00000101
    
; S
    .byte %00000011
    .byte %00000100
    .byte %00000010
    .byte %00000001
    .byte %00000110
    
; T
    .byte %00000111
    .byte %00000010
    .byte %00000010
    .byte %00000010
    .byte %00000010
    
; U
    .byte %00000101
    .byte %00000101
    .byte %00000101
    .byte %00000101
    .byte %00000111
    
; V
    .byte %00000101
    .byte %00000101
    .byte %00000101
    .byte %00000101
    .byte %00000010
    
; Y
    .byte %00000101
    .byte %00000101
    .byte %00000010
    .byte %00000010
    .byte %00000010

; space
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

; period
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000010

; exclamation point
    .byte %00000010
    .byte %00000010
    .byte %00000010
    .byte %00000000
    .byte %00000010
