require 'serverspec'

# Required by serverspec
set :backend, :exec


describe package('jitsi-meet') do
  it { should be_installed }
end

describe package('default-jre-headless') do
  it { should be_installed }
end

## FIXME! hostname is not set but expected to match
describe command('echo "get jitsi-meet/jvb-hostname" | \
                  debconf-communicate') do
  its('stdout') { should eq "0 localhost\n" }
end

describe command('echo "get jitsi-meet/jvb-serve" | \
                  debconf-communicate') do
  its('stdout') { should eq "0 false\n" }
end

describe command('echo "get jitsi-meet-prosody/jvb-hostname" | \
                  debconf-communicate') do
  its('stdout') { should eq "0 localhost\n" }
end

describe file('/etc/jitsi/meet/localhost-config.js') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should eq '644' }
  its('content') { should match(/^\s+domain: 'localhost',/) }
  its('content') { should match(/^\s+muc: 'conference\.localhost',/) }
  its('content') { should match(/^\s+bridge: 'jitsi-videobridge\.localhost',/) }
  its('content') { should match(%r{^\s+bosh: '//localhost/http-bind',}) }
  its('content') { should match(/^\s+disableThirdPartyRequests: true,/) }
end
