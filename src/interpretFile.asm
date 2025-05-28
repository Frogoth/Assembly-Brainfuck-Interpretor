section .bss
    extern filecontent
    extern bfarray
    extern filesize

%define SYS_WRITE_64

section .text
    global interpretFile

    extern exitUnknownSymbolError

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
        cmp byte [rsi + rcx], 0x2D ; check for character ]
        cmp byte [rsi + rcx], 0x0A ; check for character '\n'
        je continue

        push byte [rsi + rcx] ; push the unknown symbol to print later
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

    continue:
        ret

    interpretFile:
        mov rsi, [filecontent]
        mov rdi, [filesize]
        xor rcx, rcx ; rcx set to 0, will offset the filecontent pointer to iterate on the file content
        mov rdx, [bfarray] ; pointer to the beginning of the array
        xor r8, r8 ; iterates on the 30000 byte array

    fileLoop:
        cmp rdi, rcx
        jge done
        call checkCharacter
        inc rcx
        jmp fileLoop

    done:
        xor rax, rax
        ret
