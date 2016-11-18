require 'serverspec'

# Required by serverspec
set :backend, :exec

describe file('/etc/jitsi/jicofo/config') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should eq '644' }
  its('content') { should match(/^JICOFO_HOST=localhost$/) }
  its('content') { should match(/^JICOFO_PORT=5347$/) }
  # The regex for the "secret" may be off. Tests have failed before
  # when matching only '\w', due to a '@', so adding that.
  its('content') { should match(/^JICOFO_SECRET=.+{8,}$/) }
  its('content') { should match(/^JICOFO_AUTH_PASSWORD=.+{8,}$/) }
  its('content') { should match(/^JICOFO_AUTH_USER=focus$/) }
end

describe file('/etc/jitsi/jicofo/logging.properties') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should eq '644' }
  its('content') { should match(/^\.level=INFO$/) }
end

describe service('jicofo') do
  it { should be_enabled }
  it { should be_running }
end

describe port(5347) do
  it { should be_listening }
  it { should be_listening.on('127.0.0.1') }
  it { should_not be_listening.on('0.0.0.0') }
end

# Check that jicofo process is running as jicofo user
describe command('pgrep -u jicofo | wc -l') do
  its('stdout') { should eq "1\n" }
end

describe command('sudo netstat -nlt') do
  its('stdout') { should match(/127\.0\.0\.1:5347/) }
  its('stdout') { should_not match(/0\.0\.0\.0:5347/) }
end
