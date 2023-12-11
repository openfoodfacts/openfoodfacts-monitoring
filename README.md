# Open Food Facts Monitoring

This repository contains the deployments of monitoring tools used across Open Food Facts infrastructure.

See [Infrastructure / Observability](https://openfoodfacts.github.io/openfoodfacts-infrastructure/observability/) for more documentation.

It contains Docker Compose deployments for services deployed on monitoring server:

* **ElasticSearch** (for gathering logs) running on port `9200` and `9300`
* **Kibana** (to access elasticsearch thus logs) running on port `5601`
* **InfluxDB** (metrics database) running on port `8086`
* **Grafana** (dashboards and graphics from metrics) running on port `3000`
* **Prometheus** (metrics and monitoring) running on port `9090`
* **AlertManager** (automatic alerts triggering) running on port `9093`

> :pencil: there is another InfluxDB and Grafana for "business" metrics,
> see [openfoodfacts-infrastructure:docker/metrics](https://github.com/openfoodfacts/openfoodfacts-infrastructure/tree/develop/docker/metrics)

It also contains exporters that should be deployed on each nodes (see `docker-compose.node.yml`):
* **filebeat** [^filebeat] gather logs and send them to **Elasticsearch**
* **cadvisor** [^cadvisor] gather docker metrics
* **node_exporter** [^node_exporter] gather host metrics

PS: if you modify this, please keep [corresponding page in infrastructure](https://github.com/openfoodfacts/openfoodfacts-infrastructure/blob/develop/docs/observability.md) up to date

[^cadvisor]: https://prometheus.io/docs/guides/cadvisor/
[^filebeat]: https://www.elastic.co/fr/beats/filebeat
[^node_exporter]: https://prometheus.io/docs/guides/node-exporter/

## Configs

* [Alerts](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/prometheus/alerts.yml)
* [Prometheus Scrape targets](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/prometheus/config.yml)
* [Grafana Dashboards](https://github.com/openfoodfacts/openfoodfacts-monitoring/tree/main/configs/grafana/dashboards)
* [Grafana Datasources](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/grafana/datasources/config.yml)
* [HTTP Probe Config](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/blackbox_exporter/config.yml)
* [Filebeat Config](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/filebeat/config.yml)
