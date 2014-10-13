# Foreman Docker Plugin

This plugin enables provisioning and managing Docker containers and images in Foreman.

## Installation

Please see the Foreman manual for appropriate instructions:

* [Foreman: How to Install a Plugin](http://theforeman.org/manuals/latest/index.html#6.1InstallaPlugin)

The gem name is "foreman_docker".

RPM users can install the "ruby193-rubygem-foreman_docker" or "rubygem-foreman_docker" packages.

## Compatibility

| Foreman Version | Plugin Version |
| ---------------:| --------------:|
| >=  1.5         | 0.0.1          |

## Testing

Run `rake test:docker:test` from your Foreman directory to run the test suite.

## Latest code

You can get the develop branch of the plugin by specifying your Gemfile in this way:

    gem 'foreman_docker', :git => "https://github.com/theforeman/foreman-docker.git"

# Copyright

Copyright (c) 2014 Amos Benari

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
