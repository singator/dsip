# syntax=docker/dockerfile:1

FROM python:3.10.6-slim-buster

WORKDIR /app

COPY requirements.txt requirements.txt
COPY lm1.py lm1.py 
COPY train_model.py train_model.py
COPY resale-flat-prices-based-on-registration-date-from-jan-2017-onwards.csv resale-flat-prices-based-on-registration-date-from-jan-2017-onwards.csv
COPY test2.png test2.png
ADD templates templates

RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt
RUN python train_model.py

ENV FLASK_APP lm1

ENTRYPOINT [ "python", "-u", "-m", "flask", "run", "--host=0.0.0.0"]
