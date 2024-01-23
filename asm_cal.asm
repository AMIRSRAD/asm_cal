.model small
.stack 100h

.data

msg db 13,10," ENTER AN OPERATOR:",13,10," 1:ADD",13,10," 2:MULTIPLY",13,10," 3:DIVIDE",13,10," 4:SUBTRACT",13,10," 5:POW",13,10," 6:SQRT",13,10," 0:EXIT",13,10, "$"
w_input db "    Wrong input pressed, Try Again",13,10,"$"
msg1 db 13,10," ENTER THE FIRST NUMBER:","$"
msg2 db 13,10," ENTER THE SECOND NUMBER:","$"
msg3 db 13,10," Answer is: ","$"


.code

main proc far
;main proc


mov ax,@data ;move dataseg into ds
mov ds,ax

start:

mov ah,09h
mov dx, offset msg ;show the first msg
int 21h


mov ah,00h  ;read a key from keybaord
int 16h

cmp al,30h
je getToExit

cmp al,31h
je getToAdd

cmp al,32h
je getToMul

cmp al,33h
je getToDev

cmp al,34h
je getToSub

cmp al,35h
je getToPow

cmp al,36h
je getToSqrt


mov ah,09h
mov dx, offset w_input ;show error msg
int 21h
jmp start


jmp exit


getToAdd:; to avoid error Relative jump out of range by xxxh bytes because conditional jumps are limited in 8086
jmp addition

getToMul:
jmp multiplication

getToSub: 
jmp subtraction

getToDev:
jmp division

getToExit:
jmp exit

getToPow:
jmp power

getToSqrt:
jmp squareRoot




addition:
mov ah,09h
mov dx, offset msg1
int 21h
mov cx,0 ;we will call InputNo to handle our input as we will take each number seprately
call getInput
push dx ; pushing the 1st number in a stack
mov ah,09h
mov dx, offset msg2
int 21h
mov cx,0
call getInput
pop bx ; poping the 1st number
add dx,bx ;adding the 1st num wish 2nd
push dx  ; pushing the resault into the stack cause it we dont want to override it with msg3
mov ah,09h
mov dx, offset msg3
int 21h
pop dx
mov ax,dx
call displayDigit 
jmp restart 



multiplication:
mov ah,09h
mov dx, offset msg1
int 21h
mov cx,0
call getInput
push dx
mov ah,09h
mov dx, offset msg2
int 21h
mov cx,0
call getInput
pop bx
mov ax,dx
mul bx 
mov dx,ax
push dx 
mov ah,09h
mov dx, offset msg3
int 21h
pop dx
mov ax,dx
call displayDigit 
jmp restart 



division:
mov ah,09h
mov dx, offset msg1
int 21h
mov cx,0
call getInput
push dx
mov ah,09h
mov dx, offset msg2
int 21h
mov cx,0
call getInput
pop bx
mov ax,bx
mov cx,dx
mov dx,0
mov bx,0
div cx
mov bx,dx
mov dx,ax
push bx 
push dx 
mov ah,09h
mov dx, offset msg3
int 21h
pop dx
mov ax,dx
call displayDigit 
pop bx
jmp restart


subtraction:
mov ah,09h
mov dx, offset msg1
int 21h
mov cx,0
call getInput
push dx
mov ah,09h
mov dx, offset msg2
int 21h
mov cx,0
call getInput
pop bx
sub bx,dx
mov dx,bx
push dx 
mov ah,09h
mov dx, offset msg3
int 21h
pop dx
mov ax,dx
call displayDigit 
jmp restart


power:
mov ah,09h
mov dx, offset msg1
int 21h
mov cx,0
call getInput
push dx
mov ah,09h
mov dx, offset msg2
int 21h
mov cx,0
call getInput
pop bx
mov ax, 1       ; Initialize result to 1
mov cx, dx      ; Set loop counter to the exponent
power_loop:
imul bx  
loop power_loop  ; Decrement counter and repeat until it reaches zero
mov ah,09h
mov dx, offset msg3
int 21h
call displayDigit 

squareRoot:
mov ah,09h
mov dx, offset msg1
int 21h
mov cx,0
call getInput

MOV AX, dx
MOV CX, 0000
MOV BX, 65535 
sqr1: 
ADD BX, 02
INC CX
SUB AX, BX
JNZ sqr1

mov ah,09h
mov dx, offset msg3
int 21h
mov ax,cx
call displayDigit

restart:
mov dl, 13  ; Carriage return
mov ah, 02h   ; Function code for character output
int 21h       ; Print the carriage return
mov dl, 10  ; Line feed
mov ah, 02h   ; Function code for character output
int 21h       ; Print the line feed
mov ax,0
mov bx,0
mov dx,0
mov cx,0
jmp start


exit:
mov ah,4ch
int 21h




main endp
;other procs

              

displayDigit PROC ;gets num in ax and print its digits
push dx ;saving the values 
push cx 
push ax
mov bx,10
mov dx,0
mov cx,0
mov ah,0

store:
mov dx,0
div bx ; of div is stored in ax
push dx ; remainder of div is dx 
inc cx ; to count the digits in the number
cmp ax,0
jne store

print:
pop dx ;pops the first number cause its the highest one in the stack
add dx,30h ;convert digit to its ASCII equivalent
mov ah,02h
int 21h
loop print ;loop cx amount of times as it has cx amount of digit

pop ax
pop cx
pop dx ;loading back the values,this keeps the data in regs from destroying
ret
displayDigit endp   
               
   
               
getInput PROC ;at the end pushes the values inserted into a stack       
mov ah,00h
int 16h
mov dx,0  ; used for combining the numbers later in the combineNumbers PROC
mov bx,1   ; used for combining the numbers later in the combineNumbers PROC
cmp al,0dh ;the keypress will be stored in al so, we will comapre to  0d which represent the enter key, to know wheter he finished entering the number or not
je combineNumbers ;if it's the enter key then this mean we already have our number stored in the stack, so we will return it back using FormNo
sub ax,30h ;we will subtract 30 from the the value of ax to convert the value of key press from ascii to decimal which is a number so we can use calculation with
call displayDigit
mov ah,0 ;we will mov 0 to ah before we push ax to the stack bec we only need the value in al and since the value is uselss it wont effect
push ax  ;push the contents of ax to the stack
inc cx   ;we will add 1 to cx as this represent the counter for the number of digit
jmp getInput ;then we will jump back to input number to either take another number or press enter  
getInput endp
                 
                 
                 

combineNumbers PROC ; popes the stacks counter times in order to form them into an acc number
pop ax; Take the last input from the stack
push dx
mul bx;Here we are multiplying the value of ax with the value of bx
pop dx;After multiplication we will remove it from stack
add dx,ax;After removing from stack add the value of dx with the value of ax
mov ax,bx;Then set the value of bx in ax
mov bx,10
push dx;push the dx value again in stack before multiplying to resist any kind of accidental effect
mul bx;Multiply bx value by 10
pop dx;pop the dx after multiplying
mov bx,ax;Result of the multiplication is still stored in ax so we need to move it in bx
dec cx;After moving the value we will decrement the digit counter value
cmp cx,0;Check if the cx counter is 0
jne combineNumbers;If the cx counter is not 0 that means we have multiple digit input and we need to run format number function again
ret;If the cx counter is 0 that means all of our digits are fully formatted and stored in bx we just need to return the function
combineNumbers endp





end main








