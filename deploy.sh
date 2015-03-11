#!/bin/bash

rsync -avz --exclude=node_modules --exclude=*.sh --exclude=.git -e "ssh -p 34817" ./_site/ adam@vpn.azielinski.info:/home/adam/articles/
