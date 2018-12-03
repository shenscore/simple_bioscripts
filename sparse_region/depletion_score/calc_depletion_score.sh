#!/bin/bash

#### Description: Wrapper script to annotate mismatches. Consists of 3 parts:
####	1. Analysis of local mismatch signatures [done]
####	2?. Filtering local mismatch calls by checking for off-diagonal contact enrichments signatures [not done]
####	3. Mismatch boundary thinning to reduce mimassembly debris [done].
#### Usage: run-mismatch-detector.sh -p <percentile> -b <bin_size> -d <depletion_region> <path-to-hic-file>
#### Dependencies: GNU Parallel; Juicebox_tools; compute-quartile.awk; precompute-depletion-score.awk; ...
#### Input: Juicebox hic file.
#### Parameters: percentile which defines sensitivity to local misassemblies (0<p<100, default 5); resolution at which to search the misassemblies (default 25kb); diagonal that limits the region for calculating the insulation score (default 100kb).
#### NOTE: Unprompted parameters: k, sensitivity to depletion signal (default k=0.5).
#### Output: "Wide" and "narrow" bed file highlighting mismatch regions [mismatch_wide.bed; mismatch_narrow.bed]. Note that these represent candidate regions of misassembly and might be subject to further filtering. Additional output generated as part of this wrapper script includes depletion_score_wide.wig, depletion_score_narrow.wig track files.
#### Written by: Olga Dudchenko - olga.dudchenko@bcm.edu. Version date 12/03/2016.

USAGE="
*****************************************************
This is a wrapper for a fragment of Hi-C misassembly detection pipeline, version date: Dec 3, 2016. This fragment concerns with generating a mismatch annotation file that will later be overlaid with scaffold boundaries to excise regions spanning misassemblies.

Usage: ./run-mismatch-detector.sh [-h] [-p percentile] [-b bin_size_aka_resolution] [-d depletion_region_size] path_to_hic_file

ARGUMENTS:
path_to_hic_file     	Path to Juicebox .hic file of the current assembly.

OPTIONS:
-h			Shows this help
-c percentile		Sets percent of the map to saturate (0<=c<=100, default is 5).
-w wide_res			Sets resolution for the first-pass search of mismatches (default is 25000 bp)
-n narrow_res		Sets resolution for the precise mismatch localizaton (n<w, default is 1000 bp)
-d depletion_area	Sets the size of the region to aggregate the depletion score in the wide path (d >= 2*w, default is 100000 bp)

Unprompted
-p true/false		Use GNU Parallel to speed up computation (default is true)
-k					Sensitivity to magnitude of depletion, percent of expected (0<=k<=100, default is 50 i.e. label region as mismatch when score is 1/2 of expected)
-b NONE/VC/VC_SQRT/KR	Sets which type of contact matrix balancing to use (default KR)

Uses compute-quartile.awk, precompute-depletion-score.awk [[...]] that should be in the same folder as the wrapper script.

*****************************************************
"

## Set defaults
pct=5					# default percent of map to saturate
bin_size=5000			# default bin size to do a first-pass search for mismatches
dep_size=50000			# default for the size of the region to average the depletion score

## Set unprompted defaults
use_parallel=true		# use GNU Parallel to speed-up calculations (default)
k=10					# sensitivity to depletion score (50% of expected is labeled as a mismatch)
norm="KR"				# use an unbalanced contact matrix for analysis

## HANDLE OPTIONS

while getopts "hc:w:n:d:p:k:b:" opt; do
case $opt in
    h) echo "$USAGE" >&1
        exit 0
    ;;
    c)  re='^[0-9]+\.?[0-9]*$'
        if [[ $OPTARG =~ $re ]] && [[ ${OPTARG%.*} -ge 0 ]] && ! [[ "$OPTARG" =~ ^0*(\.)?0*$ ]] && [[ $((${OPTARG%.*} + 1)) -le 100 ]]; then
        	echo ":) -c flag was triggered, starting calculations with ${OPTARG}% saturation level" >&1
        	pct=$OPTARG
        else
        	echo ":( Wrong syntax for saturation threshold. Using the default value pct=${pct}" >&2
        fi
    ;;
    w)  re='^[0-9]+$'
        if [[ $OPTARG =~ $re ]]; then
            echo ":) -w flag was triggered, performing cursory search for mismatches at $OPTARG resolution" >&1
            bin_size=$OPTARG
        else
            echo ":( Wrong syntax for bin size. Using the default value 25000" >&2
        fi
    ;;
    n)  re='^[0-9]+$'
        if [[ $OPTARG =~ $re ]]; then
            echo ":) -n flag was triggered, performing mismatch region thinning at $OPTARG resolution" >&1
            narrow_bin_size=$OPTARG
        else
            echo ":( Wrong syntax for mismatch localization resolution. Using the default value 1000" >&2
        fi
    ;;
	d)  re='^[0-9]+$'
        if [[ $OPTARG =~ $re ]]; then
            echo ":) -d flag was triggered, depletion score will be averaged across a region bounded by $OPTARG superdiagonal" >&1
            dep_size=$OPTARG
        else
            echo ":( Wrong syntax for mapping quality. Using the default value dep_size=100000" >&2
        fi
    ;;
    p)	if [ $OPTARG == true ] || [ $OPTARG == false ]; then
    	    echo ":) -p flag was triggered. Running with GNU Parallel support parameter set to $OPTARG." >&1
			use_parallel=$OPTARG
    	else
    		echo ":( Unrecognized value for -p flag. Running with default parameters (-p true)." >&2
    	fi
    ;;
    k)  re='^[0-9]+$'
        if [[ $OPTARG =~ $re ]] && [[ $OPTARG -gt 0 ]] && [[ $OPTARG -lt 100 ]]; then
            echo ":) -k flag was triggered, starting calculations with ${OPTARG}% depletion as mismatch threshold" >&1
            k=$OPTARG
        else
            echo ":( Wrong syntax for mismatch threshold. Using the default value k=50" >&2
        fi
    ;;
    b)	if [ $OPTARG == NONE ] || [ $OPTARG == VC ] || [ $OPTARG == VC_SQRT ] || [ $OPTARG == KR ]; then
    	    echo ":) -b flag was triggered. Type of norm chosen for the contact matrix is $OPTARG." >&1
			norm=$OPTARG
    	else
    		echo ":( Unrecognized value for -b flag. Running with default parameters (-b NONE)." >&2
    	fi
    ;;
    *) echo "$USAGE" >&2
        exit 1
    ;;
esac
done

shift $(( OPTIND-1 ))

## check parameters for consistency
[[ ${dep_size} -le ${bin_size} ]] && echo >&2 ":( Requested depletion region size ${dep_size} and bin size ${bin_size} parameters are incompatible {${dep_size} < ${bin_size}). Exiting!" && echo >&2 "$USAGE" && exit 1
(( ${dep_size} % ${bin_size} != 0 )) && new_dep_size=$(( dep_size / bin_size * bin_size )) && echo >&2 ":| Warning: depletion region size ${dep_size} and bin size ${bin_size} parameters are incompatible (${dep_size} % ${bin_size} != 0). Changing depletion region size to ${new_dep_size}." && dep_size=${new_dep_size} 
[[ ${bin_size} -le ${narrow_bin_size} ]] && echo >&2 ":( Requested mismatch localization resolution ${narrow_bin_size} and cursory search bin size ${bin_size} parameters are incompatible ($bin_size < ${narrow_bin_size}). Exiting!" && echo >&2 "$USAGE" && exit 1


hic_file=$1
chr=$2
## CHECK DEPENDENCIES
	type java >/dev/null 2>&1 || { echo >&2 ":( Java is not available, please install/add to path Java to run Juicer and Juicebox. Exiting!"; exit 1; }

if [ ${use_parallel} == "true" ]; then
	type parallel >/dev/null 2>&1 || { echo >&2 ":( GNU Parallel support is set to true (default) but GNU Parallel is not in the path. Please install GNU Parallel or set -p option to false. Exiting!"; exit 1; }
fi

path_to_scripts=`cd "$( dirname $0)" && pwd`
path_to_vis=$(dirname ${path_to_scripts})"/visualize"

juicebox=${path_to_vis}/"juicebox_tools.sh"

compute_centile_script=${path_to_scripts}"/compute-centile.awk"
precompute_depletion_score=${path_to_scripts}"/precompute-depletion-score.awk"



## TODO: Check that saturation level is above a certain threshold to avoid working with extremely sparse matrices.


## DUMP HIGH-RES MATRIX FOR ANALYSIS, COMPUTE (1-PCT) QUARTILE AND COMPUTE DEPLETION SCORE
echo "...Dumping ${bin_size} resolution matrix"
straw NONE ${hic_file} $chr $chr BP ${bin_size} >${chr}.${bin_size}.txt
[ $? -ne 0 ] && echo >&2 ":( Juicebox dump is empty! Perhaps something is wrong with the hic file or the requested resolution is too high. Exiting!" && exit 1

echo "...Estimating necessary saturation level for requested misassembly sensitivity"
sat_level=`awk '\$1!=\$2{print \$3}' ${chr}.${bin_size}.txt | sort -n -S1G --parallel=24 -s | awk -v complement=1 -v p=${pct} -f ${compute_centile_script}`
## TODO: Check that saturation level is above a certain threshold to avoid working with extremely sparse matrices. No big deal but comment lines are still in the dump..
echo "...Fine resolution saturation level = ${sat_level}"

echo "...Analyzing near-diagonal mismatches"
cmd="awk 'BEGIN{printf \"%.4f\", $k/100*$sat_level*0.5*$dep_size/$bin_size*($dep_size/$bin_size-1)}'"
thr=`eval $cmd`

adjust_chr=$(echo $chr |sed 's/Chr//')
echo "variableStep chrom=${adjust_chr} span=${bin_size}" > "${chr}.depletion_score_narrow.wig"

## TODO: CHECK min+dep_size-2*bin_size or -1*bin_size. Maybe switch to n bins, not abs length
if [ ${use_parallel} == "true" ]; then
#	parallel -a ${chr}.${bin_size}.txt --will-cite --jobs 80% --pipepart --block 1G "awk -v sat_level=${sat_level} -v bin_size=${bin_size} -v dep_size=${dep_size} -f ${precompute_depletion_score} -" | awk -v bin_size=${bin_size} -v dep_size=${dep_size} 'BEGIN{OFS="\t"}NR==1{min=$1}$1>max{max=$1}$1<min{min=$1}{c[$1]+=$2}END{for(i=min+dep_size-2*bin_size; i<=max-dep_size+2*bin_size; i+=bin_size){print i, c[i]+=0}}' >> "${chr}.depletion_score_narrow.wig"
	parallel -a ${chr}.${bin_size}.txt --will-cite --jobs 80% --pipepart --block 1G "awk -v sat_level=${sat_level} -v bin_size=${bin_size} -v dep_size=${dep_size} -f ${precompute_depletion_score} -" | awk -v bin_size=${bin_size} -v dep_size=${dep_size} 'BEGIN{OFS="\t"}NR==1{min=$1}$1>max{max=$1}$1<min{min=$1}{c[$1]+=$2}END{for(i=min+dep_size-2*bin_size; i<=max-dep_size+2*bin_size; i+=bin_size){print i, c[i]+=0}}' | tee -a "${chr}.depletion_score_narrow.wig" | awk -vOFS='\t' -v chr=$chr -v thr=${thr} -v bin_size=${bin_size} '($2<thr){if(start==""){start=$1}; span+=bin_size}($2>=thr){if(start!=""){print chr, start, start+span}; start=""; span=0}END{if(start!=""){print chr, start, start+span}}' > ${chr}.sparse.bed
else
	awk -v sat_level=${sat_level} -v bin_size=${bin_size} -v dep_size=${dep_size} -f ${precompute_depletion_score} ${chr}.${bin_size}.txt | awk -v bin_size=${bin_size} -v dep_size=${dep_size} 'BEGIN{OFS="\t"}NR==1{min=$1}$1>max{max=$1}$1<min{min=$1}{c[$1]+=$2}END{for(i=min+dep_size-2*bin_size; i<=max-dep_size+2*bin_size; i+=bin_size){print i, c[i]+=0}}' >> "${chr}.depletion_score_narrow.wig"
fi

#awk -v bin_size=${bin_size} 'FILENAME==ARGV[1]{acount+=1; start[acount]=$2; end[acount]=$3; next}FNR==1{count=1;next}start[count]>=($1+bin_size){next}end[count]<=$1{for(s=start[count];s<end[count];s+=bin_size){if(cand[s]==min){print s, s+bin_size}}; count+=1}{cand[$1]=$2; if($1<=start[count]){min=$2}else if($2<min){min=$2}}END{if(count<=acount){for(s=start[count];s<end[count];s+=bin_size){if(cand[s]==min){print s, s+bin_size}}}}' "mismatch_wide.bed" "depletion_score_narrow.wig" | awk 'BEGIN{OFS="\t"}NR==1{start=$1; end=$2;next}$1==end{end=$2;next}{print "assembly", start, end; start=$1; end=$2}END{print "assembly", start, end}' > ${chr}.mismatch_narrow.bed

rm ${chr}.${bin_size}.txt
