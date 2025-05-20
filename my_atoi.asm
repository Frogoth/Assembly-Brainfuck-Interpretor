global my_atoi

section .text

my_atoi:
    xor rax, rax

convert:
    movzx rsi, byte [rdi] ; gets first character
    test rsi, rsi ; checks if first character == 0, ie.'\n'
    je done

    cmp rsi, 48
    jl error ; checks if character under range of numbers in ascii

    cmp rsi, 57
    jg error ; checks if character is above range of numbers in ascii

    sub rsi, 48 ; Convert from ASCII to decimal
    imul rax, 10 ; multiply by ten
    add rax, rsi ; add current digit to total

    inc rdi
    jmp convert

error:
    mov rax, -1

done:
    ret