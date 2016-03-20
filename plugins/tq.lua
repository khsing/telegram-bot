do

local BASE_URL = "https://api.heweather.com/x3/weather"

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
    local suggestion = weather["suggestion"]

    local city = basic.city
    local country = basic.cnty
    local temp = country..', '..city.."天气预报：\n"
    temp = temp .. "当地时间："..basic.update.loc.."\n"
    temp = temp .. "当前温度：" .. now.tmp .. "度，天气：" .. now.cond.txt
    temp = temp .. "，风向：" .. now.wind.dir .. ", 风力：" ..now.wind.sc .. "\n"
    temp = temp .. "最高温度："..daily.tmp.max.."度".. "，最低温度："..daily.tmp.min.."度".."\n"
    -- temp = temp .. "风向："..daily.wind.dir.."，风力："..daily.wind.sc.."\n"
    if aqi then temp = temp .. "空气质量："..aqi.city.qlty.."，AQI："..aqi.city.aqi.."，PM2.5："..aqi.city.pm25.."\n" end
    if suggestion then temp = temp .. "舒适度："..suggestion.comf.brf.."，"..suggestion.comf.txt.."\n" end
    return temp
  else
    return "获取天气失败！"
  end
end

local function run(msg, matches)
  local city = 'Beijing'

  if matches[1] ~= '!tq' then
    city = matches[1]
  end
  local text = get_weather(city)
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
    "^!tq (.*)$"
  },
  run = run
}

end
