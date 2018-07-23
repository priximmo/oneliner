#!/bin/bash

while true do
t=$(date) ps=$(ps auxwww | grep nominstance |grep -v ora_ | wc -l)
echo $ps echo $t' --> '$ps >> verif.log
sleep 5m
done
