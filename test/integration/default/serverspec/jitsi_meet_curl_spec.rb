require 'serverspec'

# Required by serverspec
set :backend, :exec


describe command('curl -v http://localhost/') do
  its('stderr') { should match "301 Moved Permanently" }
  its('stderr') { should match "Location: https://localhost:22443/" }
end
describe command('curl -vk https://localhost:22443/') do
  its('stderr') { should match "HTTP/1.1 200 OK" }
  its('stdout') { should match "<title>Jitsi Meet</title>" }
end

