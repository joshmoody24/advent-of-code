GBDK_URL     = https://github.com/gbdk-2020/gbdk-2020/releases/download/4.4.0/gbdk-linux64.tar.gz
GBDK_ARCHIVE = gbdk-linux64.tar.gz
GBDK_DIR     = gbdk

all: solution.gb

solution.gb: $(GBDK_DIR) solution.c input.h
	GBDK_HOME=$(CURDIR)/$(GBDK_DIR) $(GBDK_DIR)/bin/lcc -Wa-l -Wl-m -Wl-j -o solution.gb solution.c

$(GBDK_DIR):
	wget -O $(GBDK_ARCHIVE) $(GBDK_URL)
	tar -xzf $(GBDK_ARCHIVE)
	rm -f $(GBDK_ARCHIVE)

input.h: input.txt
	printf 'char *input_data = "' > input.h
	tr -d '\n' < input.txt >> input.h
	printf '";\n' >> input.h

.PHONY: clean
clean:
	rm -f solution.gb
	rm -f input.h
	rm -rf $(GBDK_DIR)

