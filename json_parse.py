import argparse
import json
import html
import unidecode
import os
from influxdb import client as influxdb

HOST = 'influxdb'
PORT = 8086
DBUSER = os.environ['INFLUXDB_USER']
DBPASS = os.environ['INFLUXDB_USER_PASSWORD']
DB = os.environ['INFLUXDB_DB']

def parse_options():
    parser = argparse.ArgumentParser()
    parser.add_argument('filename', help="JSON filename with airquality data")
    options = parser.parse_args()

    return options

def c_float(val):
    if val:
        return (float(val))
    return None

def read_json(filename):
    with open(filename) as f:
        return json.load(f)

options = parse_options()

data = read_json(options.filename)

db = influxdb.InfluxDBClient(HOST, PORT, DBUSER, DBPASS, DB)

data_key = list(data)[0]
data_subkey = list(data[data_key])[0]

for data_row in data[data_key][data_subkey]:
    influx_data = [{
        "measurement": "airquality",
        "tags": {
            "station": unidecode.unidecode(html.unescape(data_row['titulo'])),
            "lat": float(data_row['latitud']),
            "long": float(data_row['longitud'])
        },
        "time": data_row['fechasolar_utc_']+".00000Z",
        "fields": {
            'temp': 0,
            'so2': c_float(data_row['so2']),
            'no': c_float(data_row['no']),
            'no2': c_float(data_row['no2']),
            'co': c_float(data_row['co']),
            'pm10': c_float(data_row['pm10']),
            'o3': c_float(data_row['o3']),
            'dd': c_float(data_row['dd']),
            'vv': c_float(data_row['vv']),
            'tmp': c_float(data_row['tmp']),
            'hr': c_float(data_row['hr']),
            'prb': c_float(data_row['prb']),
            'rs': c_float(data_row['rs']),
            'll': c_float(data_row['ll']),
            'ben': c_float(data_row['ben']),
            'tol': c_float(data_row['tol']),
            'mxil': c_float(data_row['mxil']),
            'pm25': c_float(data_row['pm25'])
        }
    }]
    print (influx_data)
    db.write_points(influx_data)
