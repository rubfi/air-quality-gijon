#!/bin/bash

echo "    _    _       ___              _ _ _         "
echo "   / \  (_)_ __ / _ \ _   _  __ _| (_) |_ _   _ "
echo "  / _ \ | | '__| | | | | | |/ _' | | | __| | | |"
echo " / ___ \| | |  | |_| | |_| | (_| | | | |_| |_| |"
echo "/_/   \_\_|_|   \___\_\__,_|\__,_|_|_|\__|\__, |"
echo "                                          |___/ "

function grafana_ready {
    curl -s http://grafana:3000 &> /dev/null
    echo $?
}

# Downloading last week data
curl "http://opendata.gijon.es/descargar.php?id=1&tipo=JSON" -o /tmp/week.json

# Wait until Grafana is ready
until [ $(grafana_ready) -eq 0 ]
    do
        echo "Grafana not Running (yet)"
        sleep 1
    done
echo "Grafana Running: Loading Datasource and Dashboard"

# Adding the default datasource
curl 'http://admin:admin@grafana:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"gijon","type":"influxdb","url":"http://localhost:8086","access":"direct","isDefault":true,"database":"airquality","user":"dbuser","password":"dbuser"}'

# Adding the dashboard

# Small hack in order to make compatible the json exported via web
# with the format required by import api

echo '{"dashboard":' > /tmp/dashboard.json
cat aq_dashboard.json >> /tmp/dashboard.json

echo ',"inputs": [
        {
            "name": "DS_GIJON",
            "pluginId": "influxdb",
            "type": "datasource",
            "value": "gijon"
        }
      ],' >> /tmp/dashboard.json

echo '"overwrite": true}' >> /tmp/dashboard.json

curl 'http://admin:admin@grafana:3000/api/dashboards/import' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary @/tmp/dashboard.json

# Parsing last week data
python3 /airquality/json_parse.py /tmp/week.json

# Processing complete years

END=$(echo $AQ_YEARS | cut -d":" -f2)
BEGIN=$(echo $AQ_YEARS | cut -d":" -f1)

if [ "$END" != "" ] && [ "$BEGIN" != "" ]  ; then
    for ((year=$END;year>=$BEGIN;year--)); do
        echo "$(date) : Processing $year started" >> /var/log/airquality.log
        python3 /airquality/csv_parse.py /airquality/datasets/$year.csv
        echo "$(date) : Processing $year done" >> /var/log/airquality.log
    done

    # Parsing last week data again (in order to use the more recent data)
    python3 /airquality/json_parse.py /tmp/week.json
fi

tail -f /var/log/airquality.log
