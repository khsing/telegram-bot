do
  local function get_woof_hash(msg)
    if msg.to.type == 'chat' then
      local chatid = msg.to.id
      if chatid == '118298178' then
         chatid = '2526166'
      end
      return 'chat:'..chatid..':woofs'
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
      return '🐶^o^!'
    end
  end

  local function get_woof_text(msg, keyword)
    local hash = get_woof_hash(msg)
    local keyword_hash = hash..':'..keyword
    local datehash = keyword_hash .. ':' .. os.date("%Y%m%d%H")
    local replied = redis:get(datehash)
    local reply = redis:srandmember(keyword_hash)
    if reply and not replied then
      redis:setex(datehash, 3600, "1")
      return reply
    end
  end

  local function list_woof(msg, keyword)
    local hash = get_woof_hash(msg)
    local keyword_hash = hash..':'..keyword
    local replies = redis:smembers(keyword_hash)
    local reply = keyword .. ":\n"
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
        return get_woof_text(msg, keyword)
      end
    end
  end

  local function pop_woof(msg, keyword, text)
    local hash = get_woof_hash(msg)
    local keyword_hash = hash..':'..keyword
    if hash and keyword and text then
      redis:srem(keyword_hash, text)
      return "🐶🤐"
    end
  end

  local function run(msg, matches)
    local command = matches[1]:lower()
    local keyword = matches[2]
    local text = matches[3]
    if command == '!woof' then
      if keyword and text then
        return add_woof(msg, keyword, text)
      elseif keyword and not text then
        return list_woof(msg, keyword)
      else
        return "🐶🐶"
      end
    elseif command == "!unwoof" then
      if keyword and text then
        return pop_woof(msg, keyword, text)
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
      "!unwoof keyword@text: remove keyword trigger",
      "!woof keyword: list keyword text"
    },
    patterns = {
      "^(!woof)$",
      "^(!woof) (.+)@(.+)",
      "^(!unwoof) (.+)@(.+)",
      "^(!woof) (.+)$",
      "^[^!].+"
    },
    run = run
  }
end