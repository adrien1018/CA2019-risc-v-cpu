#!/bin/bash

pandoc report.md \
    -o report.pdf  \
    --latex-engine=xelatex \
    -f markdown
    -V mainfont='WenQuanYi Zen Hei Mono'
