#!/bin/bash
set -e

## Setup

brew update && brew upgrade pyenv

## Check current up-to-date version
# https://www.python.org/downloads/

if [ ! -f .python-version ]; then
    echo ".python-version not found!"
    exit 1
fi

# cat .python-version
# pyenv versions

# Skip with N if already installed
pyenv install "$(cat .python-version)"

# Set local pyenv version for this repo
pyenv local "$(cat .python-version)"

# check the currently active Python version
pyenv version
pyenv which python

# remove existing virtual environment if it exists
if [ -d ".venv" ]; then
    echo "Removing existing virtual environment..."
    rm -rf .venv
fi

# create virtual environment
python -m venv .venv

# load venv
source .venv/bin/activate

# check virtual environment
which python
python --version

# install packages
pip install -r requirements.txt
