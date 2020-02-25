# elasticsearch-on-spot
use SAM to deploy an elasticsearch cluster on AWS EC2



![Image](elasticsearch-on-spot.png)

Link:
https://cloudcraft.co/view/a4375794-569b-472d-9be3-afd7e069aaa3?key=kaVj0CBAAtiUNt94a_caZw&interactive=true&embed=true



## Deployment Steps

```bash
cd sam-app/
sam validate
sam build
sam deploy --guided
```


## AMI and Container Build Steps

```bash
cd elasticsearch-on-spot
rm ami.zip
zip -r ami.zip ./ami 
aws s3 cp ami.zip s3://bucketname/ami.zip

rm fargateelasticsearch.zip
zip -r fargateelasticsearch.zip ./fargateelasticsearch 
aws s3 cp fargateelasticsearch.zip s3://bucketname/fargateelasticsearch.zip

```
