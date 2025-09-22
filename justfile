setup:
	mkdir -p build && cd build && meson setup ../

build:
	cd build && meson compile

perf-chart:
	: > y.csv
	cp ./chart.sh ./chart1.sh
	nasm -g -f elf64 -o v.o v.asm
	git rebase --autostash --exec ./chart1.sh --exec 'tail -1 x.csv >> y.csv' 4e131bf
	./chart.R
	xdg-open benchmark_plot.png
