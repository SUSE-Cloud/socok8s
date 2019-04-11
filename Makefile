# This makefile is used to pull down argbash
# and install it, then run argbash on our run.m4 file
# This generates the run.sh script that then has built in
# Argument parsing and help output

ARGBASH_DIR = $(PWD)/build/argbash
ARGBASH_INSTALL_PREFIX = $(ARGBASH_DIR)/install
ARGBASH_VERSION = 2.8.0
ARGBASH = $(ARGBASH_INSTALL_PREFIX)/bin/argbash
RUNTARGET = run.sh

SHELL = /bin/bash

# list of targets

all: run

clean:
	$(RM) -r build/argbash
	$(RM) $(RUNTARGET)

argbash: | download
ifeq (,$(wildcard $(ARGBASH)))
	cd $(ARGBASH_DIR)/resources && $(MAKE) PREFIX=$(ARGBASH_INSTALL_PREFIX) install
endif

download:
ifeq (,$(wildcard $(ARGBASH_DIR)))
	@echo "Folder $(ARGBASH_DIR) doesn't exist"
	git clone --single-branch https://github.com/matejak/argbash.git $(ARGBASH_DIR)
	cd $(ARGBASH_DIR) && git fetch --tags && git checkout -b $(ARGBASH_VERSION)
endif

run: argbash
	$(ARGBASH) -o $(RUNTARGET) run.m4
	@echo "run.sh build complete.  You can now execute run.sh"
