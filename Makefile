##
## EPITECH PROJECT, 2024
## Makefile
## File description:
## Define Makefile's rules used to build libraries, binaries and unit tests
## Author: @lszsrd
##

# Defines compiler's flags, linker's flags and pre-processor macros
CFLAGS					+=	-Wall -Wextra -Wpedantic -Wundef -Wpointer-arith \
							-Wfloat-equal -Wcast-align -Wstrict-prototypes	 \
					 		-Waggregate-return -Wwrite-strings -Winit-self 	 \
							-Wlogical-not-parentheses -Waddress	-Wshadow	 \
							-fpic -iquote include -g
LDFLAGS					+=	-Wl,-rpath libraries -L libraries 				 \
							-l list -l strtoarray
CPPGLAGS				+=

# `ftsh` binary part
BINARY_FTSH				:=	ftsh
BINARY_FTSH_SOURCES		:=	$(shell find sources -name '*.c')
BINARY_FTSH_OBJECTS		:=	$(BINARY_FTSH_SOURCES:.c=.o)

# `strtoarray` library part
LIB_STRTOARRAY			:=	libstrtoarray.so
LIB_STRTOARRAY_SOURCES	:=	$(shell find libraries/strtoarray -name '*.c')
LIB_STRTOARRAY_OBJECTS	:=	$(LIB_STRTOARRAY_SOURCES:.c=.o)

# `list` library part
LIB_LIST				:=	liblist.so
LIB_LIST_SOURCES		:=	$(shell find libraries/list -name '*.c')
LIB_LIST_OBJECTS		:=	$(LIB_LIST_SOURCES:.c=.o)

# `unit_tests` tests part
TESTS_BINARY			:=	unit_tests
TESTS_SOURCES			:=	$(filter-out sources/ftsh/main.c,				 \
							$(shell find sources -name '*.c')				 \
							$(shell find tests/criterion -name '*.c'))
TESTS_FLAGS				:=  --coverage -L /opt/homebrew/lib -l criterion

# Builds libraries and binaries
all: libraries/$(LIB_STRTOARRAY) libraries/$(LIB_LIST) $(BINARY_FTSH)

# Builds `strtoarray` shared library
libraries/$(LIB_STRTOARRAY): $(LIB_STRTOARRAY_OBJECTS)
	$(CC) -shared -o libraries/$(LIB_STRTOARRAY) $(LIB_STRTOARRAY_OBJECTS)
	@printf "\e[1;42mSuccessfully built libraries/%s\e[0m\n" $(LIB_STRTOARRAY)

# Builds `list` shared library
libraries/$(LIB_LIST): $(LIB_LIST_OBJECTS)
	$(CC) -shared -o libraries/$(LIB_LIST) $(LIB_LIST_OBJECTS)
	@printf "\e[1;42mSuccessfully built libraries/%s\e[0m\n" $(LIB_LIST)

# Builds `BINARY_NAME` binary
$(BINARY_FTSH): $(BINARY_FTSH_OBJECTS)
	$(CC) -o $(BINARY_FTSH) $(BINARY_FTSH_OBJECTS) $(LDFLAGS)
	@printf "\e[1;42mSuccessfully built %s\e[0m\n" $(BINARY_FTSH)

# Build and runs unit tests
tests_run: libraries/$(LIB_LIST) libraries/$(LIB_STRTOARRAY)
	$(CC) $(CFLAGS) -o unit_tests $(TESTS_SOURCES) $(LDFLAGS) $(TESTS_FLAGS)
	@printf "\e[1;42mSuccessfully built binary unit_tests\e[0m\n"
	timeout 2m ./unit_tests
	gcovr -e tests -e sources/debug -e sources/ftsh/clear_ast

# Generate a compilation database for clang tooling
compile_flags: fclean
	@echo "-iquote\ninclude" > compile_flags.txt

# Delete junk and temporary files
clean:
	find . -name "*~" -delete -o -name "#*#" -delete -o -name "*.out" -delete
	find . -name "*.gc*" -delete -o -name "*.dSYM" -exec rm -r {} +

# Delete builds' files, binaries and libraries
fclean: clean
	$(RM) libraries/$(LIB_STRTOARRAY) $(LIB_STRTOARRAY_OBJECTS)
	$(RM) libraries/$(LIB_LIST) $(LIB_LIST_OBJECTS)
	$(RM) $(BINARY_FTSH) $(BINARY_FTSH_OBJECTS)
	$(RM) unit_tests

# Re-build everything needed for this project
re: fclean all

.PHONY: all clean fclean re
