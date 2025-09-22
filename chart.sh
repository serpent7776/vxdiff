#!/bin/sh
set -e

# nasm -g -f elf64 -o v.o v.asm
nasm -g -f elf64 -o d.o vxdiff.asm
ld -o vx v.o d.o
hyperfine -N -i --export-csv x.csv --command-name "$(git rev-parse HEAD)" ./vx
