[![Build Status](https://travis-ci.org/huit/puppet-ilmt.png?branch=master)](https://travis-ci.org/huit/puppet-ilmt)

ilmt

This module deploys the [IBM License Metric Tool](http://www-947.ibm.com/support/entry/portal/product/tivoli/ibm_license_metric_tool) agent on RHEL (and clone) systems.  You must either provide the module with a Puppet fileserver URI from which it can download the agent RPM, or you must take care of installing the package yourself; in this second case the only effect of this module will be to write a response file and store it in `/etc/response_file.txt`.

Support
-------

Please log tickets and issues at [GitHub](http://github.com/huit/puppet-ilmt/issues)
