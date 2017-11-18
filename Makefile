SHELL   = /bin/sh

## commands
PYTHON ?= python3
PIP ?= pip3
OCTAVE ?= octave --no-gui --no-init-file --no-history --silent
CLING ?= $(shell which cling 2> /dev/null)

## folders
LOCAL_LIBS_PATH = $(PWD)/libs

ifneq ($(CLING),)
CLING_INSTALL_PREFIX = $(realpath $(dir $(CLING))..)
else
CLING_INSTALL_PREFIX = $(LOCAL_LIBS_PATH)
CLING = $(LOCAL_LIBS_PATH)/bin/cling
endif

## Jupyter Notebook
ifneq ($(shell which jupyter-notebook 2> /dev/null),)
## jupyter-notebook command in PATH
NOTEBOOK ?= jupyter-notebook
else
## user installed package
NOTEBOOK ?= $(PYTHON) -m notebook
## install Jupyter if needed
ifeq ($(shell $(PYTHON) -m jupyter --version 2> /dev/null),)
run: install-notebook
endif
endif

## Jupyter kernel for Octave
ifeq ($(shell $(PYTHON) -m octave_kernel --version 2> /dev/null),)
run: install-octave-kernel
endif

## Interval package for Octave
ifeq ($(shell $(OCTAVE) --eval "ver ('interval').Version"),)
run: install-octave-interval
endif

## pyIbex interval library for Python
ifeq ($(shell $(PYTHON) -m pyibex --version 2> /dev/null),)
run: install-pyibex
endif

## Jupyter kernel for C++
ifeq ($(shell $(PYTHON) -m clingkernel --version 2> /dev/null),)
run: install-cling-kernel
endif

## ieeep1788 C++ library
ifeq ($(shell echo "\#include <p1788/p1788.hpp>" \
	| $(CXX) -x c++ --std=c++11 -I$(LOCAL_LIBS_PATH)/include -MM - \
	| grep p1788.hpp ),)
run: install-libieeep1788
endif

export PATH := $(CLING_INSTALL_PREFIX)/bin:$(PATH):$(HOME)/.local/bin

.PHONY: run
run:
	$(NOTEBOOK)

.PHONY: upgrade-pip
upgrade-pip:
	$(PIP) install --upgrade pip

.PHONY: install-notebook
install-notebook: upgrade-pip
	$(PIP) install --user jupyter

.PHONY: install-octave-kernel
install-octave-kernel: upgrade-pip
	$(PIP) install --user octave_kernel

.PHONY: install-pyibex
install-pyibex: upgrade-pip
	$(PIP) install --user pyibex

.PHONY: install-octave-interval
install-octave-interval:
	$(OCTAVE) --eval "pkg install -forge -local interval"


.PHONY: install-cling
install-cling: $(LOCAL_LIBS_PATH)/bin/cling

## see https://root.cern.ch/cling-build-instructions
$(LOCAL_LIBS_PATH)/src/llvm/.git/index:
	git clone http://root.cern.ch/git/llvm.git "$(LOCAL_LIBS_PATH)/src/llvm"
$(LOCAL_LIBS_PATH)/src/llvm/tools/clang/.git/index: | $(LOCAL_LIBS_PATH)/src/llvm/.git/index
	git clone http://root.cern.ch/git/clang.git "$(LOCAL_LIBS_PATH)/src/llvm/tools/clang"
$(LOCAL_LIBS_PATH)/src/llvm/tools/cling/.git/index: | $(LOCAL_LIBS_PATH)/src/llvm/.git/index
	git clone http://root.cern.ch/git/cling.git "$(LOCAL_LIBS_PATH)/src/llvm/tools/cling"
$(LOCAL_LIBS_PATH)/bin/cling $(LOCAL_LIBS_PATH)/share/cling/Jupyter/kernel/scripts/jupyter-cling-kernel: $(LOCAL_LIBS_PATH)/src/llvm/tools/cling/.git/index $(LOCAL_LIBS_PATH)/src/llvm/.git/index $(LOCAL_LIBS_PATH)/src/llvm/tools/clang/.git/index
	(cd "$(LOCAL_LIBS_PATH)/src/llvm"; git checkout cling-patches)
	(cd "$(LOCAL_LIBS_PATH)/src/llvm/tools/clang"; git checkout cling-patches)
	mkdir -p "$(LOCAL_LIBS_PATH)/build/cling"
	( \
		cd "$(LOCAL_LIBS_PATH)/build/cling"; \
		cmake ../../src/llvm \
			-DCMAKE_INSTALL_PREFIX="$(LOCAL_LIBS_PATH)" \
			-DCMAKE_BUILD_TYPE=Debug \
	)
	$(MAKE) -C "$(LOCAL_LIBS_PATH)/build/cling"
	$(MAKE) -C "$(LOCAL_LIBS_PATH)/build/cling" install
	touch $@


## see $(LOCAL_LIBS_PATH)/src/llvm/tools/cling/tools/Jupyter/README.md
.PHONY: install-cling-kernel
install-cling-kernel: $(CLING_INSTALL_PREFIX)/share/cling/Jupyter/kernel/scripts/jupyter-cling-kernel
	$(PIP) install --user --editable $(CLING_INSTALL_PREFIX)/share/cling/Jupyter/kernel
	jupyter-kernelspec install --user $(CLING_INSTALL_PREFIX)/share/cling/Jupyter/kernel/cling-cpp17
	jupyter-kernelspec install --user $(CLING_INSTALL_PREFIX)/share/cling/Jupyter/kernel/cling-cpp1z
	jupyter-kernelspec install --user $(CLING_INSTALL_PREFIX)/share/cling/Jupyter/kernel/cling-cpp14
	jupyter-kernelspec install --user $(CLING_INSTALL_PREFIX)/share/cling/Jupyter/kernel/cling-cpp11


.PHONY: check-cling-kernel
run: check-cling-kernel
check-cling-kernel:
	which jupyter-cling-kernel


.PHONY: install-libieeep1788
install-libieeep1788: $(LOCAL_LIBS_PATH)/include/p1788/p1788.hpp

$(LOCAL_LIBS_PATH)/src/libieeep1788/.git/index:
	git clone https://github.com/nadezhin/libieeep1788.git "$(LOCAL_LIBS_PATH)/src/libieeep1788"
$(LOCAL_LIBS_PATH)/include/p1788/p1788.hpp: | $(LOCAL_LIBS_PATH)/src/libieeep1788/.git/index
	mkdir -p $(LOCAL_LIBS_PATH)/build/libieeep1788
	( \
		cd $(LOCAL_LIBS_PATH)/build/libieeep1788; \
		cmake ../../src/libieeep1788 \
			-DCMAKE_INSTALL_PREFIX=$(LOCAL_LIBS_PATH) \
	)
	$(MAKE) -C $(LOCAL_LIBS_PATH)/build/libieeep1788
	$(MAKE) -C $(LOCAL_LIBS_PATH)/build/libieeep1788 install
	touch "$@"


.PHONY: clean
clean:
	$(RM) -r "$(LOCAL_LIBS_PATH)/build"


.PHONY: maintainer-clean
maintainer-clean: clean
	$(RM) -r "$(LOCAL_LIBS_PATH)"
