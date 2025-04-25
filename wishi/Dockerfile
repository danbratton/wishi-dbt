# this dockerfile is used in production in the dedicated digital ocean worker
FROM python:3.13-alpine

# This ensures logs are sent to console immediately instead of batching.
# Impacts performance slightly so should remove this ENV variable at scale.
ENV PYTHONUNBUFFERED=1

# these aren't included in 3.13-alpine
RUN apk update && \
    apk add --no-cache \
      gcc \
      musl-dev \
      postgresql-dev \
      linux-headers

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /usr/app

COPY . /usr/app

# write the profile.yml file from env var
RUN mkdir -p /root/.dbt
COPY /write_profile.sh /write_profile.sh
RUN chmod +x /write_profile.sh

ENTRYPOINT ["/bin/bash", "-c", "/write_profile.sh && dbt build"]
