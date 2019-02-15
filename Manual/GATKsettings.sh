#!/bin/bash -e

# Matthew Bashton 2012-2017

# A script of common GATK settings file, this file gets sourced by the various
# scripts in the subdirs up a level from this base dir.  This allows for
# different runs to have different settings rather than a global file in users
# home dir.

# Note pre-set for and tested on exomes, for less than 100M bases per @RG
# targeted don't run BQSR see:
# http://gatkforums.broadinstitute.org/discussion/comment/14269/#Comment_14269

# Also for RAD/Haloplex data don't run MarkDuplicates

## Base dir - should auto set to where this script resides
BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Ensure file creation is private to prevent temp files and other data being
# accessed by others
umask 077

## System settings for launching java jobs
# On FMS cluster we need to use large pages have also set tmp dir to one
# provided by SoGE for each run

# Add in module for Java 1.8 (FMS cluster specific)
module add apps/java/jdk-1.8.0_131

#JAVA="/opt/software/java/jdk1.7.0_75/jre/bin/java -XX:-UseLargePages -Djava.io.tmpdir=$TMPDIR"
JAVA="/opt/software/java/jdk1.8.0_131/bin/java -XX:-UseLargePages -Djava.io.tmpdir=$TMPDIR"
# MuTect1 needs Java 7
JAVA7="/opt/software/java/jdk1.7.0_75/jre/bin/java -XX:-UseLargePages -Djava.io.tmpdir=$TMPDIR"


## We need latest GCC libs for AVX hardware acceleration of pairHMM (FMS cluster
#specific)
module add compilers/gnu/4.9.3
## Latest version of R for plots (FMS cluster specific)
module add apps/R/3.4.0

## Location of programs
# Extra GATK setting below fixes issues with file locking on Luster FS
GATK="/opt/software/bsu/bin/GenomeAnalysisTK-3.8.jar --disable_auto_index_creation_and_locking_when_reading_rods"
# Newer versions of Picard has a unified .jar file
PICARD="/opt/software/bsu/bin/picard.jar"
BWA="/opt/software/bsu/bin/bwa"
# Since more than one version of muTect always place the one I'm using in same
# dir as analysis
MUTECT="muTect-1.1.7.jar --disable_auto_index_creation_and_locking_when_reading_rods"
FASTQC="/opt/software/bsu/bin/fastqc"
VCFUTILS="/opt/software/bsu/bin/vcfutils.pl"
VCFANNOTATE="/opt/software/bsu/bin/vcf-annotate"
VCFTOOLS="/opt/software/bsu/bin/vcftools"
SAMTOOLS="/opt/software/bsu/bin/samtools"
OLDSAMTOOLS="/opt/software/bsu/bin/samtools_0.1.18"

# Perl 5 lib settings needed for vcf-annotate to work, needs path to Vcf.pm to
# be in PER5LIB path.
PERL5LIB=/opt/software/bsu/lib/perl/:$PERL5LIB;
export PERL5LIB

## Ensembl VEP cache location, note to improve performance this will be copied
# to $TMPDIR on the start of each VEP job.
GLOBAL_VEP_CACHE="/opt/databases/ensembl-vep/90"

## Intervals
# .bed file with the regions covered for exome sequencing, -L is included here
# in the string, so setting this string blank will effectively disable it
# should you be using genome sequencing.
INTERVALS="-L ../Kit_regions_covered.bed"

# You also need to pad your intervals, ideally should be same as read length
# i.e. 100bp, setting to 0 will effectively disable padding
PADDING=100

# PCR indel model used by HC, this should be set to NONE for WGS and either
# AGGRESSIVE (less FP, loss of some TP) or CONSERVATIVE (more FP, more TP) for
# exomes, a new HOSTILE setting is now available (even less FP, loss of more TP).
PCR="CONSERVATIVE"

## GATK bundel dir
# I find it better to use a string shortcut for the bundel dir rather than a
# separate string for each file in the dir as this way you can see more clearly
# what files are being used in the analysis.  Have now switched to b37 decoy
# which avoids issues with repeated regions.
BUNDLE_DIR="/opt/databases/GATK_bundle/2.8/b37"

# Set up which datasets to use from the bundle
REF="$BUNDLE_DIR/human_g1k_v37_decoy.fasta"
MILLS_1KG_GOLD="$BUNDLE_DIR/Mills_and_1000G_gold_standard.indels.b37.vcf"
PHASE1_INDELS="$BUNDLE_DIR/1000G_phase1.indels.b37.vcf"
PHASE1_SNPS="$BUNDLE_DIR/1000G_phase1.snps.high_confidence.b37.vcf"
DBSNP="$BUNDLE_DIR/dbsnp_138.b37.vcf"
DBSNP129="$BUNDLE_DIR/dbsnp_138.b37.excluding_sites_after_129.vcf"
OMNI="$BUNDLE_DIR/1000G_omni2.5.b37.vcf"
HAPMAP="$BUNDLE_DIR/hapmap_3.3.b37.vcf"

## COSMIC location
# Currently in same dir as the working/current since tend to change
# on each run for up to date version
COSMIC="$BASE_DIR/Cosmic_b37_v87.vcf"

## Global dcov setting
# The depth of coverage setting used in downsampling the number of reads per
# sample for variant calling at any one site.  Using 30K up form default 250
# as helps with targeted calling and deeper runs for detecting lower AF,
# adjust as need be.  Now only applies to UG, dcov disabled for HC due to
# unwanted interaction with active regions downsampling.
DCOV=30000

## --maxReadsInRegionPerSample
# Defines the down sampling level for the maximum reads per sample used in the
# active region for the HC.  Default is 10000 have set this up to 30000.
# Looks like this is not functional at present:
# http://gatkforums.broadinstitute.org/discussion/6234/downsample-to-coverage-in-haplotypercaller
# MAX_READS_IN_REGION=30000
