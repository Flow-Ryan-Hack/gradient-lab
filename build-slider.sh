#!/bin/zsh
# Regenerates slider.html from index.html. The two pages share one codebase;
# the only difference is the SHOWCASE_MODE flag and the title.
cd "${0:A:h}"
sed -e 's/const SHOWCASE_MODE = false;/const SHOWCASE_MODE = true;/' \
    -e 's|<title>Gradient Lab</title>|<title>Gradient Lab — Showcase</title>|' \
    index.html > slider.html
echo "slider.html regenerated from index.html"
