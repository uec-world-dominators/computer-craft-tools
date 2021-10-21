FROM ubuntu:20.04

RUN apt-get update \
    && apt-get install -y python3 python3-pip rsync git

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY *.py /home/
CMD [ "python3", "-u", "/home/deploy.py" ]
