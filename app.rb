require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'awesome_print'
require 'rest-client'
require 'firebase'
require 'slim'

if development?
  require 'dotenv'
  Dotenv.load
end

load 'lib/helpers.rb'

# Server configs
set :bind, '0.0.0.0'
set :public_folder, 'public'

# Preload data
WHITE_LIST_USERS = ENV['WHITELIST_USERS_CSV'].split(',')
FIREBASE_URI = ENV['FIREBASE_BASE_URL']
FIREBASE_CREDENTIALS_JSON = File.open('config/firebase.json').read
FIREBASE_CLIENT = Firebase::Client.new(FIREBASE_URI, FIREBASE_CREDENTIALS_JSON)

post '/' do
  # Parse body
  json = JSON.parse(request.body.read)
  ap json

  # Ignore unimportant messages
  return '' if !json['message']
  return '' if WHITE_LIST_USERS.include? json['message']['from']['username']

  # Clean up vars
  data = json['message']
  chat_id = data['chat']['id']
  message_id = data['message_id']
  from_username = data['from']['username']
  should_kill = false

  # Join & leave event
  if data['new_chat_members']
    should_kill = true
    begin
      pushNewUsersToFirebase(users_array: data['new_chat_members'])
    rescue => e
      p e
    end
  end

  if data['left_chat_member']
    should_kill = true
    begin
      pushLeavingUserToFirebase(user: data['left_chat_member'])
    rescue => e
      p e
    end
  end

  # Detect blacklist links
  txt = data['text']
  if !should_kill && txt =~ /https?:\/\/[\S]+/
    if txt =~ /ico\.triip\.me/
    else
      should_kill = true
      p "DETECTED BLACKLISTED LINKS : #{from_username} : #{txt}"
    end
  end

  # Detect bad words
  if !should_kill && txt =~ /fuck/
    should_kill = true
    p "DETECTED BLACKLISTED WORDS : #{from_username} : #{txt}"
  end

  # Delete message
  if should_kill
    begin
      deleteMessage(chat_id: chat_id, message_id: message_id)
      restrictMemberTemporarily(chat_id: chat_id, user_id: data['from']['id'])
    rescue => e
      p e
    end
  end

  'ok'
end

get '/webhook' do
  # call to set webhook with current request's host
  setWebhook
  # call to get actual value for visual confirmation after deploying on heroku
  @webHookInfo = telegramGet(function_name: 'getWebhookInfo', params: {})
  slim :webhook
end

private

def pushNewUsersToFirebase(users_array:)
  # Sample data from Telegram
  # "new_chat_members" => [
  #    [0] {
  #               "id" => 265343741,
  #           "is_bot" => false,
  #       "first_name" => "Kent",
  #        "last_name" => "Nguyen",
  #         "username" => "kentnguyen",
  #    "language_code" => "en-SG"
  #    }
  now = Time.now.to_i
  users_by_id = users_array.map do |u|
    u['updated_at'] = now
    ["users/#{u['id']}", u]
  end.to_h
  FIREBASE_CLIENT.update '', users_by_id
end

def pushLeavingUserToFirebase(user:)
  # Sample data from Telegram
  # "left_chat_member" => {
  #            "id" => 265343741,
  #        "is_bot" => false,
  #    "first_name" => "Kent",
  #     "last_name" => "Nguyen",
  #      "username" => "kentnguyen",
  # "language_code" => "en-SG"
  # }
  user['updated_at'] = Time.now.to_i
  FIREBASE_CLIENT.update '', {
    "users_left/#{user['id']}" => user
  }
  p "USER_LEFT : #{user['username']}"
end

def deleteMessage(chat_id:, message_id:)
  telegramPost(function_name: 'deleteMessage', params: {
    chat_id: chat_id,
    message_id: message_id
  })
end

def restrictMemberTemporarily(chat_id:, user_id:)
  telegramPost(function_name: 'restrictChatMember', params: {
    chat_id: chat_id,
    user_id: user_id,
    until_date: Time.now.to_i + ENV['GRACE_PERIOD'].to_i,
    can_send_messages: false,
    can_send_media_messages: false,
    can_send_other_messages: false
  })
end


# Misc
not_found do
  { error: 404 }.to_json
end

error 401 do
  { error: 401 }.to_json
end

error do
  { error: 500 }.to_json
end

