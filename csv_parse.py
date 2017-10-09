import argparse
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
    parser.add_argument('filename', help="CSV filename with airquality data")
    options = parser.parse_args()

    return options

def c_float(val):
    if val:
        return (float(val))
    return None

def read_csv(filename):
    with open(filename, encoding='latin-1') as f:
        return [x.rstrip('\r\n').replace('"','').split(',') for x in f.readlines()[1:]]


options = parse_options()
db = influxdb.InfluxDBClient(HOST, PORT, DBUSER, DBPASS, DB)

for data_row in read_csv(options.filename):
    influx_data = [{
        "measurement": "airquality",
        "tags": {
            "station": unidecode.unidecode(data_row[1]),
            "lat": float(data_row[2]),
            "long": float(data_row[3])
        },
        "time": data_row[4]+".00000Z",
        "fields": {
            'temp': 0,
            'so2': c_float(data_row[5]),
            'no': c_float(data_row[6]),
            'no2': c_float(data_row[7]),
            'co': c_float(data_row[8]),
            'pm10': c_float(data_row[9]),
            'o3': c_float(data_row[10]),
            'dd': c_float(data_row[11]),
            'vv': c_float(data_row[12]),
            'tmp': c_float(data_row[13]),
            'hr': c_float(data_row[14]),
            'prb': c_float(data_row[15]),
            'rs': c_float(data_row[16]),
            'll': c_float(data_row[17]),
            'ben': c_float(data_row[18]),
            'tol': c_float(data_row[19]),
            'mxil': c_float(data_row[20]),
            'pm25': c_float(data_row[21])
        }
    }]
    print (influx_data)
    db.write_points(influx_data)
