section .data
hex db "0123456789ABCDEF"
ln db ' ',13,10,'$'
hdr db "DeviceID  VendorID",13,10,'$'
sft db "      ",'$'

section .text   
use16
  org  100h

start:
	call header
 	mov dx,0CF8h		;store config_addr
	mov ecx,80000000h	;1st device

loop:	
	call get_data
	add ecx,0800h		;device_num++
	test ecx,01000000h	;check no more devices (bit24=1)
	jz loop
	ret

get_data:
	mov eax,ecx		;0000 in register num field
	out dx,eax		;send eax at adress of config_adress
	add dx,4		;goto config_data
	in eax,dx		;read data to eax
	sub dx,4		;back to config adress			
	cmp ax,-1		;check no device here	
	je exit
	call print 

exit:
	ret

print:				;eax = deviceID vendorID (32 bits)
	push eax
	shr eax,16
	call printID		;deviceID
	call spaces
	pop eax
	and eax,0FFFFh
	call printID		;vendorID
	call line
	ret

printID: 	
	push ax
	shr ax,12
	call digit 
	pop ax
	push ax
	shr ax,8
	and ax,0Fh
	call digit
	pop ax
	push ax
	shr ax,4
	and ax,0Fh
	call digit
	pop ax
	push ax
	and ax,0Fh
	call digit
	pop ax
	ret

digit:
	pusha
    	lea bx,[hex] 
    	xlat 
    	mov dl,al
    	mov ah,02h     
    	int 21h
    	popa
    	ret

spaces:
	pusha
    	lea dx,[sft]
    	mov ah,09h      
    	int 21h
    	popa
   	ret

line:
	pusha
    	lea dx,[ln]
    	mov ah,09h      
    	int 21h
    	popa
    	ret

header:
	pusha
    	lea dx,[hdr]
    	mov ah,09h      
    	int 21h
    	popa
    	ret