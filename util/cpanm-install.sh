#!/bin/bash

cat  $PWD/perlmods | xargs -L 1 cpanm install -L $PWD/../extlib
