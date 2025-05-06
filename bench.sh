#!/bin/sh
hyperfine -i -N "./odiff '$1' '$2'" "./vxdiff '$1' '$2'"
