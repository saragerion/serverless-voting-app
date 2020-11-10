#!/bin/bash

######################################################
#
# File ./scripts/load-test.sh
# This script sends 100 HTTP requests to given url
#
# How to use:
# - Make sure the file is executable  :   chmod +x ./scripts/load-test.sh
# - Append the url as parameter       :   ./scripts/load-test.sh https://xxxxxxxxxxx.cloudfront.net/
#

if [ -z "$1" ]; then
    echo "Please append the URL as parameter: ./scripts/load-test.sh https://xxxxxxxxxxx.cloudfront.net/"
    exit 1
fi

start=$(date +%s)
for i in {1..100}
  do
     curl -s -o /dev/null -w "Request #$i, response status code: %{http_code}\n" "$1" &
done
wait

end=$(date +%s)
echo "Sent 100 requests to your API in $(($end - $start)) seconds."
