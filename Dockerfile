# this dockerfile is used in production in the dedicated digital ocean worker
FROM python:3.13

# This ensures logs are sent to console immediately instead of batching.
# Impacts performance slightly so should remove this ENV variable at scale.
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /usr/app/wishi

COPY . /usr/app