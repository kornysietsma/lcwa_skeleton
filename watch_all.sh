#!/bin/bash
# run precompile apps in the background
#  you could do this manually in separate terminals,
#  or kick this off from rake...
sass --watch views/scss:public/stylesheets > logs/sass.log &
coffee -o public/javascript --watch views/coffee/ > logs/coffee.log &

