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

cnt=$(awk "/^##\s/ { print \$0 }" "$markdownFile" | wc -l)

while [ $cnt -gt 0 ]
do
	title=$(awk "/^##\s/ { print \$0 }" "$markdownFile" | sed -n "$cnt p" | cut -c 4-)
	body=$(awk "/^>\s/ { print \$0 }" "$markdownFile" | sed -n "$cnt p" | cut -c 3-)
	labels=$(awk "/^### labels:/, /^### Assignees:/ { if (\$1 == \"-\") { print \$2; } } { if (\$1 == \"###\") { print \"#\"; } }" "$markdownFile" | xargs | sed -e 's/\(\s\?#\)\{1,\}/ |/g' | cut -c 4- | awk -F\| "{print \$$cnt}" | sed -e 's/ /,/g' | sed -e 's/^,//g' | sed -e 's/,$//g')
	assignees=$(awk "/^### Assignees:/, /^### Projects:/ { if (\$1 == \"-\") { print \$2; } } { if (\$1 == \"###\") { print \"#\"; } }" "$markdownFile" | xargs | sed -e 's/\(\s\?#\)\{1,\}/ |/g' | cut -c 4- | awk -F\| "{print \$$cnt}" | sed -e 's/ /,/g' | sed -e 's/^,//g' | sed -e 's/,$//g')
	projects=$(awk "/^### Projects:/, /^-{3,}/ { if (\$1 == \"-\") { print \$2; } } { if (\$1 == \"###\") { print \"#\"; } }" "$markdownFile" | xargs | sed -e 's/\(\s\?#\)\{1,\}/ |/g' | cut -c 4- | awk -F\| "{print \$$cnt}" | sed -e 's/ /,/g' | sed -e 's/^,//g' | sed -e 's/,$//g')
	echo "$tile $body $labels $assignees $projects"
	gh issue create --title "$title" --body "$body" --label "$labels" --assignee "$assignees" --project "$projects" &
	cnt=$(( $cnt-1 ))
done