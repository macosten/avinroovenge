 rem Generated 8/29/2019 9:06:07 PM by Visual bB Version 1.0.0.568
 rem **********************************
 rem * AAA's Revenge                      *
 rem * A remake of the Neopets game, for the Atari 2600! *
 rem * Can you get to 1000 points? At least this version shouldn't crash when you get there... *
 rem * by /u/macosten                 *
 rem **********************************

 set kernel multisprite
 set romsize 4k

 ; Uncommenting the following line will replace the score with the approximate number of free cycles available in a given frame (+ or - 64).
 ;White is positive; red is negative. We don't want this number to be red (when I tested it out, it wasn't, but I did test it on an emulator).
 ;set debug cyclescore
 
 ; This game uses the text minikernel by Karl G. Don't try compiling this file without the minikernel's files in the same directory.

 ; RAM was not a limiting factor of this game, so I didn't need to use any special nibble macros or anything like that.
 ; One of my design constraints is sticking to a maximum size of 4k. If you fork this game, you might not care, but beware that some things may need to be bankswitched explicitly if we increase the ROM size.

 ;===
 ; Macros
 ;===

 ;A macro to return the yoyo (ball) to the center of the player sprite.
 macro returnYoyoToPlayer
 yoyoX = player0x + 4
 yoyoY = player0y - 4
end

 ;Initializes a sound on channel 0 with the arguments <volume> <control number> <frequency> <duration>
 macro soundInitC0
 AUDV0 = {1}
 AUDC0 = {2}
 AUDF0 = {3}
 channel0SoundTimer = {4}
end

 ;Initializes a sound on channel 1 with the arguments <volume> <control number> <frequency> <duration>
 macro soundInitC1
 AUDV1 = {1}
 AUDC1 = {2}
 AUDF1 = {3}
 channel1SoundTimer = {4}
end



 ; ===
 ; Variable definitions/DIMs/DEFs
 ; ===

 ;Ranges from 1 to 12, like the numbers on a clock.
 def playerPosition = a

 dim channel0SoundTimer = b

; A movement cooldown should exist so you don't need frame-perfect inputs to move the Avinroo.
 def cooldown = c

 ;=== 1-bit flags
 dim bit0_isYoyoDeployed = d
 dim bit1_resetRestrainer = d
 dim bit2_isAbigail = d
 dim bit3_yoyoRetract = d
 dim bit4_bonusActive = d 
 dim bit5_blockPreviousPosition = d

 ;The high 2 bytes of d are free.

 dim yoyoCooldown = e

; Using ballx and bally as the coordinates
 dim yoyoX = ballx.f ;a two-byte 8.8 floating point number. 
 dim yoyoY = bally.g


;Floating-point numbers to keep track of the yoyo's movement. Ironically, we have enough RAM for this.
 dim yoyoXvelocityint = h
 dim yoyoXvelocityfrac = i

 dim yoyoYvelocityint = j
 dim yoyoYvelocityfrac = k 

 dim yoyoXvelocity = yoyoXvelocityint.yoyoXvelocityfrac 
 dim yoyoYvelocity = yoyoYvelocityint.yoyoYvelocityfrac

 dim guardSpeedInt = l
 dim guardSpeedFrac = m

 dim guardSpeed = guardSpeedInt.guardSpeedFrac ; The higher this is, the faster the guards move.

 dim channel1SoundTimer = n 

 dim bitX_isGuardFacingLeft = o ;If bit 1 is set, then guard 1 is facing left, etc. 

 dim guard1x = player1x.p ;Fractional speeds for the guards.
 dim guard2x = player2x.q 
 dim guard3y = player3y.r

 dim myLives = s

 dim previousPositionFiredAt = t

 

 ;  V W X are all free. Player 4 x/y are both also free, maybe.
 
 ;===
 ;Text Minikernel Stuff
 ;===
 dim TextTimer = y
 dim TextIndex = z ;For the Text Minikernel.

 data text_strings
 __A, __A, __A, __S, _sp, __R, __E, __V, __E, __N, __G, __E ;Each line must have 12 characters.
 __B, __Y, _sp, __M, __A, __C, __O, __S, __T, __E, __N, _ex
 __U, __P,  _sp, __T, __O, _sp, __S, __T, __A, __R, __T, _sp
 __G, __A, __M, __E, _sp, __O, __V, __E, __R, _pd,  _pd, _pd
  __M, __O, __V, __E, _sp, __A, __R, __O, __U, __N, __D, _ex
end

 const gameTitleStringOffset = 0
 const byMacostenStringOffset = 12
 const startGameStringOffset = 24
 const gameOverStringOffset = 36
 const moveAwayErrorStringOffset = 48

 const gameOverLoopOffsetLimit = gameOverStringOffset
 

 ;TextIndex = gameOverStringOffset ;Setting TextIndex will change the text displayed.
 ;===
 ; Text kernel stuff end
 ;===

 ;===
 ; Constants and other data
 ;===

 ;A convenient way to store the correct values for NUSIZ5 when we have 0, 1, 2, or 3 lives.
 data livesNUSIZTable
 0, 0, 1, 3
end

;Measured coordinates, mostly for where the player's positions should be, but also for the guards.
 const XPOS0 = $26 ; 38
 const XPOS1 = $38
 const XPOS2 = $4C
 const XPOS3 = $60
 const XPOS4 = $72

 const YPOS0 = $58
 const YPOS1 = $46 ;70
 const YPOS2 = $32
 const YPOS3 = $1E
 const YPOS4 = $0B

 const CENTERX = $50
 const CENTERY = $36

 ;With the multisprite kernel, the playfield is stored in ROM, so I'm putting it up here with the other constants.
;The playfield is the grid of blocks you'll see on the screen.
;Actually, Roothless is the square in the center of the playfield, to reduce sprite flickering...
 pfheight = 3 ;The playfield blocks will be pretty much square this way.
 playfield:
 ..........
 ..........
 .XXX..XXX.
 .X........
 .X........
 ..........
 ..........
 .X........
 .X........
 .X........
 .........X
 .........X
 .X........
 .X........
 .X........
 ..........
 ..........
 .X........
 .X........
 .XXX..XXX.
 ..........
 ..........
end
; The playfield itself is mirrored to save space... this is done by the multisprite kernel itself.

 ;===
 ;Boot Landing
 ;===
_boot

 drawscreen ;Draw the screen to avoid going over 262 on reset... whatever that means. To be honest, I just saw this in a lot of other programs.
 TextIndex = gameTitleStringOffset
 TextColor = $0F ; Set the text color to let it be visible.
 
 ;===
 ; Game Over Loop 
 ;===

_gameOverLoop

 COLUBK = $42 ; set the background color.

 TextTimer = TextTimer + 1 ; Increment the text timer.
 if TextTimer = 255 then TextIndex = TextIndex + 12 ; Advance to the next string if the text timer is 255.
 if TextIndex > gameOverLoopOffsetLimit then TextIndex = 0 ; Return to the first string if we try to advance past the last one.

 if joy0up then goto _startGame ; Start the game if the joystick button is pressed.

 ; Take care of any sounds that happen to still be playing.
 if channel0SoundTimer = 0 then AUDV0 = 0 else channel0SoundTimer = channel0SoundTimer - 1
 if channel1SoundTimer = 0 then AUDV1 = 0 else channel1SoundTimer = channel1SoundTimer - 1

 drawscreen

 if !switchreset then bit1_resetRestrainer{1} = 0 : goto _gameOverLoop 

 ;Otherwise, restart the game.
 goto _boot


_startGame
 ; =========================
 ; Initialize the game here.
 ; =========================

 ; Initialize relevant variables.
 AUDV0 = 0 : AUDV1 = 0
 AUDC0 = 0 : AUDC1 = 0
 AUDF0 = 0 : AUDF1 = 0
 a = 0 : b = 0 : c = 0 : d = 0 : e = 0 : f = 0 : g = 0 : h = 0 : i = 0 : j = 0 : k = 0 : l = 0 : m = 0 : n = 0 : o = 0 : p = 0 : q = 0 : r = 0 : myLives = 3
 t = 0 : u = 0 : v = 0 : w = 0 : x = 0
 y = 0 : z = 0

 score = 0

 ; Player and enemy sprite data.

;Player 0 is the Avinroo.
 player0:
 %00011000
 %00011000
 %00111100
 %00111100
 %00111100
 %11000011
 %11000011
end


;Player 1 is the guard that roams the top area of the dungeon.
 player1:
 %00100100
 %00100100
 %10111101
 %11111111
 %00011000
 %00111110
 %00110110
 %00111100
end

;Player 2 is the guard that roams the bottom area of the dungeon.
 player2:
 %00100100
 %00100100
 %10111101
 %11111111
 %00011000
 %00111110
 %00110110
 %00111100
end


;Player 3 is the guards(!) that straddle Roothless on the left and right. Defaults looking up
 gosub _sr_player3direction ; See _sr_player3direction for player 3 definitions

;Player 4 is the guard the follows the player around (TODO?).

;Player 5 is not actually a player, but a hack to give me a lives bar without a minikernel.
 player5:
 %00011000
 %00111100
 %01111110
 %11111111
 %11111111
 %01100110
end


;If the left difficulty switch is active, then start up as Abigail (the color of the player will be set to blue at the beginning of each frame).
 if switchleftb then bit2_isAbigail{2} = 1 else bit2_isAbigail{2} = 0

;Set the initial background color and color of the score font.
 COLUBK = $08
 scorecolor = $00

;Set initial sprite positions and speeds.
 
 ;Set the player's initial position to 0 and call the routine that sets the player's location and yoyo's velocity.
 playerPosition = 0
 gosub _sr_movePlayer

 ;For player 1 and the other virtual/multisprited sprites, the origin is at the bottom right (?) as opposed to  the top left.
 ;We'll use rand to randomize the guards' starting positions.

 ;Guard 1 starting position
 player1x = $44 + rand/8
 player1y = $40

 ;Guard 2 starting position
 player2x = $44 + rand/8 ;Center X is $54
 player2y = $20 

 ;Polyguard 3 (The guard on both sides is the same sprite) starting position
 player3x = $44 
 player3y = $20 + rand/8 ;Center Y is $30

 ;Lives counter position
 player5x = $0A
 player5y = $08

 ;Set initial guard speed.
 guardSpeed = 0.5

 ;Randomize the directions of the guards.
 bitX_isGuardFacingLeft = rand

 ;Make sure the yoyo starts out with the player... instead of wherever it feels like being.
 callmacro returnYoyoToPlayer

 ; =======
 ; GAME START!
 ; =======


_beginFrame

 ;===
 ;Frame Upkeep
 ;===


 ;These colors need to be set every frame, as do the values of each NUSIZx we care about.
 COLUBK = $08

 ; Sprite colors must be set every frame with this kernel.
 ; Set the player's color...
 if bit2_isAbigail{2} then COLUP0 = $9C else COLUP0 = $2A

 ; The others need their colors set manually.
 _COLUP1 = $16 : COLUP2 = $F4 : COLUP3 = $66 : COLUP5 = $40

 ; NUSIx settings for each player, where applicable.
 NUSIZ3 = $02 ; 0 == don't change missile, 4 == 2 medium-spaced (origins are 0x20 units apart) copies of player 3
 ; This will make them move identically, which is a little meh, but it will also mean they won't flicker, which is good...
 
 NUSIZ5 = livesNUSIZTable[myLives]
 
 if bit5_blockPreviousPosition{5} then TextIndex = moveAwayErrorStringOffset else TextIndex = gameTitleStringOffset ;If the previous position is blocked, tell the player to move; else just have the title displayed by the text minikernel while the game is active. 
 ;We can display other things, if we want... as long as we have the space to store them in ROM.

 ;===
 ;Yoyo
 ;===

 ;All of the below checks before _start_yoyoMovement used to depend on this bit being off, so to save space, let's just skip them all if this bit is on instead.
 if bit0_isYoyoDeployed{0} then goto _start_yoyoMovement

 ;Don't check for input if we're at a blocked position. 
 if bit5_blockPreviousPosition{5} && previousPositionFiredAt = playerPosition then goto _end_yoyoMovement

 ;The secondary check stops a bug in which the yoyo will not be caught if fire is held during collision.
 if joy0fire && yoyoCooldown = 0 then bit0_isYoyoDeployed{0} = 1 : yoyoCooldown = 8 : callmacro soundInitC0 2 4 14 8 ; The fact that holding down the spacebar can cause the cooldown to be nonzero when the yoyo is caught again could be undesirable, but probably won't matter. 
 
 ;This check should still be here just because it otherwise will cause the yoyo to jitter around.
 if !bit0_isYoyoDeployed{0} then goto _end_yoyoMovement

_start_yoyoMovement
 if yoyoCooldown > 0 then yoyoCooldown = yoyoCooldown - 1
 
;Move the yoyo.
 if bit3_yoyoRetract{3} then yoyoX = yoyoX - yoyoXvelocity : yoyoY = yoyoY - yoyoYvelocity else yoyoX = yoyoX + yoyoXvelocity : yoyoY = yoyoY + yoyoYvelocity

_end_yoyoMovement

 ;If the yoyo collided with the playfield, then it crashed into Roothless, so we get one point. Then, it should bounce back to us.
 ;Yes, Roothless is the two-by-two black square in the middle. What do you think this is, a fancy NES?

 if collision(ball, playfield) && !bit3_yoyoRetract{3} then score = score + 1 : bit3_yoyoRetract{3} = 1 : guardSpeed = guardSpeed + 0.00390625 : callmacro soundInitC0 2 4 9 8 else goto _skip_updatePreviousPosition
 
 ;Now we'll check if this is the same position we fired the yoyo from last time.
 ;If it is, we'll block the current position; the player won't be able to fire a yoyo from there.
 ;Otherwise, we'll update the previous firing position to the current one, then unblock it.
 if previousPositionFiredAt = playerPosition then bit5_blockPreviousPosition{5} = 1 else previousPositionFiredAt = playerPosition : bit5_blockPreviousPosition{5} = 0

_skip_updatePreviousPosition

 ;If the yoyo is touching any of the guards (the virtual sprites), return the yoyo to the player, then decrement lives.
 ;The fact that the guard we run into specifically doesn't matter is actually helpful, because it saves us from checking coordinates of virtual sprites.
 if collision(player1, ball) then callmacro returnYoyoToPlayer : yoyoXvelocity = 0 : yoyoYvelocity = 0 : myLives = myLives - 1 : callmacro soundInitC1 10 6 16 8 
 if myLives = 0 then player5y = 0 : TextIndex = gameOverStringOffset : goto _gameOverLoop ; end the game if we're out of lives.


 ;After all that, if we're touching the yoyo, pick it up.
 ;We check this here so that we can pick up the yoyo even if the fire button is being held down.
 if collision(ball, player0) && yoyoCooldown = 0 then gosub _sr_movePlayer : bit0_isYoyoDeployed{0} = 0 : bit3_yoyoRetract{3} = 0 

 ;We'd probably check if the game was over at this point, but game overs aren't implemented yet.

 ;====
 ;Done with Yoyo
 ;====

 ;===
 ;Player Movement
 ;===

 ; If the movement cooldown is more than 0, decrement it.
 if cooldown > 0 then cooldown = cooldown-1
 if cooldown > 0 then goto _end_setPlayerPosition ;Don't allow the player to move if the cooldown is nonzero.

 ;Don't bother checking for input if the yoyo is deployed.
 if bit0_isYoyoDeployed{0} then goto _end_setPlayerPosition


 ;Check the joystick inputs. Position 0 is the one on the top in the center (like 12 on a clock face), and the others increment upwards clockwise.
 if !joy0right goto _skip_movePlayerRight
 if playerPosition = 11 then playerPosition= 0 else playerPosition= playerPosition +1
 gosub _sr_movePlayer
_skip_movePlayerRight

 if !joy0left goto _skip_movePlayerLeft
 if playerPosition = 0 then playerPosition = 11 else playerPosition = playerPosition -1
 gosub _sr_movePlayer
_skip_movePlayerLeft

 ;Keep the yoyo in the center of the player.
 ballx  = player0x + 4
 bally = player0y - 4

 cooldown = 8 ; set the movement cooldown to 5 frames.

_end_setPlayerPosition
 ;====
 ; Done with player movement
 ;====

 ;===
 ;Enemy AI
 ;===

 if player1x >= $64 then bitX_isGuardFacingLeft{0} = 1
 if player1x <= $44 then bitX_isGuardFacingLeft{0} = 0 
 if bitX_isGuardFacingLeft{0} then guard1x = guard1x - guardSpeed : _NUSIZ1 = $08 else guard1x = guard1x + guardSpeed : _NUSIZ1 = $00

 if player2x >= $64 then bitX_isGuardFacingLeft{1} = 1
 if player2x <= $44 then bitX_isGuardFacingLeft{1} = 0 
 if bitX_isGuardFacingLeft{1} then guard2x = guard2x - guardSpeed : NUSIZ2 = $08 else guard2x = guard2x + guardSpeed : NUSIZ2 = $00

 if player3y >= $40 then bitX_isGuardFacingLeft{2} = 1
 if player3y <= $20 then bitX_isGuardFacingLeft{2} = 0
 if bitX_isGuardFacingLeft{2} then guard3y = guard3y - guardSpeed else guard3y = guard3y + guardSpeed
 gosub _sr_player3direction 
 ;====
 ;Done with enemies
 ;====

 ;===
 ;Sound
 ;===
 if channel0SoundTimer = 0 then AUDV0 = 0 else channel0SoundTimer = channel0SoundTimer - 1
 if channel1SoundTimer = 0 then AUDV1 = 0 else channel1SoundTimer = channel1SoundTimer - 1
 ;===
 ;Done with sound
 ;===

 ; Draw the screen.
 drawscreen
 
 ;===
 ; Reset check
 ;===
 ; Standard behavior for a 2600 program is to reset when the reset switch is pressed. We should follow that standard.

 ;Turn off the reset restrainer bit and jump to the start of the game loop if the reset switch is not pressed.
 if !switchreset then bit1_resetRestrainer{1} = 0 : goto _beginFrame

 ;Otherwise, restart the game.
 goto _boot

 ;===
 ; Subroutines (they all start with _sr_)
 ;===

 ; I used to have a lot of branching logic here, but it's actually way more efficient to have this data all in tables.
 ; the n-th player position corresponds to the n-th value in each table.

 data player0xTable
 XPOS2,  XPOS3,  XPOS4,  XPOS4, XPOS4, XPOS3, XPOS2, XPOS1, XPOS0, XPOS0, XPOS0, XPOS1
end

 data player0yTable
 YPOS0, YPOS0, YPOS1, YPOS2, YPOS3, YPOS4, YPOS4, YPOS4, YPOS3, YPOS2, YPOS1, YPOS0
end

 data yoyoXvelocityintTable
 $00, $FF, $FF, $FF, $FF, $FF, $00, $00, $01, $01, $01, $00
end
 
 data yoyoXvelocityfracTable
 $00, $8C, $00, $00, $00, $8C, $00, $80, $00, $00, $00, $80
end

 data yoyoYvelocityintTable
 $FF, $FF, $FF, $00, $00, $01, $01, $01, $00, $00, $FF, $FF
end 

 data yoyoYvelocityfracTable
 $00, $00, $80, $00, $80, $00, $00, $00, $80, $00, $80, $00
end

_sr_movePlayer
 ; direct placement of "playerPosition" into the brackets seems to make it not compile. This might be a bug with bB...?
 ; Workaround: use "a" instead, which is what playerPosition is dim'd to.
 player0x = player0xTable[a]
 player0y = player0yTable[a]
 yoyoXvelocityint = yoyoXvelocityintTable[a]
 yoyoXvelocityfrac = yoyoXvelocityfracTable[a]
 yoyoYvelocityint = yoyoYvelocityintTable[a]
 yoyoYvelocityfrac = yoyoYvelocityfracTable[a]
 return

_sr_player3direction
 if !bitX_isGuardFacingLeft{2} then goto _player3faceUp
_player3faceDown
 player3:
 %00100100
 %00100100
 %10111101
 %11111111
 %00111100
 %01011010
 %01111110
 %01111110
end
 return
_player3faceUp
  player3:
 %00100100
 %00100100
 %10111101
 %11111111
 %00111100
 %01111110
 %01011010
 %01111110
end
 return

 inline text12b.asm

 inline text12a.asm
