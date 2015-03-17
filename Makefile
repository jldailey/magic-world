COFFEE=./node_modules/.bin/coffee
JS_FILES=$(shell ls src/*.coffee | sed -e 's/src/bin/' -e 's/coffee/js/')

all: site $(JS_FILES)

bin/%.js: src/%.coffee
	mkdir -p bin && sed -e 's/# .*$$//' $< | cpp -w | coffee -sc > $@

site: site/site.ugly.js site/

%.ugly.js: %.js
	mkdir -p $(shell dirname $@) && uglify -s $< -o $@ &> /dev/null

site/site.js: ${JS_FILES}
	mkdir -p $(shell dirname $@) && browserify bin/map.js bin/pixel-art-tool.js -i fs -i buffer > site/site.js

test: all
	(cd bin && node world.js)
