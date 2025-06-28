#!/usr/bin/env bash

# quarto preview quarto/

quarto render quarto/
git add docs

git commit -m "quarto: publish site to docs/"
# git push