section .bss
    filecontent resb 4096
    fd resq 1
    filesize resq 1
    statbuff resb 144

%define SYS_READ_64 0
%define SYS_WRITE_64 1
%define SYS_OPEN_64 2
%define SYS_CLOSE_64 3
%define SYS_FSTAT_64 5

%define STDIN 0
%define STDOUT 1
%define STDERR 2

section .text
    global openFile
    global statFile
    global readFile
    global closeFile
    global printFile

    extern exitInputError
    extern exitInvalidFileError
    extern exitFileEmptyError
    extern exitInvalidReadError

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

    readFile:
        mov rax, SYS_READ_64
        mov rdi, [fd]
        mov rsi, filecontent ; sets rsi to filecontent pointer to fill filecontent
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
        mov rsi, filecontent
        mov rdx, [filesize]
        syscall
        ret