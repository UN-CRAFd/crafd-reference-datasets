#!/bin/bash

uvx ruff check --select I --fix src/
uvx ruff format src/

air format .
rm -f ~/.Rhistory