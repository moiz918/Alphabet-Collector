[org 0x0100]
jmp start

;********* variables **********

;********* variables **********

boxPosition: dw 3920
boxChar: dw 0x07dc
oldKeyboardISR: dd 0
oldTimerISR: dd 0
startMessage: db 'START !', 0
scoreMessage: db 'SCORE: ', 0
missedMessage: db 'MISSED: ', 0
gameOverMessage: db 'GAME OVER', 0
exitFlag: dw 0
restartFlag: dw 0
missedCount: dw 0
scoreCount: dw 0
randomSeed: dw 0
randomValue: dw 0
letter1: dw 0
letter1Position: dw 0
letter1Active: dw 0
letter1Timer: dw 0
letter2: dw 0
letter2Position: dw 0
letter2Active: dw 0
letter2Timer: dw 0
letter3: dw 0
letter3Position: dw 0
letter3Active: dw 0
letter3Timer: dw 0
letter4: dw 0
letter4Position: dw 0
letter4Active: dw 0
letter4Timer: dw 0
letter5: dw 0
letter5Position: dw 0
letter5Active: dw 0
letter5Timer: dw 0

;****************re-initialize***************************
reinitialize_vars:
    mov word [boxPosition], 3920        ; Reset box position
    mov word [boxChar], 0x07dc          ; Reset box character and attribute
    mov word [exitFlag], 0              ; Reset termination flag
    mov word [missedCount], 0           ; Reset life counter
    mov word [scoreCount], 0            ; Reset score

    ; Reset letter 1 variables
    mov word [letter1], 0
    mov word [letter1Position], 0
    mov word [letter1Active], 0
    mov word [letter1Timer], 0

    ; Reset letter 2 variables
    mov word [letter2], 0
    mov word [letter2Position], 0
    mov word [letter2Active], 0
    mov word [letter2Timer], 0

    ; Reset letter 3 variables
    mov word [letter3], 0
    mov word [letter3Position], 0
    mov word [letter3Active], 0
    mov word [letter3Timer], 0

    ; Reset letter 4 variables
    mov word [letter4], 0
    mov word [letter4Position], 0
    mov word [letter4Active], 0
    mov word [letter4Timer], 0

    ; Reset letter 5 variables
    mov word [letter5], 0
    mov word [letter5Position], 0
    mov word [letter5Active], 0
    mov word [letter5Timer], 0

    ; Reset random number variables
    mov word [randomSeed], 0
    mov word [randomValue], 0
    ret

;******** printing lines ********

displayStartMessage:
    push ax
    push si
    push di
    push bx
    push cx
    call clrscrn
    mov ax, 0xb800
    mov es, ax
    mov di, 1834
    mov cx, 7
    mov ah, 0x09
    mov si, startMessage
    cld
p1:
    lodsb
    stosw
    loop p1
    mov bx, 30
l1:
    mov cx, 65000
l2:
    dec cx
    cmp cx, 0
    jne l2
    dec bx
    cmp bx, 0
    jne l1
    pop cx
    pop bx
    pop di
    pop si
    pop ax
    ret

displayEndMessage:
    push ax
    push si
    push di
    push bx
    push cx
    mov ax, 0xb800
    mov es, ax
    mov di, 1832
    mov cx, 9
    mov ah, 0x84
    mov si, gameOverMessage
    cld
e1:
    lodsb
    stosw
    loop e1
    mov di, 1980
    mov cx, 7
    mov ah, 0x07
    mov si, scoreMessage
    cld
pp2:
    lodsb
    stosw
    loop pp2
    mov di, 2002
    mov cx, 8
    mov ah, 0x07
    mov si, missedMessage
    cld
ppp2:
    lodsb
    stosw
    loop ppp2
    mov ax, 1994
    push ax
    push word[scoreCount]
    call printNumber
    mov ax, 2018
    push ax
    push word[missedCount]
    call printNumber
    pop cx
    pop bx
    pop di
    pop si
    pop ax
    ret

displayMissedMessage:
    push ax
    push si
    push di
    push bx
    push cx
    mov ax, 0xb800
    mov es, ax
    mov di, 20
    mov cx, 8
    mov ah, 0x0E
    mov si, missedMessage
    cld
p3:
    lodsb
    stosw
    loop p3
    pop cx
    pop bx
    pop di
    pop si
    pop ax
    ret

displayScoreMessage:
    push ax
    push si
    push di
    push bx
    push cx
    mov ax, 0xb800
    mov es, ax
    mov di, 114
    mov cx, 7
    mov ah, 0x0E
    mov si, scoreMessage
    cld
p2:
    lodsb
    stosw
    loop p2
    pop cx
    pop bx
    pop di
    pop si
    pop ax
    ret
;********* keyboard isr *********

keyboardISR:
    push ax
    in al, 0x60
    cmp al, 0x4b            ; Left arrow key
    jne checkRightArrow
    call clearbox
    call moveBoxLeft
    call drawBox
    jmp exitISR

checkRightArrow:
    cmp al, 0x4d            ; Right arrow key
    jne checkEscape
    call clearbox
    call moveBoxRight
    call drawBox
    jmp exitISR

checkEscape:
    cmp al, 0x01            ; Escape key
    jne checkRestart
    mov word[exitFlag], 1
    jmp exitISR

checkRestart:
    cmp al, 0x1E            ; 'A' key
    jne noMatch
    mov word[restartFlag], 1

noMatch:
    pop ax
    jmp far [cs:oldKeyboardISR]

exitISR:
    mov al, 0x20
    out 0x20, al
    pop ax
    iret


;********** box movement and printing *********

drawBox:
    push ax
    mov ax, 0xB800
    mov es, ax
    mov di, word[boxPosition]
    mov ax, word[boxChar]
    mov word[es:di], ax
    pop ax
    ret

moveBoxLeft:
    cmp word[boxPosition], 3840
    jbe wrapLeft
    push ax
    mov ax, word[boxPosition]
    sub ax, 2
    mov word[boxPosition], ax
    pop ax
    jmp endLeft
wrapLeft:
    push ax
    mov ax, 3998
    mov word[boxPosition], ax
    pop ax
endLeft:
    ret

moveBoxRight:
    cmp word[boxPosition], 3998
    jae wrapRight
    push ax
    mov ax, word[boxPosition]
    add ax, 2
    mov word[boxPosition], ax
    pop ax
    jmp endRight
wrapRight:
    push ax
    mov ax, 3840
    mov word[boxPosition], ax
    pop ax
endRight:
    ret

;********** clear functions **********

clrscrn:
    push ax
    mov ax, 0xB800
    mov es, ax
    mov di, 0
clearScreenLoop:
    mov word[es:di], 0x0720
    add di, 2
    cmp di, 4000
    jne clearScreenLoop
    pop ax
    ret

clearbox:
    push ax
    mov ax, 0xB800
    mov es, ax
    mov di, 3840
clearBoxLoop:
    mov word[es:di], 0x0720
    add di, 2
    cmp di, 4000
    jne clearBoxLoop
    pop ax
    ret

;********* prints score and life *********

printNumber:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push dx
    push di
    mov ax, 0xb800
    mov es, ax ; point es to video base
    mov ax, [bp+4] ; load number in ax
    mov bx, 10 ; use base 10 for division
    mov cx, 0 ; initialize count of digits
nextDigit:
    mov dx, 0 ; zero upper half of dividend
    div bx ; divide by 10
    add dl, 0x30 ; convert digit into ascii value
    push dx ; save ascii value on stack
    inc cx ; increment count of values
    cmp ax, 0 ; is the quotient zero
    jnz nextDigit ; if no divide it again
    mov di, [bp+6] ; point di to 70th column
nextPosition:
    pop dx ; remove a digit from the stack
    mov dh, 0x07 ; use normal attribute
    mov [es:di], dx ; print char on screen
    add di, 2 ; move to next screen location
    loop nextPosition ; repeat for all digits on stack
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 4

displayNumbers:
    mov ax, 128
    push ax
    push word[scoreCount]
    call printNumber
    mov ax, 36
    push ax
    push word[missedCount]
    call printNumber
    ret
;********* timer isr **********

timerISR:
    call updateLetter1
    call updateLetter2
    call updateLetter3
    call updateLetter4
    call updateLetter5
    jmp far [cs:oldTimerISR]

;********** character functions ************

updateLetter1:
    call displayNumbers
    inc word [letter1Timer]
    cmp word [letter1Timer], 7
    jne midEnd1
    mov word [letter1Timer], 0
    cmp word [letter1Active], 0
    jne moveDown1
    mov word [randomSeed], 0
    mov word [randomValue], 0
    call setupLetter1
    mov ax, 0xb800
    mov es, ax
    mov di, [letter1Position]
    mov ax, [letter1]
    mov word[es:di], ax
    inc word [letter1Active]
    jmp end1

moveDown1:
    mov di, [letter1Position]
    mov word[es:di], 0x0720
    add word [letter1Position], 160
    cmp word [letter1Position], 3840
    ja changeLetter1
    mov di, [letter1Position]
    mov ax, [letter1]
    mov word[es:di], ax
midEnd1:
    jmp end1

changeLetter1:
    push ax
    mov ax, [letter1Position]
    cmp ax, [boxPosition]
    jne incMissedCount1
    pop ax
    inc word [scoreCount]
    mov word [letter1Position], 0
    mov word [letter1], 0
    mov word [letter1Active], 0
    jmp end1

incMissedCount1:
    pop ax
    inc word [missedCount]
    mov word [letter1Position], 0
    mov word [letter1], 0
    mov word [letter1Active], 0
end1:
    ret

updateLetter2:
    call displayNumbers
    inc word [letter2Timer]
    cmp word [letter2Timer], 3
    jne midEnd2
    mov word [letter2Timer], 0
    cmp word [letter2Active], 0
    jne moveDown2
    mov word [randomSeed], 0
    mov word [randomValue], 0
    call setupLetter2
    mov ax, 0xb800
    mov es, ax
    mov di, [letter2Position]
    mov ax, [letter2]
    mov word[es:di], ax
    inc word [letter2Active]
    jmp end2

moveDown2:
    mov di, [letter2Position]
    mov word[es:di], 0x0720
    add word [letter2Position], 160
    cmp word [letter2Position], 3840
    ja changeLetter2
    mov di, [letter2Position]
    mov ax, [letter2]
    mov word[es:di], ax
midEnd2:
    jmp end2

changeLetter2:
    push ax
    mov ax, [letter2Position]
    cmp ax, [boxPosition]
    jne incMissedCount2
    pop ax
    inc word [scoreCount]
    mov word [letter2Position], 0
    mov word [letter2], 0
    mov word [letter2Active], 0
    jmp end2

incMissedCount2:
    pop ax
    inc word [missedCount]
    mov word [letter2Position], 0
    mov word [letter2], 0
    mov word [letter2Active], 0
end2:
    ret

updateLetter3:
    call displayNumbers
    inc word [letter3Timer]
    cmp word [letter3Timer], 15
    jne midEnd3
    mov word [letter3Timer], 0
    cmp word [letter3Active], 0
    jne moveDown3
    mov word [randomSeed], 0
    mov word [randomValue], 0
    call setupLetter3
    mov ax, 0xb800
    mov es, ax
    mov di, [letter3Position]
    mov ax, [letter3]
    mov word[es:di], ax
    inc word [letter3Active]
    jmp end3

moveDown3:
    mov di, [letter3Position]
    mov word[es:di], 0x0720
    add word [letter3Position], 160
    cmp word [letter3Position], 3840
    ja changeLetter3
    mov di, [letter3Position]
    mov ax, [letter3]
    mov word[es:di], ax
midEnd3:
    jmp end3

changeLetter3:
    push ax
    mov ax, [letter3Position]
    cmp ax, [boxPosition]
    jne incMissedCount3
    pop ax
    inc word [scoreCount]
    mov word [letter3Position], 0
    mov word [letter3], 0
    mov word [letter3Active], 0
    jmp end3

incMissedCount3:
    pop ax
    inc word [missedCount]
    mov word [letter3Position], 0
    mov word [letter3], 0
    mov word [letter3Active], 0
end3:
    ret

updateLetter4:
    call displayNumbers
    inc word [letter4Timer]
    cmp word [letter4Timer], 11
    jne midEnd4
    mov word [letter4Timer], 0
    cmp word [letter4Active], 0
    jne moveDown4
    mov word [randomSeed], 0
    mov word [randomValue], 0
    call setupLetter4
    mov ax, 0xb800
    mov es, ax
    mov di, [letter4Position]
    mov ax, [letter4]
    mov word[es:di], ax
    inc word [letter4Active]
    jmp end4

moveDown4:
    mov di, [letter4Position]
    mov word[es:di], 0x0720
    add word [letter4Position], 160
    cmp word [letter4Position], 3840
    ja changeLetter4
    mov di, [letter4Position]
    mov ax, [letter4]
    mov word[es:di], ax
midEnd4:
    jmp end4

changeLetter4:
    push ax
    mov ax, [letter4Position]
    cmp ax, [boxPosition]
    jne incMissedCount4
    pop ax
    inc word [scoreCount]
    mov word [letter4Position], 0
    mov word [letter4], 0
    mov word [letter4Active], 0
    jmp end4

incMissedCount4:
    pop ax
    inc word [missedCount]
    mov word [letter4Position], 0
    mov word [letter4], 0
    mov word [letter4Active], 0
end4:
    ret

updateLetter5:
    call displayNumbers
    inc word [letter5Timer]
    cmp word [letter5Timer], 18
    jne midEnd5
    mov word [letter5Timer], 0
    cmp word [letter5Active], 0
    jne moveDown5
    mov word [randomSeed], 0
    mov word [randomValue], 0
    call setupLetter5
    mov ax, 0xb800
    mov es, ax
    mov di, [letter5Position]
    mov ax, [letter5]
    mov word[es:di], ax
    inc word [letter5Active]
    jmp end5

moveDown5:
    mov di, [letter5Position]
    mov word[es:di], 0x0720
    add word [letter5Position], 160
    cmp word [letter5Position], 3840
    ja changeLetter5
    mov di, [letter5Position]
    mov ax, [letter5]
    mov word[es:di], ax
midEnd5:
    jmp end5

changeLetter5:
    push ax
    mov ax, [letter5Position]
    cmp ax, [boxPosition]
    jne incMissedCount5
    pop ax
    inc word [scoreCount]
    mov word [letter5Position], 0
    mov word [letter5], 0
    mov word [letter5Active], 0
    jmp end5

incMissedCount5:
    pop ax
    inc word [missedCount]
    mov word [letter5Position], 0
    mov word [letter5], 0
    mov word [letter5Active], 0
end5:
    ret

;********* random chararcter and number ********

genRandChar:
    mov word [randomSeed], 0
    mov word [randomValue], 0
    push bp
    mov bp, sp
    pusha
    cmp word [randomSeed], 0
    jne nextChar
    mov ah, 00h 
    int 1ah
    inc word [randomSeed]
    mov [randomValue], dx
    jmp nextChar1

nextChar:
    mov ax, 25173
    mul word [randomValue]
    add ax, 13849
    mov [randomValue], ax

nextChar1:
    xor dx, dx
    mov ax, [randomValue]
    mov cx, [bp+4]
    inc cx
    div cx
    add dl, 'A'
    mov [bp+6], dx
    popa
    pop bp
    ret 2

genRandNum:
    mov word [randomSeed], 0
    mov word [randomValue], 0
    push bp
    mov bp, sp
    pusha
    cmp word [randomSeed], 0
    jne nextNum
    mov ah, 00h 
    int 1ah
    inc word [randomSeed]
    mov [randomValue], dx
     jmp nextNum1

nextNum:
    mov ax, 25173         
    mul word [randomValue]   
    add ax, 13849     
    mov [randomValue], ax

nextNum1:
    xor dx, dx
    mov ax, [randomValue]
    mov cx, [bp+4]
    inc cx
    div cx
    mov [bp+6], dx
    popa
    pop bp
    ret 2

setupLetter1:
    push ax
    sub sp, 2
    push 25
    call genRandChar
    pop ax
    mov ah, 0x0E
    mov word[letter1], ax
    mov ax, 0
    sub sp, 2
    push 80
    call genRandNum
    pop ax
    shl ax, 1
    add ax, 54
    cmp ax, 160
    jae adjustPosition1
    add ax, 160
adjustPosition1:
    mov word[letter1Position], ax
    pop ax
    ret

setupLetter2:
    push ax
    sub sp, 2
    push 25
    call genRandChar
    pop ax
    mov ah, 0x0C
    mov word[letter2], ax
    mov ax, 0
    sub sp, 2
    push 80
    call genRandNum
    pop ax
    shl ax, 1
    add ax, 128
    cmp ax, 160
    jae adjustPosition2
    add ax, 160
adjustPosition2:
    mov word[letter2Position], ax
    pop ax
    ret

setupLetter3:
    push ax
    sub sp, 2
    push 25
    call genRandChar
    pop ax
    mov ah, 0x0D
    mov word[letter3], ax
    mov ax, 0
    sub sp, 2
    push 80
    call genRandNum
    pop ax
    shl ax, 1
    add ax, 104
    cmp ax, 160
    jae adjustPosition3
    add ax, 160
adjustPosition3:
    mov word[letter3Position], ax
    pop ax
    ret

setupLetter4:
    push ax
    sub sp, 2
    push 25
    call genRandChar
    pop ax
    mov ah, 0x09
    mov word[letter4], ax
    mov ax, 0
    sub sp, 2
    push 80
    call genRandNum
    pop ax
    shl ax, 1
    add ax, 74
    cmp ax, 160
    jae adjustPosition4
    add ax, 160
adjustPosition4:
    mov word[letter4Position], ax
    pop ax
    ret

setupLetter5:
    push ax
    sub sp, 2
    push 25
    call genRandChar
    pop ax
    mov ah, 0x0A
    mov word[letter5], ax
    mov ax, 0
    sub sp, 2
    push 80
    call genRandNum
    pop ax
    shl ax, 1
    add ax, 36
    cmp ax, 160
    jae adjustPosition5
    add ax, 160
adjustPosition5:
    mov word[letter5Position], ax
    pop ax
    ret
;********** start *************

start:
    call displayStartMessage
    call clrscrn
    call displayScoreMessage
    call displayMissedMessage
    call drawBox

    xor ax, ax
    mov es, ax ; point es to IVT base
    mov ax, [es:9*4]
    mov word[oldKeyboardISR], ax
    mov ax, [es:9*4+2]
    mov word[oldKeyboardISR+2], ax
    mov ax, [es:8*4]
    mov word[oldTimerISR], ax
    mov ax, [es:8*4+2]
    mov word[oldTimerISR+2], ax
    cli
    mov word [es:9*4], keyboardISR
    mov [es:9*4+2], cs
    mov word [es:8*4], timerISR
    mov [es:8*4+2], cs
    sti

gameLoop:
    cmp word[missedCount], 10
    jae finalExit
    cmp word[exitFlag], 0
    jne finalExit
    jmp gameLoop

finalExit:
    cmp word[missedCount], 10
    jbe continueGame
    mov word[missedCount], 10
continueGame:
    call clrscrn
    call displayEndMessage
    cmp word[restartFlag], 1
    jne finish

    call reinitialize_vars
    jmp start

finish:
    cli
    xor ax, ax
    mov es, ax
    mov cx, [oldTimerISR]
    mov dx, [oldTimerISR+2]
    mov word [es:8*4], cx
    mov word [es:8*4+2], dx
    sti

    mov dx, start
    add dx, 15
    mov cl, 4
    shr dx, cl
    mov ax, 0x4c00
    int 21h