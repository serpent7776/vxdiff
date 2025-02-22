setup:
	mkdir -p build && cd build && meson setup ../

build:
	cd build && meson compile
