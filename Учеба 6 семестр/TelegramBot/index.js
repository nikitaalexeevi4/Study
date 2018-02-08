var TelegramBot = require('node-telegram-bot-api');
var request = require('request'), cheerio = require('cheerio');


var token = '358948313:AAGZx_ia4LjOqbCUURNREwwg_fY5jZqCfaU';
var URL = 'https://tv.yandex.ru/195?genre=for-children&genre=sport&genre=series&genre=films&grid=main&period=all-day';
const str_welcome = "Сегодня: " + getDateNow() + "\nВремя сейчас: " + getTimeNow();
const str_category = "Добро пожаловать в ТелеБотПрограммыПередачи!\nВы Можете выбрать программу по отдельным телеканалам или же по жанрам.\nЕсли возникнут проблемы в использовании, то перейдите по кнопке Помощь.";
const strHelp = "!Помощь!\n ";
const strGenre = "Выберите жанр:";
const errStr = "На данном канале нет передач по данной тематике!";
const genreFilm = "Жанр фильмы.";

var clone = require('clone');

var flag = false;
var bot = new TelegramBot (token, { polling:true,});
var all_channels = [];
var channelName = [];
var channelName1 = [];
var channelNameArr = [];
var channelNameArr1 = [];
var menuName = ["ТелеПрограмма по каналам", "ТелеПрограмма по жанрам", "Помощь"];
var menuNameArr = [];
var menuGenre = ["Фильмы", "Спорт", "Сериалы", "Детям"];
var menuGenreArr = [];
var strt = [['/start']];
var cncl = [['/cancel']]; // кнопка отмены
var gtprog = [['/getprog']];
var gtgenre = [['/getgenre']];

function test_req (err, res, body) {
	if (!err) {
		var $ = cheerio.load(body);
    	var programm = $(".tv-grid__page");
    	all_channels = $(programm).children(".tv-grid__item_is-now_no");
		$('.tv-channel-title__text').each(function(i, elem) {
			channelName.push($(this).text());
		});

   		channelNameArr = convertArr(channelName);
   		channelNameArr1 = convertArr(channelName1);
   		menuNameArr = convertArr(menuName);
   		menuGenreArr = convertArr(menuGenre);


    } else {
	    bot.sendMessage(Myid, "Произошла ошибка: " + err);
	}
}

request(URL, test_req);
    
bot.on('message', function(msg) {
	const Myid = msg.chat.id;
	var messageText = msg.text;
	 if(messageText == '/start'){
	 	flag = false;
	 	getButton(Myid, str_category, menuNameArr); 
	} else if (messageText ==  menuNameArr[0]) {
	 	getButton(Myid, str_welcome, channelNameArr); 
	} else if(channelName.indexOf(messageText) != -1 && flag == false){
		//console.log("Pervyi nah");
		var item_l = all_channels[channelName.indexOf(messageText)];
		var item = clone(item_l);
		$ = cheerio.load(item);


		var channelProg = [];
		var test1 = $('.tv-channel-events__item');
		// info(test1);
		$('.tv-channel-events__item').each(function(i, elem) { 

			 channelProg.push(getProgrammChannel(elem));
		});

		// console.log(channelProg);


		var strChanel = "";


		channelProg.forEach(function(item, i, arr) {
			if (item != "")
		  		strChanel += item + "\n";
		});
				
		if (strChanel != "") {
		getButton(Myid,strChanel, strt);
		//flag = true;
		} else {
			getButton(Myid, errStr, strt);
		} 

	} else if(messageText == '/cancel'){ 
		getButton(Myid,str_welcome, strt); 

	} else if(messageText ==  menuNameArr[1]){ 
		//console.log(flag);
		getButton(Myid, strGenre, menuGenreArr); 
		//console.log(flag);
	} else if (messageText == menuGenreArr[0]) {
		//console.log(flag);
		flag = true;
	    getButton(Myid, genreFilm, channelNameArr);
	    //console.log(flag);
	} else if(channelName.indexOf(messageText) != -1 && flag == true){
		//console.log("Vtoryi  nah");

		var item_l = all_channels[channelName.indexOf(messageText)];
		var item_1 = clone(item_l);
		$ = cheerio.load(item_1);


		var channelProg1 = [];
		
		var test1 = $('.tv-channel-events__item');
		// info(test1);
		$('.tv-channel-events__item').each(function(i, elem) { 

			 channelProg1.push(getGenreFilms(elem));
		});

		var strGenreFilm = "";


		channelProg1.forEach(function(item, i, arr) {
			if (item != "")
		  		strGenreFilm += item + "\n";
		});
				
		if (strGenreFilm != "") {
		getButton(Myid,strGenreFilm, strt);
		} else {
			getButton(Myid, errStr, strt);
		} 
	} else if(messageText ==  menuNameArr[2]){ 
			bot.sendMessage(Myid, strHelp);
	}else { 
		 errorMsg(Myid); 
	} 
});

function getDateNow() {
	var full_date = "";
	var date = new Date();
	var day = date.getDate();
	var month = date.getMonth()+1;
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

function getButton(id,msg, arr){ 
	bot.sendMessage(id, msg, {
		reply_markup: JSON.stringify({
		    keyboard: arr
		})
	});
}

function convertArr(arr){ 
	var res = [];
	for(var i = 0; i < arr.length; i++){
		var tmp = [];

		tmp.push(arr[i]);
		res.push(tmp);
	}
	return res;
}

function errorMsg(id){ 
	bot.sendMessage(id, "Ошибка! Похоже что-то пошло не так...",{
		        	reply_markup: JSON.stringify({
		        		keyboard: [['/start']]
		        	})
		        });
}

function getProgrammChannel(chnl) {

	var item = cheerio.load(chnl);
	var time = item(".tv-event__time").text();
	var nameprog = item(".tv-event__title").text();

	var time_name = [];

	var res = time + " " + nameprog;
	return res;
}

function getGenreFilms(elem) {

	var item = cheerio.load(elem);
	var nameprog = item(".tv-event_genre_films").text();

	var res = nameprog;
	return res;
}

function getGenreSports(elem) {

	var item = cheerio.load(elem);
	var nameprog = item(".tv-event_genre_sport").text();

	var res = nameprog;
	return res;
}

function getGenreChildren(elem) {

	var item = cheerio.load(elem);
	var nameprog = item(".tv-event_genre_for-children").text();

	var res = nameprog;
	return res;
}

function getGenreSerials(elem) {

	var item = cheerio.load(elem);
	var nameprog = item(".tv-event_genre_series").text();

	var res = nameprog;
	return res;
}