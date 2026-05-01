#
# MIT License
#
# (C) Copyright 2026 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# If you wish to perform a local build, you will need to clone or copy the contents of the
# cms-meta-tools repo to ./cms_meta_tools

NAME ?= types-urllib3

PYTHON_BIN := python$(PY_VERSION)
PYLINT_VENV_BASE_DIR ?= pylint-venv
PYLINT_VENV ?= $(PYLINT_VENV_BASE_DIR)/$(PY_VERSION)
PYLINT_VENV_PYBIN ?= $(PYLINT_VENV)/bin/python3
PIP_INSTALL_ARGS ?= --no-cache

ifneq ($(wildcard ${HOME}/.netrc),)
        DOCKER_ARGS ?= --secret id=netrc,src=${HOME}/.netrc
endif

all : runbuildprep lint pymod
pymod: pymod_build pymod_validate

runbuildprep:
		./generate_files_from_templates.py
		./cms_meta_tools/scripts/runBuildPrep.sh

lint:
		./cms_meta_tools/scripts/runLint.sh

pymod_build:
		rm -rf ./dist || true
		$(PYTHON_BIN) --version
		$(PYTHON_BIN) -m pip install --upgrade --user pip build setuptools wheel
		$(PYTHON_BIN) -m build --sdist
		$(PYTHON_BIN) -m build --wheel

pymod_validate:
		$(PYTHON_BIN) --version
		mkdir -p $(PYLINT_VENV_BASE_DIR)
		$(PYTHON_BIN) -m venv $(PYLINT_VENV)
		$(PYLINT_VENV_PYBIN) -m pip install --upgrade $(PIP_INSTALL_ARGS) pip
		$(PYLINT_VENV_PYBIN) -m pip install --disable-pip-version-check $(PIP_INSTALL_ARGS) dist/*.whl
		$(PYLINT_VENV_PYBIN) -m pip list --format freeze
