#!/bin/bash -e 
#$ -cwd -V
#$ -pe smp 5
#$ -l h_vmem=30G
#$ -l h_rt=24:00:00
#$ -R y

# Matthew Bashton 2012-2015                                                    
# Runs PrintReads to apply BQSR needs an input .bam to recal and the           
# Recal_data.grp file.  Using -L optionally in $INTERVALS to remove off target 
# reads as we don't call variants on these later.                              

set -o pipefail
hostname
date

source ../GATKsettings.sh

B_NAME=`basename $1 .bam`
D_NAME=`dirname $1`
B_PATH_NAME=$D_NAME/$B_NAME

echo "** Variables **"
echo " - BASE_DIR = $BASE_DIR"
echo " - B_NAME = $B_NAME"
echo " - B_PATH_NAME = $B_PATH_NAME"
echo " - INTERVALS = $INTERVALS"
echo " - PADDING = $PADDING"
echo " - PWD = $PWD"

echo "Copying input $B_PATH_NAME.* to $TMPDIR" 
/usr/bin/time --verbose cp -v $B_PATH_NAME.bam $TMPDIR 
/usr/bin/time --verbose cp -v $B_PATH_NAME.bai $TMPDIR

echo "Running GATK"
/usr/bin/time --verbose $JAVA -Xmx26g -jar $GATK \
-T PrintReads \
-nct 5 \
$INTERVALS \
--interval_padding $PADDING \
-I $TMPDIR/$B_NAME.bam \
-R $BUNDLE_DIR/ucsc.hg19.fasta \
-BQSR $B_NAME.Recal_data.grp \
-o $TMPDIR/$B_NAME.Recalibrated.bam \
--log_to_file $B_NAME.PrintReads.log 

echo "Copying output $TMPDIR/$B_NAME.Recalibrated.* to $PWD"
/usr/bin/time --verbose cp -v $TMPDIR/$B_NAME.Recalibrated.bam $PWD
/usr/bin/time --verbose cp -v $TMPDIR/$B_NAME.Recalibrated.bai $PWD

echo "Deleting $TMPDIR/$B_NAME.*"
rm $TMPDIR/$B_NAME.*

date
echo "END"