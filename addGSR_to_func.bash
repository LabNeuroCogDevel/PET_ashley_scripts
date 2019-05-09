#!/usr/bin/env bash
set -euo pipefail

echo "dont use. here only to exlain where .gs_ts files in e.g. func/1/ came from"
exit 1

# use the file given or run on all
[ $# -eq 0 ] && echo "USAGE: $0 all; $0 /Volumes/Phillips/mMR_PETDA/subjs/11434_20160601/func/1/nfswdktm_func_1_5.nii.gz" && exit 1
if [ $1 == "all" ]; then
  echo "listing all final (no gsr) files"
  files=( /Volumes/Phillips/mMR_PETDA/subjs/1*_2*/func/[1-6]/nfswdktm_func_[1-6]_5.nii.gz);
else 
  files=($@) 
fi


# start in preproc directory with the func suffix, generate global signal timeseries
mk_gs_ts(){
   local noprefix="$1"
	# skip if we already have a gsr file
	[ -r .gs_ts_deriv ] && echo "$sdir: has gs_ts" && return 0

   [ ! -r dktm_${noprefix}.nii.gz  ] && echo "$sdir/dktm_${noprefix}.nii.gz DNE; no desike data!?" && return 1

	# make global signal timeseries and derivative
   local bmaskcreate=0
   [ ! -s .brainmask_ero2x ] &&
      fslmaths ktm_${noprefix}_tmean_mask -eroF -eroF .brainmask_ero2x -odt char &&
      bmaskcreate=1
	3dmaskave -mask .brainmask_ero2x.nii.gz -q dktm_${noprefix}.nii.gz > .gs_ts
	1d_tool.py -overwrite -infile .gs_ts -demean -write .gs_ts
	1d_tool.py -overwrite -infile .gs_ts -derivative -demean -write .gs_ts_deriv
   [ $bmaskcreate == 1 ] && rm .brainmask_ero2x.nii.gz
}

# given a file, get the preprocessFunctional "funcFile" no prefix name
get_suffix(){
   local f="$1"                  # path/to/blah/nfswdktm_thingwecareabout_5.nii.gz
   fname=$(basename $f .nii.gz); # nfswdktm_thingwecareabout_5
   noprefix=${fname#*_};         # thingwecareabout_5
   # remove smoothing kernel (probably 5, but could be 4)
   noprefix=${noprefix/_[45]/}   # thingwecareabout
   echo $noprefix 
}


## generate gsr time series for each functional
for f in ${files[@]}; do
   [ ! -r $f ] && echo "no such file '$f'" && continue
   noprefix=$(get_suffix $f)
   # find directory
	sdir=$(dirname $f)
	echo "$sdir"
	cd $sdir
   # get gsr timeseries files
   mk_gs_ts $noprefix || continue
done

