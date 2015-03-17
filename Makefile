NPM_PACKAGE := $(shell node -e 'process.stdout.write(require("./package.json").name)')
NPM_VERSION := $(shell node -e 'process.stdout.write(require("./package.json").version)')

TMP_PATH    := /tmp/${NPM_PACKAGE}-$(shell date +%s)

REMOTE_NAME ?= origin
REMOTE_REPO ?= $(shell git config --get remote.${REMOTE_NAME}.url)

CURR_HEAD   := $(firstword $(shell git show-ref --hash HEAD | cut -b -6) master)
GITHUB_PROJ := https://github.com//mcecot/${NPM_PACKAGE}


lint:
	./node_modules/.bin/eslint --reset .

test: lint
	./node_modules/.bin/mocha -R spec

coverage:
	rm -rf coverage
	./node_modules/.bin/istanbul cover node_modules/.bin/_mocha

test-ci: lint
	istanbul cover ./node_modules/mocha/bin/_mocha --report lcovonly -- -R spec && cat ./coverage/lcov.info | ./node_modules/coveralls/bin/coveralls.js && rm -rf ./coverage

# test:
# 	$(MAKE) lint
# 	@NODE_ENV=test ./node_modules/.bin/mocha -b --reporter $(REPORTER)

clean:
	rm -rf dist
	mkdir dist

compile: clean
	coffee -c -b -o ./dist/ ./index.coffee

browserify: lint
	# Browserify
	./node_modules/.bin/browserify . \
		-s markdownitCheckbox \
		> dist/markdown-it-checkbox.js
	# Minify
	./node_modules/.bin/uglifyjs dist/markdown-it-checkbox.js \
		-b beautify=false,ascii-only=true -c -m -v \
		--preamble "/*! ${NPM_PACKAGE} ${NPM_VERSION} ${GITHUB_PROJ} @license MIT */" \
	 	> dist/markdown-it-checkbox.min.js

.PHONY: lint test coverage
.SILENT: lint test
