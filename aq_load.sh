#!/bin/bash

if [  $# -lt 1 ]; then
    echo "Usage: $0 [ last | validated | <url> ]"
    echo ""
    echo -e " \tlast         Downloads last available data"
    echo -e " \tvalidated    Downloads last validated data. Uses \$AQ_CURRENT_YEAR_URL in order to know current year"
    echo -e " \t<url>        Downloads last available data form <url>"
    exit 1
fi

if [ "$1" == "last" ]; then
    # Downloading last week data
    echo "$(date) : Downloading last available data" >> /var/log/airquality.log
    curl "http://opendata.gijon.es/descargar.php?id=1&tipo=JSON" -o /tmp/week.json
    python3 /airquality/json_parse.py /tmp/week.json
    echo "$(date) : Downloading last available data : Done" >> /var/log/airquality.log
    exit

fi

if [ "$1" == "validated" ]; then
    # Downloading last validated data
    echo "$(date) : Downloading last validated data" >> /var/log/airquality.log
    curl "$AQ_CURRENT_YEAR_URL" -o /tmp/current_year.csv
    python3 /airquality/csv_parse.py /tmp/current_year.csv

    # Load also the last week of non validated data
    /usr/bin/curl "http://opendata.gijon.es/descargar.php?id=1&tipo=JSON" -o /tmp/week.json
    /usr/local/bin/python3  /airquality/json_parse.py /tmp/week.json
    echo "$(date) : Downloading last validated data: Done" >> /var/log/airquality.log
    exit
fi

# Downloading a specific JSON file
echo "$(date) : Downloading and processing JSON file: $1" >> /var/log/airquality.log
curl "$1" -o /tmp/aq_data.json
python3  /airquality/json_parse.py /tmp/aq_data.json
echo "$(date) : Downloading and processing JSON file: $1 : Done" >> /var/log/airquality.log
