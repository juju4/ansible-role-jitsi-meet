require 'spec_helper'

nginx_https_port = 22443
local_hostname = 'localhost'
## NOK, get hostname of system executing rspec...
#local_hostname = Socket.gethostbyname(Socket.gethostname).first 

describe package('nginx'), :if => os[:family] == 'ubuntu' && os[:release] == '16.04' do
  it { should be_installed }
  its('version') { should >= '1.6.2-5' }
end
describe package('nginx'), :if => os[:family] == 'ubuntu' && os[:release] == '14.04' do
  it { should be_installed }
  its('version') { should >= '1.4.6' }
end

describe file("/etc/nginx/sites-available/#{local_hostname}.conf") do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode') { should eq '644' }

  ssl_regexes = [
    %r{^\s+ssl_certificate /var/lib/prosody/#{local_hostname}.crt;$},
    %r{^\s+ssl_certificate_key /var/lib/prosody/#{local_hostname}.key;$}
  ]
  ssl_regexes.each do |ssl_regex|
    its('content') { should match(ssl_regex) }
  end
end

describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

nginx_ports = [ 80, nginx_https_port ]
nginx_ports.each do |nginx_port|
  describe port(nginx_port) do
    it { should be_listening }
    it { should be_listening.on('0.0.0.0').with('tcp') }
    it { should_not be_listening.on('127.0.0.1') }
  end
end

# Check that nginx process is running as nginx user
#describe command('pgrep -u www-data | wc -l') do
  # The default jitsi-meet config sets 4 workers
  ## FIXME! 'etc/nginx/nginx.conf:2:worker_processes auto;'. have 2 on lxd containers
  #its('stdout') { should eq "4\n" }
#  its('stdout') { should >= 2 }
#end
context 'worker' do
  it "should be greater than #{2}" do
    expect(`pgrep -u www-data | wc -l`.to_i).to be >= 2
  end 
end

describe command('sudo netstat -nlt') do
  its('stdout') { should_not match(/127\.0\.0\.1:80/) }
  its('stdout') { should_not match(/127\.0\.0\.1:#{nginx_https_port}/) }
  its('stdout') { should match(/0\.0\.0\.0:80/) }
  its('stdout') { should match(/0\.0\.0\.0:#{nginx_https_port}/) }
end
