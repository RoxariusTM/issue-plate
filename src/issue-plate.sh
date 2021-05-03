#!/bin/sh

readonly markdownFile="$1"

if [ "$#" -gt 1 ]
then
	echo "too many arguments."
fi

if ! [ -e "$markdownFile" ]
then
	echo "you need to enter the path to the markdown file."
fi

