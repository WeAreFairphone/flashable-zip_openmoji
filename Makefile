# Makefile by Roberto M.F. (Roboe)
# https://github.com/WeAreFairphone/flashabe-zip_noto-emoji

SOURCE       := ./src/
SOURCEFILES  := $(shell find $(SOURCE) 2> /dev/null | sort)

NOTOEMOJI_VERSION := v2018-04-24-pistol-update
NOTOEMOJI_FONT    := ./assets/NotoColorEmoji_$(NOTOEMOJI_VERSION).ttf
NOTOEMOJI_URL     := https://github.com/googlei18n/noto-emoji/raw/$(NOTOEMOJI_VERSION)/fonts/NotoColorEmoji.ttf
NOTOEMOJI_DEST    := ./src/noto-color-emoji.ttf

FLASHABLEZIP := ./build/noto-color-emoji.zip
RELEASENAME  := "noto-color-emoji-$(NOTOEMOJI_VERSION)_%Y-%m-%d.zip"


.PHONY: all build clean release install
all: build

build: $(FLASHABLEZIP)
$(FLASHABLEZIP): $(SOURCEFILES) $(NOTOEMOJI_FONT)
	@echo "Building flashable ZIP..."
	@mkdir -pv `dirname $(FLASHABLEZIP)`
	@cp -f "$(NOTOEMOJI_FONT)" "$(NOTOEMOJI_DEST)"
	@rm -f "$(FLASHABLEZIP)"
	@cd "$(SOURCE)" && zip \
		"../$(FLASHABLEZIP)" . \
		--recurse-path \
		--exclude '*.asc' '*.xml'
	@echo "Result: $(FLASHABLEZIP)"

$(NOTOEMOJI_FONT):
	@echo "Downloading noto-emoji..."
	@mkdir -pv `dirname $(NOTOEMOJI_FONT)`
	@curl \
		-L "$(NOTOEMOJI_URL)" \
		-o "$(NOTOEMOJI_FONT)" \
		--connect-timeout 30

clean:
	@echo Removing built files...
	rm -f "$(NOTOEMOJI_DEST)"
	rm -f "$(FLASHABLEZIP)"
	@# only remove dir if it's empty:
	@rmdir -p `dirname $(FLASHABLEZIP)` 2>/dev/null || true

release: $(FLASHABLEZIP)
	@mkdir -pv release
	@cp -v "$(FLASHABLEZIP)" "release/$$(date +$(RELEASENAME))"

install: $(FLASHABLEZIP)
	@echo "Waiting for ADB sideload mode"
	@adb wait-for-sideload
	@adb sideload $(FLASHABLEZIP)
