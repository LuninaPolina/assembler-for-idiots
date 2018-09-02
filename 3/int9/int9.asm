section .data
hex: db "0123456789ABCDEF" 
int9_segment dw 0
int9_offset dw 0
esc_flag db 0

section .text   
use16
  org  100h          

start: 
    mov ax,0			;save original int 9
    mov es,ax
    mov bx,[es:36]
    mov [int9_offset],bx
    mov bx,[es:38]
    mov [int9_segment],bx
    mov bx,int09h    		;replace original int9 
    mov [es:36],bx
    mov [es:38],cs

loop:
    cmp byte [esc_flag],01
    jne loop

exit:
    mov ax,0
    mov es,ax
    mov bx,[int9_offset]	;return original int9 
    mov [es:36],bx
    mov bx,[int9_segment]
    mov [es:38],bx
    int 20h

int09h:
    in al,60h   		;get scan from port
    mov [esc_flag],al
    cmp al,81h  		;print only key press
    jae nxt
    call print

nxt:
    mov al,20h  		;signal of interrupt end
    out 20h,al
    iret

 print:
    push ax            
    shr al,4
    call digit
    pop ax
    and al,0Fh
    call digit
    mov dl,' ' 
    mov ah,02h      
    int 21h 
              
digit:
    lea bx,[hex]
    xlat 
    mov dl,al
    mov ah,02h     
    int 21h
    ret