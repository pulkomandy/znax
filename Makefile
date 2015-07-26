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
$(NAME).dsk:: $(NAME).BIN LOADER.BIN

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
ZNXGAME.scr: SCREENMODE = 0 44 64
ZNXINTRO.scr: SCREENMODE = 1
HISCORES.scr: SCREENMODE = 1

# This adds shrlogo.exo to the dependancies of loader.o. Assumes it will be
# INCBIN there...
obj/loader.o:: ZNXINTRO.exo
obj/GAME.o: ZNXGAME.exo
obj/hiscore.o: HISCORES.exo LOADER.exo

# TODO - move everything below to a generic cpc.mk file...
# GENERIC RULES ###############################################################

.DEFAULT_GOAL := $(NAME).dsk

# Nice header for doing something
BECHO = @echo -ne "\x1B[46m\t$(1) \x1B[1m$(2)\n\x1B[0m"

# Build the DSK-File (main rule)
%.dsk:
	$(call BECHO, "Putting files in DSK...")
	cpcfs $@ f
	#pydsk.py -d $@ -s 304 ZNXINTRO.exo
	for i in $^;do cpcfs $@ p $$i;done;

# Run the emulator
emu: $(NAME).dsk
	$(call BECHO,"Running emu...")
	cd "/Bigdisk/8bit/cpc/!TOOLS/ACE_MOS/ACE" && ./ACE DRIVEA=$(realpath $^) ROM7=ROMs/CPM05.ROM

# Link the sources ($^ means "all dependencies", so all of them should be .o 
# files - which is good, since anything else should be incbined somewhere)
%.BIN:
	$(call BECHO,"Linking $@")
	vlink -sd -sc -M -Ttext $(START) -Tlink.ld -b amsdos -o $@ $^ > $@.map
	
#-Ttext $(START)

# Assemble the sources
obj/%.o: src/%.z80
	$(call BECHO,"Assembling $<...")
	mkdir -p obj
	vasmz80_oldstyle -Fvobj -o $@ $<

# Crunch a screen
%.exo: %.scr
	$(call BECHO,"Crunching $<...")
	exoraw -o $@ $<

%.exo: %.BIN
	$(call BECHO,"Crunching $<...")
	exoraw -o $@ $<

# convert png to cpc screen format
# SCREENMODE can force the screenmode, otherwise it's guessed from the png 
# bitdepth
%.scr: res/%.png
	$(call BECHO,"Converting $<...")
	png2crtc $< $@ 7 $(SCREENMODE)

clean:
	$(call BECHO,"Cleaning...")
	rm *.exo *.BIN *.BIN.map .dsk obj/*.o
