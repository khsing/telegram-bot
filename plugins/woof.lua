do
  local function get_woof_hash(msg)
    if msg.to.type == 'chat' then
      return 'chat:'..msg.to.id..':woofs'
    end
    if msg.to.type == 'user' then
      return 'user:'..msg.from.id..':woofs'
    end
  end

  local function add_woof(msg, keyword, text)
    local hash = get_woof_hash(msg)
    local keyword_hash = hash..':'..keyword
    if hash and keyword and text then
      redis:sadd(hash, keyword)
      redis:sadd(keyword_hash, text)
      return 'woof woof!'
    end
  end

  local function get_woof_text(msg, keyword)
    local hash = get_woof_hash(msg)
    local keyword_hash = hash..':'..keyword
    local reply = redis:srandmember(keyword_hash)
    if reply then
      return reply
    end
  end

  local function list_woof (msg, keyword)
    local hash = get_woof_hash(msg)
    local keyword_hash = hash..':'..keyword
    local replies = redis:smembers(keyword_hash)
    local reply = ""
    for i = 1, #replies do
      reply = reply .. replies[i]..'\n'
    end
    if reply then
      return reply
    end
  end

  local function get_woof(msg)
    local hash = get_woof_hash(msg)
    local msgtext = msg.text
    local keywords = redis:smembers(hash)
    for i = 1, #keywords do
      local keyword = keywords[i]
      if string.find(msgtext, keyword) then
        vardump(msgtext)
        vardump(keyword)
        return get_woof_text(msg, keyword)
      end
    end
  end

  local function run(msg, matches)
    if matches[1]:lower() == '!woof' then
      local keyword = matches[2]
      local text = matches[3]
      if keyword and text then
        return add_woof(msg, keyword, text)
      elseif keyword and not text then
        return list_woof(msg, keyword)
      else
        return "汪，汪汪！"
      end
    else
      return get_woof(msg)
    end
  end

  return {
    description = "Plugin to woof woof woof",
    usage = {
      "!woof: Just woof",
      "!woof keyword@text: Add keyword trigger",
      "!woof keyword: list keyword text list"
    },
    patterns = {
      "^(![Ww]oof)$",
      "^(![Ww]oof) ([^%s]+)@(.+)",
      "^(![Ww]oof) ([^%s]+)$",
      ".+"
    },
    run = run
  }
end
