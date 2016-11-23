require 'spec_helper'

if ENV.has_key?('SERVERSPEC_JITSI_CUSTOM')

  describe file('/var/www/jitsi-custom/interface_config.js') do
    it { should be_file }
    its('mode') { should eq '644' }
  end

end

