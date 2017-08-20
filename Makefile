COFFEE=./node_modules/.bin/coffee
UGLIFY=./node_modules/.bin/uglify
BROWSERIFY=./node_modules/.bin/browserify
MOCHA=./node_modules/.bin/mocha
MOCHA_REPORTER?=spec
MOCHA_OPTS=--compilers coffee:coffee-script/register -R ${MOCHA_REPORTER} --bail
JS_FILES=$(shell ls src/*.coffee | sed -e 's/src/lib/' -e 's/coffee/js/')

all: $(JS_FILES) site/textures/tiles.png
	@echo '  ' DONE

clean:
	rm -rf site/site.js ${JS_FILES}

lib/%.js: src/%.coffee defines.h ${COFFEE}
	@echo -n ' +' $@
	@mkdir -p lib && sed -e 's/# .*$$//' $< | cpp -w | ${COFFEE} -sc > $@

site/textures/tiles.png: site/textures/tiles-tr2.png
	@echo -n $@ '> '
	@convert site/textures/tiles-tr2.png -transparent white site/textures/tiles.png

${COFFEE}:
	npm install coffeescript@next --no-save
	
${MOCHA}:
	npm install mocha --no-save

test: all ${MOCHA}
	@${MOCHA} ${MOCHA_OPTS}

.PHONY: image test ugly
