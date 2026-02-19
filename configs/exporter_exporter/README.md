# Exporter exporter config

See https://github.com/tcolgate/exporter_exporter

The mods_available contains a list of exporter configuration to proxy.

The default folder is default modules enabled.

You can create a specifc directory for a VM,
and configure it with `EXPORTER_EXPORTER_CONFIG_DIR` variable.

The directories can contains symlinks to `mods_available`
in the form: `../mods_available/<module_name.yaml>`

If you module is specific in any way (eg. a hard-coded ip address),
just put the file directly in the specific folder.