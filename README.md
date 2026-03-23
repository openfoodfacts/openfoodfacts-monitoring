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
* **exporter_exporter** [^exporter_exporter] consolidates Prometheus metrics from services running on this node, exposing them on a single, secure endpoint.

PS: if you modify this, please keep [corresponding page in infrastructure](https://github.com/openfoodfacts/openfoodfacts-infrastructure/blob/develop/docs/observability.md) up to date

[^cadvisor]: https://prometheus.io/docs/guides/cadvisor/
[^filebeat]: https://www.elastic.co/fr/beats/filebeat
[^node_exporter]: https://prometheus.io/docs/guides/node-exporter/
[^exporter_exporter]: https://github.com/tcolgate/exporter_exporter

## Configs

* [Alerts](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/prometheus/alerts.yml)
* [Prometheus Scrape targets](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/prometheus/config.yml)

   Please read the comment on top of file to understand the various labels.

* [Grafana Dashboards](https://github.com/openfoodfacts/openfoodfacts-monitoring/tree/main/configs/grafana/dashboards)
* [Grafana Datasources](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/grafana/datasources/config.yml)
* [HTTP Probe Config](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/blackbox_exporter/config.yml)
* [Filebeat Config](https://github.com/openfoodfacts/openfoodfacts-monitoring/blob/main/configs/filebeat/config.yml)

## Local Development

When running locally different configs with a `-dev` suffix are used. These are generated from the production configs using the `update_dev_config.py` script. This script runs automatically as part of `make dev` and can be run manually with `make update_dev_config` (note that [uv](https://docs.astral.sh/uv/getting-started/installation/) needs to be installed locally to run this python script).

The script uses live probes where these are possible from outside of the production network. Internal probes, such as the `exporter_exporter`, are directed locally and track the metrics of any services that are running locally. Local equivalents are only created for production (`.org`) services. The original server name is retained for grouping.

### Testing blackbox exporter config locally

You can first start the blackbox exporter service:
`docker compose up blackbox-exporter`
Look at the log, it may tell about errors in the config.

You can then test a probe manually, you must pass as parameter the `target` (the URL to probe),
and the `module` used to probe it. Adding `debug=true` will help you debug the probe.

For example:
http://127.0.0.1:9115/probe?target=https://prometheus.openfoodfacts.org/&module=http_probe_auth_monitoring&debug=true will probe `http://prometheus.openfoodfacts.org` with the `http_probe_auth_monitoring` module.

Look at the `probe_success` metrics to see if the probe succeeded.