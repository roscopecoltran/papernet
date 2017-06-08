
## #################################################################
## NODEJS - HELPERS
## #################################################################

# This task, since it is first, will be the default when make is invoked without a specific task.
# You can make make make only your preferred targets by default.
# all: install lint test coverage docs

# There are some variables that need to be set, or you may simply wish to override some of them to
# suit your specific needs.
# ghuser = $(APP_NAMESPACE)
lintfiles = lib test
testflags += --require should

# You can also change what tasks are to be executed as requirements of other tasks. For example, you
# could tell make to lint your files before your tests are run:
# test: lint

# ... or prohibit some targets to complete if they are executed on a different platform version:
# gh-pages: platform-version

## #################################################################
## BASE
## #################################################################

# Base configuration for the Node.js platform Make targets

# Directory where project binaries reside
bindir := node_modules/.bin/

# Current Node.js version (in the form v{MAJOR}.{MINOR}, i.e. v5.5)
platform_v := $(shell node -v | cut -f 1,2 -d .)

# Target Node.js version
platform_t ?= v6.5

## #################################################################
## COMPARE VERSION
## #################################################################

# This task allows restricting other tasks to be run only when platform versions match expectations
err_platform_mismatch = Platform version mismatch: current: $(platform_v), required: $(platform_t)

platform-version:
	$(if platform_v, , $(error Failed to detect current platform via platform_v))
	$(if platform_t, , $(error Target platform not specified - set it via platform_t))
	$(if $(filter-out $(platform_v), $(platform_t)), $(error $(err_platform_mismatch)))

## #################################################################
## NPM - INSTALL DEPS
## #################################################################

# Install dependencies (added for compatibility reasons with usual workflows with make, .e. calling
# make && make install)
node_modules: package.json
	@npm prune && npm install

install: node_modules

clean-install:
	@rm -rf node_modules

## #################################################################
## DOCS GENERATION
## #################################################################

# Generate documentation

docdir ?= docs
jsdocconf ?= jsdoc.json

docs: node_modules
	@$(bindir)jsdoc --configure $(jsdocconf) --destination $(docdir)

# Delete docs
clean-docs:
	@rm -rf $(docdir)

clean: clean-docs

## #################################################################
## LINT
## #################################################################

# Lint all js files (configuration available in .eslintrc)

# By default, lint files in these locations
lintfiles ?= lib test index.js

lint: node_modules
	@$(bindir)eslint $(lintfiles)

## #################################################################
## COVERALLS
## #################################################################

# Submit code coverage to Coveralls (works from Travis; from localhost, additional setup is needed)
coveralls: coverage
	@$(bindir)coveralls < coverage/lcov.info

## #################################################################
## COVERAGE
## #################################################################

# Generate coverage report (html report available in coverage/lcov-report)
coverage: node_modules
	@$(bindir)istanbul cover $(bindir)_mocha > /dev/null -- $(testflags)

clean-coverage:
	@rm -rf coverage

clean: clean-coverage

## #################################################################
## TEST
## #################################################################

# Command line args for Mocha test runner
testflags ?= --check-leaks --no-exit

test: node_modules
	@$(bindir)mocha $(testflags)	

.PHONY: clean-coverage test coveralls clean-docs clean-install lint platform-version

