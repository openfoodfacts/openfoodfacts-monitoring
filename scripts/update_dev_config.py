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

import os
import sys

from ruyaml import YAML
import shutil
import pathlib

PROMETHEUS_CONFIG = "configs/prometheus"
PROMETHEUS_DEV_CONFIG = "configs/prometheus-dev"
EXPORTER_EXPORTER_CONFIG = 'configs/exporter_exporter'
EXPORTER_EXPORTER_DEV_CONFIG = f"{EXPORTER_EXPORTER_CONFIG}/dev"
EXPORTER_EXPORTER_DEV_URL = "http://host.docker.internal:8202/"

pathlib.Path(EXPORTER_EXPORTER_DEV_CONFIG).mkdir(parents=True, exist_ok=True) 
shutil.copytree(PROMETHEUS_CONFIG, PROMETHEUS_DEV_CONFIG, dirs_exist_ok=True)

# Note that comments aren't always removed cleanly as they can sometimes get attached
# to the wrong node. Could use typ="safe" here to not load any comments 
# but it makes the resulting output quite difficult to read
yaml = YAML()
yaml.indent(mapping=2, sequence=4, offset=2)

with open(f"{PROMETHEUS_CONFIG}/config.yml", "r", encoding="utf-8") as f:
    prometheus_config = yaml.load(f)

for key, value in prometheus_config.items():
    if key == "scrape_configs":
        for j in range(len(value) - 1, -1, -1):
            scrape_config = value[j]
            # Remove config for legacy infrastructure that we can't test in dev
            if scrape_config["job_name"] in ["free-exporters", "ks1-exporters"]:
                value.pop(j)

            elif "scheme" in scrape_config:
                # Assume it is an exporter_exporter
                scrape_config.pop("scheme") # Revert to default of http
                scrape_config.pop("basic_auth", None) # No authentication for local connection
                static_configs = scrape_config.get("static_configs", [])
                for s in range(len(static_configs) - 1, -1, -1):
                    server = static_configs[s]
                    labels = server["labels"]
                    # Don't include staging exporters as we only emulate production locally
                    if labels["env"] == "staging":
                        static_configs.pop(s)
                    else:
                        server_name = labels["server"]
                        # Create a dev exporter_exporter config for each target referenced for the server
                        for target in server["targets"]:
                            config_name = f"{EXPORTER_EXPORTER_CONFIG}/{server_name}/{target.split('/')[0]}.yaml"
                            if os.path.exists(config_name):
                                shutil.copy(config_name, EXPORTER_EXPORTER_DEV_CONFIG)
                            else:
                                print(f"*** exporter_exporter config not found for {server_name}: {target}", file=sys.stderr)

                        # Point all exporter_exporter configs to the local URL
                        labels["base_url"] = EXPORTER_EXPORTER_DEV_URL

                        # Not sure whether to do this as may affect dashboards
                        # labels["env"] = "localhost"
    
with open(f"{PROMETHEUS_DEV_CONFIG}/config.yml", "w", encoding="utf-8") as f:
    yaml.dump(prometheus_config, f)