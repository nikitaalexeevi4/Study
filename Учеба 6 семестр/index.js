var TelegramBot = require('node-telegram-bot-api');
var request = require('request'), cheerio = require('cheerio');
var token = '358948313:AAGZx_ia4LjOqbCUURNREwwg_fY5jZqCfaU';
var URL = 'https://tv.mail.ru/uljanovsk/';
const str_welcome = "Hello, world!\nToday is " + getDateNow() + "\nTime now is " + getTimeNow();

var bot = new TelegramBot (token, { polling:true,});
var all_channels = [];
var channelName = [];
var channelNameArr = [];

request(URL, function (err, res, body) {
	if (!err) {
		var $ = cheerio.load(body);
    	var programm = $(".p-channels_grid");

   		programm.each(function () {
        	var self = $(this),
        	cont = self.find('.p-channels__items'),
        	itm = {
            title: cont.find('.p-channels__item__info__title').text(),
            img  : cont.find('img').attr('src')
        };

        channelName.push(itm);
     	console.log(str_welcome);
     	channelName.forEach(function(entry) {
    		console.log(entry);
		});
});
    } else {
		    bot.sendMessage(chatId, "Произошла ошибка: " + err);
		    }
});

    

bot.on('message', function(msg) {
	var id = msg.chat.id;
	var messageText = msg.text;
	// console.log(msg);
	// bot.sendMessage(id, msg.text);
	if (messageText == '/start') {
		// bot.sendMessage(id, 'Hello, world!');
		bot.sendMessage(id, str_welcome);
	}
	console.log(msg);
});

function getDateNow() {
	var full_date = "";
	var date = new Date();
	var day = date.getDate();
	var month = date.getMonth();
	var year = date.getFullYear();
	full_date = day + "." + month + "." + year;
	return full_date;
}

function getTimeNow() {
	var full_times = "";
	var times = new Date();
	var hour = times.getHours();
	var min = times.getMinutes();
	var sec = times.getSeconds();
	full_times =  hour + ":" + min + ":" + sec;
	return full_times;
}

function getCountry(lg){ // формируем из пути для флага страны ее название
	var sl = lg.attribs.style.lastIndexOf("/");
	var dt = lg.attribs.style.lastIndexOf(".");
	return lg.attribs.style.substring(sl+1, dt);
	
}
// function getChannels(cnhl) {
// 	var result = "";
// 	var tmp = cheerio.load(cnhl);
// 	var channel = tmp(".tv-channel-title__text").text();
// 	var channels = [];
	
// 	tmp('.b-tv-image__picture image').each(function(i, elem) {
// 		channels.push(tmp(this).text());
// 	});
// 	result = channel + channels;
// 	return result;
// }