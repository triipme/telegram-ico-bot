# Set Telegram webhook with current request's host
def setWebhook
# https://api.telegram.org/bot#{token}/getWebhookInfo
  url = "https://api.telegram.org/bot#{ENV['BOT_TOKEN']}/setWebhook"
  RestClient.post(url, {url: request.base_url})
  "WEBHOOK configured to url: " + request.base_url
end

# Telegram GET wrapper
def telegramGet(function_name:, params:)
  url = "https://api.telegram.org/bot#{ENV['BOT_TOKEN']}/#{function_name}"
  begin
    response = RestClient.get(url, params: params)
    json = JSON.parse(response.body)
    return json['result']
  rescue => e
    p e.response.body
  end
end

# Telegram POST wrapper
def telegramPost(function_name:, params:)
  url = "https://api.telegram.org/bot#{ENV['BOT_TOKEN']}/#{function_name}"
  begin
    response = RestClient.post(url, params)
    return JSON.parse(response.body)
  rescue => e
    p e.response.body
  end
end
