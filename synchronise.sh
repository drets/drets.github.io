#!/bin/sh
rsync -av --delete --exclude '.git' _site/ ../master/
