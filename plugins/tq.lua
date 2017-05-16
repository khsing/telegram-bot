do

local BASE_URL = "https://free-api.heweather.com/v5"
local CITY_HAS_US_AQI = {
  "北京",
  "成都",
  "广州",
  "上海",
  "沈阳"
}

local function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end


local function get_usaqi(city)
  local city = city:lower()
  local usaqi = nil
  local url = nil
  if city == "北京" or city == "beijing" then
    url = "http://www.stateair.net/web/rss/1/1.xml"
  elseif city == "成都" or city == "chengdu"  then
    url = "http://www.stateair.net/web/rss/1/2.xml"
  elseif city == "广州" or city == "guangzhou"  then
    url = "http://www.stateair.net/web/rss/1/3.xml"
  elseif city == "上海" or city == "shanghai" then
    url = "http://www.stateair.net/web/rss/1/4.xml"
  elseif city == "沈阳" or city == "shenyang" then
    url = "http://www.stateair.net/web/rss/1/5.xml"
  else
    return nil
  end
  local b, code = http.request(url)
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
  url = url..'/weather?key=b61f6ee2c9b9481ebaa7753fe22d40af'
  url = url..'&city='..location
  local b, c, h = https.request(url)
  -- print(b)
  if c ~= 200 then return nil end
  local weather = json:decode(b)["HeWeather5"][1]
  print(weather)
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
    if alarms then
      for i, alarm in ipairs(alarms) do
        temp = temp .. alarm.title .. ":" .. alarm.txt .. "\n"
      end
    end
    temp = temp .. "当地时间："..basic.update.loc.."\n"
    temp = temp .. "当前温度：" .. now.tmp .. "度，体感温度：".. now.fl .. "，天气：" .. now.cond.txt
    temp = temp .. "，风向：" .. now.wind.dir .. ", 风力：" ..now.wind.sc .. "\n"
    temp = temp .. "最高温度："..daily.tmp.max.."度".. "，最低温度："..daily.tmp.min.."度".."\n"
    -- temp = temp .. "风向："..daily.wind.dir.."，风力："..daily.wind.sc.."\n"
    if aqi then temp = temp .. "空气质量："..aqi.city.qlty.."，AQI："..aqi.city.aqi.."，PM2.5："..aqi.city.pm25.."\n" end
    if inTable(CITY_HAS_US_AQI, city) then
      temp = temp .. "美使馆数据：" .. get_usaqi(city) .. "\n"
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
  local city = matches[2]
  if not city then
    city = "Beijing"
  end
  local text = nil
  if cmd == '!tq' then
    text = get_weather(city)
  elseif cmd == '!usaqi' then
    text = get_usaqi(city)
  end
  if not text then
    text = '现阶段我真的不知道.'
  end
  return text
end


local function cron( ... )
  -- body
end

return {
  description = "weather in that city (Beijing is default)",
  usage = {
    "!tq (city)",
    "!usaqi (city)"
  },
  patterns = {
    "^(!tq)$",
    "^(!tq) (.*)$",
    "^(!usaqi)$",
    "^(!usaqi) (.*)"
  },
  run = run
}

end