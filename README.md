# Air Quality Gijón
*Monitoring Air Quality Open Data with Docker + InfluxDB + Grafana*

Air Quality Gijón is a multi container Docker application which takes the air quality info from the open data portal of the City of Gijón and shows it in a Grafana dashboard.

*Air Quality [open data of the City of Gijón](https://transparencia.gijon.es/set/medio-ambiente/calidad_aire_ultimos) is provided in different formats under a Creative Commons Attribution 3.0 License*

## Installation/Usage

The project relies in docker and docker-compose. Please, be sure that you have installed:

  * Docker: <https://www.docker.io>
  * Docker-compose: <https://docs.docker.com/compose/install/>

Once docker and docker-compose are installed, clone or download this repository and just execute `docker-compose up` . Docker-compose will download all required images and build the composed multi container application.

After some time downloading and composing things, you should be able to connect to to [http://localhost:3000/dashboard/db/gijon-calidad-del-aire](http://localhost:3000/dashboard/db/gijon-calidad-del-aire) (user: admin / pass: admin) and see the result.

## Notes

### Loading data from previous years (before building the application)
By default only the data from the current year is loaded. In case you want to insert in the database also previous years, you  have to modify the value of the variable `AQ_YEARS` in `airquality.env` file before launching `docker-compose up` (Note that loading a complete year takes time)

### Loading data to the databases once the application is running

In case you want to load in the database data for other years **once the container has been started**, you can use the next command to load JSON files.

    docker exec airquality /airquality/aq_load.sh “<<URL>>"

e.g for the data from 2016

    docker exec airquality /airquality/aq_load.sh “http://opendata.gijon.es/descargar.php?id=23&tipo=JSON"

You can find the ids of the files to download [here](https://transparencia.gijon.es/search/risp_dataset/page/1808-catalogo-de-datos?utf8=%E2%9C%93&search=Calidad+del+aire)

### Updating the data once the application is running

In case you want to have the data updated hourly, the recommentation is to add in the crontab (or in your operating system job scheduler) of the host, calls to:

    docker exec airquality /airquality/aq_load.sh last

once every hour, and

    docker exec airquality /airquality/aq_load.sh validated

once a week.

## Result
Once everything is ready you should see a dashboard like this:

![Air Quality Gijón](https://raw.githubusercontent.com/rubfi/air-quality-gijon/master/img/Gijon-CalidadDelAire.png)

