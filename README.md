## Telegram Bot for ICO purpose

This is a special-purpose Bot for processing messages in Telegram Group/Super Group within ICO context.
The goal is to fight potential scammers by:

- Make it harder to get members' usernames in the group
- Ban any links (or blacklisted links) being posted on discussion group

The button below makes it super easy to get started by deploying on Heroku free dyno:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

This initial codebase was written in a night, probably [CUI](http://brej.org/edit/influence/), so feel free to contribute and make this rudimentary Bot much better.

Let's **fight scammers together**!

Made for [ico.triip.me](https://ico.triip.me) by [Kent Nguyen](github.com/kentnguyen)

---

### Bot In action

![Join](https://raw.githubusercontent.com/triipme/telegram-ico-bot/master/public/screenshot_hide_joined.jpeg)

![Ban](https://raw.githubusercontent.com/triipme/telegram-ico-bot/master/public/screenshot_temp_ban.jpeg)

---

### Current features

- Delete member joined/left event notification.
- Whitelist users by username, these users can post anything.
- Do not allow new member to chat for *X minutes*.
- Detect any URL links, and ban users for *X minutes*.
- Detect vulgar words, and ban users for *X minutes*.
- Store users on Firebase database when joined/left, as Telegram does not have this API to get data.

### Wishlist (help, please!)

- Auto PM new member with a template message.
- Auto post periodically.
- Improve error-handling.
- Unit tests LOL!

### Technical

- Deployed on Heroku
- Ruby 2.5 with Sinatra framework
- HTTPS Webhook called by Telegram
- Auto set webhook by GET `/webhook` with proper host on browser

### File structure

All logics are contained within these files:

    app.rb
    config/helpers.rb

The rest are miscellaneous framework files necessary for running on Heroku.

---

### Setup local development environment

- Change values in `.env` file.
- Follow instructions in `config/firebase.json` to config link with Firebase.
- Start server with `ruby app.rb`.
- User local tunneling such as `ngrok` to create a public URL.
- Load `/webhook` in browser with public URL.
