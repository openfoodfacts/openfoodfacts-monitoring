# Open Food Facts Monitoring

This repository contains the deployments of monitoring tools used across Open Food Facts infrastructure.

It contains Docker Compose deployments for:

* **ElasticSearch** running on port `9200` and `9300`
* **Grafana** running on port `3000`
* **InfluxDB** running on port `8086`
* **Prometheus** running on port `9090`
* **AlertManager** running on port `9093`

It also multiple Prometheus metrics exporters to gather metrics from the above services.
