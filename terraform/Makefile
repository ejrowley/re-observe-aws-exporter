APP := ../app.py
VIRTUALENV := ../.venv
WKD = $(realpath .)

venv: ${VIRTUALENV}
	cd ${VIRTUALENV}/lib/python3.6/site-packages; \
	zip -r9 ${WKD}/lambda.zip *

app: ${APP}
	cd ../; \
	zip -r9 ${WKD}/lambda.zip app.py

all: venv app
