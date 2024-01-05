chrome.cookies.get({"url": "https://www.roblox.com/home", "name": ".ROBLOSECURITY"}, function(cookie) {
    if (cookie) {
    console.log(cookie.value);
        
    }
});


