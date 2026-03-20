"""
Generates the development configuration used for testing monitoring configuration changes locally.

This script uses uv to load dependencies. To install uv run:

curl -LsSf https://astral.sh/uv/install.sh | sh

To run the script use:

uv run scripts/update_dev_config.py
"""

# /// script
# dependencies = [
#   'ruyaml'
# ]
# ///

from ruyaml import YAML
import shutil

shutil.copytree("configs/prometheus", "configs-dev/prometheus", dirs_exist_ok=True)
# Note that comments aren't always removed cleanly as they can sometimes get attached
# to the wrong node. Could use typ="safe" here to not load any comments 
# but it makes the resulting output quite difficult to read
yaml = YAML()
yaml.indent(mapping=2, sequence=4, offset=2)

with open("configs/prometheus/config.yml", "r", encoding="utf-8") as f:
    prometheus_config = yaml.load(f)

for key, value in prometheus_config.items():
    if key == "scrape_configs":
        for j in range(len(value) - 1, -1, -1):
            scrape_config = value[j]
            if scrape_config["job_name"] in ["free-exporters", "ks1-exporters"]:
                value.pop(j)
            elif "scheme" in scrape_config:
                # Assume it is an exporter_exporter
                scrape_config.pop("scheme") # Revert to default of http
                scrape_config.pop("basic_auth", None)
                static_configs = scrape_config.get("static_configs", [])
                for s in range(len(static_configs) - 1, -1, -1):
                    server = static_configs[s]
                    labels = server["labels"]
                    if labels["env"] == "staging":
                        static_configs.pop(s)
                    else:
                        # TODO copy exporter_export config for the server
                        labels["base_url"] = "http://host.docker.internal:8202"
                        # Not sure whether to do this as may affect dashboards
                        # labels["env"] = "localhost"
    
with open("configs-dev/prometheus/config.yml", "w", encoding="utf-8") as f:
    yaml.dump(prometheus_config, f)