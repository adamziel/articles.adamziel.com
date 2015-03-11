#!/bin/bash

rvm 1.9.3 do jekyll b
bash push.sh
bash deploy.sh
