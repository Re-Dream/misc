YT = {}

YT.Key = file.Read("googleapikey.txt", "DATA") --insert key here

local function char_to_pchar(c)
	return string.format("%%%02X", c:byte(1,1))
end

local function encodeURI(str)
	return (str:gsub("[^%;%,%/%?%:%@%&%=%+%$%w%-%_%.%!%~%*%'%(%)%#]", char_to_pchar))
end

YT.Search = function(wordsandstuff, callback)
	http.Fetch("https://www.googleapis.com/youtube/v3/search?part=id&type=video&key="..YT.Key.."&q="..encodeURI(wordsandstuff), function(body,len,heads)
		callback(body,len,heads)
	end, function(err)
		callback(false)
		return false,err
	end)
end

YT.GetInfo = function(videoid, callback)
	http.Fetch("https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&key="..YT.Key.."&id="..videoid, function(body,len,heads)
		callback(body,len,heads)
	end, function(err)
		callback(false)
		return false,err
	end)
end

YT.GetContentDetails = function(videoid, callback)
	http.Fetch("https://www.googleapis.com/youtube/v3/videos?part=contentDetails&key="..YT.Key.."&id="..videoid, function(body,len,heads)
		callback(body,len,heads)
	end, function(err)
		callback(false)
		return false,err
	end)
end
