#!/bin/sh

name=SHIP-Td-SHIP-Td_B2_merged

for chr in {1..22} X
do
    find_correct_REF_ALT-SHIP.sh SHIP-TREND $name $chr
done


