name 'backend'
maintainer 'Sushil Chaudhari'
maintainer_email 'sushil@clearstack.io'
license 'Clearstack Inc All Rights Reserved'
description 'Installs/Configures Support Applications.'
long_description 'Installs/Configures OpenLDAP, Email, Index, File'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/backend/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/backend'

depends 'openldap'

depends 'apt'
depends 'ark'
depends 'java'

depends 'nfs'

depends 'm_newrelic'
depends 'hostname'

