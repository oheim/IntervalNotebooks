SHELL   = /bin/sh

PYTHON ?= python3
PIP ?= pip3

## Jupyter Notebook
ifneq ($(shell which jupyter 2> /dev/null),)
## jupyter command in PATH
NOTEBOOK ?= jupyter notebook
else
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
endif

.PHONY: run
run:
	$(NOTEBOOK)

.PHONY: install-notebook
install-notebook:
	$(PIP) install --upgrade pip
	$(PIP) install --user jupyter
