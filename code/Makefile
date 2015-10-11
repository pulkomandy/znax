# generic CPC-project makefile
# Copyright 2011 PulkoMandy - Shinra!

# TODO
# * I usually do incbin "something.exo" in my sourcecode, but this doesn't get 
#	in the makefile dependancies. Either add something equivalent to gcc -M in 
#	vasm, or find another way... (grep INCBIN + generate dependencies ?)

# USER SETTINGS ################################################################

# Enter your demo name here
NAME:=ZNAX

# Set disk contents
../$(NAME).dsk:: $(NAME).BIN LOADER.BIN

../$(NAME).cdt:: LOADER.BIN $(NAME).BIN

# List the sourcefiles for your main code. This is currently statically linked
# at &300 and (hopefully) loaded there by the loader code.
# TODO use a target variable for the address, and get it from VASM/VLINK somehow
$(NAME).BIN:: obj/MENU.o obj/howto.o obj/keyboard.o obj/GAME.o obj/exomizer.o \
	obj/SPRTEST.o obj/ArkosPlayer.o obj/hiscore.o obj/howto.o
$(NAME).BIN: START = 0x300

# List the dependancies for LOADER.BIN. Linked at &9000
LOADER.BIN: obj/loader.o obj/exomizer.o
LOADER.BIN: START = 0x9000

# define screenmode for each picture
IMG/ZNXGAME.scr: SCREENMODE = 0 44 64
IMG/ZNXINTRO.scr: SCREENMODE = 1
IMG/HISCORES.scr: SCREENMODE = 1

# This adds shrlogo.exo to the dependancies of loader.o. Assumes it will be
# INCBIN there...
obj/loader.o:: obj/ZNXINTRO.exo
obj/GAME.o: obj/ZNXGAME.exo
obj/MENU.o: res/ZNXHOWTO.bin
obj/hiscore.o: obj/HISCORES.exo obj/ZNXINTRO.exo
obj/SPRTEST.o: IMG/znax-spritesA.spr IMG/znax-spritesB.spr IMG/znax-spritesC.spr IMG/digits.spr \
    IMG/htptiles-1.spr IMG/htptiles-2.spr IMG/htptiles-3.spr IMG/htptiles-4.spr IMG/htptiles-5.spr \
    src/font16.z80

# TODO - move everything below to a generic cpc.mk file...
# GENERIC RULES ###############################################################

.DEFAULT_GOAL := ALL
ALL: ../$(NAME).dsk ../$(NAME).cdt

# Nice header for doing something
BECHO = @echo -ne "\x1B[46m\t$(1) \x1B[1m$(2)\n\x1B[0m"

# Build the DSK-File (main rule)
../%.dsk:
	$(call BECHO, "Putting files in $@...")
	cpcfs $@ f
	for i in $^;do cpcfs $@ p $$i;done;

# Build the CDT-File (main rule)
../%.cdt:
	$(call BECHO, "Putting files in $@...")
	j=-n;for i in $^;do 2cdt $$j -r $$i $$i $@;j="";done;

# Run the emulator
emu: ../$(NAME).dsk
	$(call BECHO,"Running emu...")
	cd "/Dev/8bit/cpc/ACE" && ./ACE DRIVEA=$(realpath $^) ROM7=ROMs/CPM07.ROM FASTDRIVES

# Link the sources ($^ means "all dependencies", so all of them should be .o 
# files - which is good, since anything else should be incbined somewhere)
%.BIN:
	$(call BECHO,"Linking $@")
	vlink -sd -sc -M -Ttext $(START) -Tlink.ld -b amsdos -o $@ $^ > $@.map

# Assemble the sources
obj/%.o: src/%.z80
	$(call BECHO,"Assembling $<...")
	mkdir -p obj
	vasmz80_oldstyle -Fvobj -o $@ $<

# Crunch a screen
obj/%.exo: IMG/%.scr
	$(call BECHO,"Crunching $<...")
	exoraw -o $@ $<

obj/%.exo: res/%.bin
	$(call BECHO,"Crunching $<...")
	exoraw -o $@ $<

# convert png to cpc screen format
# SCREENMODE can force the screenmode, otherwise it's guessed from the png 
# bitdepth
IMG/%.scr: res/%.png
	$(call BECHO,"Converting $<...")
	png2crtc $< $@ 7 $(SCREENMODE)

IMG/%.spr: res/%.png
	$(call BECHO,"Converting $<...")
	png2crtc $< $@ 0 0

clean:
	$(call BECHO,"Cleaning...")
	rm *.BIN *.BIN.map obj/*.{o,exo} IMG/*.{spr,scr}
