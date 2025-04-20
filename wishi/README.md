# Purpose
This repository holds the dbt installation for Wishi, a wishlist app I built and maintain at getwishi.com. The purpose of open sourcing this repo is to share how I implemented the data model with dbt.

A walkthrough of the data model is at [WALKTHROUGH.md](https://github.com/danbratton/wishi-dbt/blob/main/wishi/WALKTHROUGH.md).

# Production
The `dbt/Dockerfile` is used in production
# Local development
## Prerequisites
1. Set up a local folder called `wishi` with two subfolders called `app` and `dbt`
2. Pull the wishi repo (it's private) into the folder called `wishi/app`
3. Pull this repo into `wishi/dbt`
4. Review the `README.md` for the wishi repo as the rest of the steps are there

# Production
The `dbt/Dockerfile` is used in production to run a daily job. 