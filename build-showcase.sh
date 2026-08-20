#!/bin/zsh
# Regenerates index.html — the showcase, and the public entry point — from
# editor.html. The two pages share one codebase; the only difference is the
# SHOWCASE_MODE flag and the title.
cd "${0:A:h}"
sed -e 's/const SHOWCASE_MODE = false;/const SHOWCASE_MODE = true;/' \
    -e 's|<title>Gradient Lab</title>|<title>Gradient Lab — Showcase</title>|' \
    editor.html > index.html
echo "index.html regenerated from editor.html"
