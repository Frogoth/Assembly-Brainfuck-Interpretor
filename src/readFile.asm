section .bss
    fd resq 1
    global filesize
    filesize: resq 1
    statbuff resb 144

%define SYS_READ_64 0
%define SYS_WRITE_64 1
%define SYS_OPEN_64 2
%define SYS_CLOSE_64 3
%define SYS_FSTAT_64 5

%define STDIN 0
%define STDOUT 1
%define STDERR 2

; allocation values
%define SYS_MMAP     9
%define PROT_READ    1
%define PROT_WRITE   2
%define MAP_PRIVATE  2
%define MAP_ANONYMOUS 0x20


section .text
    global openFile
    global statFile
    global allocateBuffer
    global readFile
    global closeFile
    global printFile
    global checkFileValidity

    extern exitInputError
    extern exitInvalidFileError
    extern exitFileEmptyError
    extern exitInvalidReadError
    extern exitAllocateError
    extern filecontent
    extern exitClosingMissingLoopError
    extern exitUnclosedLoopError

    openFile: ; modifies rsi and rdx, puts fd in rax as return value
        mov rax, SYS_OPEN_64 ; syscall to open file, filename is loaded in rdi with pop rdi
        xor rsi, rsi ; flags to open
        mov rdx, 0644o ; mode of open
        syscall ; open puts fd in rax

        cmp rax, 0 ; compares rax to 0
        jl exitInvalidFileError ; if rax is lower than 0, the program exits with according error message
        mov [fd], rax
        xor rax, rax
        ret

    statFile:
        mov rdi, [fd] ; put fd in rdi
        mov rax, SYS_FSTAT_64
        mov rsi, statbuff ; set rsi to pointer to struct so it fills it
        syscall

        test rax, rax
        jnz exitInputError ; check return value, should be 0

        ; structs are pointers to multiple data in series, offset by 8 bits, to access the size of the file
        mov rax, [statbuff + 48] ; put file size in rax
        mov [filesize], rax ; put size from rax to filesize because we can't move memory to memory
        cmp qword [filesize], 0 ; check file size, should be higher than 0
        jle exitFileEmptyError
        ret

    allocateBuffer:
        mov rdi, 0 ; let kernel choose where to allocate memory
        mov rsi, [filesize]
        mov rdx, PROT_READ | PROT_WRITE
        mov r10, MAP_PRIVATE | MAP_ANONYMOUS
        mov r8, -1
        mov r9, 0
        mov rax, SYS_MMAP
        syscall

        cmp rax, -4095 ; stores pointer to buffer in rax, or -1 on error
        jae exitAllocateError
        mov [filecontent], rax ; store pointer to filecontent
        xor rax, rax
        ret

    readFile:
        mov rax, SYS_READ_64
        mov rdi, [fd]
        mov rsi, [filecontent] ; sets rsi to filecontent pointer to fill filecontent
        mov rdx, [filesize]
        syscall ; fd is already stored in rdi and the file size is stored in rdx

        test rax, rax
        js exitInvalidReadError
        xor rax, rax
        ret

    closeFile:
        mov rax, SYS_CLOSE_64
        mov rdi, [fd]
        syscall
        ret

    printFile:
        mov rax, SYS_WRITE_64
        mov rdi, STDOUT
        mov rsi, [filecontent]
        mov rdx, [filesize]
        syscall
        ret

    checkFileValidity:
        mov rsi, [filecontent] ; original pointer to the buffer
        mov rdi, [filesize]
        xor rcx, rcx ; used to iterate over the file buffer
        xor rdx, rdx ; rdx will be the loop flag, if the file ends and rdx == 1, a loop isn't closed, if a loop ends but the flag == 0, we cannot close an unexisting loop

    fileLoop:
        cmp rdi, rcx
        jge done
        jmp checkLoop

    done:
        cmp rdx, 0
        jnz exitUnclosedLoopError
        xor rax, rax
        ret

    checkLoop:
        cmp byte [rsi + rcx], 0x5B ; compare current character with [
        je checkStartOfLoop
        cmp byte [rsi + rcx], 0x5D ; compare current character with ]
        je checkEndOfLoop
        jmp fileLoop

    checkStartOfLoop:
        inc rdx
        jmp fileLoop

    checkEndOfLoop:
        cmp rdx, 0 ; check if loop began, if rdx == 0, the loop didn't begin
        jz exitClosingMissingLoopError
        dec rdx
        jmp fileLoop