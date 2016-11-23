require_relative 'spec_helper'


local_hostname = 'localhost'
## NOK, get hostname of system executing rspec...
#local_hostname = Socket.gethostbyname(Socket.gethostname).first 

describe file("/etc/prosody/conf.avail/#{local_hostname}.cfg.lua") do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should eq '644' }

  its('content') do
    should contain(
      "VirtualHost \"#{local_hostname}\"").before(
        'authentication = "anonymous"')
  end

  wanted_enabled_modules = %w(bosh pubsub ping)
  wanted_enabled_modules.each do |enabled_module|
    its('content') do
      should contain(
        enabled_module.to_s).from(
          /^\s+modules_enabled = \{/).to(
            /^\s+\}$/)
    end
  end
  its('content') do
    should contain(
      "VirtualHost \"auth.#{local_hostname}\"").before(
        'authentication = "internal_plain"')
  end

  wanted_config_line_pairs = {
    "VirtualHost \"auth.#{local_hostname}\"" => 'authentication = "internal_plain"',
    "Component \"conference.#{local_hostname}\" \"muc\"" =>
      "admins = { \"focus@auth.#{local_hostname}\" }",
    "Component \"jitsi-videobridge.#{local_hostname}\"" => 'component_secret = ',
    "Component \"focus.#{local_hostname}\"" => 'component_secret = '
  }
  wanted_config_line_pairs.each do |line1, line2|
    regexp1 = /#{Regexp.quote(line1)}/
    regexp2 = /#{Regexp.quote(line2)}/
    regexp = /^#{regexp1}\n\s+#{regexp2}/m
    describe command("cat /etc/prosody/conf.avail/#{local_hostname}.cfg.lua") do
      its('stdout') { should match(regexp) }
    end
  end

  describe command("luac -p /etc/prosody/conf.avail/#{local_hostname}.cfg.lua") do
    its('exit_status') { should eq 0 }
  end

  describe file("/var/lib/prosody/auth%2e#{local_hostname}") do
    it { should be_directory }
    it { should be_owned_by 'prosody' }
    it { should be_grouped_into 'prosody' }
    its('mode') { should eq '750' }
  end

  describe file("/var/lib/prosody/auth%2e#{local_hostname}/accounts/focus.dat") do
    it { should be_file }
    it { should be_owned_by 'prosody' }
    it { should be_grouped_into 'prosody' }
    its('mode') { should eq '640' }
    regexp = /^\s+\["password"\] = ".+";$/
    its('content') { should match(regexp) }
  end
end

describe command('prosodyctl about') do
  its('stdout') { should match(/Prosody 0\.9/) }
  its('stdout') { should match(/Lua version:/) }
  its('stdout') { should match(/Config directory:\s*\/etc\/prosody/) }
end

