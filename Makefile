COFFEE=./node_modules/.bin/coffee
JS_FILES=$(shell ls src/*.coffee | sed -e 's/src/bin/' -e 's/coffee/js/')

all: site $(JS_FILES)

bin/%.js: src/%.coffee
	coffee -o bin -c $<

site: site/site.ugly.js

%.ugly.js: %.js
	mkdir -p $(shell dirname $@)
	uglify -s $< -o $@

site/site.js:
	mkdir -p site
	browserify bin/map.js > site/site.js

test:
	${COFFEE} world.coffee
