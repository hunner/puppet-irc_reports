puppet-irc\_reports
==================

Description
-----------

A Puppet report handler for sending notifications of failed runs to IRC.

Requirements
------------

* `puppet` (version 2.6.5 and later)

Installation & Usage
--------------------

1. Install `puppet-irc_reports` as a module in your Puppet master's module path.

1. Include `irc_reports` on your puppet master.

1. Enable pluginsync and reports on your master and clients in `puppet.conf`

    [master]
        reports = irc
    [agent]
        report = true
        pluginsync = true

1. Run the Puppet client and sync the report as a plugin

Based on
--------

puppet-irc by James Turnbull <james@lovedthanlost.net>

License
-------

    License:: Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
