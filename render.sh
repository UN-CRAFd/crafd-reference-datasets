#!/usr/bin/env bash

quarto render quarto/
git add docs
git commit -m "quarto: publish site to docs/"
git push