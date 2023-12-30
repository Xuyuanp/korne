# .DELETE_ON_ERROR:
.SECONDARY:
.PHONY: clean all setup
.DEFAULT: all

container_cmd ?= docker
container_args ?= -w /board -v $(shell pwd):/board --rm

setup:
	npm install


gen: config.yaml
	npm run gen

output/pcbs/board.kicad_pcb: config.yaml

output/cases/%.jscad: gen

cases/%.stl: output/cases/%.jscad
	if [ -f "$@" ] ; then rm $@ ; fi
	npx @jscad/cli@1 $< -of stla -o $@

cases/%-mirrord.stl: cases/%.stl
	admesh --yz-mirror --write-ascii-stl=$@ $<

clean:
	rm -rf output

cases: \
	cases/top.stl \
	cases/top-mirrord.stl \
	cases/bottom.stl \
	cases/bottom-mirrord.stl

pcbs: \
	output/pcbs/board.kicad_pcb

all: \
	pcbs \
	cases
