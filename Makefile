COFFEE=./node_modules/.bin/coffee
UGLIFY=./node_modules/.bin/uglify
BROWSERIFY=./node_modules/.bin/browserify
JS_FILES=$(shell ls src/*.coffee | sed -e 's/src/bin/' -e 's/coffee/js/')

all: site $(JS_FILES) image

bin/%.js: src/%.coffee defines.h
	mkdir -p bin && sed -e 's/# .*$$//' $< | cpp -w | coffee -sc > $@

site: site/site.ugly.js site/

%.ugly.js: %.js
	mkdir -p $(shell dirname $@) && (${UGLIFY} -s $< -o $@ > /dev/null)

site/site.js: ${JS_FILES}
	mkdir -p $(shell dirname $@) && ${BROWSERIFY} bin/map.js bin/pixel-art-tool.js -i fs > site/site.js

image:
	convert site/textures/tiles-tr2.png -transparent white site/textures/tiles-tr2.png

test: all
	(cd bin && node world.js)

.PHONY: image test
