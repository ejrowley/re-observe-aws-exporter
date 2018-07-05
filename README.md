# re-observe-aws-exporter

A spike into getting some potentially interesting metrics from the AWS API into Prometheus. We're focussing on metrics that aren't surfaced through CloudWatch or some other way.

## Credentials

You'll need to make sure boto3 can make API calls—it reads the necessary things from the environment. This means you'll probably need to set the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION` (and possibly `AWS_SESSION_TOKEN`) environment variables.

## Running

You can run it locally with `python app.py`, this will run the app interactively outputting metrics to stdout. Running the app with `python app.py --daemonize` will run the app daemonized. It exposes its metrics on a http server on port 8000.

You can spin up a Prometheus, Grafana and instance of the app with `docker-compose up`


## Running on PaaS

You can deploy this on PaaS from the `sandbox` space in RE as it contains the `firebreak-access` user provided service which holds the necessary credentials for AWS read access for EC2 and S3.

## Testing deployment of PaaS

Run this curl command - `curl https://re-observe-aws-exporter.cloudapps.digital` to get the AWS metrics.
