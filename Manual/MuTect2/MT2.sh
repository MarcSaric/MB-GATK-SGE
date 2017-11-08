#!/bin/bash -eu
#$ -cwd -V
#$ -pe smp 2
#$ -l h_rt=24:00:00
#$ -l h_vmem=20G
#$ -R y
#$ -q all.q,bigmem.q

# Matthew Bashton 2012-2016
# Runs MuTect using options passed in at command-line.
# Needs the location of the tumor and normal file.
# Another script needs to call this one which has a list of all pairs of files.
# Note optional VCF output is multi sample VCF - this can be split later with
# Split_VCF

set -o pipefail
hostname
date

source ../GATKsettings.sh

NORMAL=$1
TUMOR=$2

B_NAME_N=$(basename "$NORMAL" .bam)
B_NAME_T=$(basename "$TUMOR" .bam)
D_NAME=$(dirname $1)

B_PATH_NAME_N=$D_NAME/$B_NAME_N
B_PATH_NAME_T=$D_NAME/$B_NAME_T

echo "** Variables **"
echo " - BASE_DIR = $BASE_DIR"
echo " - REF = $REF"
echo " - dbSNP = $DBSNP"
echo " - COSMIC = $COSMIC"
echo " - PWD = $PWD"
echo " - NORMAL = $NORMAL"
echo " - TUMOR = $TUMOR"
echo " - B_NAME_N = $B_NAME_N"
echo " - B_NAME_T = $B_NAME_T"
echo " - B_PATH_NAME_N = $B_PATH_NAME_N"
echo " - B_PATH_NAME_T = $B_PATH_NAME_T"
echo " - INTERVALS = $INTERVALS"
echo " - PADDING = $PADDING"

echo "Copying input $FILE1 to $TMPDIR/"
/usr/bin/time --verbose cp -v $B_PATH_NAME_N.bam $TMPDIR
/usr/bin/time --verbose cp -v $B_PATH_NAME_N.bai $TMPDIR

echo "Copying input $FILE2 to $TMPDIR/"
/usr/bin/time --verbose cp -v $B_PATH_NAME_T.bam $TMPDIR
/usr/bin/time --verbose cp -v $B_PATH_NAME_T.bai $TMPDIR

echo "Running MuTect2 on normal:$B_NAME_N.bam vs tumor:$B_NAME_T.bam"
/usr/bin/time --verbose $JAVA -Xmx16g -jar $GATK \
-T MuTect2 \
$INTERVALS \
--interval_padding $PADDING \
-R $REF \
--cosmic $COSMIC \
--dbsnp $DBSNP \
--input_file:normal $TMPDIR/$B_NAME_N.bam \
--input_file:tumor $TMPDIR/$B_NAME_T.bam \
--out $TMPDIR/$B_NAME_N.vs.$B_NAME_T.vcf \
--bamOutput $TMPDIR/$B_NAME_N.vs.$B_NAME_T.bam \
--log_to_file $TMPDIR/$B_NAME_N.vs.$B_NAME_T.log

echo "Copying $TMPDIR/$B_NAME_N.vs.$B_NAME_T.* to $PWD"
/usr/bin/time --verbose cp $TMPDIR/$B_NAME_N.vs.$B_NAME_T.* $PWD

echo "Deleting $TMPDIR/*"
rm $TMPDIR/*

date
echo "END"
