Title: Using s3cmd to sync and invalidate cloudfront content on AWS
Category: aws
Tags: aws, cloudfront, s3
Slug: s3cmd-sync-and-cf-invalidation
Summary: How to use s3cmd to upload static content (in this case, generated with pelican) and have s3cmd do the heavy lifting with also invalidating CloudFront paths for you.
Date: Mon Nov  2 19:51:32 EST 2015
Status: published

Recently, working with [`s3cmd`][1] has been difficult because the command suffers from a lack of documentation regarding the policy requirements that the software needs to perform its duties. The following is a policy configuration for *S3* and *CloudFront* that enumerate what I *hope* are the minimum requirements that s3cmd needs to deploy a static site to S3 while also invalidating CloudFront paths at the same time. I merely established these policies through trial and error.

[1]:http://s3tools.org/download

A key component is to notice that when assigning the S3 user's policy, you _must_ ensure that you both allow access to the bucket objects with `"arn:aws:s3:::bucket/*",` **as well as**  `"arn:aws:s3:::bucket"` (note the first example has a trailing '/*' and the following doesn't) - for some reason this is necessary for the `--cf-invalidate` option to work with `s3cmd`, and was the most diffuclt part in getting this to work correctly.

The resultant command to publish the website with Pelican's Makefile is `make s3_upload` and now looks as follows:
```makefile
s3_upload: publish
        s3cmd sync $(OUTPUTDIR)/ s3://$(S3_BUCKET) --acl-public --delete-removed \
        --guess-mime-type --no-mime-magic --no-preserve --cf-invalidate
```
**S3 Tangent**: `--no-mime-magic` is not a default option either, it is required in order to avoid a broken libmagic library setting the wrong MIME header in s3. If you don't use this, you'll be serving CSS content as text and your website will be broken. Additionally, `--no-preserve` is important because s3cmd was built with file preservation in mind, and will set a custom header for each object that stores sensitive information, such as UID and GID of the uploader. This is beneficial when archiving files (because it acts more like tar), but not so useful when trying to serve a website.

<br />

####**IAM Policies:**

CloudFront policy configuration:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1446510379000",
            "Effect": "Allow",
            "Action": [
                "cloudfront:CreateInvalidation",
                "cloudfront:GetCloudFrontOriginAccessIdentity",
                "cloudfront:GetCloudFrontOriginAccessIdentityConfig",
                "cloudfront:GetDistribution",
                "cloudfront:GetDistributionConfig",
                "cloudfront:GetInvalidation",
                "cloudfront:ListDistributions",
                "cloudfront:ListInvalidations"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```
######_Reminder_: [There are no ARNs for CloudFront][2], simply use '*'

[2]:http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/UsingWithIAM.html#CloudFront_ARN_Format
*[ARNs]: Amazon Resource Name

S3 Bucket policy configuration:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1446509955000",
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject",
                "s3:GetBucketLocation",
                "s3:GetBucketWebsite",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:ListBucket",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::bucket/*",
                "arn:aws:s3:::bucket"
            ]
        }
    ]
}
```