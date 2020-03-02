# elasticsearch-on-spot

Use SAM to deploy an ElasticSearch cluster on AWS EC2.



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
aws s3 cp ami.zip s3://<bucketname>/ami.zip

rm fargateelasticsearch.zip
zip -r fargateelasticsearch.zip ./fargateelasticsearch 
aws s3 cp fargateelasticsearch.zip s3://<bucketname>/fargateelasticsearch.zip


Example for a bucket with name: sam-app-buildbucket-q6q9gvg7dirr
cd elasticsearch-on-spot
rm ami.zip
zip -r ami.zip ./ami 

rm fargateelasticsearch.zip
zip -r fargateelasticsearch.zip ./fargateelasticsearch 

aws s3 cp ami.zip s3://sam-app-buildbucket-1jcplrdfk0zxf/ami.zip
aws s3 cp fargateelasticsearch.zip s3://sam-app-buildbucket-1jcplrdfk0zxf/fargateelasticsearch.zip


```

## How It Works

**Motivation For The ElasticSearch Cluster Design**:

We want to build a highly available ElasticSearch system that has 3 master-eligible nodes and can have a variable number of data nodes.

Typically, the way to perform discovery for an ElasticSearch cluster on AWS is via using the discovery-ec2 plugin. This plugin internally uses the equivalent of `aws ec2 describe-instances` command to filter nodes based on the region, availability zones, by security group(s), tag values. This is great but it requires use of AWS APIs - which means the ElasticSearch node should either have an IAM role or have credentials present on it.

In this case, we want to have no more assumptions beyond that the initial master node's private IP is referenced by a DNS record. Every instance there after uses the DNS record to discover the ElasticSearch cluster.

We use security group to inform the node's role: master or data. We do this as the security group the instance belongs to is available on the node itself. If we had used tags, it would've required an AWS API call.

---

The `ami/` dir contains the instructions to build the ElasticSearch AMI and launch it. This is used by the SAM template during code build and after starting up the auto-scaling group.

`setup_elasticsearch.sh` -> provisions the AMI with ElasticSearch, Kibana and Metricbeat.

`init_node.sh` -> This is the boot time script that sets up the ElasticSearch node based on DNS and sets the node role based on the security group name.

