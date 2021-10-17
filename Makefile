# Makefile by Roberto M.F. (Roboe)
# https://github.com/WeAreFairphone/flashabe-zip_openmoji

SOURCE       := ./src/
SOURCEFILES  := $(shell find $(SOURCE) 2> /dev/null | sort)

OPENMOJI_VERSION := 13.1.0
OPENMOJI_FONT    := ./assets/OpenMoji-Color_$(OPENMOJI_VERSION).ttf
OPENMOJI_URL     := https://github.com/hfg-gmuend/openmoji/raw/$(OPENMOJI_VERSION)/font/OpenMoji-Color.ttf
OPENMOJI_DEST    := ./src/openmoji-color.ttf

FLASHABLEZIP := ./build/openmoji-color.zip
RELEASENAME  := $(shell date +"openmoji-color-$(OPENMOJI_VERSION)_%Y-%m-%d.zip")
RELEASEZIP   := release/$(RELEASENAME)
RELEASESUM   := $(RELEASEZIP).sha256sum


.PHONY: all build clean release install
all: build

build: $(FLASHABLEZIP)
$(FLASHABLEZIP): $(SOURCEFILES) $(OPENMOJI_FONT)
	@echo "Building flashable ZIP..."
	@mkdir -pv "$(@D)"
	@cp -f "$(OPENMOJI_FONT)" "$(OPENMOJI_DEST)"
	@rm -f "$@"
	@cd "$(SOURCE)" && zip \
		"../$@" . \
		--recurse-path \
		--exclude '*.asc' '*.xml'
	@echo "Result: $@"

$(OPENMOJI_FONT):
	@echo "Downloading openmoji..."
	@mkdir -pv "$(@D)"
	@curl \
		-L "$(OPENMOJI_URL)" \
		-o "$@" \
		--connect-timeout 30

clean:
	@echo Removing built files...
	rm -f "$(OPENMOJI_DEST)"
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
