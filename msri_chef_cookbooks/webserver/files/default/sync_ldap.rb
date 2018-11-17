#!/usr/bin/env ruby
gem "bugsnag"

require 'net/http'
require 'uri'
require 'fileutils'

require 'bugsnag'
Bugsnag.configure do |config|
  config.api_key = "ad8ff91dc709e6521a31266f9846aac6"
  config.release_stage = "production"
end


#msri_url='https://www.msri.org'
msri_url='http://www.msri.org'
msri_rails_root='/opt/msri/apps/www/current'
user_email = 'ajaya@clearstack.io'
user_token = 'zp7gqkfWP35a56tBAxrR'

ldap_host='directory.msri.org'
ldap_admin='cn=admin,dc=msri,dc=org'
ldap_admin_password = 'msrinextgen'

Dir.chdir("#{msri_rails_root}/tmp")
Dir.glob("*.resync") do |filename|
  type = File.basename(filename, '.resync')

  begin
    uri = URI.parse("#{msri_url}/#{type}.ldif?user_email=#{user_email}&user_token=#{user_token}")
    #http = Net::HTTP.new(uri.host, uri.port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #response = http.get(uri.request_uri)  #Net::HTTP.get_response uri
    response = Net::HTTP.get_response uri

    File.open("#{type}.ldif", 'w') { |file| file.write(response.body) }
    system("ldapadd -x -h #{ldap_host} -D #{ldap_admin} -w #{ldap_admin_password} -c -f #{type}.ldif")

    FileUtils.mv "#{type}.ldif", "#{msri_rails_root}/log/#{type}.ldif.#{Time.now}"
    FileUtils.rm_f("#{type}.resync")

  rescue Exception => e
    Bugsnag.notify(e)
  end

end
