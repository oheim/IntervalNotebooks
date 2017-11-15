SHELL   = /bin/sh

## commands
PYTHON ?= python3
PIP ?= pip3
OCTAVE ?= octave --no-gui --no-init-file --no-history --silent

## folders
CLING_INSTALL_PREFIX ?= ../cling_2017-11-13_ubuntu16

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

## Jupyter Kernel for Octave
ifeq ($(shell $(PYTHON) -m octave_kernel --version 2> /dev/null),)
run: install-octave-kernel
endif

## Interval package for Octave
ifeq ($(shell $(OCTAVE) --eval "ver ('interval').Version"),)
run: install-octave-interval
endif

ifeq ($(shell $(PYTHON) -m clingkernel --version 2> /dev/null),)
run: install-cling-kernel
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
