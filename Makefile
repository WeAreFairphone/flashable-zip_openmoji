# Makefile by Roberto M.F. (Roboe)
# https://github.com/WeAreFairphone/flashabe-zip_noto-emoji

SOURCE       := ./src/
SOURCEFILES  := $(shell find $(SOURCE) 2> /dev/null | sort)

NOTOEMOJI_VERSION := v2018-04-24-pistol-update
NOTOEMOJI_FONT    := ./assets/NotoColorEmoji_$(NOTOEMOJI_VERSION).ttf
NOTOEMOJI_URL     := https://github.com/googlei18n/noto-emoji/raw/$(NOTOEMOJI_VERSION)/fonts/NotoColorEmoji.ttf
NOTOEMOJI_DEST    := ./src/noto-color-emoji.ttf

FLASHABLEZIP := ./build/noto-color-emoji.zip
RELEASENAME  := $(shell date +"noto-color-emoji-$(NOTOEMOJI_VERSION)_%Y-%m-%d.zip")
RELEASEZIP   := release/$(RELEASENAME)
RELEASESUM   := $(RELEASEZIP).sha256sum


.PHONY: all build clean release install
all: build

build: $(FLASHABLEZIP)
$(FLASHABLEZIP): $(SOURCEFILES) $(NOTOEMOJI_FONT)
	@echo "Building flashable ZIP..."
	@mkdir -pv "$(@D)"
	@cp -f "$(NOTOEMOJI_FONT)" "$(NOTOEMOJI_DEST)"
	@rm -f "$@"
	@cd "$(SOURCE)" && zip \
		"../$@" . \
		--recurse-path \
		--exclude '*.asc' '*.xml'
	@echo "Result: $@"

$(NOTOEMOJI_FONT):
	@echo "Downloading noto-emoji..."
	@mkdir -pv "$(@D)"
	@curl \
		-L "$(NOTOEMOJI_URL)" \
		-o "$@" \
		--connect-timeout 30

clean:
	@echo Removing built files...
	rm -f "$(NOTOEMOJI_DEST)"
	rm -f "$(FLASHABLEZIP)"
	@# only remove dir if it's empty:
	@rmdir -p `dirname $(FLASHABLEZIP)` 2>/dev/null || true

release: $(RELEASEZIP) $(RELEASESUM)
$(RELEASEZIP): $(FLASHABLEZIP)
	@mkdir -pv "$(@D)"
	@echo -n "Release file: "
	@cp -v "$(FLASHABLEZIP)" "$@"
$(RELEASESUM): $(RELEASEZIP)
	@echo "Release checksum: $@"
	@cd "$(@D)" && sha256sum $(RELEASENAME) > $(@F)

install: $(FLASHABLEZIP)
	@echo "Waiting for ADB sideload mode"
	@adb wait-for-sideload
	@adb sideload $(FLASHABLEZIP)
