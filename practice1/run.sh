nasm -f elf "$1".asm && gcc "$1".o -m32 -o "$1.exe" && ./"$1.exe"

#gcc -m32 -o test -s ./runtime/runtime.o