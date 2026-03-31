README.md

The initial request was -in an empty folder of Kiro-:
"Create 3 terraform modules for RDS Aurora MySQL, DynamoDB and S3. You have to create default values for the most of the cases, except: tier of protection (0, 1 or 2), primary and secondary region -if applicable-, workload name, mandatory tags (cost center, project name and environment). The tier of protection means: tier 0 with multi-az and multi-region deployment with backups every hour, tier 1 multi-az deployment only and backups every 3 hours, and 2 without multi-az neither multi-region deployment with backup daily at 1 am GMT. The values for environment are: dev, qa, uat and prod only. The values for cost center start from 1000 to 9999 only. For the databases users has to deploy development IAM Users only. "

The additional requests were:
"Build a Feature

Technical Design [High-Level Design, Low-Level Design]"

A picture of [image](Initial_Request.png)