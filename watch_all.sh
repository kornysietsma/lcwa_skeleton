#!/bin/bash
# run precompile apps in the background
#  you could do this manually in separate terminals,
#  or kick this off from rake...
sass --watch views/scss:public/stylesheets > logs/sass.log &
coffee -c --watch views/coffee/ -o public/javascript > logs/coffee.log &

