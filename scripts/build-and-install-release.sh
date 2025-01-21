#!/usr/bin/env bash

meson setup -Dbuildtype=release -Doptimization=3 -Ddebug=false --prefix=/usr --reconfigure build
meson compile -C build
meson install -C build
