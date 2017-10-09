FROM python:3.6.3

RUN pip install influxdb unidecode

RUN mkdir /airquality

ADD ./datasets/ /airquality/datasets/

ADD json_parse.py /airquality/
ADD csv_parse.py /airquality/
ADD aq_dashboard.json /airquality/

ADD run.sh /airquality/
RUN chmod 755 /airquality/run.sh

ADD aq_load.sh /airquality/
RUN chmod 755 /airquality/aq_load.sh

RUN touch /var/log/airquality.log

WORKDIR /airquality
