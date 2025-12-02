TARGET = aoc-2025-day2-pt1

SOURCES = main.asm

OBJECTS = $(SOURCES:.asm=.o)

all: $(TARGET).gb

%.o: %.asm
	rgbasm -o $@ $<

$(TARGET).gb: $(OBJECTS)
	rgblink -o $@ $(OBJECTS)
	rgbfix -v -p 0xFF $@

clean:
	rm -f $(OBJECTS) $(TARGET).gb

run: $(TARGET).gb
	sameboy $(TARGET).gb

.PHONY: all clean
