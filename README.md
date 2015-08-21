# Foreman Docker Plugin

[![Code Climate](https://codeclimate.com/github/theforeman/foreman-docker/badges/gpa.svg)](https://codeclimate.com/github/theforeman/foreman-docker)
[![Gem Version](https://badge.fury.io/rb/foreman_docker.svg)](http://badge.fury.io/rb/foreman_docker)
[![Dependency Status](https://gemnasium.com/theforeman/foreman-docker.svg)](https://gemnasium.com/theforeman/foreman-docker)
[![Issue Stats](http://issuestats.com/github/theforeman/foreman-docker/badge/pr)](http://issuestats.com/github/theforeman/foreman-docker)

```foreman_docker``` enables provisioning and managing of [Docker](http://docker.com) containers and images in [Foreman](http://github.com/theforeman/foreman), all of that under the GPL v3+ license.

* Website: [TheForeman.org](http://theforeman.org)
* ServerFault tag: [Foreman](http://serverfault.com/questions/tagged/foreman)
* Issues: [foreman_docker Redmine](http://projects.theforeman.org/projects/docker/issues)
* Wiki: [Foreman wiki](http://projects.theforeman.org/projects/foreman/wiki/About)
* Community and support: #theforeman for general support, #theforeman-dev for development chat in [Freenode](irc.freenode.net)
* Mailing lists:
    * [foreman-users](https://groups.google.com/forum/?fromgroups#!forum/foreman-users)
    * [foreman-dev](https://groups.google.com/forum/?fromgroups#!forum/foreman-dev)

## Features

* Special view with logs and processes of Foreman managed containers
    ![](http://i.imgur.com/D21bdgj.png)
    ![](http://i.imgur.com/XnrPTZC.png)
* Wizard for container creation and cgroups configuration
    ![Select a docker image](http://i.imgur.com/IoMuNnr.png)
    ![Cgroups configuration](http://i.imgur.com/74d99Tf.png)
* Commit and upload containers: creates an image with the status of your current container
    ![Commit and upload to the docker hub](http://i.imgur.com/coF5Y0L.png)
* Container listing and basic CRUD operations
    ![](http://i.imgur.com/DPcaHkZ.png)

### Planned
* [Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes/) integration
* Events stream ([#8037](http://projects.theforeman.org/issues/8037))
* Tight integration between Docker hosts [Atomic](http://www.projectatomic.io/) and [CoreOS](http://coreos.com/) and containers ([#7653](http://projects.theforeman.org/issues/7653), [#7652](http://projects.theforeman.org/issues/7652))
* Quickstart images - pre-supplied images and configuration ([#7869](http://projects.theforeman.org/issues/7869))
* Links to other containers ([#7866](http://projects.theforeman.org/issues/7866))
* API ([#7874](http://projects.theforeman.org/issues/7874))
* [Hammer CLI](http://github.com/theforeman/hammer-cli-foreman) support ([#8227](http://projects.theforeman.org/issues/8227))

## Installation

Please see the Foreman manual for appropriate instructions:

* [Foreman: How to Install a Plugin](http://theforeman.org/manuals/latest/index.html#6.1InstallaPlugin)

### Red Hat, CentOS, Fedora, Scientific Linux (rpm)

Set up the repo as explained in the link above, then run

    # yum install ruby193-rubygem-foreman_docker

### Debian, Ubuntu (deb)

Set up the repo as explained in the link above, then run

    # apt-get install ruby-foreman-docker

### Bundle (gem)

Add the following to bundler.d/Gemfile.local.rb in your Foreman installation directory (/usr/share/foreman by default)

    $ gem 'foreman_docker'

Then run `bundle install` and `foreman-rake db:migrate` from the same directory

--------------

To verify that the installation was successful, go to Foreman, top bar **Administer > About** and check 'foreman_docker' shows up in the **System Status** menu under the Plugins tab. You should also see a **'Containers'** button show up in the top bar, similar to this

![](http://i.imgur.com/Ug14Ktl.png)

## Configuration

Go to **Infrastructure > Compute Resources** and click on "New Compute Resource".

Choose the **Docker provider**, and fill in all the fields. User name, password, and email are used so that Docker clients such as Foreman can make the host download images from the Docker hub. Your password will be encrypted in the database.

That's it. You're now ready to create and manage containers in your new Docker compute resource.

## Compatibility

| Foreman | Plugin |
| ---------------:| --------------:|
| >= 1.5         | 0.0.1 - 0.0.3   |
| >= 1.6         | 0.1.0 - 0.2.0   |
| >= 1.7         | 1.0.0+          |

See extras/RELEASE.md for more detailed information on compatibility and releases.

## How to contribute?

Generally, follow the [Foreman guidelines](http://theforeman.org/contribute.html). For code-related contributions, fork this project and send a pull request with all changes. Some things to keep in mind:
* Code from the master branch can contain features only present in [Fog's](http://github.com/fog/fog) master branch, we commit to wait for the next Fog release to put that code in a foreman-docker release.
* [Follow the rules](http://theforeman.org/contribute.html#SubmitPatches) about commit message style and create a Redmine issue. Doing this right will help reviewers to get your contribution merged faster.
* [Rubocop](https://github.com/bbatsov/rubocop) will analyze your code, you can run it locally with `rake rubocop`.
* All of our pull requests run the full test suite in our [Jenkins CI system](http://ci.theforeman.org/). Please include tests in your pull requests for any additions or changes in functionality


### Testing

Run `rake test:docker` from your Foreman directory to run the test suite.

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

