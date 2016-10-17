#!/usr/bin/env bash

webhook_url=$1
chef_server=$2
channel=$3
username=$4

if [[ $chef_server == "" ]]
then
    echo "No chef_server specified"
    exit 1
fi

DATE=`date +%Y-%m-%d`

echo "*************overall usage*****************" > output/$DATE.txt 2>&1
knife exec -E 'p api.get("/license")' -s $chef_server >> output/$DATE.txt 2>&1
echo "*************overall usage*****************" >> output/$DATE.txt 2>&1

knife opc org list -a > org_list 2>&1

while read p; do                                                                           
echo "$p: "
echo "knife exec -E 'p api.get(\"/organizations/$p/nodes\").size' -s $chef_server" | bash
done <org_list >> output/$DATE.txt 2>&1

## Post to Slack if you have that set up
if [[ $webhook_url == "" ]]
then
    echo "No webhook_url specified"
    exit 1
else


    output_text=$(<output/$DATE.txt)
    escapedText=$(echo $output_text | sed 's/"/ /g' | sed "s/'/ /g" | sed "s/{/ /g" | sed "s/}/ /g" )

    json="{\"channel\": \"$channel\", \"username\":\"$username\", \"icon_emoji\":\":chef-client:\", \"text\": \"$escapedText\"}"

    echo "$json"
    echo "****************"
    echo "sending to $webhook_url"

    curl -s -d "payload=$json" "$webhook_url"

    rm -rf output/*
    rm -rf org_list
fi
