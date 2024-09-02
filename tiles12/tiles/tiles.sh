#!/bin/bash

for i in ~/zips/*; do
    unzip $i
    if [ $? -ne 0 ]; then
        echo "Error occurred during unzipping $i"
        exit 1
    fi

    j="$(basename $i .zip)"
    blender -b -P blender_script.py -- $j.obj
    if [ $? -ne 0 ]; then
        echo "Error occurred during Blender processing of $j.obj"
        exit 1
    fi

    # Calculate position
    read -r lat lon < <(node calc_position.js $j.obj)
    if [ $? -ne 0 ]; then
        echo "Error occurred during position calculation for $j.obj"
        exit 1
    fi

    # Make a cURL request and capture the response
    response=$(curl -s -XPOST https://api.cesium.com/v1/assets \
        -H "Authorization: Bearer <your_access_token>" \
        -d "{ \"type\": \"3DTILES\", \"options\": { \"sourceType\": \"3D_MODEL\", \"position\": [$lat, $lon, 91] } }")
    if [ $? -ne 0 ]; then
        echo "Error occurred during Cesium API request"
        exit 1
    fi

    # Extract asset ID or relevant data from response
    asset_id=$(echo "$response" | jq -r '.assetMetadata.id')
    bucket=$(echo "$response" | jq -r '.uploadLocation.bucket')
    prefix=$(echo "$response" | jq -r '.uploadLocation.prefix')
    access_key=$(echo "$response" | jq -r '.uploadLocation.accessKey')
    secret_access_key=$(echo "$response" | jq -r '.uploadLocation.secretAccessKey')
    session_token=$(echo "$response" | jq -r '.uploadLocation.sessionToken')
    method=$(echo "$response" | jq -r '.onComplete.method')
    url=$(echo "$response" | jq -r '.onComplete.url')
    fields=$(echo "$response" | jq -r '.onComplete.fields')

    # Use the extracted data (e.g., asset_id) in the AWS CLI call
    AWS_ACCESS_KEY_ID=$access_key AWS_SECRET_ACCESS_KEY=$secret_access_key AWS_SESSION_TOKEN=$session_token aws s3 cp $j-processed.obj s3://$bucket/$prefix/
    if [ $? -ne 0 ]; then
        echo "Error occurred during S3 upload"
        exit 1
    fi

    # Second cURL request for further processing
    curl -s -XPOST $url \
        -H "Authorization: Bearer <your_access_token>" \
        #-d "{ \"asset_id\": \"$asset_id\", \"status\": \"completed\" }"
        -d $fields
    if [ $? -ne 0 ]; then
        echo "Error occurred during the second cURL request"
        exit 1
    fi

    echo "Processed $j successfully."
done
