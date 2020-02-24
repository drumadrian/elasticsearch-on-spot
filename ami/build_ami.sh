
# set a uuid for the resultsxml file name in S3
UUID=$(cat /proc/sys/kernel/random/uuid)

echo "I like logs for dinner"

echo "Starting upload test"
ls -al /usr/local/bin
ls -al /usr/bin/
python -V
aws s3 cp /beef/diagram.png s3://amazon-s3-bucket-load-test-storagebucket-knlgpd3wpz0n/diagram.png

# echo "Running test"
# bzt test.json -o modules.console.disable=true

# t=$(python -c "import random;print(random.randint(1, 30))")
# echo "sleep for: $t seconds."
# sleep $t

# echo "Uploading results"
# aws s3 cp /tmp/artifacts/results.xml s3://$S3_BUCKET/results/${TEST_ID}/${UUID}.xml
