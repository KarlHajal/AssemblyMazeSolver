# MPLAB IDE generated this makefile for use with GNU make.
# Project: sevensegment.mcp
# Date: Sat Apr 22 22:21:04 2017

AS = MPASMWIN.exe
CC = 
LD = mplink.exe
AR = mplib.exe
RM = rm

program.cof : program.o
	$(CC) /p16F84A "program.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"program.cof" /M"program.map" /W /x

program.o : program.asm D:/lrakl/Software/Microchip/MPASM\ Suite/p16f84A.inc
	$(AS) /q /p16F84A "program.asm" /l"program.lst" /e"program.err" /d__DEBUG=1

clean : 
	$(CC) "program.o" "program.hex" "program.err" "program.lst" "program.cof"

