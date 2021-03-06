# ForemanSpecificTemplate

This plug-in adds a template chooser endpoint to [The Foreman](https://theforeman.org/) for usage with systems that require different boot actions.

For instance; Windows installations.

## Compatibility

| Foreman Version | Plugin Version |
| --------------- | -------------- |
| >= 1.14         | any            |

## Installation

See [Plugins install instructions](https://theforeman.org/plugins/)
for how to install Foreman plugins.

## Usage

**NB**: This plugin only allows deploying PXE templates for hosts currently in build mode.

```
# Deploy 'PXELinux default local boot' for this host
curl "http://foreman.example.com/specifictemplate/set?template_name=PXELinux%20default%20local%20boot"
curl "http://foreman.example.com/unattended/specifictemplate?template_name=PXELinux%20default%20local%20boot"

# Deploy the local boot template for this host
curl "http://foreman.example.com/unattended/specifictemplate?template_type=local"
# Deploy the default boot template for this host
curl "http://foreman.example.com/unattended/specifictemplate?template_type=default"

# Restore this host to the default PXE template
curl http://foreman.example.com/specifictemplate/set
curl http://foreman.example.com/unattended/specifictemplate
```

## Copyright

Copyright (c) 2017 Alexander Olofsson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

