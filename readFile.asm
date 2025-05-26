section .bss
    extern filecontent
    extern statbuff

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

    openFile:
        mov rax, SYS_OPEN_64 ; syscall to open file, filename is loaded in rdi with pop rdi
        mov rsi, 0 ; flags to open
        mov rdx, 0644o ; mode of open
        syscall ; open puts fd in rax

        cmp rax, 0 ; compares rax to 0
        jl exitInvalidFileError ; if rax is lower than 0, the program exits with according error message
        ret

    statFile:
        mov rdi, rax ; put fd in rdi
        push rdi
        mov rax, SYS_FSTAT_64
        mov rsi, statbuff ; set rsi to pointer to struct so it fills it
        syscall

        test rax, rax
        jnz exitInputError ; check return value, should be 0

        ; structs are pointers to multiple data in series, spaced by 8 bits, to access the size of the file
        mov rdx, [statbuff + 48] ; put file size in rdx
        cmp rdx, 0 ; check file size, should be higher than 0
        jle exitFileEmptyError
        pop rdi ; restores fd in rdi
        ret

    readFile:
        push rdi
        push rdx
        mov rax, SYS_READ_64
        mov rsi, filecontent ; sets rsi to filecontent pointer to fill filecontent
        syscall ; fd is already stored in rdi and the file size is stored in rdx
        pop rdx
        pop rdi
        ret

    closeFile:
        push rdx
        mov rax, SYS_CLOSE_64
        syscall
        pop rdx
        ret

    printFile:
        mov rax, SYS_WRITE_64
        mov rdi, STDOUT
        mov rsi, filecontent
        syscall
        ret