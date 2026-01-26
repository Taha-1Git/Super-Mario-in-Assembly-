
INCLUDE Irvine32.inc
includelib kernel32.lib
includelib winmm.lib


PlaySoundA PROTO :PTR BYTE, :DWORD, :DWORD


mciSendStringA PROTO :PTR BYTE, :PTR BYTE, :DWORD, :DWORD

SND_SYNC    equ 0000h
SND_ASYNC   equ 0001h
SND_FILENAME equ 00020000h

Beep PROTO :DWORD, :DWORD
GetAsyncKeyState PROTO :DWORD

VK_SPACE equ 20h



.data

.data
jumpheight db 4
strcoin BYTE "Coin : ",0

;levelScore BYte "LEVEL : ",0
;healthstr Byte "Health : ",0
;timestr byte "Time : ",0
;score BYTE 0
;timerr dw 400
;lastTickCount dd ?
;fallen db 0
;col db 0



; ========== SKILL TREE SYSTEM ==========
skill_coins db 0              ; Coins spent on skills (separate from score)
base_speed db 50              ; Base delay between movements (lower = faster)
speed_modifier db 0           ; Speed upgrades (-5 per level)
jump_modifier db 0            ; Extra jump height (0-3)
health_modifier db 0          ; Extra starting health (0-2)
score dd 0



; Skill unlock status (0 = locked, 1 = unlocked)

skill_speed1 db 0             ; Speed +10% (5 coins)
skill_speed2 db 0             ; Speed +20% (10 coins)
skill_speed3 db 0             ; Speed +30% (15 coins)

skill_jump1 db 0              ; Jump +1 (7 coins)
skill_jump2 db 0              ; Jump +2 (14 coins)
skill_jump3 db 0              ; Jump +3 (21 coins)

skill_health1 db 0            ; Health +1 (8 coins)
skill_health2 db 0            ; Health +2 (16 coins)

skill_ammo1 db 0              ; Ammo +10 (6 coins)
skill_ammo2 db 0              ; Ammo +20 (12 coins)

max_health db 3               ; Maximum health
starting_ammo db 20           ; Starting ammo per level



; UI Strings
skillTreeTitle db "========== SKILL TREE ==========",0
skillTreeClose db "Press 'T' to close | 'R' to Reset All",0
speedPath db "SPEED PATH:",0
jumpPath db "JUMP PATH:",0
defensePath db "DEFENSE PATH:",0
ammoPath db "AMMO PATH:",0
availableCoins db "Available Coins: ",0
unlockPrompt db "Press number to unlock (if you have coins)",0

; Skill descriptions
speedSkill1 db " Speed +10% (5 coins)",0
speedSkill2 db " Speed +20% (10 coins) [Requires 1]",0
speedSkill3 db " Speed +30% (15 coins) [Requires 2]",0
jumpSkill1 db " Jump +1 (7 coins)",0
jumpSkill2 db " Jump +2 (14 coins) [Requires 4]",0
jumpSkill3 db " Jump +3 (21 coins) [Requires 5]",0
healthSkill1 db " Health +1 (8 coins)",0
healthSkill2 db " Health +2 (16 coins) [Requires 7]",0
ammoSkill1 db " Ammo +10 (6 coins)",0
ammoSkill2 db " Ammo +20 (12 coins) [Requires 9]",0



levelScore BYte "LEVEL : ",0
healthstr Byte "Health : ",0
timestr byte "Time : ",0
coin BYTE 0
timerr dw 400
lastTickCount dd ?
fallen db 0
col db 0
pausemsg db "Game Paused ,Press P to resume ",0


xPos BYTE 3  ;columns 0
yPos BYTE 7;rows 24
prevYPos BYTE 0


xCoinPos BYTE ?
yCoinPos BYTE ?

inputChar BYTE ?

; for gravity
isjumping byte 'f'

;health
health db 3

; for coins
x_coins byte ?
y_coins byte ?


LEVEL_WIDTH  = 132
LEVEL_HEIGHT = 32




    level1 LABEL BYTE
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "          =                             =                                       =                                       =           ",13,10
    BYTE "         ===                           ===   |\\\\\\\\\|                       ===                         ==          ===          ",13,10
    BYTE "        =====                         =====  |         |                      =====                   =======         =====         ",13,10
    BYTE "      ?         |/////|                      |         |                                         ============                       ",13,10
    BYTE "                |     |           @          |         |                                    =================                       ",13,10
    BYTE "                |     |                      |         |                             ========================                       ",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                /|  ",13,10
    BYTE "                                                                                                                               / |  ",13,10
    BYTE "                                                                                                                              /  |  ",13,10
    BYTE "                                                                                                                             /___|  ",13,10
    BYTE "                                                                                                                                 |  ",13,10
    BYTE "                                                     ==========                                                                  |  ",13,10  ; High platform
    BYTE "                                                                                                                                 |  ",13,10
    BYTE "                                                                                                                                 |  ",13,10
    BYTE "                                     ==========                    ==========                                                    |  ",13,10  ; Mid platforms
    BYTE "                                                                                                                                 |  ",13,10
    BYTE "                                                                                                                                 |  ",13,10
    BYTE "                    ==========                     ???                        ==========                                         |  ",13,10  ; Lower platforms
    BYTE "                                                                                                                                 |  ",13,10
    BYTE "                                                                                                                                 |  ",13,10  ; Near ground
    BYTE "                                                                                                                                 |  ",13,10
    BYTE "=========================================    =====================       ========================================================|==",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | |      | | | | | | | | | |         | | | | | | | | | | | | | | | | | | | | | | | | | | | | | ",13,10
    BYTE "========================================     =====================       ========================================================|==",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | |      | | | | | | | | | |         | | | | | | | | | | | | | | | | | | | | | | | | | | | | | ",13,10
    BYTE "========================================     =====================       ========================================================|==",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10

 
 



level2 LABEL BYTE
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                   ------                                                           ",13,10
    BYTE "                                                                   |    |                                                           ",13,10
    BYTE " *---*                                                       ======|    |           |-----                                   *---*  ",13,10
    BYTE " |   |                                                                  |           |               ?                        |   |  ",13,10
    BYTE " |   |                                                  =====           |===========|                                        |   |  ",13,10
    BYTE " |                                                                                                                               |  ",13,10
    BYTE "========             ============             ======================================================================================",13,10                                                                                                                                    
    BYTE "                                                                                                                                    ",13,10
    BYTE "           =======                  ======                                                                                          ",13,10
    BYTE "                                                                                                                               /|   ",13,10
    BYTE "                                                                                                                              / |   ",13,10
    BYTE "                                                                                                                             /  |   ",13,10
    BYTE "                                                                                                                            /   |   ",13,10  ; High platform
    BYTE "                              *---*                                                                                        /----|   ",13,10
    BYTE "         /*\                  |   |                   ?                                                                         |   ",13,10
    BYTE "        /   \                 |   |                                                                                             |   ",13,10  ; Mid platforms
    BYTE "       /     \                    |                                                                                             |   ",13,10
    BYTE "=======       ======================================================================================================================",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |",13,10
    BYTE "====================================================================================================================================",13,10
   

    level3 LABEL BYTE
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                            *-----| ",13,10
    BYTE "                                                                                                                            |     | ",13,10
    BYTE "                                                                                                                            |     | ",13,10
    BYTE "                                                                                                                                  | ",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE " |------*                                                                                                                   *-----| ",13,10
    BYTE " |      |                                                                                                                   |     | ",13,10
    BYTE " |      |                   ====             ====            ====             ====               ====           ==          |     | ",13,10
    BYTE " |                                 ====              ====            ====              ====             ====                      | ",13,10
    BYTE "========================                                                                                           =================",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10  ; High platform
    BYTE "                                                                                                                                /|  ",13,10
    BYTE "                                                                                                                               / |  ",13,10
    BYTE "                                                                                                                              /  |  ",13,10  ; Mid platforms
    BYTE "                                                                                                                             /   |  ",13,10
    BYTE "                                                                                                                            /----|  ",13,10
    BYTE "                                                                                                                                 |  ",13,10
    BYTE " |-----*                               |//////|                             |//////|                                             |  ",13,10
    BYTE " |     |              |/////|          |\\\\\\|                             |\\\\\\|         |/////|                             |  ",13,10
    BYTE " |     |              |\\\\\|          |\\\\\\|                             |//////|         |\\\\\|                             |  ",13,10
    BYTE " |                    |/////|          |//////|                             |\\\\\\|         |/////|                             |  ",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |",13,10
    BYTE "====================================================================================================================================",13,10,0




    level4 LABEL BYTE
 
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                             =======================================",13,10
    BYTE "                                                                                             |                     |                ",13,10
    BYTE "                                                                                             |                     |                ",13,10
    BYTE "                                                                                             |                     |                ",13,10
    BYTE "                                                                                             |                     |                ",13,10
    BYTE "===                                                                                          |                     |                ",13,10
    BYTE "  |                                                                                          |                     |                ",13,10
    BYTE "  |                                                                                          |                     |                ",13,10
    BYTE "  |                                                                                          |                     |                ",13,10
    BYTE "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",13,10
    BYTE "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",13,10
    BYTE "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",13,10
    BYTE "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",13,10
    BYTE "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10,0


   
   


level5 LABEL BYTE
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                THANK YOU                                                                           ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                  FOR SAVING THE PRINCESS                                                           ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                                                                                    ",13,10
    BYTE "                                                                      _________                                                     ",13,10
    BYTE "                                                                      |   |   |                                                     ",13,10
    BYTE "                                                                      |   |   |                                                     ",13,10
    BYTE "                                                                   ___|___|___|___                                                  ",13,10
    BYTE "                                                                  |               |                                                 ",13,10
    BYTE "                                                                  |   PRINCESS    |                                                 ",13,10
    BYTE "                                                                  |    CASTLE     |                                                 ",13,10
    BYTE "                                                                  |               |                                                 ",13,10
    BYTE "                                                                  |     _____     |                                                 ",13,10
    BYTE "                                                                  |    |     |    |                                                 ",13,10
    BYTE "                                                                  |    | [ ] |    |                                                 ",13,10
    BYTE "                                                                  |    |_____|    |                                                 ",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |",13,10
    BYTE "====================================================================================================================================",13,10
    BYTE " | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |",13,10
    BYTE "====================================================================================================================================",13,10,0
 
   


 
     MAXCoins db 12

 coinx db  12,25,43,62,80,96,111,25,82,42,70,58
 coiny db  5,4,3,2,3,4,5,19,19,16,16,13



; Level 2 coins - placed on platforms
MAXCoins2 db 13
coinx2 db  4 , 120 , 100 , 102 ,105,127,32,38,78,4,58,80,63
coiny2 db  7,7,18,7,18,7,18,18,7,3,5,3,3


MAXCoins3 db 13
coinx3 db  4,120,100,102,105,127,32,38,78,4,58,80,63
coiny3 db  6,6,18,6,18,6,18,18,4,3,5,3,3



MAXCoins4 db 13
coinx4 db  4,120,100
coiny4 db  7,7,18

;;;;;;;;;;;;;;;;;;;;
;enemy section

enemy1x db 20
enemy1y db 24

enemy1_alive db 1
dir_enemy_1 db 1



enemy2x db 100
enemy2y db 24

enemy2_alive db 1
dir_enemy_2 db 1


enemy3x db  120
enemy3y db 7

enemy3_alive db 0
dir_enemy_3 db 1


enemy4x db 40
enemy4y db 6

enemy4_alive db 0
dir_enemy_4 db -1


enemy5x db  10
enemy5y db 11

enemy5_alive db 0
dir_enemy_5 db 1


enemy6x db  100
enemy6y db 11

enemy6_alive db 0
dir_enemy_6 db -1





ktx db 100
kty db 7

kt_alive db 0
kt_dir db 1

 currentlevel db 1

 ;;player bullet logic

 px db 0
 py db 0
 pa db 0
 ammo db 20
 ammostr db 'Bullets Left  :',0



 ;;;;;;;;sounds

jumpSound db "smb_coin.wav", 0
polesound db "smb_flagpole.wav",0
jumpsound1 db "smb_jump-small",0
diesound db "smb_mariodie.wav",0
pausesound db "smb_pause.wav",0
worldclear db "smb_world_clear.wav",0
power db "smb_powerup",0
fires db "smb_fireball",0
pipe db "smb_pipe.wav",0
stageclear db "smb_stage-clear.wav",0

jumpCount db 0                  ; Tracks how many times we jumped (0, 1, or 2)
soundJump2 db "smb_kick.wav", 0 ; Name of file for the double jump sound
                                ; (Ensure you have a wav file with this name)



; --- MCI COMMANDS ---
cmdClose      db "close bgm", 0
cmdPlay       db "play bgm repeat", 0
cmdStop       db "stop bgm", 0

; Define specific commands for each level

; Ensure these files exist in your folder!
cmdOpenLvl1   db "open level1sound.wav type MPEGVideo alias bgm", 0
cmdOpenLvl2   db "open level2sound.wav type MPEGVideo alias bgm", 0
cmdOpenLvl3   db "open level3sound.wav type MPEGVideo alias bgm", 0
cmdOpenLvl4   db "open level4sound.wav type MPEGVideo alias bgm", 0


welcomeTitle1 BYTE "  _____ _    _ _____  ______ _____  ",13,10
              BYTE " / ____| |  | |  __ \|  ____|  __ \ ",13,10
              BYTE "| (___ | |  | | |__) | |__  | |__) |",13,10
              BYTE " \___ \| |  | |  ___/|  __| |  _  / ",13,10
              BYTE " ____) | |__| | |    | |____| | \ \ ",13,10
              BYTE "|_____/ \____/|_|    |______|_|  \_\",13,10,0

welcomeTitle2 BYTE "  __  __          _____  _____ ____  ",13,10
              BYTE " |  \/  |   /\   |  __ \|_   _/ __ \ ",13,10
              BYTE " | \  / |  /  \  | |__) | | || |  | |",13,10
              BYTE " | |\/| | / /\ \ |  _  /  | || |  | |",13,10
              BYTE " | |  | |/ ____ \| | \ \ _| || |__| |",13,10
              BYTE " |_|  |_/_/    \_\_|  \_\_____\____/ ",13,10,0

rollNumberMsg BYTE "         Roll Number: 24I-0584",13,10,0

menuOption1 BYTE "  1. Start Game",0
menuOption2 BYTE "  2. High Scores",0
menuOption3 BYTE "  3. Instructions",0
menuOption4 BYTE "  4. Exit",0
.data
; Add this with your other menu strings
menuOption5 BYTE "  5. Load Game",0

menuPrompt BYTE "  Select Option (1-4): ",0

bigMario LABEL BYTE
    BYTE " "
    BYTE "        _____",13,10
    BYTE "        _|*|*|_",13,10
    BYTE "       |  |_|  |",13,10
    BYTE "      _| >_O_< |_",13,10
    BYTE "     | |_/| |\_| |",13,10
    BYTE "    _|_____|_____|_",13,10
    BYTE "   |     (|_|)     |",13,10
    BYTE "   |     /| |\     |",13,10
    BYTE "   |____/ | | \____|",13,10
    BYTE "       |  | |  |",13,10
    BYTE "       |__| |__|",13,10
    BYTE "       |  | |  |",13,10
    BYTE "      _|  | |  |_",13,10
    BYTE "     |_____|_____|",0

; ========================================
; INSTRUCTIONS DATA
; ========================================
instructTitle BYTE "===== INSTRUCTIONS =====",13,10,0
instruct1 BYTE "MOVEMENT:",13,10
          BYTE "  A - Move Left",13,10
          BYTE "  D - Move Right",13,10
          BYTE "  W - Jump",13,10
          BYTE "  Q - Jump Left",13,10
          BYTE "  E - Jump Right",13,10,0

instruct2 BYTE "COMBAT:",13,10
          BYTE "  F - Shoot Bullet",13,10
          BYTE "  Jump on enemies to defeat them",13,10,0

instruct3 BYTE "OBJECTIVE:",13,10
          BYTE "  Collect coins (C)",13,10
          BYTE "  Defeat enemies",13,10
          BYTE "  Reach the end of each level",13,10
          BYTE "  Collect mushrooms (@) for health",13,10,0

instruct4 BYTE "Press any key to return to menu...",0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; =============================================================
;               PERFECT HIGH SCORE SYSTEM DATA
; =============================================================
hs_filename     BYTE "high.txt", 0
hs_fileHandle   HANDLE ?

; Data Structures for Top 10
; We store 10 scores. Names are fixed 16 bytes (15 chars + null).
scoreArray      DWORD 10 DUP(0)          
nameArray       BYTE  10 DUP(16 DUP(0))  
itemCount       DWORD 0                  

; File Buffers
hs_buffer       BYTE 5000 DUP(?)          
hs_bufSize      DWORD ?
hs_strBuffer    BYTE 20 DUP(?)            
hs_comma        BYTE ",", 0
hs_newLine      BYTE 0Dh, 0Ah, 0          

; Temporary var for Sorting swaps
tempNameBuf     BYTE 16 DUP(?)

; UI Text
msgHeader       BYTE "================ TOP 10 SCORES ================", 0Dh, 0Ah, 0
msgRank         BYTE ". ", 0
msgPoints       BYTE " pts", 0Dh, 0Ah, 0
msgNoHighScores BYTE "No high scores yet! Play the game to set one.", 0Dh, 0Ah, 0
msgPressKey     BYTE 0Dh, 0Ah, "Press any key to return...", 0






; High score arrays (Top 10)
playerNames BYTE 10 DUP(20 DUP(?))  ; 10 names, 20 chars each
playerScores DWORD 10 DUP(?)        ; 10 scores

namePrompt BYTE "Enter Your Name (max 15 chars): ", 0
playerName BYTE 20 DUP(?), 0


.data
; ... existing data ...

; File Config

; Buffers for Text Processing
commaStr        BYTE ",", 0
newLineStr      BYTE 13, 10, 0   ; Carriage Return + Line Feed
charBuf         BYTE ?           ; To read 1 character at a time
numBuffer       BYTE 20 DUP(0)   ; To convert numbers to string
readBuffer      BYTE 50 DUP(0)   ; Temp buffer for reading lines

; ... existing arrays ...



; Victory Messages
victoryMsg1 db "================================================",0
victoryMsg2 db "        CONGRATULATIONS!",0
victoryMsg3 db "    YOU SAVED THE PRINCESS!",0
victoryMsg4 db "      THANK YOU HERO!",0
victoryMsg5 db "================================================",0
victoryMsg6 db "      Final Score: ",0
victoryMsg7 db "   Press ANY KEY to exit...",0



; for loading game


loopCount DWORD ?






.code
main PROC
    call GetMseconds
    mov lastTickCount, eax
   
    call LoadHighScores

StartNewSession:
 
    call ResetGame

 
    call ShowWelcomeScreen
   
 
    cmp eax, 5
    je PerformLoad

     jmp SetupLevel

PerformLoad:
   
    call LoadGame
   

SetupLevel:
   
    call InitializeSkills
    call LoadLevel          ; Will load the map based on 'currentlevel'
    call DrawPlayer
    call drawcoin
    call setcolors1
    call PlayCurrentLevelMusic

   
    jmp gameLoop


   
gameLoop:
   
   cmp currentlevel,1
   jne sk

   cmp xpos,34
   jne sk
   cmp ypos, 6
   jne sk 

   ;inc height of jump 
   mov jumpheight , 6

   sk:


    CheckSpaceSound:
    INVOKE GetAsyncKeyState, VK_SPACE
    test ax, 8000h
    jz noSpace

    ; Play beep
    INVOKE Beep, 800, 120     ; 800 Hz for 120 ms

noSpace:


    cmp currentlevel,4
    jne co
    cmp ypos,24
    jl co
     call updateplayer
   push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR diesound, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
     dec health
    mov ypos,19
    mov xpos,0

   ;  call ApplySkillModifiers

    ;call updateplayer
    call drawplayer
     ; call updateplayer

    co:

  ;  call drawmountain

   
   

  call  checklevel2mushroom
  call  checklevel22mushroom
  call checkmushroom

   cmp currentlevel,3

    jne conti
    cmp ypos,24
    jne conti
    cmp xpos,127
    jne conti

    call celebration
   
    ; ===== SWITCH TO LEVEL 4 =====
    mov currentlevel,4
    mov v_enemy_alive,0
    mov enemy4_alive,0
    mov enemy5_alive,0
    mov enemy6_alive,0

    ; Initialize Bowser for Level 4
    mov bowser_alive, 1
    mov bowser_health, 2
    mov bowser_x, 107
    mov bowser_y, 15
    mov bowser_fire_alive, 0
    mov bowser_fire_delay, 0
    mov bowser_step, 0
    mov bowser_move_delay, 0
    mov bowser_dir, 1
     mov platform_y, 20
    mov platform_dir, -1
    mov platform_delay, 0

    call PlayCurrentLevelMusic

    call clrscr
    call loadlevel
        call ApplySkillModifiers  
    call drawcoin
     call draw_moving_platform





    ; Player position at start of level 4
    mov xPos, 0
    mov yPos, 19
    call DrawPlayer
    call drawcoin
    jmp gameLoop    ; Continue to main loop


    conti:


    ;;level 3 special enemy

    cmp currentlevel,3
jne skip_v_enemy
cmp v_enemy_alive,1
jne skip_v_enemy
call update_v_enemy
call draw_v_enemy





skip_v_enemy:

; ===== LEVEL 4 BOWSER UPDATES =====
cmp currentlevel, 4
jne skip_bowser_updates
cmp bowser_alive, 1
jne skip_bowser_updates
call update_bowser
call update_bowser_fire
skip_bowser_updates:


; ===== END BOWSER UPDATES =====

  ;call update_moving_platform


cmp currentlevel,3
jne skipnormalenmeycheck
call draw_normal_enemy


skipnormalenmeycheck:

    cmp currentlevel,3
    jne moveon

    call level3_floor2

    moveon:

    call checkkptcollision
      cmp currentlevel,2
      jne check_next

      cmp kt_alive,1
      jne check_next

    call  update_kt
    call draw_kt
    check_next:
   
    cmp currentlevel,2
    jne nneexxtt
     cmp enemy3_alive,1
   jne nneexxtt
   mov al , enemy3y
   cmp al,ypos
   jne nneexxtt
   mov ah, enemy3x
   cmp ah,xpos
   jne nneexxtt

      push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR diesound, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
   sub health,1
   mov eax , 500

   call delay

   mov ypos,7
   mov xpos,2
    nneexxtt:

   


    call update_flying_enemy
    call update_bullet
;call playerbullet


   call checklevel2tunnels
   call checklevel2tunnels2


   
   cmp currentlevel ,1
   jne con
   cmp ypos,7
   jne con
   cmp xpos,128
   jne con

   mov dl,xpos
   mov dh,ypos
   call gotoxy
   mov al,' '
   call writechar

   mov xpos,0
   mov ypos,24

   call updateplayer

   con:

    cmp ypos, 24  
   
jne no_reset
mov fallen, 0    
no_reset:


    call pitfall
    cmp fallen,1
    jne remaining
 mov   xPos,0
mov yPos , 24
   remaining :

    call checklevel3

 

    cmp health , 0

    jne connt
      push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR diesound, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx

   jmp exitgame
    connt:

    cmp timerr , 0
    je exitgame



    cmp enemy2_alive ,1
    jne l2
      cmp currentlevel,1
      jne l2
      call draw_normal_enemy
    l2:
    cmp enemy1_alive ,1
    jne next
    cmp currentlevel,1
    jne next
call draw_normal_enemy


 


   next:
   cmp currentlevel, 1
   jne continue
   push ecx
   movzx ecx, xpos
   cmp xpos,128

 
   jae switchtolevel2
   pop ecx
  jmp continue



switchToLevel2:
call celebration
    mov currentLevel, 2
    mov enemy1_alive,0
        mov enemy2_alive,0
        mov enemy3_alive,1
        mov kt_alive,1
        call draw_kt
         mov bullet_alive, 0    
         mov f_enemy_alive,1

    mov bulletDelay, 0      
    call Clrscr             ; Clear screen

    call LoadLevel         ; Load level 2
    mov xPos, 0             ; Reset player to left side
    mov yPos, 18            ; Reset to ground level
    call PlayCurrentLevelMusic

     call ApplySkillModifiers

    call DrawPlayer
    call drawcoin
   ; call checkcoincollision
    jmp gameLoop




   continue:

 
   
   ;inc enemy1y
    cmp enemy2_alive,1
   jne bb
   mov al , enemy2y
   cmp al,ypos
   jne bb
   mov ah, enemy2x
   cmp ah,xpos
   jne bb

   
   sub health,1
   mov eax , 500

   call delay

  mov xPos, 0  ;columns 0
mov yPos,24 ;rows 24

call updateplayer
call drawplayer
   


  ; call removeenemy2

   bb:

   cmp enemy1_alive,1
   jne cc
   mov al , enemy1y
   cmp al,ypos
   jne cc
   mov ah, enemy1x
   cmp ah,xpos
   jne cc
   

  ; call removeenemy1

     push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR diesound, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
   sub health,1
   mov eax , 500
   call delay
    mov xPos, 0  ;columns 0
mov yPos,24 ;rows 24

call updateplayer
call drawplayer
   


 cc:


; Check V-enemy collision (Level 3)
cmp currentlevel,3
jne skip_v_check
cmp v_enemy_alive,1
jne skip_v_check
mov al, v_enemy_y
cmp al, ypos
jne skip_v_check
mov ah, v_enemy_x
cmp ah, xpos
jne skip_v_check

; Hit by V-enemy
   push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR diesound, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
sub health,1
mov eax, 500
call delay
mov xPos, 0
mov yPos, 24
call updateplayer
call drawplayer

skip_v_check:

call update_enemy1

 cmp currentlevel, 4
    jne skip_platform_update
    call update_moving_platform
    skip_platform_update:
 



gravity:
    call CheckSolidBelow
    cmp al,1            ; if the function returns 1 in al then it means it is on ground/platform
    je onground
   
    ; If not on ground, fall down (ONE space only)
    call UpdatePlayer
    inc yPos            ; Only increment by 1
    call DrawPlayer
    call CheckCoinCollision

onground:
mov jumpcount,0
   call update_player_bullet
    mov eax,50
    call Delay


   
  call GetMseconds
mov ebx, lastTickCount
sub eax, ebx        ; elapsed ms
cmp eax, 1000
jl skipTimerUpdate

; 1 second passed
dec timerr
add lastTickCount, 1000  ; don't set it to eax

   skipTimerUpdate:

    mov eax,blue + (black * 16)
    call SetTextColor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;display data

        .data
        strscore db "Score : ",0
        .code

; draw score:
mov dl,0
mov dh,0
call Gotoxy
mov edx,OFFSET strcoin
call WriteString
mov al,coin
call WriteInt



        ; draw level
mov dl,20
mov dh,0
call Gotoxy
mov edx,OFFSET levelScore
call WriteString
       
mov al,currentlevel
       ; dec al
call WriteInt


        ; writehealth



        mov dl,40
mov dh,0
call Gotoxy
mov edx,OFFSET healthstr
call WriteString
       
mov al,health
     
call WriteInt



        ; write timer

          mov dl,60
mov dh,0
call Gotoxy
mov edx,OFFSET timestr
call WriteString
       
movzx eax,timerr
     
call WriteDec

        mov al ,' '
        call writechar
        call writechar




     

    ; Display ammo - ADD THIS BLOCK
mov dl,80
mov dh,0
call Gotoxy
mov edx,OFFSET ammostr
call WriteString
movzx eax,ammo
call WriteDec
mov al,' '
call writechar
call writechar



        ; draw score:
mov dl,100
mov dh,0
call Gotoxy
mov edx,OFFSET strscore
call WriteString
mov eax,score
call WriteInt




mov eax,white + (black * 16)
call SetTextColor


; get user key input:
call ReadKey
        jz noinput
mov inputChar,al


     

; exit game if user types 'x':
cmp inputChar,"x"
je exitGame

cmp inputChar,"w"
je moveUp

cmp inputChar,"s"
je moveDown

cmp inputChar,"a"
je moveLeft

cmp inputChar,"d"
je moveRight

        cmp inputChar,"e"
        je jumpright

         cmp inputChar,"q"
        je jumpleft


       cmp inputChar,"f"          
je shootBullet

        cmp inputChar,"t"
        je openSkillTree
       
        cmp inputChar,"T"
        je openSkillTree    
       

        ; In gameLoop, after ReadKey:
cmp inputChar, 'p'



je PauseGame
.data
whatlevel db ?
whattime db ?
.code
PauseGame:
  push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR pausesound, 0,  SND_SYNC (0) OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
mov al,currentlevel
mov whatlevel,al
    call Clrscr
    mov dh, 12
    mov dl, 50
    call Gotoxy
    mov edx, OFFSET pauseMsg  ; "PAUSED - Press P to Resume"
    call WriteString
WaitUnpause:
    call ReadChar
    cmp al, 'p'
    je Resume
    cmp al, 'l'       ; Press 'L' to Save (Log)
    je DoSave
    jmp WaitUnpause

DoSave:
    call SaveGame
    jmp WaitUnpause   ; Return to pause loop
Resume:
; ----- Player pressed P ? restore colors depending on level -----

    mov al, whatlevel
    cmp al, 1
    jne SkipColorRestore
    call setcolors1


    call Clrscr
call LoadLevel
call DrawPlayer
call setcolors1        ; <— now the colors stick!
call drawcoin
jmp gameLoop


SkipColorRestore:
    call Clrscr
    call LoadLevel
    call DrawPlayer
    call drawcoin
    jmp gameLoop


jmp gameloop

shootBullet:                
    call playerbullet
    jmp gameloop

openSkillTree:
    call DisplaySkillTree
    jmp gameloop


        jmp gameloop


       
        jumpright:
    call CheckSolidBelow
    cmp al,0
    je gameLoop         ; Not on ground
      push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR jumpsound1, 0, SND_ASYNC OR SND_FILENAME

     pop edi
   pop esi
   pop ecx             ; Restore Loop Counter so the loop continues correctl

    movzx ecx,jumpheight
jumpLoop2:

    ; CHECK DIAGONAL BLOCK
    mov al,xPos
    add al,2            ; you move 2 right
    mov ah,yPos
    dec ah              ; jump upward
    call CheckCollision

    cmp al, 2
je specialHit       ; player hit [?] from below

    cmp al,1
    je gameLoop         ; BLOCKED ? stop jump





     ; CHECK DIAGONAL BLOCK
    mov al,xPos
    add al,3            ; you move 3 right
    mov ah,yPos
    dec ah              ; jump upward
    call CheckCollision

    cmp al, 2

je specialHit       ; player hit [?] from below
    cmp al,1
    je gameLoop         ; BLOCKED ? stop jump




    call UpdatePlayer

    dec yPos            ; jump up
    add xPos,2          ; jump right

    call DrawPlayer
    call CheckCoinCollision

    mov eax,70
    call Delay
loop jumpLoop2
jmp gameLoop




     jumpleft:
    call CheckSolidBelow
    cmp al,0
    je gameLoop

    movzx ecx,jumpheight

      push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR jumpsound1, 0, SND_ASYNC OR SND_FILENAME

     pop edi
   pop esi
   pop ecx             ; Restore Loop Counter so the loop continues correctl

jumpLoop3:

    ; CHECK DIAGONAL BLOCK
    mov al,xPos
    sub al,2            ; moving left 2
    mov ah,yPos
    dec ah
    call CheckCollision
    cmp al, 2
je specialHit       ; player hit [?] from below
    cmp al,1
    je gameLoop


     mov al,xPos
    sub al,3            ; moving left 2
    mov ah,yPos
    dec ah
    call CheckCollision
    cmp al, 2
je specialHit       ; player hit [?] from below
    cmp al,1
    je gameLoop

    call UpdatePlayer

    dec yPos
    sub xPos,2

    call DrawPlayer
    call CheckCoinCollision

    mov eax,70
    call Delay
loop jumpLoop3
jmp gameLoop


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



        moveUp:
    ; 1. Check if we have jumps remaining (Max 2)
    cmp jumpCount, 2
    jge gameLoop         ; If jumps >= 2, ignore key press

    ; 2. Increment Jump Count
    inc jumpCount

    ; 3. Save Registers before playing sound (Prevent Crash)
    push ecx          
    push esi            
    push edi            

    ; 4. Decide which sound to play
    cmp jumpCount, 2
    je play_second_sound

    ; Play First Jump Sound
    INVOKE PlaySoundA, ADDR jumpsound1, 0,  SND_ASYNC  OR SND_FILENAME
    jmp sound_done

play_second_sound:
    ; Play Double Jump Sound
    INVOKE PlaySoundA, ADDR soundJump2, 0, SND_ASYNC OR SND_FILENAME

sound_done:
    ; 5. Restore Registers
    pop edi
    pop esi
    pop ecx

    ; 6. Perform the Physical Jump
    movzx ecx, jumpheight
   
    jumpLoop:
        ; Check if ceiling above
        mov al,xPos
        mov ah,yPos
        dec ah
        call CheckCollision
        cmp al, 2
        je specialHit       ; player hit [?] from below
        cmp al,1
        je gameLoop         ; Hit ceiling, stop
       
        call UpdatePlayer
        dec yPos
        call DrawPlayer
        call CheckCoinCollision ; Checks coin while moving up
        mov eax, 70
        call Delay
    loop jumpLoop
    jmp gameLoop

moveDown:
call UpdatePlayer

cmp yPos , 24
je nodown
add yPos,2
nodown :

;inc yPos

call DrawPlayer
         call CheckCoinCollision
jmp gameLoop


  moveLeft:
    ; Check for wall on left
    mov al,xPos
    dec al
    mov ah,yPos
    call CheckCollision

    cmp al,1
    je noleft2          ; Hit wall
   
    call UpdatePlayer
    cmp xPos,0
    je noleft
    dec xPos
noleft:
    call DrawPlayer
    call CheckCoinCollision
    jmp gameLoop
noleft2:
    jmp gameLoop

moveRight:
    ; Check for wall on right
    mov al,xPos
    inc al
    mov ah,yPos
    call CheckCollision
    cmp al,1
    je noright2         ; Hit wall
   
    call UpdatePlayer
    inc xPos
    call DrawPlayer
    call CheckCoinCollision
    jmp gameLoop
noright2:
    jmp gameLoop


        noInput:

 
    mov al, yPos
    mov prevYPos, al

    jmp gameLoop

    specialHit:

    ; erase the [?] block
   ; --------------------------------------
; 1. ERASE TILE ON SCREEN
; --------------------------------------
mov dl, xPos
mov dh, yPos
dec dh
call Gotoxy
mov al, '='          ; for “used” block (or use ' ')
call WriteChar

; going to that address and then adding dh,dl removing the ?

; AL = X coordinate
mov al, xPos

; AH = Y coordinate (head position)
mov ah, yPos
dec ah               ; tile Mario hit

push eax            
push edx            

; EBX = Y, ECX = X
movzx ebx, ah
movzx ecx, al


mov eax, ebx
mov edx, LEVEL_WIDTH + 2
mul edx
add eax, ecx        

; choose level base
cmp currentlevel, 1

je _useL1
cmp currentlevel, 2

je _useL2
cmp currentlevel, 3

je _useL3
jmp _useL1

je _useL4
jmp _useL4

_useL1:
    mov esi, OFFSET level1
    jmp _writeBlock

_useL2:
    mov esi, OFFSET level2
    jmp _writeBlock

_useL3:
    mov esi, OFFSET level3
    jmp _writeBlock
_useL4:
 mov esi, OFFSET level4
    jmp _writeBlock

_writeBlock:
    add esi, eax
    mov BYTE PTR [esi], '='    
                               

pop edx
pop eax

   cmp currentlevel,1
   jg c2
      push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR power, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
     add score,100
    inc health        ; or INC score, etc.
    jmp cal

    c2:
      cmp currentlevel,1
   jg c3
      push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR power, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
     add score,100
    inc coin
    jmp cal

    c3:
     add score,100
   add coin,2
      push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR power, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx


    cal:

 
    mov eax, 80
    call Delay

    jmp gameLoop


exitGame:



  
    call AddHighScore  
   
  
    call ShowHighScores
   
  
    jmp StartNewSession

   exit_game:
    call Clrscr
    pop edx
    pop eax
    exit        ; This effectively closes the program


   
exit
main ENDP


DrawPlayer PROC
; draw player at (xPos,yPos):

    push eax
    mov eax,green+ (black * 16)
    call SetTextColor
   
mov dl,xPos
mov dh,yPos
call Gotoxy
mov al,"X"
call WriteChar



    mov eax,white + (black * 16)
    call SetTextColor

    pop eax


ret
DrawPlayer ENDP

UpdatePlayer PROC
mov dl,xPos
mov dh,yPos
call Gotoxy
mov al," "
call WriteChar
ret
UpdatePlayer ENDP

LoadLevel PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

     cmp currentlevel, 5
    jne check_level_4
    mov esi, OFFSET level5
    mov ecx, LEVEL_HEIGHT
    jmp drawRow

    check_level_4:
   
    cmp currentlevel,4
    jne checknextlevel2
     mov esi, OFFSET level4       ; pointer to level data
    mov ecx, LEVEL_HEIGHT        ; row counter
    jmp drawRow

    checknextlevel2:

    cmp currentlevel,3
    jne checknextlevel
     mov esi, OFFSET level3       ; pointer to level data
    mov ecx, LEVEL_HEIGHT        ; row counter
    jmp drawRow


    checknextlevel:
    cmp currentlevel , 1
    je lvvl1
     mov esi, OFFSET level2       ; pointer to level data
    mov ecx, LEVEL_HEIGHT        ; row counter
    jmp drawRow

    lvvl1:
    mov esi, OFFSET level1       ; pointer to level data
    mov ecx, LEVEL_HEIGHT        ; row counter
    xor ebx, ebx                 ; row index = 0

drawRow:
    cmp ecx, 0
    je done

    ; Position cursor at start of row
    mov dl, 0
    mov dh, bl
    call Gotoxy

    ; Print 132 characters manually
    mov edi, LEVEL_WIDTH         ; 132 chars per row
printChars:
    mov al, [esi]            ; read character

    ; --- color decision ---
    cmp al, '@'
    jne normalColor

    ; @ -> green
    push eax
    mov eax, green + (black * 16)
    call SetTextColor
    pop eax
    jmp printIt

normalColor:
    push eax
    mov eax, white + (black * 16)
    call SetTextColor
    pop eax

printIt:
    call WriteChar           ; print character

    inc esi
    dec edi
    jnz printChars


   
    add esi, 2                   ; skip 13,10

    inc ebx
    dec ecx
    jmp drawRow

done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
LoadLevel ENDP


CheckCoinCollision PROC
    push eax
    push ecx
    push esi
    push edi
    push edx

    cmp currentlevel,4
    jne chek3
      movzx ecx, MAXCoins4              ; Number of coins
    mov esi, OFFSET coinx4
    mov edi, OFFSET coiny4
      jmp  nextcoin

      chek3:

    cmp currentlevel,3
    jne checknext
    movzx ecx, MAXCoins3              ; Number of coins
    mov esi, OFFSET coinx3
    mov edi, OFFSET coiny3
      jmp  nextcoin

    checknext :
    cmp currentlevel,1
    je lvlccc1
      movzx ecx, MAXCoins2              ; Number of coins
    mov esi, OFFSET coinx2
    mov edi, OFFSET coiny2

   jmp  nextcoin
    lvlccc1:

    movzx ecx, MAXCoins              ; Number of coins
    mov esi, OFFSET coinx
    mov edi, OFFSET coiny

nextCoin:
    ; Check if coin already collected (marked as 255)
    mov al, [esi]
    cmp al, 255
    je skipCoin

    ; Check X position
    mov al, [esi]
    cmp al, xPos
    jne skipCoin

    ; Check Y position
    mov al, [edi]
    cmp al, yPos
    jne skipCoin

   ; ===== COIN COLLECTED! =====
   push ecx            ; Save Loop Counter
   push esi            ; Save X Array Pointer
   push edi            ; Save Y Array Pointer
   


    INVOKE PlaySoundA, ADDR jumpSound, 0, SND_ASYNC OR SND_FILENAME


    pop edi
    pop esi
    pop ecx

     add score,200
    inc coin
    inc skill_coins          ; Also add to skill currency

    ; Erase coin from screen
    mov dl, [esi]
    mov dh, [edi]
    call Gotoxy
    mov al, ' '
    call WriteChar
    call drawplayer
    ; Mark coin as collected (so we don't collect it again)
    mov BYTE PTR [esi], 255
    mov BYTE PTR [edi], 255

skipCoin:
    inc esi
    inc edi
    loop nextCoin

    pop edx
    pop edi
    pop esi
    pop ecx
    pop eax
    ret
CheckCoinCollision ENDP
drawcoin proc
    push ecx
    push edi
    push esi
    push eax     ; Save EAX as well
    push edx     ; Save EDX

    cmp currentlevel, 4
    jne checklvl3_dc

    ; Setup Level 4
    mov edi, offset coinx4
    mov esi, offset coiny4
    movzx ecx, MAXCoins4
    jmp l1_dc

checklvl3_dc:
    cmp currentlevel, 3
    jne checknext_dc

    ; Setup Level 3
    mov edi, offset coinx3
    mov esi, offset coiny3
    movzx ecx, MAXCoins3
    jmp l1_dc

checknext_dc:
    cmp currentlevel, 1
    je lvl1_dc

    ; Setup Level 2
    mov edi, offset coinx2
    mov esi, offset coiny2
    movzx ecx, MAXCoins2
    jmp l1_dc

lvl1_dc:
    ; Setup Level 1
    mov edi, offset coinx
    mov esi, offset coiny
    movzx ecx, MAXCoins

l1_dc:
    ; === FIX: CHECK IF COIN IS COLLECTED ===
    mov al, [edi]       ; Get X coordinate from array
    cmp al, 255         ; Check if it is 255 (Collected)
    je skip_drawing     ; If collected, skip drawing code
    ; =======================================

    mov dl, [edi]
    mov dh, [esi]
    call gotoxy
   
    mov eax, yellow + (black * 16)
    call SetTextColor
   
    mov al, 'C'
    call WriteChar
   
    mov eax, white + (black * 16)
    call SetTextColor

skip_drawing:
    inc esi
    inc edi
    loop l1_dc

    pop edx
    pop eax
    pop esi
    pop edi
    pop ecx
    ret
drawcoin endp

CheckCollision PROC
    ; Input: AL = X position, AH = Y position
    ; Output: AL = 1 if solid block (=), 0 if empty
    push ebx
    push ecx
    push edx
    push esi

    movzx ebx,ah        ; Y position
    movzx ecx,al        ; X position

    ; Boundary checks
    cmp ebx,26
    jge isSolid
    cmp ecx,132 ;;check till the 132 column
    jge isEmpty

    ; offset = Y * (LEVEL_WIDTH + 2) + X
    mov eax,ebx
    mov edx,LEVEL_WIDTH + 2
    mul edx
    add eax,ecx

    ; ===== FIX: Proper level selection =====
    cmp currentlevel, 1
    je uselevel1
   
    cmp currentlevel, 2
    je uselevel2
   
    cmp currentlevel, 3
    je uselevel3
   
    cmp currentlevel, 4
    je uselevel4
   

uselevel1:
    mov esi, OFFSET level1
    jmp checkChar

uselevel2:
    mov esi, OFFSET level2
    jmp checkChar

uselevel3:
    mov esi, OFFSET level3
    jmp checkChar

uselevel4:
    mov esi, OFFSET level4
    jmp checkChar

    ; ========================================

checkChar:
    add esi,eax
    mov al,[esi]

    ; Check if it's a solid character
    cmp al,'='
    je isSolid
    cmp al,'*'
    je isSolid
    cmp al,'|'              
    je isSolid
    cmp al,'?'
    je isSpecial
    cmp al,'\'
    je isSolid
    cmp al,'/'
    je isSolid
     cmp al,'-'
    je isSolid
    cmp al,'~'
je isSolid

isEmpty:
    mov al,0
    jmp doneCollision

isSolid:
    mov al,1
    jmp doneCollision

    isSpecial:
    mov al, 2      ; return 2 = special block
    jmp doneCollision


doneCollision:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
CheckCollision ENDP
CheckSolidBelow PROC
push ebx
push ecx
push edx

    ; ONLY check platform if in Level 4
    cmp currentlevel, 4
    jne skip_platform_check
   
    call check_on_moving_platform
    cmp al, 1
    je platform_is_solid
   
skip_platform_check:
   
    ; Normal collision check
    mov al, xpos
    mov ah, yPos
    inc ah
   
    cmp ah, 25
    jg atBottom
   

    call checkcollision
    jmp doneSolidCheck
   
atBottom:
    mov al, 1
    jmp doneSolidCheck
   
platform_is_solid:
    mov al, 1
   
doneSolidCheck:
    pop edx
    pop ecx
    pop ebx
    ret
CheckSolidBelow ENDP

draw_kt proc
  push eax


  cmp kt_alive ,1
  jne skip


  mov dl,ktx
mov dh,kty
call Gotoxy
mov al,"K"
call WriteChar


  skip:


  pop eax
  ret
draw_kt endp

draw_normal_enemy proc
    push eax
   
    mov eax, green + (black * 16)
    call SetTextColor
   
    ; Draw Level 1 enemies
    cmp currentlevel, 1
    jne check_level2_enemies
   
    cmp enemy1_alive, 1
    jne check_enemy2_level1
    mov dl, enemy1x
    mov dh, enemy1y
    call Gotoxy
    mov al, "Y"
    call WriteChar
   
check_enemy2_level1:
    cmp enemy2_alive, 1
    jne done_drawing
    mov dl, enemy2x
    mov dh, enemy2y
    call Gotoxy
    mov al, "Y"
    call WriteChar
    jmp done_drawing
   
check_level2_enemies:
    ; Draw Level 2 enemy
    cmp currentlevel, 2
    jne check_level3_enemies
   
    cmp enemy3_alive, 1
    jne done_drawing
    mov dl, enemy3x
    mov dh, enemy3y
    call Gotoxy
    mov al, "Y"
    call WriteChar
    jmp done_drawing
   
check_level3_enemies:
    ; Draw Level 3 enemies
    cmp currentlevel, 3
    jne done_drawing
   
    cmp enemy4_alive, 1
    jne check_enemy5_level3
    mov dl, enemy4x
    mov dh, enemy4y
    call Gotoxy
    mov al, "Z"
    call WriteChar

check_enemy5_level3:
    cmp enemy5_alive, 1
    jne check_enemy6_level3
    mov dl, enemy5x
    mov dh, enemy5y
    call Gotoxy
    mov al, "Z"
    call WriteChar

check_enemy6_level3:
    cmp enemy6_alive, 1
    jne done_drawing
    mov dl, enemy6x
    mov dh, enemy6y
    call Gotoxy
    mov al, "Z"
    call WriteChar

done_drawing:
    mov eax, white + (black * 16)
    call SetTextColor
   
    pop eax
    ret
draw_normal_enemy endp



removeenemy1 proc

    push eax
   

mov dl,enemy1x
mov dh,enemy1y
call Gotoxy
mov al," "
call WriteChar

  mov  enemy1_alive , 0
    pop eax


ret

removeenemy1 endp





.data
enemy1_step db 0
enemy2_step db 0
enemy3_step db 0
enemy4_step db 0

enemy5_step db 0
enemy6_step db 6

kt_step db 0

.code


update_kt proc
 push eax
    push ebx
    push ecx
    push edx






    ;;;;;;;;;;
    cmp currentlevel,2
    jne nexxt

    cmp kt_alive,1
    jne nexxt

    mov dl, ktx
    mov dh, kty
    call Gotoxy
    mov al, ' '
    call WriteChar

    mov al, kt_step
    cmp al, 5
    jne doMove
    neg kt_dir
    mov kt_step, 0

doMove:
    mov al, ktx
    add al, kt_dir
    mov ktx, al
    inc kt_step

    mov dl, ktx
    mov dh, kty
    call Gotoxy
    mov al, 'K'
    call WriteChar

    ;;;;;;;;;;

    nexxt:

      pop edx
    pop ecx
    pop ebx
    pop eax
    ret
update_kt endp



removeenemy2 proc

    push eax
   
    ;;
mov dl,enemy2x

mov dh,enemy2y
call Gotoxy
mov al," "
call WriteChar

  mov  enemy2_alive , 0



    pop eax


ret

removeenemy2 endp


removeenemy3 proc

    push eax
   
 
mov dl,enemy3x

mov dh,enemy3y
call Gotoxy
mov al," "
call WriteChar

  mov  enemy3_alive , 0



    pop eax


ret

removeenemy3 endp

; Level 3 Enemies (4, 5, 6) specific removal procedures
removeenemy4 proc
    push eax
    mov dl,enemy4x
    mov dh,enemy4y
    call Gotoxy
    mov al," "
    call WriteChar
    mov enemy4_alive, 0
    pop eax
    ret
removeenemy4 endp

removeenemy5 proc
    push eax
    mov dl,enemy5x
    mov dh,enemy5y
    call Gotoxy
    mov al," "
    call WriteChar
    mov enemy5_alive, 0
    pop eax
    ret
removeenemy5 endp

removeenemy6 proc
    push eax
    mov dl,enemy6x
    mov dh,enemy6y
    call Gotoxy
    mov al," "
    call WriteChar
    mov enemy6_alive, 0
    pop eax
    ret
removeenemy6 endp


update_enemy1 PROC
    push eax
    push ebx
    push ecx
    push edx

    ; Level 3 Enemies (4, 5, 6)
    cmp currentlevel, 3
    jne check_level1_enemies ; Skip if not Level 3

    ; --- Enemy 4 ---
    cmp enemy4_alive, 1
    jne check_e5

    ; Collision check for Enemy 4
    mov al, enemy4y
    cmp al, yPos
    jne no_e4_collision
    mov ah, enemy4x
    cmp ah, xPos
    jne no_e4_collision
    ; Player hit by Enemy 4
       push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR diesound, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
    sub health, 1
    mov eax, 500
    call delay
    mov xPos, 0
    mov yPos, 6
    call updateplayer
    call drawplayer
    jmp no_e4_collision ; Skip enemy movement for this frame after hit

no_e4_collision:
    mov dl, enemy4x
    mov dh, enemy4y
    call Gotoxy
    mov al, ' '
    call WriteChar

    mov al, enemy4_step
    cmp al, 4
    jne doMove4_L3
    neg dir_enemy_4
    mov enemy4_step, 0
doMove4_L3: ; Unique label for Enemy 4 movement
    mov al, enemy4x
    add al, dir_enemy_4
    mov enemy4x, al
    inc enemy4_step
    ; Draw Enemy 4
    mov dl, enemy4x
    mov dh, enemy4y
    call Gotoxy
    mov al, 'Y'
    call WriteChar

check_e5:
    ; --- Enemy 5 ---
    cmp enemy5_alive, 1
    jne check_e6

    ; Collision check for Enemy 5
    mov al, enemy5y
    cmp al, yPos
    jne no_e5_collision
    mov ah, enemy5x
    cmp ah, xPos
    jne no_e5_collision
    ; Player hit by Enemy 5
    sub health, 1
    mov eax, 500
    call delay
    mov xPos, 5
    mov yPos, 11
    call updateplayer
    call drawplayer
    jmp no_e5_collision ; Skip enemy movement for this frame after hit

no_e5_collision:
    mov dl, enemy5x
    mov dh, enemy5y
    call Gotoxy
    mov al, ' '
    call WriteChar

    mov al, enemy5_step
    cmp al, 4
    jne doMove5_L3 ; Unique label for Enemy 5 movement
    neg dir_enemy_5
    mov enemy5_step, 0
doMove5_L3: ; Unique label for Enemy 5 movement
    mov al, enemy5x
    add al, dir_enemy_5
    mov enemy5x, al
    inc enemy5_step
    ; Draw Enemy 5
    mov dl, enemy5x
    mov dh, enemy5y
    call Gotoxy
    mov al, 'Y'
    call WriteChar

check_e6:
    ; --- Enemy 6 ---
    cmp enemy6_alive, 1
    jne skip_l3_enemies ; All Level 3 enemies processed

    ; Collision check for Enemy 6
    mov al, enemy6y
    cmp al, yPos
    jne no_e6_collision
    mov ah, enemy6x
    cmp ah, xPos
    jne no_e6_collision
    ; Player hit by Enemy 6
    sub health, 1
    mov eax, 500
    call delay
    mov xPos, 0
    mov yPos, 24
    call updateplayer
    call drawplayer
    jmp no_e6_collision ; Skip enemy movement for this frame after hit

no_e6_collision:
    mov dl, enemy6x
    mov dh, enemy6y
    call Gotoxy
    mov al, ' '
    call WriteChar

    mov al, enemy6_step
    cmp al, 10
    jne doMove6_L3 ; Unique label for Enemy 6 movement
    neg dir_enemy_6
    mov enemy6_step, 0
doMove6_L3: ; Unique label for Enemy 6 movement
    mov al, enemy6x
    add al, dir_enemy_6
    mov enemy6x, al
    inc enemy6_step
    ; Draw Enemy 6
    mov dl, enemy6x
    mov dh, enemy6y
    call Gotoxy
    mov al, 'Y'
    call WriteChar

skip_l3_enemies:
    jmp done_all_enemies ; All Level 3 enemies handled, jump to end

check_level1_enemies:
    ; Level 2 Enemies
    cmp currentlevel, 2
    jne next_level_1_enemies ; Skip if not Level 2

    cmp enemy3_alive, 1
    jne next_level_1_enemies

    ; Collision check for Enemy 3 (Level 2 specific)
    mov al, enemy3y
    cmp al, yPos
    jne no_e3_collision_l2
    mov ah, enemy3x
    cmp ah, xPos
    jne no_e3_collision_l2
    ; Player hit by Enemy 3
    sub health, 1
    mov eax, 500
    call delay
    mov xPos, 0
    mov yPos, 18 ; Level 2 ground
    call updateplayer
    call drawplayer
    jmp no_e3_collision_l2

no_e3_collision_l2:
    mov dl, enemy3x
    mov dh, enemy3y
    call Gotoxy
    mov al, ' '
    call WriteChar

    mov al, enemy3_step
    cmp al, 4
    jne doMove3_L2 ; Unique label for Enemy 3 movement
    neg dir_enemy_3
    mov enemy3_step, 0
doMove3_L2: ; Unique label for Enemy 3 movement
    mov al, enemy3x
    add al, dir_enemy_3
    mov enemy3x, al
    inc enemy3_step

    mov dl, enemy3x
    mov dh, enemy3y
    call Gotoxy
    mov al, 'Y'
    call WriteChar
    jmp done_all_enemies ; Level 2 enemies handled

next_level_1_enemies:
    ; Level 1 Enemies (Enemy 1 and Enemy 2)

    ; --- Enemy 1 ---
    cmp enemy1_alive, 1
    jne skip1

    ; Collision check for Enemy 1
    mov al, enemy1y
    cmp al, yPos
    jne no_e1_collision
    mov ah, enemy1x
    cmp ah, xPos
    jne no_e1_collision
    ; Player hit by Enemy 1
    sub health, 1
    mov eax, 500
    call delay
    mov xPos, 0
    mov yPos, 24 ; Level 1 ground
    call updateplayer
    call drawplayer
    jmp no_e1_collision

no_e1_collision:
    mov dl, enemy1x
    mov dh, enemy1y
    call Gotoxy
    mov al, ' '
    call WriteChar

    mov al, enemy1_step
    cmp al, 4
    jne doMove1_L1 ; Unique label for Enemy 1 movement
    neg dir_enemy_1
    mov enemy1_step, 0
doMove1_L1: ; Unique label for Enemy 1 movement
    mov al, enemy1x
    add al, dir_enemy_1
    mov enemy1x, al
    inc enemy1_step

    mov dl, enemy1x
    mov dh, enemy1y
    call Gotoxy
    mov al, 'Y'
    call WriteChar

skip1:
    ; --- Enemy 2 ---
    cmp enemy2_alive, 1
    jne done_all_enemies

    ; Collision check for Enemy 2
    mov al, enemy2y
    cmp al, yPos
    jne no_e2_collision
    mov ah, enemy2x
    cmp ah, xPos
    jne no_e2_collision
    ; Player hit by Enemy 2
       push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR diesound, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx

    sub health, 1
    mov eax, 500
    call delay
    mov xPos, 0
    mov yPos, 24 ; Level 1 ground
    call updateplayer
    call drawplayer
    jmp no_e2_collision

no_e2_collision:
    mov dl, enemy2x
    mov dh, enemy2y
    call Gotoxy
    mov al, ' '
    call WriteChar

    mov al, enemy2_step
    cmp al, 4
    jne doMove2_L1 ; Unique label for Enemy 2 movement
    neg dir_enemy_2
    mov enemy2_step, 0
doMove2_L1: ; Unique label for Enemy 2 movement
    mov al, enemy2x
    add al, dir_enemy_2
    mov enemy2x, al
    inc enemy2_step

    mov dl, enemy2x
    mov dh, enemy2y
    call Gotoxy
    mov al, 'Y'
    call WriteChar

done_all_enemies:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
update_enemy1 ENDP

checklevel3 PROC

    ; only active in level 2
    cmp currentlevel, 2
    jne done

    ; must be at tunnel exit height (head)
    cmp yPos, 18
    jne done

    ; must be to the far right of level
    movzx eax, xPos
    cmp eax, 125
    jl done

    ; ===== SUCCESS ? switch to LEVEL 3 =====
    call celebration
    mov currentlevel, 3
    call PlayCurrentLevelMusic

    call ClrScr
    call LoadLevel

    ; reset player
    mov xPos, 0
    mov yPos,0

     mov  enemy4_alive,1
      mov  enemy5_alive,1
       mov  enemy6_alive,1
       mov v_enemy_alive,1

   ;;speacial feature
     call ApplySkillModifiers


    call DrawPlayer

    call drawcoin

done:
    ret
checklevel3 ENDP

celebration PROC
    push eax
    push ebx
    push ecx
    push edx

mov enemy3_alive ,0
    call updateplayer

    mov xPos, 130
    cmp currentlevel,2
    jne con2
    mov ypos,15

    con2:
    mov yPos, 13

    ; Draw first time
    call DrawPlayer
    cmp currentlevel,2
    jne con

    mov ecx,5
    jmp slide_down
    con:
    mov ecx, 11          ; slide for 11 steps


 
slide_down:
 push ecx          
   push esi            
   push edi            ;
   
    INVOKE PlaySoundA, ADDR polesound, 0, SND_ASYNC OR SND_FILENAME

    pop edi
    pop esi
    pop ecx

 

sd:

    ; Erase old frame
    call UpdatePlayer

    ; Move player down
    inc yPos

    ; Draw at new pos
    call DrawPlayer

    ; Delay for animation
    mov eax, 80
    call Delay

    loop sd

    ; small pause before switching
      push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR worldclear, 0,  SND_SYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
     



    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
celebration ENDP

pitfall proc

  push eax
    push ebx
    push ecx
    push edx

 
    cmp currentlevel , 1
    jg second_check


    l1:
    cmp fallen , 1
    je second_check

    cmp xpos,66
    jle second_check
    cmp xpos,73
    jge second_check
    cmp ypos,24
    jl second_check

    mov fallen , 1
       push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR diesound, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
    sub health ,1
 
   
 call updateplayer

 second_check:

  cmp currentlevel , 1
    jg skip


    l2:
    cmp fallen , 1
    je skip

    cmp xpos,39
    jle skip
    cmp xpos,45
    jge skip
    cmp ypos,24
    jle skip
       push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR diesound, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
    mov fallen , 1

    sub health ,1
 
   
 call updateplayer

    skip:

      pop edx
    pop ecx
    pop ebx
    pop eax
    ret
pitfall endp



checklevel2tunnels PROC
    push eax
    push ebx
    push ecx
    push edx

   
    cmp currentlevel, 2
    jne exit_tunnel


tunnelA:
    cmp xPos, 32
    jl exit_tunnel
    cmp xPos, 34
    jg exit_tunnel
    cmp yPos, 18
    jne exit_tunnel

    ; Erase player
    call UpdatePlayer

      push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR pipe, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx

    mov xPos, 2
    mov yPos, 7

    call DrawPlayer
    jmp exit_tunnel


exit_tunnel:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
checklevel2tunnels ENDP



checklevel2tunnels2 PROC
    push eax
    push ebx
    push ecx
    push edx

   
    cmp currentlevel, 2
    jne exit_tunnel2


tunnelB:
 

 cmp xpos ,127
 jne exit_tunnel2

 cmp ypos,7  
 jne exit_tunnel2



    ; Erase player
    call UpdatePlayer

      push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR pipe, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx



   mov xPos, 35
    mov yPos, 18

    call DrawPlayer
    jmp exit_tunnel2


exit_tunnel2:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
checklevel2tunnels2 ENDP
.data
   
 
f_enemy_x     db  60        ; starting position
f_enemy_y     db  10        ; flies near top
f_enemy_alive db  1
f_enemy_dir   db  1         ; 1 = right, -1 = left

; bullet
bullet_x      db  0
bullet_y      db  0
bullet_alive  db  0

; shooting timer
bulletDelay   dw  0
.code
update_flying_enemy PROC
    push eax
    push ebx
    push ecx
    push edx

    ; Only active in LEVEL 2
    cmp currentlevel,2
    jne done

    cmp f_enemy_alive,1
    jne done

   
   
    mov dl,f_enemy_x
    mov dh,f_enemy_y
    call Gotoxy
    mov al,' '
    call WriteChar

    ; 2. MOVE
    mov al,f_enemy_x
    add al,f_enemy_dir
    mov f_enemy_x,al

    ; Bounce edges
    cmp al,50
    jg checkRight
    mov f_enemy_dir,1
    jmp drawEnemy

checkRight:
    cmp al,110
    jl drawEnemy
    mov f_enemy_dir,-1

drawEnemy:
   

    mov dl,f_enemy_x
    mov dh,f_enemy_y
    call Gotoxy
    mov al,'F'
    call WriteChar

    ; ===== SHOOTING MECHANISM =====
    ; If bullet is alive, we cannot fire another one yet
    cmp bullet_alive,1
    je done

    ; Timer Logic
    mov ax, bulletDelay
    inc ax
    mov bulletDelay, ax
   
    cmp ax, 15         ; Increased to 15 to make it less "machine-gun" like
    jl done

    ; Fire!
    mov bulletDelay, 0
    mov bullet_alive,1
   
    ; Spawn bullet at enemy position
    mov al,f_enemy_x
    mov bullet_x,al
    mov al,f_enemy_y
    inc al              ; appears below enemy
    mov bullet_y,al

done:
   

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
update_flying_enemy ENDP
update_bullet PROC
    push eax
    push edx

    cmp currentlevel,2
    jne done

    cmp bullet_alive,1
    jne done

    ; erase old bullet
    mov dl,bullet_x
    mov dh,bullet_y
    call Gotoxy
    mov al,' '
    call WriteChar

    ; move downward
    mov al,bullet_y
    inc al
    mov bullet_y,al

    ; out of bounds
    cmp al,18
    jg killBullet

    ; draw new bullet
    mov dl,bullet_x
    mov dh,bullet_y
    call Gotoxy
    mov al,' '
    call WriteChar

   
    mov al ,xPos
    cmp bullet_x,al
    jne done
    mov bl,yPos
    cmp bullet_y,bl
    jne done
       push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR diesound, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
 
    sub health,1
    mov bullet_alive,0

    mov xPos,0
    mov yPos,18


    call updateplayer
    call drawplayer

    jmp done

killBullet:
    mov bullet_alive,0

done:
    pop edx
    pop eax
    ret
update_bullet ENDP

playerbullet proc
push eax
push ebx
push ecx
push edx

cmp pa,1
je nofire

cmp ammo ,0
je nofire

mov pa,1

mov al, xpos
inc al

mov px,al
mov al,ypos
mov py, al

dec ammo


nofire :

pop edx
pop ecx
pop ebx
pop eax
ret
playerbullet endp


; update_player_bullet modified to include new enemy removal
update_player_bullet PROC
    push eax
    push ebx
    push edx
   
    ; Checking  if bullet is active
    cmp pa, 1      
    jne done_pb
   
    ; ERASE OLD BULLET POSITION
    mov dl, px
    mov dh, py
    call Gotoxy
    mov al, ' '
    call WriteChar
   
    ; MOVEING  BULLET TO THE RIGHT
    inc px
   
    ; CHECK SCREEN BOUNDARIES (130 is safe limit)
    movzx eax, px
    movzx ebx,xPos
    add ebx,8
    cmp eax, ebx
    jge destroy_pb

    ; 4. CHECK WALL COLLISION
    mov al, px
    mov ah, py
    call CheckCollision   ; Returns 1 in AL if wall
    cmp al, 1
    je destroy_pb         ; Hit a wall? Destroy.
   
    ; 5. CHECK ENEMY COLLISION
   
    cmp enemy1_alive, 1
    jne check_e2
    mov al, px
    cmp al, enemy1x
    jne check_e2
    mov al, py
    cmp al, enemy1y
    jne check_e2
   
    ; Hit Enemy 1
     push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR soundJump2, 0,  SND_SYNC (0) OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
    call removeenemy1
       push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR power, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
      add score,100
    add coin, 5
    jmp destroy_pb

check_e2:
    ; (Check Enemy 2)
    cmp enemy2_alive, 1
    jne check_e3
    mov al, px
    cmp al, enemy2x
    jne check_e3
    mov al, py
    cmp al, enemy2y
    jne check_e3
   
    ; Hit Enemy 2
     push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR soundJump2, 0,  SND_SYNC (0) OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
    call removeenemy2
     add score,100
    add coin, 5
    jmp destroy_pb

check_e3:
    cmp currentlevel,2
    jne check_e4_L3 ; Go to Level 3 enemy checks
    cmp enemy3_alive, 1
    jne check_e4_L3
    mov al, px
    cmp al, enemy3x
    jne check_e4_L3
    mov al, py
    cmp al, enemy3y
    jne check_e4_L3
   
    ; Hit Enemy 3 (Level 2)
     push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR soundJump2, 0,  SND_SYNC (0) OR SND_FILENAME

     pop edi
     pop esi
     pop ecx

    call removeenemy3
     add score,100
    add coin, 5
    jmp destroy_pb

check_e4_L3:
    ; (Check Enemy 4 - Level 3)
    cmp currentlevel,3
    jne check_e5_L3
    cmp enemy4_alive, 1
    jne check_e5_L3
    mov al, px
    cmp al, enemy4x
    jne check_e5_L3
    mov al, py
    cmp al, enemy4y
    jne check_e5_L3
   
    ; Hit Enemy 4
     push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR soundJump2, 0,  SND_SYNC (0) OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
    call removeenemy4
     add score,100
    add coin, 5
    jmp destroy_pb

check_e5_L3:
    ; (Check Enemy 5 - Level 3)
    cmp currentlevel,3
    jne check_e6_L3
    cmp enemy5_alive, 1
    jne check_e6_L3
    mov al, px
    cmp al, enemy5x
    jne check_e6_L3
    mov al, py
    cmp al, enemy5y
    jne check_e6_L3
   
    ; Hit Enemy 5
     push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR soundJump2, 0,  SND_SYNC (0) OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
    call removeenemy5
     add score,100
    add coin, 5
    jmp destroy_pb

check_e6_L3:
    ; (Check Enemy 6 - Level 3)
    cmp currentlevel,3
    jne check_v_enemy
    cmp enemy6_alive, 1
    jne check_v_enemy
    mov al, px
    cmp al, enemy6x
    jne check_v_enemy
    mov al, py
    cmp al, enemy6y
    jne check_v_enemy
   
    ; Hit Enemy 6
     push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR soundJump2, 0,  SND_SYNC (0) OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
    call removeenemy6
     add score,100
    add coin, 5
    jmp destroy_pb
    ;;;;;;;;;;;;;;;;;;;;;;;;;level 3 enemy pb  ;;;;;;;;;;;;;;;;;;;;;
    check_v_enemy:
    cmp currentlevel, 3
    jne check_bowser
    cmp v_enemy_alive, 1
    jne draw_pb
    mov al, px
    cmp al, v_enemy_x
    jne draw_pb
    mov al, py
    cmp al, v_enemy_y
    jne draw_pb
   
    ; Hit V-enemy
     push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR soundJump2, 0,  SND_SYNC (0) OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
    call remove_v_enemy
     add score,1000
    add coin, 10
    jmp destroy_pb



 check_bowser:
    cmp currentlevel, 4
    jne draw_pb
    cmp bowser_alive, 1
    jne draw_pb
   
    ; Check X collision
    mov al, px
    cmp al, bowser_x
    jne draw_pb
   
    ; Check Y collision
    mov al, py
    cmp al, bowser_y
    jne draw_pb
   
    ; Hit Bowser!
    dec bowser_health
   
    ; Check if Bowser is defeated
    cmp bowser_health, 0
    jne just_damage
   
    ; Bowser defeated!
    call remove_bowser
    add score,1500
   ; add score, 50
   
    ; *** ADD THIS: Trigger victory sequence ***
    mov currentlevel, 5
    call VictorySequence
    mov eax ,2000
    call delay
    call showwelcomescreen
   
just_damage:
    ; Bowser still alive, just took damage
    add score, 2
    jmp destroy_pb
 
draw_pb:
    mov dl, px
    mov dh, py
    call Gotoxy
      push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR fires, 0,   SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
    ; Set color to Light Red on Black to make it obvious
    mov eax, lightRed + (black * 16)
    call SetTextColor
   
    mov al, '>'          ; Use an arrow character
    call WriteChar
   
    ; Reset color back to white
    mov eax, white + (black * 16)
    call SetTextColor
   
    jmp done_pb
   
destroy_pb:
    mov pa, 0       ; Deactivate bullet
   
done_pb:
    pop edx
    pop ebx
    pop eax
    ret
update_player_bullet ENDP
checkkptcollision proc

    push eax
    push ebx
    push ecx
    push edx

    cmp currentlevel,2
    jne nochecck
    cmp kt_alive,1
    jne nochecck
    mov al,ktx
    cmp xpos,al
    jne nochecck       ; FIXED — label must match
    mov cl,ypos
    cmp cl,kty

    jne nochecck
  call  draw_kt
    inc col

    cmp col,3
    jne nochecck

    mov kt_alive,0
    mov enemy3_alive ,0
   mov dl , enemy3x
   mov dh , enemy3y
   call gotoxy
   mov al,' '
   call writechar
    call update_enemy1

nochecck:

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

checkkptcollision endp

level3_floor2 PROC
    push eax
    push ebx
    push ecx
    push edx

    ; Only active in level 3
    cmp currentlevel, 3
    jne l3_done

    ; ==================================================
    ; 1. CHECK X POSITION (Right Edge)
    ; Use >= 124 because jumping adds +2/+3 to X,
    ; so you might skip exactly 125.
    ; ==================================================
    movzx eax, xPos
    cmp eax, 124
    jl l3_done         ; If X < 124, do nothing

   

    cmp yPos, 8
    jle transfer_to_middle


    cmp yPos, 15
    jle transfer_to_ground

    ; If Y is higher (like 24), do nothing
    jmp l3_done

transfer_to_middle:
    ; ERASE PLAYER
    call UpdatePlayer
   
    ; SET NEW COORDS (Top -> Middle)

       push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR pipe, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx

    mov xPos, 2      ; Left side
    mov yPos, 11     ; Middle Floor Height
   
    ; DRAW PLAYER
    call DrawPlayer
    jmp l3_done

transfer_to_ground:
    ; ERASE PLAYER
    call UpdatePlayer
   
       push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR pipe, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx


        push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR pipe, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx

    mov xPos, 2      ; Left side
    mov yPos, 24     ; Ground Floor Height
   
    ; DRAW PLAYER
    call DrawPlayer
    jmp l3_done

l3_done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
level3_floor2 endp

.data
; V-shaped jumping enemy for Level 3
v_enemy_x db 50
v_enemy_y db 24          ; starts on ground
v_enemy_alive db 1
v_enemy_dir db 1         ; 1 = right, -1 = left
v_enemy_jump_state db 0  ; 0 = ground, 1 = jumping up, 2 = falling down
v_enemy_jump_counter db 0
v_enemy_jump_height db 4 ; how high it jumps
.data
v_enemy_step db 0
v_enemy_move_delay db 0

.code

draw_v_enemy PROC
    push eax
    push edx
   
    cmp currentlevel, 3
    jne done_draw_v
   
    cmp v_enemy_alive, 1
    jne done_draw_v
   
    ; Draw enemy with distinct color
    mov eax, lightMagenta + (black * 16)
    call SetTextColor
   
    mov dl, v_enemy_x
    mov dh, v_enemy_y
    call Gotoxy
    mov al, 'V'
    call WriteChar
   
    mov eax, white + (black * 16)
    call SetTextColor
   
done_draw_v:
    pop edx
    pop eax
    ret
draw_v_enemy ENDP

update_v_enemy PROC
    push eax
    push ebx
    push ecx
    push edx
   
    cmp currentlevel, 3
    jne done_v_update
   
    cmp v_enemy_alive, 1
    jne done_v_update
   
    ; Erase old position
    mov dl, v_enemy_x
    mov dh, v_enemy_y
    call Gotoxy
    mov al, ' '
    call WriteChar
   
    ; ---------------------------------
    ; HORIZONTAL MOVEMENT (like ground enemies)
    ; ---------------------------------
    inc v_enemy_move_delay
    cmp v_enemy_move_delay, 2    ; Move every 2 frames (adjust speed)
    jl skip_horizontal_move
   
    mov v_enemy_move_delay, 0
   
    ; Check step counter for direction change
    mov al, v_enemy_step
    cmp al, 8                     ; Change direction every 8 steps
    jne continue_move
   
    neg v_enemy_dir
    mov v_enemy_step, 0
   
continue_move:
    mov al, v_enemy_x
    add al, v_enemy_dir
    mov v_enemy_x, al
    inc v_enemy_step
   
    ; Boundary check (keep between X: 10 and 120)
    cmp v_enemy_x, 10
    jl reverse_dir
    cmp v_enemy_x, 120
    jg reverse_dir
    jmp skip_horizontal_move
   
reverse_dir:
    neg v_enemy_dir
    mov v_enemy_step, 0
   
skip_horizontal_move:
   
   
    mov al, v_enemy_jump_state
    cmp al, 0
    je state_ground
    cmp al, 1
    je state_jumping
    jmp state_falling
   
state_ground:
    ; Check if should start jumping
    mov al, v_enemy_jump_counter
    inc al
    mov v_enemy_jump_counter, al
    cmp al, 5                    ; Jump every 5 frames
    jl draw_v_enemy_pos
   
    ; Start jump
    mov v_enemy_jump_counter, 0
    mov v_enemy_jump_state, 1    ; Start jumping up
    jmp draw_v_enemy_pos
   
state_jumping:
    ; Move up
    dec v_enemy_y
   
    ; Check if reached peak
    mov al, v_enemy_jump_counter
    inc al
    mov v_enemy_jump_counter, al
   
    movzx ebx, v_enemy_jump_height
    cmp al, bl
    jl draw_v_enemy_pos
   
    ; Reached peak, start falling
    mov v_enemy_jump_counter, 0
    mov v_enemy_jump_state, 2    ; Start falling
    jmp draw_v_enemy_pos
   
state_falling:
    ; Move down
    inc v_enemy_y
   
    ; Check if reached ground (Y = 24)
    cmp v_enemy_y, 24
    jl draw_v_enemy_pos
   
    ; Hit ground, reset to ground state
    mov v_enemy_y, 24
    mov v_enemy_jump_counter, 0
    mov v_enemy_jump_state, 0    ; Back to ground
   
draw_v_enemy_pos:
    ; Draw at new position
    mov dl, v_enemy_x
    mov dh, v_enemy_y
    call Gotoxy
   
    mov eax, lightMagenta + (black * 16)
    call SetTextColor
    mov al, 'V'
    call WriteChar
    mov eax, white + (black * 16)
    call SetTextColor
   
done_v_update:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
update_v_enemy ENDP

remove_v_enemy PROC
    push eax
    push edx
   
    mov dl, v_enemy_x
    mov dh, v_enemy_y
    call Gotoxy
    mov al, ' '
    call WriteChar
   
    mov v_enemy_alive, 0
   
    pop edx
    pop eax
    ret
remove_v_enemy ENDP



.data
mush1_active db 0
mush1x db 54
mush1y db 15
count1 db 1

mush2_active db 0
mush2x db 100
mush2y db 4
count2 db 1



.code

checklevel2mushroom proc
push eax
push ebx
push ecx
push edx

cmp currentlevel,2
jne no

cmp xpos,54
jne skip
cmp ypos,17
jne skip

 mov dh, 15
    mov dl, 54
    call gotoxy
    mov al ,'@'
   call writechar
  mov mush1_active,1
 
skip:





cmp ypos,17
jne no
cmp xpos,54
jne no

cmp count1,1
jne no

mov ecx, 6
slide:
    ; Erase old frame
   
 mov dh, mush1y
    mov dl, mush1x
    call gotoxy
    mov al ,' '
   call writechar

    ; Move player down
    inc mush1x

    ; Draw at new pos
     mov dh, mush1y
    mov dl, mush1x
    call gotoxy
    mov al ,'@'
   call writechar

    ; Delay for animation
    mov eax, 80
    call Delay

    loop slide
    mov dh, mush1y
    mov dl, mush1x
    call gotoxy
    mov al ,' '
   call writechar



   mov dh, 18
    mov dl, 59
    call gotoxy
    mov al ,'@'
   call writechar
   inc count1
no:

pop edx
pop ecx
pop ebx
pop eax
ret

checklevel2mushroom endp


checklevel22mushroom proc
    push eax
    push ebx
    push ecx
    push edx

    cmp currentlevel,2
    jne skipfunc

   
    cmp count2, 1
    jne skip

    cmp xpos,100
    jne skip
    cmp ypos,7
    jne skip

    mov dh, mush2y
    mov dl, mush2x
    call gotoxy
    mov al ,'@'
    call writechar
    mov mush2_active,1
 
skip:


skipfunc:

    cmp ypos,6
    jne no
    cmp xpos,100
    jne no
   
    ; This ensures animation only runs once
    cmp count2,1
    jne no

    mov ecx, 6
slide:
    ; Erase old frame
    mov dh, mush2y
    mov dl, mush2x
    call gotoxy
    mov al ,' '
    call writechar

    ; Move mushroom right
    inc mush2x

    ; Draw at new pos
    mov dh, mush2y
    mov dl, mush2x
    call gotoxy
    mov al ,'@'
    call writechar

    ; Delay for animation
    mov eax, 80
    call Delay

    loop slide

    ; Clear the last position of the slide
    mov dh, mush2y
    mov dl, mush2x
    call gotoxy
    mov al ,' '
    call writechar

    ; Draw final position
    mov dh, 7
    mov dl, 106
    call gotoxy
    mov al ,'@'
    call writechar
   
    ; Increment count so neither block runs again
    inc count2
no:

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
checklevel22mushroom endp
.data
mush1_collected db 0
mush2_collected db 0
.code

checkmushroom proc
    push eax
    push ebx
    push ecx
    push edx

    cmp currentlevel, 2
    jne check_next_mush

    cmp xpos, 106
    jne check_next_mush
    cmp ypos, 7
    jne check_next_mush
   
 
    cmp mush2_active, 1
    jne check_next_mush

 
    cmp mush2_collected, 0
    jne check_next_mush

    ; --- Collect Mushroom 2 ---
    mov dh, 7
    mov dl, 106
    call gotoxy
    mov al ,' '
    call writechar

    inc health
    mov mush2_collected, 1  ; Mark as collected
      call drawplayer

check_next_mush:

    cmp currentlevel, 2
    jne no

   
    cmp xpos, 59
    jne no
    cmp ypos, 18
    jne no
   
    ; This is Mushroom 1
    cmp mush1_active, 1
    jne no
   
 
    cmp mush1_collected, 0
    jne no

 
    mov dh, 18
    mov dl, 59
    call gotoxy
    mov al ,' '
    call writechar

    inc health
    mov mush1_collected, 1
    call drawplayer

no:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
checkmushroom endp


setcolors1 proc

push eax
push ebx
push ecx
push edx

cmp currentlevel,1
jne exi




  mov al,219
    call SetTextColor  
    ;cloud 1
    mov dh,2
    mov dl,10
     call gotoxy
    call writechar

    mov ecx,3
    mov bl,0
    l4:

      mov dh,3
    mov dl,9
    add dl,bl
     call gotoxy
    call writechar

    inc bl

    loop l4


     mov ecx,5
    mov bl,0
    l6:

      mov dh,4
    mov dl,8
    add dl,bl
     call gotoxy
    call writechar

    inc bl

    loop l6










     mov dh,2
    mov dl,40
     call gotoxy
    call writechar

    mov ecx,3
    mov bl,0
    l7:

      mov dh,3
    mov dl,39
    add dl,bl
     call gotoxy
    call writechar

    inc bl

    loop l7


     mov ecx,5
    mov bl,0
    l8:

      mov dh,4
    mov dl,38
    add dl,bl
     call gotoxy
    call writechar

    inc bl

    loop l8



    ;cloud 3


     mov dh,2
    mov dl,80
     call gotoxy
    call writechar

    mov ecx,3
    mov bl,0
    l9:

      mov dh,3
    mov dl,79
    add dl,bl
     call gotoxy
    call writechar

    inc bl

    loop l9


     mov ecx,5
    mov bl,0
    l10:

      mov dh,4
    mov dl,78
    add dl,bl
     call gotoxy
    call writechar

    inc bl

    loop l10



     mov dh,2
    mov dl,120
     call gotoxy
    call writechar

    mov ecx,3
    mov bl,0
    l11:

      mov dh,3
    mov dl,119
    add dl,bl
     call gotoxy
    call writechar

    inc bl

    loop l11


     mov ecx,5
    mov bl,0
    l12:

      mov dh,4
    mov dl,118
    add dl,bl
     call gotoxy
    call writechar

    inc bl

    loop l12



 

    mov eax, white + (black * 16)  ; Set EAX with combined color values
    call SetTextColor  




 mov eax, brown + (BLUE * 16)  ; Set EAX with combined color values
    call SetTextColor  
    mov ecx,41
   mov bl,0
   l1:
    mov eax,219
    mov dh,25
   
    mov dl,0
    add dl,bl

    call gotoxy
    call writechar
    inc bl
    loop l1



     mov ecx,21
   mov bl,0
   l2:
    mov eax,219
    mov dh,25
   
    mov dl,45
    add dl,bl

    call gotoxy
    call writechar
    inc bl
    loop l2




   
     mov ecx,59
   mov bl,0
   l3:
    mov eax,219
    mov dh,25
   
    mov dl,73
    add dl,bl

    call gotoxy
    call writechar
    inc bl
    loop l3




   ;;;


   

 mov eax, brown + (BLUE * 16)  ; Set EAX with combined color values
    call SetTextColor  
    mov ecx,21
   mov bl,0
   la:
    mov eax,219
    mov dh,26
   
    mov dl,0
    add dl,bl

    call gotoxy
    call writechar
    add bl,2
    loop la



     mov ecx,11
   mov bl,0
   lb:
    mov eax,219
    mov dh,26
   
    mov dl,45
    add dl,bl

    call gotoxy
    call writechar
  add bl,2
    loop lb




   
     mov ecx,30
   mov bl,0
   lc:
    mov eax,219
    mov dh,26
   
    mov dl,73
    add dl,bl

    call gotoxy
    call writechar
    add bl,2
    loop lc





    ;;;;;;;;;;

 mov eax, brown + (BLUE * 16)  ; Set EAX with combined color values
    call SetTextColor  
    mov ecx,41
   mov bl,0
   l121:
    mov eax,219
    mov dh,27
   
    mov dl,0
    add dl,bl

    call gotoxy
    call writechar
    inc bl
    loop l121



     mov ecx,21
   mov bl,0
   l21:
    mov eax,219
    mov dh,27
   
    mov dl,45
    add dl,bl

    call gotoxy
    call writechar
    inc bl
    loop l21


    ;;;;;;;;;;;





     mov eax, brown + (BLUE * 16)  ; Set EAX with combined color values
    call SetTextColor  
    mov ecx,21
   mov bl,0
   laa:
    mov eax,219
    mov dh,28
   
    mov dl,0
    add dl,bl

    call gotoxy
    call writechar
    add bl,2
    loop laa



     mov ecx,11
   mov bl,0
   lbb:
    mov eax,219
    mov dh,28
   
    mov dl,45
    add dl,bl

    call gotoxy
    call writechar
  add bl,2
    loop lbb




   
     mov ecx,30
   mov bl,0
   lcc:
    mov eax,219
    mov dh,28
   
    mov dl,73
    add dl,bl

    call gotoxy
    call writechar
    add bl,2
    loop lcc


    ;;;


   
     mov ecx,59
   mov bl,0
   l311:
    mov eax,219
    mov dh,27
   
    mov dl,73
    add dl,bl

    call gotoxy
    call writechar
    inc bl
    loop l311


      mov ecx,41
   mov bl,0
   l122:
    mov eax,219
    mov dh,29
   
    mov dl,0
    add dl,bl

    call gotoxy
    call writechar
    inc bl
    loop l122



     mov ecx,21
   mov bl,0
   l23:
    mov eax,219
    mov dh,29
   
    mov dl,45
    add dl,bl

    call gotoxy
    call writechar
    inc bl
    loop l23




   
     mov ecx,59
   mov bl,0
   l34:
    mov eax,219
    mov dh,29
   
    mov dl,73
    add dl,bl

    call gotoxy
    call writechar
    inc bl
    loop l34


   
    mov ecx , 132
   mov bl,0
   ground1:

 
    mov dh,8
    mov dl,0
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop ground1


    mov al, 220   ; Set EAX with combined color values
    call SetTextColor
 
    mov ecx , 24
   mov bl,0
  ll:

 
    mov dh,7
    mov dl,85
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop ll

     mov ecx , 17
   mov bl,0
  ll2:

 
    mov dh,6
    mov dl,92
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop ll2




   
     mov ecx , 12
   mov bl,0
  ll3:

 
    mov dh,5
    mov dl,97
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop ll3



     mov ecx , 6
   mov bl,0
  ll4:

 
    mov dh,5
    mov dl,102
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop ll4

     mov ecx , 7
   mov bl,0
  ll5:

 
    mov dh,4
    mov dl,102
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop ll5


      mov ecx , 2
   mov bl,0
  ll6:

 
    mov dh,3
    mov dl,107
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop ll6



   
      mov ecx , 10
   mov bl,0
  lp1:

 
    mov dh,21
    mov dl,20
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop lp1


   
   
      mov ecx , 10
   mov bl,0
  lp2:

 
    mov dh,21
    mov dl,78
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop lp2



      mov ecx , 10
   mov bl,0
  lp3:

 
    mov dh,18
    mov dl,37
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop lp3


   
      mov ecx , 10
   mov bl,0
  lp4:

 
    mov dh,18
    mov dl,67
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop lp4


   
      mov ecx , 10
   mov bl,0
  lp5:

 
    mov dh,15
    mov dl,53
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop lp5





   
      mov ecx , 10
   mov bl,0
  lp6:

 
    mov dh,19
    mov dl,100
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop lp6







   
      mov al, 219   ; Set EAX with combined color values
    call SetTextColor  

    mov ecx , 132
   mov bl,0
   water:

 
    mov dh,30
    mov dl,0
    add dl,bl
    call gotoxy
    call writechar
    inc bl







   loop water

   
    mov ecx , 132
   mov bl,0
   water2:

 
    mov dh,31
    mov dl,0
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop water2


   
    mov ecx , 132
   mov bl,0
   water3:

 
    mov dh,32
    mov dl,0
    add dl,bl
    call gotoxy
    call writechar
    inc bl


   loop water3

   


 

     mov eax, white + (black * 16)  ; Set EAX with combined color values
    call SetTextColor  
    exi:

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret




setcolors1 endp


.data
; Bowser boss variables
bowser_x db 110
bowser_y db 15
bowser_alive db 1
bowser_dir db -1          ; -1 = left, 1 = right
bowser_step db 0
bowser_health db 10       ; Boss has 10 health points
bowser_fire_x db 0
bowser_fire_y db 0
bowser_fire_alive db 0
bowser_fire_delay dw 0
bowser_move_delay db 0    ; NEW - for slowing down movement

.code
draw_bowser PROC
    push eax
    push edx
    push ecx

    cmp currentlevel, 4
    jne bowser_done

    cmp bowser_alive, 1
    jne bowser_done

    ; Draw Bowser with distinctive color (Light Red for boss)
    mov eax, lightRed + (black * 16)
    call SetTextColor
   
    mov dl, bowser_x
    mov dh, bowser_y
    call Gotoxy
    mov al, 'B'           ; 'B' for Bowser
    call WriteChar
   
    ; Draw health bar above Bowser
    mov dl, bowser_x
    sub dl, 2
    mov dh, bowser_y
    dec dh
    call Gotoxy
   
    mov eax, yellow + (black * 16)
    call SetTextColor
   
    ; Draw health segments
    movzx ecx, bowser_health
    cmp ecx, 0
    je skip_health_draw
    mov al, '+'
draw_health_loop:

    call WriteChar

    loop draw_health_loop
   
skip_health_draw:
    ; Reset color
    mov eax, white + (black * 16)
    call SetTextColor

bowser_done:
    pop ecx
    pop edx
    pop eax
    ret
draw_bowser ENDP


update_bowser PROC
    push eax
    push ebx
    push ecx
    push edx

    cmp currentlevel, 4
    jne done_update_bowser

    cmp bowser_alive, 1
    jne done_update_bowser

    ; --- CHECK COLLISION WITH PLAYER ---
    mov al, bowser_y
    cmp al, yPos
    jne no_bowser_collision
    mov ah, bowser_x
    cmp ah, xPos
    jne no_bowser_collision
       push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR diesound, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
    ; Player touched Bowser - take damage
    sub health, 1
    mov eax, 500
    call delay
    mov xPos, 0
    mov yPos, 19
    call updateplayer
    call drawplayer
    jmp done_update_bowser  ; Skip rest of update after hit

no_bowser_collision:
    ; --- ADD MOVEMENT DELAY (SLOW DOWN BOWSER) ---
    inc bowser_move_delay
    cmp bowser_move_delay, 3   ; Move every 3 frames (adjust 2-5 for speed)
    jl skip_bowser_move
    mov bowser_move_delay, 0   ; Reset delay

    ; --- ERASE OLD POSITION ---
    ; Clear health bar
    mov dl, bowser_x
    sub dl, 2
    mov dh, bowser_y
    dec dh
    call Gotoxy
    mov ecx, 15           ; Clear max possible health bar
    mov al, ' '
clear_health_loop:
    call WriteChar
    loop clear_health_loop
   
    ; Clear Bowser
    mov dl, bowser_x
    mov dh, bowser_y
    call Gotoxy
    mov al, ' '
    call WriteChar

    ; --- HORIZONTAL MOVEMENT ---
    mov al, bowser_step
    cmp al, 10            ; Move 10 steps before changing direction
    jne continue_bowser_move
   
    neg bowser_dir
    mov bowser_step, 0

continue_bowser_move:
    mov al, bowser_x
    add al, bowser_dir
    mov bowser_x, al
    inc bowser_step
   
    ; Boundary check (keep between 85 and 115)
    cmp bowser_x, 85
    jl reverse_bowser_dir
    cmp bowser_x, 115
    jg reverse_bowser_dir
    jmp skip_reverse

reverse_bowser_dir:
    neg bowser_dir
    mov bowser_step, 0

skip_reverse:
skip_bowser_move:

    ; --- FIRE MECHANISM ---
    cmp bowser_fire_alive, 1
    je skip_fire_check
   
    ; Increment fire delay
    mov ax, bowser_fire_delay
    inc ax
    mov bowser_fire_delay, ax
   
    cmp ax, 50            ; Fire every 50 frames (adjust 30-70 for frequency)
    jl skip_fire_check
   
    mov bowser_fire_delay, 0
    mov bowser_fire_alive, 1
   
    ; Spawn fire at Bowser's position
    mov al, bowser_x
    mov bowser_fire_x, al
    mov al, bowser_y
   ; inc al                ; Fire appears below Bowser
    mov bowser_fire_y, al

skip_fire_check:
    ; Always redraw Bowser at new position
    call draw_bowser

done_update_bowser:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
update_bowser ENDP

update_bowser_fire PROC
    push eax
    push ebx
    push edx

    cmp currentlevel, 4
    jne done_fire
   
    cmp bowser_fire_alive, 1
    jne done_fire

    ; Erase old fire position
    mov dl, bowser_fire_x
    mov dh, bowser_fire_y
    call Gotoxy
    mov al, ' '
    call WriteChar

    ; Move fire horizontally (left direction toward player)
    mov al, bowser_fire_x
    dec al                ; Move left
    mov bowser_fire_x, al

    ; Check if fire went off screen (x = 0)
    cmp al, 80
    jle kill_fire
   

    ; Check collision with player
    mov al, bowser_fire_y
    cmp al, yPos
    jne no_fire_hit
    mov bl, bowser_fire_x
    cmp bl, xPos
    jne no_fire_hit
       push ecx          
   push esi            
   push edi            
   
     INVOKE PlaySoundA, ADDR diesound, 0,  SND_ASYNC OR SND_FILENAME

     pop edi
     pop esi
     pop ecx
    ; Player hit by fire
    sub health, 1
    mov bowser_fire_alive, 0
   
    ; Respawn player
    mov xPos, 0
    mov yPos, 20
    call updateplayer
    call drawplayer
    jmp done_fire

no_fire_hit:
    ; Draw fire at new position
    mov dl, bowser_fire_x
    mov dh, bowser_fire_y
    call Gotoxy
   
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov al, '-'           ; Horizontal fire character
    call WriteChar
    mov eax, white + (black * 16)
    call SetTextColor
    jmp done_fire

kill_fire:
    mov bowser_fire_alive, 0

done_fire:
    pop edx
    pop ebx
    pop eax
    ret
update_bowser_fire ENDP

remove_bowser PROC
    push eax
    push edx
    push ecx
   
    ; Clear Bowser
    mov dl, bowser_x
    mov dh, bowser_y
    call Gotoxy
    mov al, ' '
    call WriteChar
   
    ; Clear health bar
    mov dl, bowser_x
    sub dl, 2
    mov dh, bowser_y
    dec dh
    call Gotoxy
    mov ecx, 15
    mov al, ' '
clear_bar:
    call WriteChar
    loop clear_bar
   
    mov bowser_alive, 0
   
    pop ecx
    pop edx
    pop eax
    ret
remove_bowser ENDP
; Add these variables to your .data section after the Bowser variables

.data
; Moving platform variables
total db 9
platform_x db 5,15,25,35,45,55,65,75,85         ; X position (fixed horizontal position)
platform_y db 20 ,19,21,22,18,17,19,20,19          ; Y position (starts at bottom)
platform_dir db -1 ,1,-1,1,-1,1,-1,1,-1        ; -1 = up, 1 = down
platform_min_y db 14      ; Top limit
platform_max_y db 24      ; Bottom limit
platform_width db 8        ; Platform width

platform_delay db 0        ; Movement delay counter
var1 db 0
.code

; ============================================
; DRAW MOVING PLATFORM PROCEDURE
; ============================================
draw_moving_platform PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    cmp currentlevel, 4
    jne done_draw_platform
   
    ; Set color
    mov eax, cyan + (black * 16)
    call SetTextColor
   
    ; Setup for Loop
    movzx ecx, total       ; Loop 3 times
    mov ebx, 0                   ; EBX is our index (starts at 0)

draw_loop_start:
    push ecx                     ; Save outer loop counter

   
    ; We use [Label + Register] addressing
    mov dh, platform_y[ebx]      ; Load Y from array at index EBX
    mov dl, platform_x[ebx]      ; Load X from array at index EBX
    call Gotoxy



    movzx ecx, platform_width    ; Load width for inner loop
    mov al, '='
inner_draw_loop:
    call WriteChar
    loop inner_draw_loop

   
    pop ecx                      ; Restore outer loop counter
    inc ebx                      ; Move to next index (0 -> 1 -> 2)
    loop draw_loop_start         ; Repeat

    ; Reset color
    mov eax, white + (black * 16)
    call SetTextColor
   
done_draw_platform:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
draw_moving_platform ENDP
update_moving_platform PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
   
    cmp currentlevel, 4
    jne done_update_platform
   
    ; --- GLOBAL DELAY TIMER ---
    inc platform_delay
    cmp platform_delay, 4      
    jl skip_platform_update_logic ; If delay not met, skip logic but still draw
    mov platform_delay, 0
   
 
    movzx ecx, total       ; Number of platforms
    mov ebx, 0                   ; Index (0, 1, 2...)

update_loop:
    push ecx                     ; Save outer loop counter

    mov dh, platform_y[ebx]      ; Get Y from array
    mov dl, platform_x[ebx]      ; Get X from array
    call Gotoxy
   
    movzx ecx, platform_width
    mov al, ' '
erase_loop:
    call WriteChar
    loop erase_loop

   
    mov al, platform_y[ebx]      ; Load current Y
    add al, platform_dir[ebx]    ; Add specific direction
    mov platform_y[ebx], al      ; Store back to array
   
    ; Check Boundaries
    cmp al, platform_min_y
    jle reverse_dir
    cmp al, platform_max_y
    jge reverse_dir
    jmp check_collision          ; Skip reverse if within bounds

reverse_dir:
    neg platform_dir[ebx]        ; Flip direction for THIS platform

check_collision:
   
    ; --------------------------
   
    ; A. Check X Bounds
    mov al, xPos
    cmp al, platform_x[ebx]
    jl next_platform_iter        ; Player left of platform
   
    mov dl, platform_x[ebx]
    add dl, platform_width
    cmp al, dl
    jge next_platform_iter       ; Player right of platform

    ; B. Check Y Gap (Sticky Logic)
    ; Gap = Platform_Y - Player_Y
    mov al, platform_y[ebx]
    sub al, yPos
   
    ; Accept gaps 0, 1, 2
    cmp al, 1
    je move_player_with_plat
    cmp al, 2
    je move_player_with_plat
    cmp al, 0
    je move_player_with_plat
   
    jmp next_platform_iter       ; Not on this platform

move_player_with_plat:
    ; Erase Player Old Pos
    call UpdatePlayer
   
    ; Snap Player Y to (Platform_Y - 1)
    mov al, platform_y[ebx]
    dec al
    mov yPos, al
   
    ; Draw Player New Pos
    call DrawPlayer

next_platform_iter:
    pop ecx                      ; Restore outer loop counter
    inc ebx                      ; Increment Index
    dec ecx                      ; Manually decrement to check for zero
    cmp ecx, 0
    jg update_loop               ; Jump if greater than 0
   
    ; We used manual jump because `loop` can be tricky with long jumps
    ; but `loop update_loop` is usually fine if short enough.

skip_platform_update_logic:
   
    ; Redraw ALL platforms at their new positions
    call draw_moving_platform
   
done_update_platform:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
update_moving_platform ENDP
check_on_moving_platform PROC
    ; Returns AL = 1 if player is on ANY platform, 0 otherwise
    push ebx
    push ecx
    push edx
   
    cmp currentlevel, 4
    jne not_on_any_platform
   
    movzx ecx, total       ; Loop through all
    mov ebx, 0                   ; Index

check_plat_loop:
    ; 1. Check X Bounds
    mov al, xPos
    cmp al, platform_x[ebx]
    jl check_next_plat           ; Too far left
   
    mov dl, platform_x[ebx]
    add dl, platform_width
    cmp al, dl
    jge check_next_plat          ; Too far right

    ; 2. Check Y Gap
    mov al, platform_y[ebx]
    sub al, yPos
   
    ; Allow gaps 1 or 2
    cmp al, 1
    je found_platform
    cmp al, 2
    je found_platform
   
check_next_plat:
    inc ebx
    loop check_plat_loop         ; Continue to next platform

    ; If loop finishes, we are not on any platform
    jmp not_on_any_platform

found_platform:
    pop edx
    pop ecx
    pop ebx
    mov al, 1                    ; Return 1 (Solid)
    ret

not_on_any_platform:
    pop edx
    pop ecx
    pop ebx
    mov al, 0                    ; Return 0 (Falling)
    ret
check_on_moving_platform ENDP


InitializeSkills PROC
    push eax
   
    ; Set initial values
    mov base_speed, 50
    mov speed_modifier, 0
    mov jump_modifier, 0
    mov health_modifier, 0
    mov skill_coins, 0
    mov max_health, 3
    mov starting_ammo, 20
   
    ; Lock all skills
    mov skill_speed1, 0
    mov skill_speed2, 0
    mov skill_speed3, 0
    mov skill_jump1, 0
    mov skill_jump2, 0
    mov skill_jump3, 0
    mov skill_health1, 0
    mov skill_health2, 0
    mov skill_ammo1, 0
    mov skill_ammo2, 0
   
    pop eax
    ret
InitializeSkills ENDP

ApplySkillModifiers PROC
    push eax
    push ebx
   
    ; Apply jump height
    mov al, 4                    ; Base jump height
    add al, jump_modifier
    mov jumpheight, al
   
    ; Apply health
    mov al, max_health
    mov health, al
   
    ; Apply ammo
    mov al, starting_ammo
    mov ammo, al
   
    pop ebx
    pop eax
    ret
ApplySkillModifiers ENDP

DisplaySkillTree PROC
    push eax
    push ebx
    push ecx
    push edx
   

RedrawTree:
   
    call Clrscr
   
    ; Title
    mov dl, 40
    mov dh, 1
    call Gotoxy
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov edx, OFFSET skillTreeTitle
    call WriteString
   
    ; Available Coins
    mov dl, 45
    mov dh, 3
    call Gotoxy
    mov eax, white + (black * 16)
    call SetTextColor
    mov edx, OFFSET availableCoins
    call WriteString
    movzx eax, coin;skill_coins
    call WriteDec
   
    ; ========== SPEED PATH ==========
    mov dl, 10
    mov dh, 6
    call Gotoxy
    mov eax, cyan + (black * 16)
    call SetTextColor
    mov edx, OFFSET speedPath
    call WriteString
   
    ; Speed 1
    mov dl, 12
    mov dh, 7
    call Gotoxy
    cmp skill_speed1, 1
    je speed1_unlocked
    mov eax, gray + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, '1'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET speedSkill1
    call WriteString
    jmp speed1_done
speed1_unlocked:
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, 'X'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET speedSkill1
    call WriteString
speed1_done:

    ; Speed 2
    mov dl, 12
    mov dh, 8
    call Gotoxy
    cmp skill_speed2, 1
    je speed2_unlocked
    mov eax, gray + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, '2'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET speedSkill2
    call WriteString
    jmp speed2_done
speed2_unlocked:
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, 'X'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET speedSkill2
    call WriteString
speed2_done:

    ; Speed 3
    mov dl, 12
    mov dh, 9
    call Gotoxy
    cmp skill_speed3, 1
    je speed3_unlocked
    mov eax, gray + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, '3'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET speedSkill3
    call WriteString
    jmp speed3_done
speed3_unlocked:
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, 'X'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET speedSkill3
    call WriteString
speed3_done:

    ; ========== JUMP PATH ==========
    mov dl, 45
    mov dh, 6
    call Gotoxy
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov edx, OFFSET jumpPath
    call WriteString
   
    ; Jump 1
    mov dl, 47
    mov dh, 7
    call Gotoxy
    cmp skill_jump1, 1
    je jump1_unlocked
    mov eax, gray + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, '4'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET jumpSkill1
    call WriteString
    jmp jump1_done
jump1_unlocked:
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, 'X'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET jumpSkill1
    call WriteString
jump1_done:

    ; Jump 2
    mov dl, 47
    mov dh, 8
    call Gotoxy
    cmp skill_jump2, 1
    je jump2_unlocked
    mov eax, gray + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, '5'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET jumpSkill2
    call WriteString
    jmp jump2_done
jump2_unlocked:
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, 'X'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET jumpSkill2
    call WriteString
jump2_done:

    ; Jump 3
    mov dl, 47
    mov dh, 9
    call Gotoxy
    cmp skill_jump3, 1
    je jump3_unlocked
    mov eax, gray + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, '6'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET jumpSkill3
    call WriteString
    jmp jump3_done
jump3_unlocked:
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, 'X'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET jumpSkill3
    call WriteString
jump3_done:

    ; ========== DEFENSE PATH ==========
    mov dl, 80
    mov dh, 6
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov edx, OFFSET defensePath
    call WriteString
   
    ; Health 1
    mov dl, 82
    mov dh, 7
    call Gotoxy
    cmp skill_health1, 1
    je health1_unlocked
    mov eax, gray + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, '7'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET healthSkill1
    call WriteString
    jmp health1_done
health1_unlocked:
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, 'X'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET healthSkill1
    call WriteString
health1_done:

    ; Health 2
    mov dl, 82
    mov dh, 8
    call Gotoxy
    cmp skill_health2, 1
    je health2_unlocked
    mov eax, gray + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, '8'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET healthSkill2
    call WriteString
    jmp health2_done
health2_unlocked:
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, 'X'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET healthSkill2
    call WriteString
health2_done:

    ; ========== AMMO PATH ==========
    mov dl, 10
    mov dh, 12
    call Gotoxy
    mov eax, lightMagenta + (black * 16)
    call SetTextColor
    mov edx, OFFSET ammoPath
    call WriteString
   
    ; Ammo 1
    mov dl, 12
    mov dh, 13
    call Gotoxy
    cmp skill_ammo1, 1
    je ammo1_unlocked
    mov eax, gray + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, '9'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET ammoSkill1
    call WriteString
    jmp ammo1_done
ammo1_unlocked:
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, 'X'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET ammoSkill1
    call WriteString
ammo1_done:

    ; Ammo 2
    mov dl, 12
    mov dh, 14
    call Gotoxy
    cmp skill_ammo2, 1
    je ammo2_unlocked
    mov eax, gray + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, '0'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET ammoSkill2
    call WriteString
    jmp ammo2_done
ammo2_unlocked:
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov al, '['
    call WriteChar
    mov al, 'X'
    call WriteChar
    mov al, ']'
    call WriteChar
    mov edx, OFFSET ammoSkill2
    call WriteString
ammo2_done:

    ; Instructions
    mov dl, 35
    mov dh, 18
    call Gotoxy
    mov eax, white + (black * 16)
    call SetTextColor
    mov edx, OFFSET unlockPrompt
    call WriteString
   
    mov dl, 40
    mov dh, 20
    call Gotoxy
    mov edx, OFFSET skillTreeClose
    call WriteString
   
    ; Wait for input
skill_menu_loop:
    call ReadKey
    jz skill_menu_loop
   
    cmp al, 'C'
    je close_skill_menu
    cmp al, 'c'
    je close_skill_menu
   
    cmp al, 'r'
    je reset_skills
    cmp al, 'R'
    je reset_skills
   
    cmp al, '1'
    je try_unlock_speed1
    cmp al, '2'
    je try_unlock_speed2
    cmp al, '3'
    je try_unlock_speed3
    cmp al, '4'
    je try_unlock_jump1
    cmp al, '5'
    je try_unlock_jump2
    cmp al, '6'
    je try_unlock_jump3
    cmp al, '7'
    je try_unlock_health1
    cmp al, '8'
    je try_unlock_health2
    cmp al, '9'
    je try_unlock_ammo1
    cmp al, '0'
    je try_unlock_ammo2
   
    jmp skill_menu_loop



try_unlock_speed1:
    call UnlockSpeed1
    jmp RedrawTree
   
try_unlock_speed2:
    call UnlockSpeed2
    jmp RedrawTree
   
try_unlock_speed3:
    call UnlockSpeed3
    jmp RedrawTree
   
try_unlock_jump1:
    call UnlockJump1
    jmp RedrawTree
   
try_unlock_jump2:
    call UnlockJump2
    jmp RedrawTree
   
try_unlock_jump3:
    call UnlockJump3
    jmp RedrawTree
   
try_unlock_health1:
    call UnlockHealth1
    jmp RedrawTree
   
try_unlock_health2:
    call UnlockHealth2
    jmp RedrawTree
   
try_unlock_ammo1:
    call UnlockAmmo1
    jmp RedrawTree
   
try_unlock_ammo2:
    call UnlockAmmo2
    jmp RedrawTree

reset_skills:
    call ResetAllSkills
    jmp RedrawTree




close_skill_menu:
    ; 1. Clear Screen and Reload Basic Map
    call Clrscr
    call LoadLevel
   
    ; 2. Restore Background and Level Specific Visuals
   
    ; --- LEVEL 1 RESTORE ---
    cmp currentlevel, 1
    jne not_level1
    call setcolors1            
   
    cmp enemy1_alive, 1
    jne check_e2_restore
    call draw_normal_enemy
check_e2_restore:
    cmp enemy2_alive, 1
    jne finish_restore
    call draw_normal_enemy
    jmp finish_restore
   
not_level1:
    ; --- LEVEL 2 RESTORE ---
    cmp currentlevel, 2
    jne not_level2
    cmp enemy3_alive, 1
    jne skip_e3
    call draw_normal_enemy
skip_e3:
    cmp kt_alive, 1
    jne not_level2
    call draw_kt
    jmp finish_restore
   
not_level2:
    ; --- LEVEL 3 RESTORE ---
    cmp currentlevel, 3
    jne not_level3
    cmp enemy4_alive, 1
    jne check_e5
    call draw_normal_enemy
check_e5:
    cmp enemy5_alive, 1
    jne check_e6
    call draw_normal_enemy
check_e6:
    cmp enemy6_alive, 1
    jne check_v
    call draw_normal_enemy
check_v:
    cmp v_enemy_alive, 1
    jne finish_restore
    call draw_v_enemy
    jmp finish_restore
   
not_level3:
    ; --- LEVEL 4 RESTORE ---
    cmp currentlevel, 4
    jne finish_restore
    cmp bowser_alive, 1
    jne skip_bowser_restore
    call draw_bowser
skip_bowser_restore:
    call draw_moving_platform
   
finish_restore:
    ; 3. Draw Coins
    call drawcoin
   
    ; 4. Update Game Variables from Skills
    call ApplySkillModifiers
   
    ; 5. Draw Player LAST so they appear ON TOP
    call DrawPlayer
   
    ; 6. CRITICAL: Reset Delta Timer to prevent jumpy physics
    call GetMseconds
    mov lastTickCount, eax
   
    ; 7. Flush Input Buffer to prevent accidental movement
FlushBufferLoop:
    mov eax, 10
    call Delay
    call ReadKey
    jnz FlushBufferLoop
   
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
   
DisplaySkillTree ENDP


UnlockSpeed1 PROC
    push eax
    cmp skill_speed1, 1
    je already_unlocked_s1
    cmp coin, 5
    jl not_enough_s1
   
    mov skill_speed1, 1
    sub coin, 5
    sub speed_modifier, 5
   
already_unlocked_s1:
not_enough_s1:
    pop eax
    ret
UnlockSpeed1 ENDP

UnlockSpeed2 PROC
    push eax
  ;  cmp skill_speed1, 0
   ; je prereq_s2
    cmp skill_speed2, 1
    je already_unlocked_s2
    cmp coin, 10
    jl not_enough_s2
   
    mov skill_speed2, 1
    sub coin, 10
    sub speed_modifier, 5
   
already_unlocked_s2:
not_enough_s2:
prereq_s2:
    pop eax
    ret
UnlockSpeed2 ENDP

UnlockSpeed3 PROC
    push eax
   ; cmp skill_speed2, 0
  ;  je prereq_s3
    cmp skill_speed3, 1
    je already_unlocked_s3
    cmp coin, 15
    jl not_enough_s3
   
    mov skill_speed3, 1
    sub coin, 15
    sub speed_modifier, 5
   
already_unlocked_s3:
not_enough_s3:
prereq_s3:
    pop eax
    ret
UnlockSpeed3 ENDP

UnlockJump1 PROC
    push eax
   ; cmp skill_jump1, 1
  ; je already_unlocked_j1
    cmp coin, 7
    jl not_enough_j1
   
    mov skill_jump1, 1
    sub coin, 7
    inc jump_modifier
   
already_unlocked_j1:
not_enough_j1:
    pop eax
    ret
UnlockJump1 ENDP

UnlockJump2 PROC
    push eax
   ; cmp skill_jump1, 0
   ; je prereq_j2
    cmp skill_jump2, 1
    je already_unlocked_j2
    cmp coin, 14
    jl not_enough_j2
   
    mov skill_jump2, 1
    sub coin, 14
    inc jump_modifier
   
already_unlocked_j2:
not_enough_j2:
prereq_j2:
    pop eax
    ret
UnlockJump2 ENDP

UnlockJump3 PROC
    push eax
   ; cmp skill_jump2, 0
    ;je prereq_j3
    cmp skill_jump3, 1
    je already_unlocked_j3
    cmp coin, 21
    jl not_enough_j3
   
    mov skill_jump3, 1
    sub coin, 21
    inc jump_modifier
   
already_unlocked_j3:
not_enough_j3:
prereq_j3:
    pop eax
    ret
UnlockJump3 ENDP

UnlockHealth1 PROC
    push eax
   ; cmp skill_health1, 1
   ; je already_unlocked_h1
    cmp coin, 8
    jl not_enough_h1
   
    mov skill_health1, 1
    sub coin, 8
    inc max_health
    inc health_modifier
   
already_unlocked_h1:
not_enough_h1:
    pop eax
    ret
UnlockHealth1 ENDP

UnlockHealth2 PROC
    push eax
   ; cmp skill_health1, 0
   ; je prereq_h2
    cmp skill_health2, 1
    je already_unlocked_h2
    cmp coin, 16
    jl not_enough_h2
   
    mov skill_health2, 1
    sub coin, 16
    inc max_health
    inc health_modifier
   
already_unlocked_h2:
not_enough_h2:
prereq_h2:
    pop eax
    ret
UnlockHealth2 ENDP

UnlockAmmo1 PROC
    push eax
  ;  cmp skill_ammo1, 1
  ;  je already_unlocked_a1
    cmp coin, 6
    jl not_enough_a1
   
    mov skill_ammo1, 1
    sub coin, 6
    add starting_ammo, 10
   
already_unlocked_a1:
not_enough_a1:
    pop eax
    ret
UnlockAmmo1 ENDP

UnlockAmmo2 PROC
    push eax
  ;  cmp skill_ammo1, 0
  ;  je prereq_a2
    cmp skill_ammo2, 1
    je already_unlocked_a2
    cmp coin, 12
    jl not_enough_a2
   
    mov skill_ammo2, 1
    sub coin, 12
    add starting_ammo, 20
   
already_unlocked_a2:
not_enough_a2:
prereq_a2:
    pop eax
    ret
UnlockAmmo2 ENDP


ResetAllSkills PROC
    push eax
   
   
    mov al, coin
    push eax
   
      call InitializeSkills
   
    pop eax
    mov coin, al
   
 
    call ApplySkillModifiers
   
    pop eax
    ret
ResetAllSkills ENDP

PlayCurrentLevelMusic PROC
    push eax
    push edx

    ; 1. Always close whatever music was playing before
    INVOKE mciSendStringA, ADDR cmdClose, 0, 0, 0

    ; 2. Check which level we are in and pick the right command
    cmp currentlevel, 1
    je load_lvl1
    cmp currentlevel, 2
    je load_lvl2
    cmp currentlevel, 3
    je load_lvl3
    cmp currentlevel, 4
    je load_lvl4
    jmp done_music ; If level is invalid, do nothing

load_lvl1:
    mov edx, OFFSET cmdOpenLvl1
    jmp start_music
load_lvl2:
    mov edx, OFFSET cmdOpenLvl2
    jmp start_music
load_lvl3:
    mov edx, OFFSET cmdOpenLvl3
    jmp start_music
load_lvl4:
    mov edx, OFFSET cmdOpenLvl4
    jmp start_music

start_music:
    ; 3. Open the file selected in EDX
    INVOKE mciSendStringA, edx, 0, 0, 0
   
    ; 4. Play it on loop
    INVOKE mciSendStringA, ADDR cmdPlay, 0, 0, 0

done_music:
    pop edx
    pop eax
    ret
PlayCurrentLevelMusic ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ============================================
; SHOW WELCOME SCREEN
; ============================================


ShowWelcomeScreen PROC
    ; We save EDX, but NOT EAX.
    ; EAX is used to send the user's choice back to the main procedure.
    push edx
   
welcome_loop:
    call Clrscr

    mov eax, yellow + (black * 16)
    call SetTextColor
   
    mov dh, 3
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET welcomeTitle1
    call WriteString
   
    mov dh, 10
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET welcomeTitle2
    call WriteString
   
    mov eax, cyan + (black * 16)
    call SetTextColor
    mov dh, 15
    mov dl, 90
    call Gotoxy
    mov edx, OFFSET rollNumberMsg
    call WriteString
   
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov dh, 18
    mov dl, 100
    call Gotoxy
    mov edx, OFFSET bigMario
    call WriteString
   

    mov eax, white + (black * 16)
    call SetTextColor
   
    ; Option 1: Start
    mov dh, 18
    mov dl, 100
    call Gotoxy
    mov edx, OFFSET menuOption1
    call WriteString
   
    ; Option 2: High Scores
    mov dh, 20
    mov dl, 100
    call Gotoxy
    mov edx, OFFSET menuOption2
    call WriteString
   
    ; Option 3: Instructions
    mov dh, 22
    mov dl, 100
    call Gotoxy
    mov edx, OFFSET menuOption3
    call WriteString
   
    ; Option 4: Exit
    mov dh, 24
    mov dl, 100
    call Gotoxy
    mov edx, OFFSET menuOption4
    call WriteString

    ; Option 5: Load Game (NEW FEATURE)
    mov dh, 26
    mov dl, 100
    call Gotoxy
    mov edx, OFFSET menuOption5
    call WriteString
   
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov dh, 28
    mov dl, 100
    call Gotoxy
    mov edx, OFFSET menuPrompt
    call WriteString
   
    ; Read Input
    call ReadChar
   


    cmp al, '1'
    je return_new_game
   
    cmp al, '2'
    je show_highscores
   
    cmp al, '3'
    je show_instructions
   
    cmp al, '4'
    je do_exit_game
   
    cmp al, '5'
    je return_load_game
   
    ; If invalid input, redraw menu
    jmp welcome_loop

; --- HANDLERS ---

return_new_game:
    call GetPlayerName
    mov eax, 1          ; Return 1 to Main (Signal: Start New)
    jmp finish_welcome

return_load_game:
    mov eax, 5          ; Return 5 to Main (Signal: Load Game)
    jmp finish_welcome

show_highscores:
    call ShowHighScores
    jmp welcome_loop    ; Return to menu after viewing

show_instructions:
    call ShowInstructions
    jmp welcome_loop    ; Return to menu after viewing

do_exit_game:
    call Clrscr
    exit                ; Quit program immediately

finish_welcome:
    call Clrscr
    pop edx
    ret                 ; Return to MAIN procedure
ShowWelcomeScreen ENDP

; ============================================
; GET PLAYER NAME
; ============================================
GetPlayerName PROC
    push eax
    push ecx
    push edx
   
    call Clrscr
   
    mov dh, 12
    mov dl, 30
    call Gotoxy
   
    mov eax, yellow + (black * 16)
    call SetTextColor
   
    mov edx, OFFSET namePrompt
    call WriteString
   
    ; Reset color
    mov eax, white + (black * 16)
    call SetTextColor

    ; Inside GetPlayerName, before ReadString:
    mov edi, OFFSET playerName
    mov ecx, 20
    mov al, 0
    rep stosb       ; Fill playerName with 0s to clean it
   
    ; Now Read String...
    mov edx, OFFSET playerName
    mov ecx, 15
    call ReadString

   
    ; Small delay
    mov eax, 500
    call Delay
   
    pop edx
    pop ecx
    pop eax
    ret
GetPlayerName ENDP


ShowInstructions PROC
    push eax
    push edx
   
    call Clrscr
   
    ; Title
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 3
    mov dl, 30
    call Gotoxy
    mov edx, OFFSET instructTitle
    call WriteString
   
    ; Movement
    mov eax, cyan + (black * 16)
    call SetTextColor
    mov dh, 6
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET instruct1
    call WriteString
   
    ; Combat
    mov dh, 12
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET instruct2
    call WriteString
   
    ; Objective
    mov dh, 16
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET instruct3
    call WriteString
   
    ; Press key prompt
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov dh, 25
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET instruct4
    call WriteString
   
    ; Wait for key
    call ReadChar
   
    pop edx
    pop eax
    ret
ShowInstructions ENDP


ResetGame PROC
    push eax
    push ecx
    push esi

    ; 1. Reset Core Stats
    mov score, 0
    mov coin, 0
    mov health, 3
    mov currentlevel, 1
    mov skill_coins, 0
   
    ; 2. Reset Player Position
    mov xPos, 3
    mov yPos, 7
    mov jumpCount, 0
    mov isjumping, 'f'
   
    ; 3. Reset Skills & Attributes
    mov skill_speed1, 0
    mov skill_speed2, 0
    mov skill_speed3, 0
    mov skill_jump1, 0
    mov skill_jump2, 0
    mov skill_jump3, 0
    mov skill_health1, 0
    mov skill_health2, 0
    mov skill_ammo1, 0
    mov skill_ammo2, 0
   
    mov jumpheight, 4
    mov max_health, 3
    mov starting_ammo, 20
    mov ammo, 20
   
    ; 4. RESET ENEMIES (STATUS AND POSITIONS)
    ; --- Level 1 Enemies ---
    mov enemy1_alive, 1     ; Alive
    mov enemy1x, 20         ; Reset X
    mov enemy1y, 24         ; Reset Y

    mov enemy2_alive, 1     ; Alive
    mov enemy2x, 100        ; Reset X
    mov enemy2y, 24         ; Reset Y

    ; --- Level 2 Enemies ---
    mov enemy3_alive, 0     ; Starts dead (until level 2)
    mov enemy3x, 120
    mov enemy3y, 7

    mov kt_alive, 0
    mov ktx, 100
    mov kty, 7

    mov f_enemy_alive, 0    ; Reset Flying enemy
    mov f_enemy_x, 60
    mov f_enemy_y, 10
    mov bullet_alive, 0     ; Reset enemy bullet

    ; --- Level 3 Enemies ---
    mov enemy4_alive, 0
    mov enemy4x, 40
    mov enemy4y, 6

    mov enemy5_alive, 0
    mov enemy5x, 10
    mov enemy5y, 11

    mov enemy6_alive, 0
    mov enemy6x, 100
    mov enemy6y, 11

    mov v_enemy_alive, 0
    mov v_enemy_x, 50
    mov v_enemy_y, 24

    ; --- Bowser ---
    mov bowser_alive, 1
    mov bowser_health, 2    ; Reset HP
    mov bowser_x, 110       ; Reset X
    mov bowser_y, 15        ; Reset Y
    mov bowser_fire_alive, 0

    ; 5. Reset Mushrooms
    mov mush1_active, 0
    mov mush1_collected, 0
    mov mush1x, 54          ; Reset position in case it moved
    mov mush1y, 15
   
    mov mush2_active, 0
    mov mush2_collected, 0
    mov mush2x, 100
    mov mush2y, 4
   
    mov count1, 1
    mov count2, 1
   
    ; 6. RESET COIN ARRAYS
    ; --- Level 1 Coins ---
    mov coinx[0], 12
    mov coinx[1], 25
    mov coinx[2], 43
    mov coinx[3], 62
    mov coinx[4], 80
    mov coinx[5], 96
    mov coinx[6], 111
    mov coinx[7], 25
    mov coinx[8], 82
    mov coinx[9], 42
    mov coinx[10], 70
    mov coinx[11], 58

    ; (CoinY usually doesn't change, but good to be safe)
    mov coiny[0], 5
    mov coiny[1], 4
    mov coiny[2], 3
    mov coiny[3], 2
    mov coiny[4], 3
    mov coiny[5], 4
    mov coiny[6], 5
    mov coiny[7], 19
    mov coiny[8], 19
    mov coiny[9], 16
    mov coiny[10], 16
    mov coiny[11], 13

    ; --- Level 2 Coins ---
    mov coinx2[0], 4
    mov coinx2[1], 120
    mov coinx2[2], 100
    mov coinx2[3], 102
    mov coinx2[4], 105
    mov coinx2[5], 127
    mov coinx2[6], 32
    mov coinx2[7], 38
    mov coinx2[8], 78
    mov coinx2[9], 4
    mov coinx2[10], 58
    mov coinx2[11], 80
    mov coinx2[12], 63

    ; --- Level 3 Coins ---
    mov coinx3[0], 4
    mov coinx3[1], 120
    mov coinx3[2], 100
    mov coinx3[3], 102
    mov coinx3[4], 105
    mov coinx3[5], 127
    mov coinx3[6], 32
    mov coinx3[7], 38
    mov coinx3[8], 78
    mov coinx3[9], 4
    mov coinx3[10], 58
    mov coinx3[11], 80
    mov coinx3[12], 63

    ; --- Level 4 Coins ---
    mov coinx4[0], 4
    mov coinx4[1], 120
    mov coinx4[2], 100

    pop esi
    pop ecx
    pop eax
    ret
ResetGame ENDP





AddHighScore PROC
    call LoadHighScores
   
  
    mov eax, itemCount
    cmp eax, 10
    jl Just_Add_To_End
   
  
  
    mov eax, scoreArray[36]    
    mov ebx, score
   
    cmp ebx, eax
    jle Skip_Add        ; If New Score <= Lowest Score, do nothing
   
  
    mov esi, 9          ; Target Index = 9
    jmp Store_Data      ; Jump to store, DO NOT increment itemCount

Just_Add_To_End:
    mov esi, itemCount  ; Target Index = Current Count
    inc itemCount       ; We are adding a new one, so count goes up

Store_Data:
  
    mov eax, score
    mov scoreArray[esi*4], eax
   
  
    ; Calculate offset: esi * 16
    mov eax, 16
    mul esi
    mov edi, OFFSET nameArray
    add edi, eax        ; Destination: nameArray + offset
   
    ; Source: playerName
    push esi            ; Save ESI (Target Index)
    mov esi, OFFSET playerName
    mov ecx, 15
    cld
    rep movsb         
    pop esi            
   
    
    call SortHighScores
    call WriteScoresToFile

Skip_Add:
    ret
AddHighScore ENDP

LoadHighScores PROC
    ; Reset count
    mov itemCount, 0
   
    ; Clear arrays (IMPORTANT!)
    mov edi, OFFSET nameArray
    mov ecx, 160                ; 10 names × 16 bytes
    mov al, 0
    rep stosb
   
    mov edi, OFFSET scoreArray
    mov ecx, 10
    mov eax, 0
clear_scores:
    mov [edi], eax
    add edi, 4
    loop clear_scores
   
    ; Open File
    mov edx, OFFSET hs_filename
    call OpenInputFile
    mov hs_fileHandle, eax
   
    cmp eax, INVALID_HANDLE_VALUE
    je Load_Ret
   
    ; Read File
    mov edx, OFFSET hs_buffer
    mov ecx, SIZEOF hs_buffer
    call ReadFromFile
    mov hs_bufSize, eax
   
    mov eax, hs_fileHandle
    call CloseFile
   
    cmp hs_bufSize, 0
    je Load_Ret
   
    ; --- PARSING ---
    mov esi, 0              ; Buffer index
    mov edi, 0              ; Array index (item count)
   
Parse_Loop:
    cmp esi, hs_bufSize
    jge Load_Done
    cmp edi, 10
    jge Load_Done
   
 
    mov eax, 16
    mul edi
    mov ebx, OFFSET nameArray
    add ebx, eax            ; EBX = address of nameArray[edi]
   
    mov ecx, 0              ; Character counter

Copy_Name:
    cmp esi, hs_bufSize
    jge Load_Done
   
    mov al, hs_buffer[esi]
    inc esi
   
    cmp al, ','             ; Found separator
    je End_Name
   
    cmp al, 13              ; Unexpected newline
    je Parse_Loop
    cmp al, 10
    je Parse_Loop
   
    mov [ebx], al           ; Store character
    inc ebx
    inc ecx
    cmp ecx, 15             ; Max 15 chars
    jl Copy_Name
   
    ; Skip to comma
Skip_To_Comma:
    cmp esi, hs_bufSize
    jge Load_Done
    mov al, hs_buffer[esi]
    inc esi
    cmp al, ','
    jne Skip_To_Comma

End_Name:
    mov BYTE PTR [ebx], 0   ; Null terminate
   
   
    mov edx, OFFSET hs_strBuffer
    mov ecx, 0
   
Copy_Score:
    cmp esi, hs_bufSize
    jge Convert_Score
   
    mov al, hs_buffer[esi]
   
    ; Check for end of number
    cmp al, 13              ; CR
    je Convert_Score
    cmp al, 10              ; LF
    je Convert_Score
    cmp al, ' '
    je Skip_Score_Char      ; Ignore spaces
    cmp al, ','
    je Convert_Score
   
    ; Must be a digit
    cmp al, '0'
    jl Skip_Score_Char
    cmp al, '9'
    jg Skip_Score_Char
   
    ; Store digit
    mov [edx], al
    inc edx
    inc ecx
   
Skip_Score_Char:
    inc esi
    jmp Copy_Score

Convert_Score:
    mov BYTE PTR [edx], 0   ; Null terminate
   
    ; Skip CR/LF
    cmp esi, hs_bufSize
    jge Do_Convert
    mov al, hs_buffer[esi]
    cmp al, 13
    jne Check_LF
    inc esi
Check_LF:
    cmp esi, hs_bufSize
    jge Do_Convert
    mov al, hs_buffer[esi]
    cmp al, 10
    jne Do_Convert
    inc esi

Do_Convert:
    ; Convert string to number
    push esi
    push edi
   
    mov edx, OFFSET hs_strBuffer
    call ParseDecimal32     ; Result in EAX
   
    pop edi
    mov scoreArray[edi*4], eax
   
    pop esi
   
    inc edi
    jmp Parse_Loop

Load_Done:
    mov itemCount, edi      

Load_Ret:
    ret
LoadHighScores ENDP

WriteScoresToFile PROC
    ; Create Output File
    mov edx, OFFSET hs_filename
    call CreateOutputFile
    mov hs_fileHandle, eax
   
    cmp eax, INVALID_HANDLE_VALUE
    je Write_Ret
   
    mov ecx, itemCount
    mov esi, 0              ; Loop Index
   
Write_Loop:
    push ecx                ; Save outer loop counter
   
    ; 1. Write Name
    mov eax, 16
    mul esi
    mov edx, OFFSET nameArray
    add edx, eax
   
    push edx
    call StrLength          ; Get length of name
    pop edx
    mov ecx, eax
    mov eax, hs_fileHandle
    call WriteToFile
   
    ; 2. Write Comma
    mov edx, OFFSET hs_comma
    mov ecx, 1
    mov eax, hs_fileHandle
    call WriteToFile
   
    ; 3. Write Score
    mov eax, scoreArray[esi*4]
    mov edx, OFFSET hs_strBuffer
    call IntToString        ; Convert EAX to String in EDX
   
    ; Get Length of Score String
    mov edx, OFFSET hs_strBuffer
    call StrLength
    mov ecx, eax
    mov eax, hs_fileHandle
    call WriteToFile
   
    ; 4. Write NewLine
    mov edx, OFFSET hs_newLine
    mov ecx, 2
    mov eax, hs_fileHandle
    call WriteToFile
   
    inc esi
    pop ecx                 ; Restore outer loop counter
    loop Write_Loop
   
    mov eax, hs_fileHandle
    call CloseFile

Write_Ret:
    ret
WriteScoresToFile ENDP

ShowHighScores PROC
    call Clrscr
   
    ; Ensure data is fresh
    call LoadHighScores
   
    mov dh, 2
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgHeader
    call WriteString
   
    cmp itemCount, 0
    jg Print_Scores
   
    mov dh, 4
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgNoHighScores
    call WriteString
    jmp Show_Wait
   
Print_Scores:
    mov ecx, itemCount
    mov esi, 0
   
Print_Loop:
    ; Position Cursor
    mov eax, esi
    add eax, 4      ; Start at row 4
    mov dh, al
    mov dl, 25
    call Gotoxy

    ; Print Rank #
    mov eax, esi
    inc eax
    call WriteDec
    mov edx, OFFSET msgRank
    call WriteString
   
    ; Print Name
    mov eax, 16
    mul esi
    mov edx, OFFSET nameArray
    add edx, eax
    call WriteString
   
    ; Spacing
    mov al, 9               ; Tab
    call WriteChar
    call WriteChar
   
    ; Print Score
    mov eax, scoreArray[esi*4]
    call WriteDec
   
    mov edx, OFFSET msgPoints
    call WriteString
   
    inc esi
    loop Print_Loop

Show_Wait:
    mov dh, 16
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgPressKey
    call WriteString
    call ReadChar
    ret
ShowHighScores ENDP

SortHighScores PROC
    ; Check if there are enough items to sort
    cmp itemCount, 2
    jl Sort_Done
   
    ; Outer Loop Counter = N - 1
    mov ecx, itemCount
    dec ecx
   
OuterLoop:
    push ecx                ; Save Outer Loop Counter
    mov esi, 0              ; Reset Array Index
   
InnerLoop:
    ; --- COMPARE SCORES ---
    ; Current: scoreArray[esi*4]
    ; Next:    scoreArray[esi*4 + 4]
    mov eax, scoreArray[esi*4]
    mov ebx, scoreArray[esi*4 + 4]
   
    ; Check order (Descending)
    cmp eax, ebx
    ; ERROR FIX: "jge No_Swap" might be too far.
    ; We use inverse logic: Jump if LESS to a nearby label to Perform Swap.
    ; If Greater or Equal, we jump over the swap using a long unconditional jump.
    jl Perform_Swap
    jmp No_Swap             ; This is a JMP (unlimited range), fixing the "too far" error

Perform_Swap:
 


   
    ; 1. Swap Integers (Scores)
    mov scoreArray[esi*4], ebx
    mov scoreArray[esi*4 + 4], eax
   
    ; 2. Swap Strings (Names)
    ; Preserve registers
    push esi
    push ecx
    push edi
   
    cld                    
   
    ; --- Step A: Copy Name[esi] into Temp ---
    mov eax, 16            
    mul esi                
    mov edx, eax            ; Save offset in EDX for recalculation later
   
    lea esi, nameArray      
    add esi, eax            ; ESI = &Name[Current]
   
    mov edi, OFFSET tempNameBuf
    mov ecx, 16            
    rep movsb
   
    ; --- Step B: Copy Name[esi+1] into Name[esi] ---
    ; Restore original Index Offset from EDX (calculated above)
    ; Name[Current] is at nameArray + EDX
    mov edi, OFFSET nameArray
    add edi, edx            ; Destination
   
    ; Name[Next] is at nameArray + EDX + 16
    mov esi, OFFSET nameArray
    add esi, edx
    add esi, 16             ; Source
   
    mov ecx, 16
    rep movsb
   
    ; --- Step C: Copy Temp into Name[esi+1] ---
    ; Dest is Name[Next] (nameArray + EDX + 16)
    mov edi, OFFSET nameArray
    add edi, edx
    add edi, 16
   
    mov esi, OFFSET tempNameBuf
    mov ecx, 16
    rep movsb
   
    ; Restore registers
    pop edi
    pop ecx
    pop esi
   

No_Swap:
    inc esi                 ; Move to next index
   
    ; ERROR FIX: Replace "loop InnerLoop" with DEC/JNZ
    ; "loop" is limited to 127 bytes. "jnz" can jump anywhere.
    dec ecx
    jnz InnerLoop
   
    ; End of Outer Loop
    pop ecx                 ; Restore Outer Loop Counter
   
    dec ecx
    jnz OuterLoop

Sort_Done:
    ret
SortHighScores ENDP

IntToString PROC
    ; Converts EAX to String at EDX
    push ebx
    push ecx
    push edx
    push esi
    push edi
   
    mov edi, edx        ; EDI = buffer
    mov ecx, 0          ; digit count
    mov ebx, 10
   
    cmp eax, 0
    jne DivLoop
    mov BYTE PTR [edi], '0'
    inc edi
    jmp DoneConvert
   
DivLoop:
    mov edx, 0
    div ebx             ; EAX / 10
    push edx            ; Push Remainder
    inc ecx
    cmp eax, 0
    jne DivLoop
   
PopDigits:
    pop eax
    add al, '0'
    mov [edi], al
    inc edi
    loop PopDigits

DoneConvert:
    mov BYTE PTR [edi], 0 ; Null terminate
   
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
IntToString ENDP


.data
saveFilename    BYTE "savegame.txt", 0
saveHandle      HANDLE ?
saveBuffer      BYTE 200 DUP(?)     ; Buffer to hold file data
saveBufSize     DWORD ?
commaDelim      BYTE ",", 0
strBuffer       BYTE 20 DUP(0)      ; Temp buffer for IntToString conversion
msgSaveSuccess  BYTE "Game Saved!", 0
msgLoadSuccess  BYTE "Game Loaded!", 0
msgLoadFail     BYTE "No Save Found!", 0


.code
SaveGame PROC
    ; 1. Create the File
    mov edx, OFFSET saveFilename
    call CreateOutputFile
    mov saveHandle, eax
    cmp eax, INVALID_HANDLE_VALUE
    je SaveRet

    ; --- SAVE VARIABLES ---
    movzx eax, currentLevel
    call WriteValueToFile
   
    movzx eax, health
    call WriteValueToFile
   
    movzx eax, xPos
    call WriteValueToFile
   
    movzx eax, yPos
    call WriteValueToFile
   
    mov eax, score
    call WriteValueToFile
   
    movzx eax, ammo
    call WriteValueToFile
   
    movzx eax, coin
    call WriteValueToFile

    ; --- SAVE COIN STATES (LEVEL 1) - Size 12 ---
    mov ecx, 12
    mov esi, 0
SaveCoins1:
    push ecx            ; Save loop counter
    movzx eax, coinx[esi]
    call WriteValueToFile
    inc esi
    pop ecx             ; Restore loop counter
    loop SaveCoins1

    ; --- SAVE COIN STATES (LEVEL 2) - Size 13 ---
    mov ecx, 13
    mov esi, 0
SaveCoins2:
    push ecx
    movzx eax, coinx2[esi]
    call WriteValueToFile
    inc esi
    pop ecx
    loop SaveCoins2

    ; --- SAVE COIN STATES (LEVEL 3) - Size 13 ---
    mov ecx, 13
    mov esi, 0
SaveCoins3:
    push ecx
    movzx eax, coinx3[esi]
    call WriteValueToFile
    inc esi
    pop ecx
    loop SaveCoins3

    ; --- SAVE COIN STATES (LEVEL 4) - Size 3 ---
    mov ecx, 3
    mov esi, 0
SaveCoins4:
    push ecx
    movzx eax, coinx4[esi]
    call WriteValueToFile
    inc esi
    pop ecx
    loop SaveCoins4

    ; 3. Close File
    mov eax, saveHandle
    call CloseFile

    ; Feedback
    mov dh, 1
    mov dl, 60
    call Gotoxy
    mov edx, OFFSET msgSaveSuccess
    call WriteString
    mov eax, 1000
    call Delay

SaveRet:
    ret
SaveGame ENDP

; --- Helper to write EAX and a comma to saveHandle ---
WriteValueToFile PROC
    push eax
    push ecx
    push edx

    ; Convert EAX to String
    mov edx, OFFSET strBuffer
    call IntToString            ; You already have this PROC in your code

    ; Write Number String
    mov edx, OFFSET strBuffer
    call StrLength
    mov ecx, eax
    mov eax, saveHandle
    mov edx, OFFSET strBuffer
    call WriteToFile

    ; Write Comma
    mov eax, saveHandle
    mov edx, OFFSET commaDelim
    mov ecx, 1
    call WriteToFile

    pop edx
    pop ecx
    pop eax
    ret
WriteValueToFile ENDP

LoadGame PROC
    ; 1. Open File
    mov edx, OFFSET saveFilename
    call OpenInputFile
    mov saveHandle, eax
    cmp eax, INVALID_HANDLE_VALUE
    je LoadFail

    ; 2. Read File into Buffer
    mov edx, OFFSET saveBuffer
    mov ecx, SIZEOF saveBuffer
    call ReadFromFile
    mov saveBufSize, eax
   
    mov eax, saveHandle
    call CloseFile

    ; 3. Parse the Buffer
    mov esi, 0              ; Buffer Index

    ; --- LOAD VARIABLES ---
    call ParseNextNumber
    mov currentLevel, al

    call ParseNextNumber
    mov health, al

    call ParseNextNumber    ; FIXED: Was WriteValueToFile
    mov xPos, al

    call ParseNextNumber    ; FIXED: Was WriteValueToFile
    mov yPos, al

    call ParseNextNumber
    mov score, eax

    call ParseNextNumber
    mov ammo, al

    call ParseNextNumber
    mov coin, al

    ; --- LOAD COIN STATES (LEVEL 1) ---
    mov ecx, 12
    mov edi, 0
LoadCoins1:
    push ecx
    call ParseNextNumber    ; Read number (e.g., 12 or 255)
    mov coinx[edi], al      ; Update array in memory
    inc edi
    pop ecx
    loop LoadCoins1

    ; --- LOAD COIN STATES (LEVEL 2) ---
    mov ecx, 13
    mov edi, 0
LoadCoins2:
    push ecx
    call ParseNextNumber
    mov coinx2[edi], al
    inc edi
    pop ecx
    loop LoadCoins2

    ; --- LOAD COIN STATES (LEVEL 3) ---
    mov ecx, 13
    mov edi, 0
LoadCoins3:
    push ecx
    call ParseNextNumber
    mov coinx3[edi], al
    inc edi
    pop ecx
    loop LoadCoins3

    ; --- LOAD COIN STATES (LEVEL 4) ---
    mov ecx, 3
    mov edi, 0
LoadCoins4:
    push ecx
    call ParseNextNumber
    mov coinx4[edi], al
    inc edi
    pop ecx
    loop LoadCoins4

    ; Visual Feedback
    mov dh, 1
    mov dl, 60
    call Gotoxy
    mov edx, OFFSET msgLoadSuccess
    call WriteString
    mov eax, 1000
    call Delay
    ret

LoadFail:
    mov dh, 1
    mov dl, 60
    call Gotoxy
    mov edx, OFFSET msgLoadFail
    call WriteString
    mov eax, 1000
    call Delay
    ret
LoadGame ENDP

; --- Helper: Reads next number from saveBuffer at ESI ---
ParseNextNumber PROC
    push ebx
    push edx
    push edi

    mov edi, OFFSET strBuffer ; Use temp buffer
    mov ebx, 0                ; Char count

ParseLoop:
    ; Check Bounds
    cmp esi, saveBufSize
    jge DoneParse

    ; Get Char
    mov al, saveBuffer[esi]
    inc esi

    ; Check Delimiter
    cmp al, ','
    je DoneParse
    cmp al, 13 ; CR
    je ParseLoop
    cmp al, 10 ; LF
    je ParseLoop

    ; Store in temp string
    mov [edi], al
    inc edi
    jmp ParseLoop

DoneParse:


    mov BYTE PTR [edi], 0    
   
    ; Convert String to Int
    push esi
    mov edx, OFFSET strBuffer
    call ParseDecimal32      
    pop esi

    pop edi
    pop edx
    pop ebx
    ret
ParseNextNumber ENDP



VictorySequence PROC
    push eax
    push ebx
    push ecx
    push edx

    call WriteScoresToFile
    
    ; Play Level Clear Sound
    push ecx          
    push esi            
    push edi            
    INVOKE PlaySoundA, ADDR stageclear, 0, SND_ASYNC OR SND_FILENAME
    pop edi
    pop esi
    pop ecx

    ; Clear screen and load victory level
    call Clrscr
    call LoadLevel
    
    ; Set player start position (far left)
    mov xPos, 0
    mov yPos, 24
 
    mov ecx, 55              ; Run for 70 steps (to reach castle)
    
auto_run_loop:
    push ecx                 ; Save counter
    call UpdatePlayer
    inc xPos                 ; Move player right
    call DrawPlayer
    mov eax, 80
    call Delay
    pop ecx                  ; Restore counter
    loop auto_run_loop
    
    mov ecx, 5
enter_castle:
    push ecx
    call UpdatePlayer
    dec yPos                 ; Move up slightly
    call DrawPlayer
    mov eax, 100
    call Delay
    pop ecx
    loop enter_castle
    
    ; Erase player (entered castle)
    call UpdatePlayer
 
    mov eax, 500
    call Delay
    
    ; Clear screen for message
    call Clrscr
   
    mov eax, yellow + (blue * 16)
    call SetTextColor
  
    mov dl, 35
    mov dh, 8
    call Gotoxy
    mov edx, OFFSET victoryMsg1
    call WriteString
    
   
    mov eax, lightGreen + (blue * 16)
    call SetTextColor
    mov dl, 35
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET victoryMsg2
    call WriteString
    
    ; Line 3 - YOU SAVED THE PRINCESS
    mov eax, white + (blue * 16)
    call SetTextColor
    mov dl, 35
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET victoryMsg3
    call WriteString
    
    ; Line 4 - THANK YOU HERO
    mov eax, lightMagenta + (blue * 16)
    call SetTextColor
    mov dl, 35
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET victoryMsg4
    call WriteString
    
    ; Line 5
    mov eax, yellow + (blue * 16)
    call SetTextColor
    mov dl, 35
    mov dh, 16
    call Gotoxy
    mov edx, OFFSET victoryMsg5
    call WriteString



    
    ; 1. Check if there is time remaining
    movzx ecx, timerr       ; Load the WORD variable 'timerr' into ECX
    cmp ecx, 0
    je skip_time_bonus      ; If 0, skip calculation

    ; Display "Calculating Time Bonus..."
    mov eax, white + (blue * 16)
    call SetTextColor
    mov dl, 35
    mov dh, 20
    call Gotoxy
    ; You can define a new string or just output raw text here if needed
    ; For now, we will just process the math visually

time_bonus_loop:
    ; Add Bonus (e.g., 50 points per second)
    add score, 50
    
    ; Decrement the timer variable in memory
    dec timerr 
    
    ; Optional: Play a short beep for effect (Countdown sound)
    ; We push/pop ECX because Beep/Delay might affect registers
    push ecx
    INVOKE Beep, 1000, 15   ; 1000Hz, 15ms duration
    pop ecx

    ; Small Delay to make the count feel like an animation
    mov eax, 10
    call Delay

    loop time_bonus_loop

skip_time_bonus:



    
    ; Final Score Display
    mov eax, cyan + (blue * 16)
    call SetTextColor
    mov dl, 35
    mov dh, 18
    call Gotoxy
    mov edx, OFFSET victoryMsg6
    call WriteString
    
    mov eax, score          
    call WriteDec
    
    ; Press any key
    mov eax, white + (blue * 16)
    call SetTextColor
    mov dl, 35
    mov dh, 22
    call Gotoxy
    mov edx, OFFSET victoryMsg7
    call WriteString
    
    ; Wait for key press
    call ReadChar
    
    ; Reset color
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
VictorySequence ENDP

END main




