PREFIX?=/usr/local

TEMPORARY_FOLDER=./tmp_portable_test_summaries
OS := $(shell uname)

dependencies:
	brew install gd
	brew install exiftool

build: dependencies
	swift build --disable-sandbox -c release -Xswiftc -static-stdlib

test:
	swift test

lint:
	swiftlint

clean:
	swift package clean

xcode:
	swift package generate-xcodeproj

install: build
	mkdir -p "$(PREFIX)/bin"
	cp -f ".build/release/TestSummaries" "$(PREFIX)/bin/test-summaries"

portable_zip: build
	mkdir -p "$(TEMPORARY_FOLDER)"
	cp -f ".build/release/TestSummaries" "$(TEMPORARY_FOLDER)/test-summaries"
	cp -f "LICENSE" "$(TEMPORARY_FOLDER)"
	(cd $(TEMPORARY_FOLDER); zip -r - LICENSE test-summaries) > "./portable_testsummaries.zip"
	rm -r "$(TEMPORARY_FOLDER)"

