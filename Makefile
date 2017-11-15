SHELL   = /bin/sh

## commands
PYTHON ?= python3
PIP ?= pip3
OCTAVE ?= octave --no-gui --no-init-file --no-history --silent

## folders
CLING_INSTALL_PREFIX ?= ../cling_2017-11-13_ubuntu16

LOCAL_LIBS_PATH = $(PWD)/libs

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

.PHONY: install-notebook
install-notebook:
	$(PIP) install --upgrade pip
	$(PIP) install --user jupyter

.PHONY: install-octave-kernel
install-octave-kernel:
	$(PIP) install --upgrade pip
	$(PIP) install --user octave_kernel

.PHONY: install-octave-interval
install-octave-interval:
	$(OCTAVE) --eval "pkg install -forge -local interval"

CLING_JUPYTER_KERNEL_PATH = $(CLING_INSTALL_PREFIX)/share/cling/Jupyter/kernel
.PHONY: install-cling-kernel
install-cling-kernel:
	export PATH=$(CLING_INSTALL_PREFIX)/bin:$(PATH)
	$(PIP) install --user --editable $(CLING_JUPYTER_KERNEL_PATH)
	jupyter-kernelspec install --user $(CLING_JUPYTER_KERNEL_PATH)/cling-cpp17
	jupyter-kernelspec install --user $(CLING_JUPYTER_KERNEL_PATH)/cling-cpp1z
	jupyter-kernelspec install --user $(CLING_JUPYTER_KERNEL_PATH)/cling-cpp14
	jupyter-kernelspec install --user $(CLING_JUPYTER_KERNEL_PATH)/cling-cpp11

.PHONY: check-cling-kernel
run: check-cling-kernel
check-cling-kernel:
	which jupyter-cling-kernel

LIBIEEEP1788_WORKSPACE=$(LOCAL_LIBS_PATH)/src/libieeep1788
$(LIBIEEEP1788_WORKSPACE):
	git clone https://github.com/nadezhin/libieeep1788.git "$(LIBIEEEP1788_WORKSPACE)"
# It is faster to not compile examples and tests of libieeep1788
	sed -i -e "s#add_subdirectory(examples)##" \
		$(LOCAL_LIBS_PATH)/src/libieeep1788/CMakeLists.txt
	sed -i -e "s#add_subdirectory(test)##" \
		$(LOCAL_LIBS_PATH)/src/libieeep1788/CMakeLists.txt

.PHONY: install-libieeep1788
install-libieeep1788: | $(LIBIEEEP1788_WORKSPACE)
	mkdir -p $(LOCAL_LIBS_PATH)/build/libieeep1788
	( \
		cd $(LOCAL_LIBS_PATH)/build/libieeep1788; \
		cmake ../../src/libieeep1788 \
			-DCMAKE_INSTALL_PREFIX=$(LOCAL_LIBS_PATH) \
	)
	$(MAKE) -C $(LOCAL_LIBS_PATH)/build/libieeep1788 install
