do

local BASE_URL = "https://api.heweather.com/x3/weather"

local function get_usaqi()
  local usaqi = nil
  local b, code = http.request("http://www.stateair.net/web/rss/1/1.xml")
  if c ~= 200 then
    return feedparser.parse(b).entries[1].summary
  else
    return nil
  end
end

local function get_weather(location)
  print("Finding weather in ", location)
  location = string.gsub(location," ","+")
  local url = BASE_URL
  url = url..'?city='..location
  url = url..'&key=b61f6ee2c9b9481ebaa7753fe22d40af'
  local b, c, h = http.request(url)
  if c ~= 200 then return nil end
  local weather = json:decode(b)["HeWeather data service 3.0"][1]
  if weather['status'] == 'ok' then
    local basic = weather["basic"]
    local aqi = weather["aqi"]
    local now = weather["now"]
    local daily = weather["daily_forecast"][1]
    local tomorrow = weather["daily_forecast"][2]
    local suggestion = weather["suggestion"]
    local alarms = weather["alarms"]
    local city = basic.city
    local country = basic.cnty
    local temp = country..', '..city.."天气：\n"
    -- if alarms:
    --   for i, alarm in ipairs(alarms) do
    --     temp = temp .. alarm.title .. ":" .. alarm.txt .. "\n"
    --   end
    -- end
    temp = temp .. "当地时间："..basic.update.loc.."\n"
    temp = temp .. "当前温度：" .. now.tmp .. "度，体感温度：".. now.fl .. "，天气：" .. now.cond.txt
    temp = temp .. "，风向：" .. now.wind.dir .. ", 风力：" ..now.wind.sc .. "\n"
    temp = temp .. "最高温度："..daily.tmp.max.."度".. "，最低温度："..daily.tmp.min.."度".."\n"
    -- temp = temp .. "风向："..daily.wind.dir.."，风力："..daily.wind.sc.."\n"
    if aqi then temp = temp .. "空气质量："..aqi.city.qlty.."，AQI："..aqi.city.aqi.."，PM2.5："..aqi.city.pm25.."\n" end
    if city == "北京" then
      temp = temp .. "美使馆数据：" .. get_usaqi() .. "\n"
    end
    if suggestion then temp = temp .. "舒适度："..suggestion.comf.brf.."，"..suggestion.comf.txt.."\n" end
    if tomorrow then
      temp = temp .. "明日预报("..tomorrow.date..")："
      temp = temp .. tomorrow.astro.sr .. " 日出 " ..tomorrow.astro.ss .. " 日落，"
      temp = temp .. "白天" .. tomorrow.cond.txt_d .. "，夜间" .. tomorrow.cond.txt_n .."，"
      temp = temp .. "最高温度" .. tomorrow.tmp.max .. "度，最低温度" .. tomorrow.tmp.min .. "度，"
      temp = temp .. "相对湿度" .. tomorrow.hum .. "%，"
      temp = temp .. "降水概率" .. tomorrow.pop .. "%，"
      temp = temp .. tomorrow.wind.dir .. "风" .. tomorrow.wind.sc .. "级，风速:" .. tomorrow.wind.spd .." kmph\n"
    end
    return temp
  else
    return "获取天气失败！"
  end
end

local function run(msg, matches)
  local cmd = matches[1]:lower()
  local keyword = matches[2]
  if cmd == '!tq' then
    if keyword then
      city = keyword
    else
      city = "Beijing"
    end
    local text = get_weather(city)
  elseif cmd == '!usaqi' then
    local text = get_usaqi()
  end
  if not text then
    text = '现阶段我真的不知道.'
  end
  return text
end

return {
  description = "weather in that city (Beijing is default)",
  usage = "!tq (city)",
  patterns = {
    "^!tq$",
    "^!tq (.*)$",
    "^!usaqi$"
  },
  run = run
}

end