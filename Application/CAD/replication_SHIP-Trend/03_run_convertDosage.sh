#!/bin/sh

name=SHIP-0_R4a

for chr in {1..22}
do
    convertDosage_corrREFALT_matchedGTEx_CAD-SHIP-0.sh SHIP-0 $name $chr
done


name=SHIP-Td-SHIP-Td_B2_merged

for chr in {1..22}
do
    convertDosage_corrREFALT_matchedGTEx_CAD-SHIP-TREND.sh SHIP-TREND $name $chr
done


