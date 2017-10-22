.model small ; #5 Invert strings in the file
.stack 100h  
.data  
     
    param_error_msg db 'Command line error!', 0dh, 0ah, '$'
    open_error_msg db 'Cannot open file!', 0dh, 0ah, '$'
    all_done_msg db 'File have been inverted!',0dh,0ah,'$' 
    commandLine db 30 dup('$')  
    openFileMsg db 'Name of the opened file:',0dh,0ah,'$'
    buffer db 200 dup('$');buffer for our strings
    bufferFile db 'buffer.txt',0h
    ident1 dw ?;identificator for our file
    ident2 dw ?;identificator for buffer
    
    temp db dup 10(?)
    temp_pointer_high dw ?
    temp_pointer_low dw ?
    
.code
start:           
    mov si, 80h  
    xor cx, cx
    mov cl, es:[si]  
    cmp cx, 0;check command line for arguments
    je param_error
    inc si
    inc si
    
    mov ax, @data
    mov ds, ax  
    mov di,offset commandLine 
    
next_symbol: ;copy symbols from the command line
    mov cl,byte ptr es:[si]
    cmp cl,0D
    je open_file    
    mov al,byte ptr es:[si]
    mov byte ptr ds:[di],al
    inc si
    inc di  
    jmp next_symbol 
     
 open_file:  
     
    lea dx, openFileMsg    
    mov ah, 09h
    int 21h
    
    lea dx, commandLine
    mov ah, 09h 
    int 21h  
    
    dec di
    mov byte ptr ds:[di],0
    
    mov ax, 3d00h ;open file for reading
    lea dx, commandLine
    int 21h
    jc open_error 
    
    mov ident1,ax;save identificator in variable
    
    mov ax, 3d02h ;open buffer file for writing
    lea dx, bufferFile
    int 21h
    jc open_error  
    
    mov ident2,ax;save identificator in variable
     
    mov ax,@data
    mov ds,ax
    xor di,di 
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;go to the end of file
    mov bx,ident1 
    xor cx,cx
    xor dx,dx
    mov ax,4202h
    int 21h
    
    mov ax,@data
    mov ds,ax
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;go 1 letter back
    mov bx,ident1
    xor cx,cx
    mov dx,-1
    mov ax,4201h
    int 21h
     
    mov ax,@data
    mov ds,ax
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;read 1 letter to the temp
    mov bx,ident1 
    mov cx,1 
    lea dx,temp
    mov ax,3f00h
    int 21h
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;go 2 letters back
    mov bx,ident1
    xor cx,cx
    mov dx,-2
    mov ax,4201h
    int 21h 
    
    jmp find_sentence 
     
    
    pre_find_sentence:
    ;;;;;;;;;;;;;;;;set previous position in the file
    mov ax,4200h
    mov bx,ident1
    mov cx,temp_pointer_high
    mov dx,temp_pointer_low
    int 21h
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;go 1 letter back
    mov bx,ident1
    xor cx,cx
    mov dx,-1
    mov ax,4201h
    int 21h 
     
     
    find_sentence:
    mov ax,@data
    mov ds,ax
     
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;get current position in file
    mov ax,4201h
    mov bx,ident1
    xor cx,cx
    xor dx,dx
    int 21h
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;compare current position with the beginning 
    cmp ax,0
    jne do_next
    cmp dx,0
    je read_last_string;we are in the beginning, so we should read 1 last string
    
    do_next:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;save position in the file
    mov temp_pointer_high,dx
    mov temp_pointer_low,ax 
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;read 1 letter 
    mov bx,ident1 
    mov cx,1 
    lea dx,temp
    mov ax,3f00h
    int 21h
    
    cmp temp,'.'
    je sentence_found;;;;;;;;;;;;;;if we found the beginning of the sentence
    
    
    mov ax,@data
    mov ds,ax
    
    mov bx,ident1 ;go 2 letters back
    xor cx,cx
    mov dx,-2
    mov ax,4201h
    int 21h
    
    jmp find_sentence 
    
    
    sentence_found:
    mov ax,@data
    mov ds,ax
    
    mov bx,ident1 ;read 1 letter
    mov cx,1
    lea dx,temp
    mov ax,3f00h
    int 21h
    
    mov ax,@data
    mov ds,ax
    
    mov bx,ident2 ;write 1 letter to the buffer file
    mov cx,1
    lea dx,temp
    mov ax,4000h
    int 21h
    
    cmp temp,'.'
    jne sentence_found
    jmp pre_find_sentence
     
   read_last_string: 
    mov ax,@data
    mov ds,ax
    
    mov bx,ident1 ;read 1 letter
    mov cx,1
    lea dx,temp
    mov ax,3f00h
    int 21h
    
    mov ax,@data
    mov ds,ax
    
    mov bx,ident2 ;write 1 letter to the buffer file
    mov cx,1
    lea dx,temp
    mov ax,4000h
    int 21h
    
    cmp temp,'.'
    jne read_last_string
    ;;;;;;;;;;;;;;;;we have write all strings to the buffer file
    mov bx,ident1
    xor cx,cx
    mov dx,0
    mov ax,4202h
    int 21h
    ;;;;;;;;;;;;;;;;save file length
    mov temp_pointer_high,dx
    mov temp_pointer_low,ax
   
    ;;;;;;;;;;;;;;;;close files
    mov ah,3eh
    mov bx,ident2
    int 21h
    
    mov ah,3eh
    mov bx,ident1
    int 21h
    
    ;;;;;;;;;;;;;;;;open files in different mode
    mov ax, 3d00h ;open buffer file for reading
    lea dx, bufferFile
    int 21h
    jc open_error 
    
    mov ident2,ax;save identificator in variable
    
    mov ax, 3d02h ;open main file for writing
    lea dx, commandLine
    int 21h
    jc open_error  
    
    mov ident1,ax;save identificator in variable
    
    
    mov bx,ident2
    xor cx,cx
    mov dx,0
    mov ax,4200h
    int 21h
    
    mov bx,ident1
    xor cx,cx
    mov dx,0
    mov ax,4200h
    int 21h
     
    writecycle:
    mov bx,ident2 ;read 1 letter
    mov cx,1
    lea dx,temp
    mov ax,3f00h
    int 21h
    
    mov bx,ident1 ;write 1 letter to the main file
    mov cx,1
    lea dx,temp
    mov ax,4000h
    int 21h 
    
    ;;;;;;;;;;;;;get position
    mov bx,ident2
    xor cx,cx
    mov dx,0
    mov ax,4201h
    int 21h
    
    cmp ax,temp_pointer_low
    jne writecycle
    cmp dx,temp_pointer_high
    jne writecycle:
     
    
close_file:
    mov ah,3eh
    mov bx,ident2
    int 21h
    
    mov ah,3eh
    mov bx,ident1
    int 21h
    
    lea dx, all_done_msg    
    mov ah, 09h
    int 21h
    
    jmp exit
    
    

open_error:
    lea dx, open_error_msg    
    mov ah, 09h
    int 21h
    jmp exit 

param_error:
    mov ax, @data
    mov ds, ax 
    lea dx, param_error_msg    
    mov ah, 09h
    int 21h    
    
exit:
    mov ax, 4c00h
    int 21h
    
end start 