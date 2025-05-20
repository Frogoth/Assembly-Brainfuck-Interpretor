global my_strlen

section .text

    my_strlen:
            xor rcx, rcx
        .strlen_loop:
            cmp byte [rsi + rcx], 0
            je .done
            inc rcx
            jmp .strlen_loop
        .done:
            ret