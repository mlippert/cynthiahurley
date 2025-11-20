#
# Makefile to build and test the python sources
#

# force the shell used to be bash in case for some commands we want to use
# set -o pipefail ex:
#    set -o pipefail ; SOMECOMMAND 2>&1 | tee $(LOG_FILE)
SHELL := /bin/bash

# Test if a variable has a value, callable from a recipe
# like $(call ndef,ENV)
ndef = $(if $(value $(1)),,$(error $(1) not set))

PYLINT := pylint
PYSTYLE := pycodestyle

LINT_LOG := ../logs/lint.log
TEST_LOG := ../logs/test.log

PYSOURCES = \
	chwdata/chw_db.py                   \
	chwdata/retail_orders.py            \
	chwdata/wines.py                    \
	visualize/meetings.py               \
	visualize/utterance_duration.py     \
	visualize/utterance_gap_len.py      \
	visualize/zero_duration_distrib.py  \
	visualize/meeting_timeline.py       \
	main.py

# Pattern rules
# lint a python source
# a lint error shouldn't stop the build
%.lint : %.py
	$(call ndef,VIRTUAL_ENV)
	-$(PYLINT) $< | tee $@
	-$(PYSTYLE) $< | tee --append $@
	-@cat $@ >> $(LINT_LOG)
	-@echo >> $(LINT_LOG)


.DEFAULT_GOAL := help
.DELETE_ON_ERROR :
.PHONY : all init install build lint-log vim-lint lint test clean clean-build help

lint : clean-lintlog $(patsubst %.py,%.lint,$(PYSOURCES)) ## run lint over all python source updating the .lint files

test : ## (Not implemented) run the unit tests
	@echo test would run "$(MOCHA) --reporter spec test | tee $(TEST_LOG)"

clean : clean-build ## remove ALL created artifacts

clean-build : ## remove all artifacts created by the build target
	find . -name \*.lint -type f -print -delete

clean-lintlog :
	@rm $(LINT_LOG) 2> /dev/null || true

## Help documentation à la https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
## if you want the help sorted rather than in the order of occurrence, pipe the grep to sort and pipe that to awk
help :
	@echo ""                                                                   ; \
	echo "Useful targets in this pysrc Makefile:"                              ; \
	(grep -E '^[a-zA-Z_-]+ ?:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = " ?:.*?## "}; {printf "\033[36m%-20s\033[0m : %s\n", $$1, $$2}') ; \
	echo ""                                                                    ; \
	echo "If VIRTUAL_ENV needs to be set for a target, run '. activate' first" ; \
	echo ""
