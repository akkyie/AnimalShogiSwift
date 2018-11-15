.PHONY: build
build:
	swift build

.PHONY: test
test:
	swift test

.PHONY: project
project:
	swift package generate-xcodeproj --enable-code-coverage

.PHONY: clean
clean:
	swift package clean
	rm -rf *.xcodeproj

.PHONY: format
format:
	swiftformat .
