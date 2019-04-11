# This makefile is used to pull down argbash
# and install it, then run argbash on our run.m4 file
# This generates the run.sh script that then has built in
# Argument parsing and help output

SRCM4 = socok8s.m4

BUILD_DIR = $(PWD)/build
ARGBASH_DIR = $(BUILD_DIR)/argbash
COMPLETION_DIR = $(BUILD_DIR)/completion
MAN_DIR = $(BUILD_DIR)/manpage

ARGBASH_INSTALL_PREFIX = $(ARGBASH_DIR)/install
ARGBASH_VERSION = 2.8.0
ARGBASH = $(ARGBASH_INSTALL_PREFIX)/bin/argbash
RUNTARGET = socok8s.sh

COMPLETION_TARGET = $(COMPLETION_DIR)/$(RUNTARGET)

TARGETDEFSRST = socok8s-defs.rst
TARGETRST = socok8s.rst
TARGETMAN = socok8s.1

SHELL = /bin/bash

# list of targets

all: run completion manpage

clean:
	$(RM) -r build/argbash
	$(RM) $(RUNTARGET)
	$(RM) -r $(COMPLETION_DIR)
	$(RM) -r $(MAN_DIR)

argbash: | download
ifeq (,$(wildcard $(ARGBASH)))
	@cd $(ARGBASH_DIR)/resources && $(MAKE) --quiet PREFIX=$(ARGBASH_INSTALL_PREFIX) install
endif

download:
ifeq (,$(wildcard $(ARGBASH_DIR)))
	@echo "Git cloning argbash"
	@git clone -q --single-branch https://github.com/matejak/argbash.git $(ARGBASH_DIR)
	@cd $(ARGBASH_DIR) && git fetch -q --tags && git checkout -q -b $(ARGBASH_VERSION)
endif

completion: run
	@echo ""
	@echo ""
	@echo "Generating bash-completion script $(COMPLETION_TARGET)"
	@mkdir -p $(COMPLETION_DIR)
	@$(ARGBASH) $(SRCM4) --type completion --strip all -o $(COMPLETION_TARGET)
	@echo "Now source the completion script to add bash-completion support"
	@echo "source $(COMPLETION_TARGET)"

manpage: run
	@echo ""
	@echo "Building manpage for $(RUNTARGET)"
	@mkdir -p $(MAN_DIR)
ifeq (,$(wildcard $(MAN_DIR)/$(TARGETDEFSRST)))
	@$(ARGBASH) $(RUNTARGET) --type manpage-defs --strip all -o $(MAN_DIR)/$(TARGETDEFSRST)
endif
	@$(ARGBASH) $(RUNTARGET) --type manpage --strip all -o $(MAN_DIR)/$(TARGETRST)
	@rst2man $(MAN_DIR)/$(TARGETRST) > $(MAN_DIR)/$(TARGETMAN)
	@echo "Manpage build done  $(MAN_DIR)/$(TARGETMAN)"
	man $(MAN_DIR)/$(TARGETMAN)


run: argbash
	@echo "Generating $(RUNTARGET)"
	@$(ARGBASH) -o $(RUNTARGET) $(SRCM4)
	@echo "socok8s.sh build complete.  You can now execute socok8s.sh"
