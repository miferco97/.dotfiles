#!/usr/bin/env bash

pushd $DOTFILES
for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g")
do
    files=$(find $folder -d -maxdepth 1 | grep /)
    for file in $files
    do
        file_to_link_test=${file##*/}
	file_linked="${DOTFILES}/${file}" 
	if [[ ! -z $file_to_link_test ]]; then
	    file_to_link="$HOME/${file#*/}"
	    echo $file_linked
	    echo $file_to_link
	    #HERE GOES THE MAIN PART IN THIS CASE REMOVE THE SYMLINK
	    rm $file_to_link
	fi
    done
done
popd
