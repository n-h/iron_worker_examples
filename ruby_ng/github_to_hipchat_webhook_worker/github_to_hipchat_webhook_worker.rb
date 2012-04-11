require 'cgi'
require 'yaml'
require 'hipchat-api'

# the payload we get from github needs to be decoded first
cgi_parsed = CGI::parse(payload)
log "cgi_parsed: #{cgi_parsed.inspect}"

# Then we can parse the json
parsed = JSON.parse(cgi_parsed['payload'][0])
log "parsed: #{parsed.inspect}"

# Also parse the config we uploaded with this worker for our Hipchat stuff
webhook_config = YAML.load_file('webhook_config.yml')
log "webhook_config: #{webhook_config.inspect}"

hipchat = HipChat::API.new(webhook_config['hipchat']['api_key'])
# Go through each commit and post a message to the chat room
parsed['commits'].each do |c|
  log hipchat.rooms_message(webhook_config['hipchat']['room'], 'WebhookWorkerNG', "Rev: <a href=\"#{c['url']}\">#{c['id'][0,9]}</a> - #{c['message']}", true).body
end
