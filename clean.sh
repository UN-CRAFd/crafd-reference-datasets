#!/bin/bash
set -e

source .venv/bin/activate
pip install -r requirements.txt

black src/
isort src/

pip freeze > requirements.txt

# Rscript -e "styler::style_dir()"