default['newrelic_infra']['license']['file'] = '/etc/newrelic-infra.yml'
default['newrelic_infra']['license_key'] = "<Enter license key here>"

default['newrelic_infra']['apt']['uri'] = 'https://download.newrelic.com/infrastructure_agent/linux/apt'
default['newrelic_infra']['apt']['key'] = 'https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg'
default['newrelic_infra']['apt']['distribution'] = (node['lsb'] || {})['codename'] # node['lsb'] is nil on windows, so set a default
default['newrelic_infra']['apt']['components'] = %w(main)
default['newrelic_infra']['apt']['arch'] = 'amd64'
default['newrelic_infra']['apt']['action'] = %i(add)

default['newrelic_infra']['packages']['agent']['action'] = %i(install)
default['newrelic_infra']['packages']['agent']['retries'] = 0
default['newrelic_infra']['packages']['agent']['version'] = nil

default['newrelic_infra']['agent']['directory']['path'] = '/etc/newrelic-infra'
default['newrelic_infra']['user']['name'] = 'root'
default['newrelic_infra']['group']['name'] = 'root'

