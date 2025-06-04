section .bss
    extern filecontent
    extern bfarray
    extern filesize

%define SYS_READ_64 0
%define SYS_WRITE_64 1

%define STDIN 0
%define STDOUT 1

section .text
    global interpretFile

    extern exitUnknownSymbolError
    extern exitOutOfBoundPointer

    checkCharacter:
        xor rax, rax
        cmp byte [rsi + rcx], 0x3C ; check for character <
        je decrPointer
        cmp byte [rsi + rcx], 0x3E ; check for character >
        je incrPointer
        cmp byte [rsi + rcx], 0x2B ; check for character +
        je incrChar
        cmp byte [rsi + rcx], 0x2D ; check for character -
        je decrChar
        cmp byte [rsi + rcx], 0x2C ; check for character ,
        je getChar
        cmp byte [rsi + rcx], 0x2E ; check for character .
        je printChar
        cmp byte [rsi + rcx], 0x2B ; check for character [
        je beginLoop
        cmp byte [rsi + rcx], 0x2D ; check for character ]
        je endLoop
        cmp byte [rsi + rcx], 0x0A ; check for character '\n'
        je continue

        push word [rsi + rcx] ; push the unknown symbol to print later
        jmp exitUnknownSymbolError

    decrPointer:
        cmp r8, 0
        jle exitOutOfBoundPointer
        dec r8
        ret

    incrPointer:
        cmp r8, 29999
        jge exitOutOfBoundPointer
        inc r8
        ret

    incrChar:
        cmp r8,29999
        jg exitOutOfBoundPointer
        cmp r8, 0
        jl exitOutOfBoundPointer
        inc byte [rdx + r8]
        ret

    decrChar:
        cmp r8, 29999
        jg exitOutOfBoundPointer
        cmp r8, 0
        jl exitOutOfBoundPointer
        dec byte [rdx + r8]
        ret

    getChar:
        cmp r8, 29999
        jg exitOutOfBoundPointer
        cmp r8, 0
        jl exitOutOfBoundPointer

        push rsi ; store all registers needed by the interpretor before syscall
        push rdi
        push rdx
        push rcx
        push r9
        push r8

        lea rsi, [rdx + r8] ; put adress for rdx r8 is pointing to in rsi so read writes it inside directly
        mov rax, SYS_READ_64
        mov rdi, STDIN
        mov rdx, 1
        syscall

        pop r8
        pop r9
        pop rcx
        pop rdx
        pop rdi
        pop rsi

        ret


    printChar:
        cmp r8, 29999 ; check if r8 is pointing out of the buffer to avoid unpredicted behaviour
        jg exitOutOfBoundPointer
        cmp r8, 0
        jl exitOutOfBoundPointer

        push rsi ; store all registers needed by the interpretor before syscall
        push rdi
        push rcx
        push rdx
        push r8
        push r9

        mov rax, SYS_WRITE_64
        mov rdi, STDOUT
        lea rsi, [rdx + r8] ; put the adress of rdx + r8 to rsi, making it a buffer and not a simple character
        mov rdx, 1 ; prints only one thing
        syscall

        pop r9 ; restores all registers to their initial state before syscall
        pop r8
        pop rdx
        pop rcx
        pop rdi
        pop rsi
        ret

    beginLoop:
        mov r9, rcx
        ret

    endLoop:
        mov rcx, r9
        ret

    continue:
        ret ; returns to fileLoop to continue execution, rcx is still incremented but no action is done

    interpretFile:
        mov rsi, [filecontent]
        mov rdi, [filesize]
        xor rcx, rcx ; rcx set to 0, will offset the filecontent pointer to iterate on the file content
        mov rdx, [bfarray] ; pointer to the beginning of the array
        xor r8, r8 ; iterates on the 30000 byte array
        xor r9, r9 ; will be used to store loop adress

    fileLoop:
        cmp rdi, rcx ; check if character == \0
        jge done ; loops until \0
        call checkCharacter
        inc rcx ; increment character pointer
        jmp fileLoop

    done:
        xor rax, rax
        ret
