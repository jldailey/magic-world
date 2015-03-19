COFFEE=./node_modules/.bin/coffee
UGLIFY=./node_modules/.bin/uglify
BROWSERIFY=./node_modules/.bin/browserify
MOCHA=./node_modules/.bin/mocha
MOCHA_OPTS=--compilers coffee:coffee-script/register -R spec --bail
JS_FILES=$(shell ls src/*.coffee | sed -e 's/src/bin/' -e 's/coffee/js/')

all: site $(JS_FILES) image

bin/%.js: src/%.coffee defines.h
	@echo -n $@ '> '
	@mkdir -p bin && sed -e 's/# .*$$//' $< | cpp -w | coffee -sc > $@

site: site/site.js site/textures/tiles.png

ugly: site/site.ugly.js

%.ugly.js: %.js
	@echo -n $@...
	@mkdir -p $(shell dirname $@) && (${UGLIFY} -s $< -o $@ > /dev/null)
	@echo ' OK'

site/site.js: ${JS_FILES}
	@echo -n $@ '> '
	@mkdir -p $(shell dirname $@) && ${BROWSERIFY} bin/map.js -i fs | grep -v sourceMappingURL > site/site.js

site/textures/tiles.png: site/textures/tiles-tr2.png
	@echo -n $@ '> '
	@convert site/textures/tiles-tr2.png -transparent white site/textures/tiles.png

${MOCHA}:
	npm install mocha

test: all ${MOCHA}
	@${MOCHA} ${MOCHA_OPTS}

.PHONY: image test ugly
