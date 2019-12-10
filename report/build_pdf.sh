#!/bin/bash

pandoc report.md \
    -o report.pdf  \
    --pdf-engine=xelatex \
    -f markdown \
    -V mainfont='Noto Sans Mono CJK TC'
