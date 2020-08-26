FROM python:3.7-slim

RUN apt-get -qq update \
    && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# get packages
COPY requirements.txt .
RUN pip3 install --upgrade -r requirements.txt

COPY . /apps

WORKDIR /apps

ENTRYPOINT ["python", "main.py"]