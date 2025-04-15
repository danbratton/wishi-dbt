#!/bin/sh
# uses the DBT_PROFILES_YML env var
echo "$DBT_PROFILES_YML" > /root/.dbt/profiles.yml
exec "$@"