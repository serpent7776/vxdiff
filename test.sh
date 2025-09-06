#!/bin/sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ok() {
	a=$(readlink -f "$SCRIPT_DIR/$1")
	b=$(readlink -f "$SCRIPT_DIR/$2")
	o=$(./odiff "$a" "$b" | head -1 | cut -f2-4 -d' ')
	v=$(./vxdiff "$a" "$b" | head -1 | cut -f4 -d' ')
	[ "$o" = "Images are equal." ] && [ "$v" -eq 0 ] || (echo "FAIL $a $b: $o $v")
}

fails() {
	a=$(readlink -f "$SCRIPT_DIR/$1")
	b=$(readlink -f "$SCRIPT_DIR/$2")
	o=$(./odiff "$a" "$b" | tail -1 | cut -d' ' -f3 | sed -E 's/\x1B\[[0-9;]*[mGKH]//g')
	v=$(./vxdiff "$a" "$b" | tail -1 | cut -d' ' -f4)
	[ "$o" = "$v" ] || (echo "FAIL $a $b: $o $v")
}

ok test-images/extreme-alpha.png test-images/extreme-alpha-1.png
ok test-images/purple4x4.png test-images/purple8x8.png

fails test-images/white4x4.png test-images/purple8x8.png
fails test-images/orangefullalpha.png test-images/orangefullalpha2.png
fails test-images/orange.png test-images/orange_changed.png
fails test-images/orange.png test-images/orange_diff.png
fails test-images/orange.png test-images/orange_diff_green.png
fails test-images/orange.png test-images/orange2.png
fails test-images/funocaml.png test-images/funocaml2.png
fails test-images/foo.png test-images/foo2.png
