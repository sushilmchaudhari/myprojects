#!/bin/sh

RUBY_VER=$(/usr/local/rvm/bin/rvm list default | grep ruby- | awk '{print $1}')

GEMSET_NM=$1

#PASSENGER_ROOT=$(/usr/local/rvm/wrappers/"$RUBY_VER"@"$GEMSET_NM"/passenger-config --root)
PASSENGER_ROOT=$(/usr/local/rvm/bin/rvm "$RUBY_VER"@"$GEMSET_NM" exec  passenger-config --root)
#RUBY_PATH="/usr/local/rvm/rubies/$RUBY_VER/bin/ruby"

# Escape paths for passing into sed:
PASSENGER_ROOT=$(echo $PASSENGER_ROOT | sed -e 's/\([\/ ]\)/\\\1/g')
#RUBY_PATH=$(echo $RUBY_PATH | sed -e 's/\([\/ ]\)/\\\1/g')

# Copy the config:
cp -fv $2 $3

# Patch the config:
sed -e "s/##PASSENGER_ROOT##/${PASSENGER_ROOT}/g" -i $3
#sed -e "s/##RUBY_PATH##/${RUBY_PATH}/g" -i $3

