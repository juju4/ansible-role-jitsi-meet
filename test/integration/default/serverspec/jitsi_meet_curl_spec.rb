require_relative 'spec_helper'


describe command('curl -v http://localhost/') do
  its('stderr') { should match "301 Moved Permanently" }
  its('stderr') { should match "Location: https://localhost:22443/" }
end
describe command('curl -vkL http://localhost/http-bind') do
  its('stdout') { should match "It works! Now point your BOSH client to this URL to connect to Prosody." }
  its('stdout') { should_not match "404 Not Found" }
  its('stdout') { should_not match "Whatever you were looking for is not here. Where did you put it?" }
end
describe command('curl -v http://localhost:5280/http-bind') do
  its('stdout') { should match "It works! Now point your BOSH client to this URL to connect to Prosody." }
  its('stdout') { should_not match "404 Not Found" }
  its('stdout') { should_not match "Whatever you were looking for is not here. Where did you put it?" }
end
describe command('curl -vk https://localhost:22443/') do
  its('stderr') { should match "HTTP/1.1 200 OK" }
  its('stdout') { should match "<title>Jitsi Meet</title>" }
end

