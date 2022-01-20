# Open Food Facts Monitoring

This repository contains the deployments of monitoring tools used across Open Food Facts infrastructure.

It contains Docker Compose deployments for:

* **ElasticSearch** running on port `9200` and `9300`
* **Grafana** running on port `3000`
* **Kibana** running on port `5601`
* **InfluxDB** running on port `8086`
* **Prometheus** running on port `9090`
* **AlertManager** running on port `9093`

It also multiple Prometheus metrics exporters to gather metrics from the above services.

## Configs

* [Alerts](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/prometheus/alerts.yml)
* [Prometheus Scrape targets](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/prometheus/config.yml)
* [Grafana Dashboards](https://github.com/openfoodfacts/openfoodfacts-monitoring/tree/main/configs/grafana/dashboards)
* [Grafana Datasources](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/grafana/datasources/config.yml)
* [HTTP Probe Config](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/blackbox_exporter/config.yml)
* [Filebeat Config](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/filebeat/config.yml)
