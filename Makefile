##
##
## bfinterpretor Makefile
##
##

SRC		=	src/bfinterpretor.asm \
			src/my_strlen.asm \
			src/my_atoi.asm \
			src/exitErrors.asm \
			src/readFile.asm

OBJS	=	$(SRC:.asm=.o)

EXEC	=	bfinterpretor

all: $(EXEC)

$(EXEC): $(OBJS)
	ld -o $(EXEC) $(OBJS)

%.o: %.asm
	nasm -f elf64 $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(EXEC)

re: fclean all

.PHONY: all clean fclean re