#!/bin/sh


if [ "$1" = "" ] ;
then
 echo "gen file prefix (incl. directory) required!"
 exit 0
fi
genfileprefix=$1

qctool -g ${genfileprefix}.gen.gz -osnp ${genfileprefix}.snps_stats -s ${genfileprefix}.sample -snp-stats
