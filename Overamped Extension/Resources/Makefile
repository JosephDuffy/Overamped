.PHONY: extension popup

build: extension popup bundle

extension:
	cd extension; \
	npm install; \
	npm run build

popup:
	cd popup; \
	npm install; \
	npm run build

bundle:
	mkdir -p ./build/extension/build
	cp -R $(wildcard ./extension/build/*) ./build/extension/build

	mkdir -p ./build/popup/build
	cp -R $(wildcard ./popup/build/*) ./build/popup/build

	mkdir -p ./build/static
	cp -R $(wildcard ./static/*) ./build/static

	cp ./manifest.json ./build

	cp -R ./_locales ./build