package;

import oauth.Client;
import oauth.Tokens;
import Secret;

class BDScheduler {
	static var auth_url = "https://accounts.google.com/o/oauth2/auth";
	static var token_url = "https://accounts.google.com/o/oauth2/token";
	static var redirect_uris = "urn:ietf:wg:oauth:2.0:oob";
	static var scope_uri = "https://www.googleapis.com/auth/calendar";
//	static var auth_code = "4/7JAdiE4iq8XcPklnz6B8zs3V3RxzttsR66pBKQI7jvY.YiOKtADOBPobBrG_bnfDxpKqcx_YkgI";

	static function getAuthCode():String {
	//CLIENT Open window to show user the authentication screen
		var auth_url_ret = oauth.OAuth2.buildAuthUrl(auth_url, Secret.client_key, 
				{ redirectUri:redirect_uris,
					scope:scope_uri,
					state:oauth.OAuth2.nonce() });
		Sys.println(auth_url_ret);

		Sys.print("auth_code : ");
		return Sys.stdin().readLine();
	}

	static function makeClientViaAccessToken(accessToken:String, refreshToken:String):Client2 {
		var expires = 3600;
		return MyOAuth2.connect(new oauth.Consumer(Secret.client_key, Secret.client_secret),
					new OAuth2AccessToken(accessToken, expires),
					new RefreshToken(refreshToken));
	}

	static function makeClientViaAuthCode(authCode:String):Client2 {
		var consumer = MyOAuth2.connect(new oauth.Consumer(Secret.client_key, Secret.client_secret));
		return consumer.getAccessToken2(token_url, authCode, redirect_uris);
	}

	static function showToken(client:Client) {
		var oauth2_tmp:OAuth2AccessToken = cast(client.accessToken, OAuth2AccessToken);
		Sys.println(oauth2_tmp.token);
		Sys.println(oauth2_tmp.expires);
		Sys.println(client.refreshToken.token);
	}

	static function makeStartTime(item: String): String {
		var date = ~/([0-9]+)\/([0-9]+[,0-9]*)/;
		if (!date.match(item)) {
			return "";
		}

		var day = ~/([0-9]+),([0-9]+)/;
		if (day.match(date.matched(2))) {
			date = ~/([0-9]+)\/([0-9]+),[0-9]+/;
			date.match(item);
		}

		var jsonItem = '"dateTime": ';
		var format = "%Y-%m-%dT%T+09:00";
		var time = ~/([0-9]+):([0-9]+)～([0-9]+):([0-9]+)/;
		if (!time.match(item)) {
			jsonItem = '"date": ';
			format = "%Y-%m-%d";
		}

		return jsonItem + '"'
			+ DateTools.format(new Date(Date.now().getFullYear(),
					Std.parseInt(date.matched(1))-1,
					Std.parseInt(date.matched(2)),
					(time.match(item)) ? Std.parseInt(time.matched(1)) : 0,
					(time.match(item)) ? Std.parseInt(time.matched(2)) : 0,
					00),
					format)
			+ '"';
	}

	static function makeEndTime(item: String): String {
		var date = ~/([0-9]+)\/([0-9]+[,0-9]*)/;
		if (!date.match(item)) {
			return "";
		}

		var day = ~/([0-9]+),([0-9]+)/;
		if (day.match(date.matched(2))) {
			date = ~/([0-9]+)\/[0-9]+,([0-9]+)/;
			date.match(item);
		}

		var jsonItem = '"dateTime": ';
		var format = "%Y-%m-%dT%T+09:00";
		var time = ~/([0-9]+):([0-9]+)～([0-9]+):([0-9]+)/;
		if (!time.match(item)) {
			jsonItem = '"date": ';
			format = "%Y-%m-%d";
		}

		return jsonItem + '"'
			+ DateTools.format(new Date(Date.now().getFullYear(),
					Std.parseInt(date.matched(1))-1,
					Std.parseInt(date.matched(2)),
					(time.match(item)) ? Std.parseInt(time.matched(3)) : 0,
					(time.match(item)) ? Std.parseInt(time.matched(4)) : 0,
					00),
					format)
			+ '"';
	}

	static function makeStartTimeHBC(item: String): String {
		var date = ~/([0-9]+)\/([0-9]+[,0-9]*)/;
		if (!date.match(item)) {
			return "";
		}

		var jsonItem = '"dateTime": ';
		var format = "%Y-%m-%dT%T+09:00";
		var time = ~/([0-9]+)時-([0-9]+)時/;
		if (!time.match(item)) {
			jsonItem = '"date": ';
			format = "%Y-%m-%d";
		}

		return jsonItem + '"'
			+ DateTools.format(new Date(Date.now().getFullYear(),
					Std.parseInt(date.matched(1))-1,
					Std.parseInt(date.matched(2)),
					(time.match(item)) ? Std.parseInt(time.matched(1)) : 0,
					00,
					00),
					format)
			+ '"';
	}

	static function makeEndTimeHBC(item: String): String {
		var date = ~/([0-9]+)\/([0-9]+[,0-9]*)/;
		if (!date.match(item)) {
			return "";
		}

		var jsonItem = '"dateTime": ';
		var format = "%Y-%m-%dT%T+09:00";
		var time = ~/([0-9]+)時-([0-9]+)時/;
		if (!time.match(item)) {
			jsonItem = '"date": ';
			format = "%Y-%m-%d";
		}

		return jsonItem + '"'
			+ DateTools.format(new Date(Date.now().getFullYear(),
					Std.parseInt(date.matched(1))-1,
					Std.parseInt(date.matched(2)),
					(time.match(item)) ? Std.parseInt(time.matched(2)) : 0,
					00,
					00),
					format)
			+ '"';
	}

	static function getLocationHBC(item: String): String {
		var r = ~/ /g;
		var parts = r.split(item);
		return (parts.length > 1) ? parts[2] : "";
	}


	static function getLocation(item: String): String {
		var r = ~/\n/g;
		var parts = r.split(item);
		return (parts.length > 1) ? parts[2] : "";
	}

	static function getBCName(str: String): String {
		var abc = ~/[0-9]+:[0-9]+/;
		if (abc.match(str)) {
			return "ABC";
		}

		var hbc = ~/[0-9]+時-[0-9]+時/;
		if (hbc.match(str)) {
			return "HBC";
		}

		return "";
	}

	static function main():Void {
//		var client = makeClientViaAuthCode( getAuthCode() );

		var client = makeClientViaAccessToken(Secret.acc_token, Secret.ref_token);
	
		//SERVER Get a new access token if the old one has expired
		client.refreshAccessToken(token_url);

		showToken( client );

		Sys.println("Please input schedule:");
		var sches = Sys.stdin().readAll().toString();

		var bc_name = getBCName(sches);

		var sp = ~/^ *$/mg;
		if ( bc_name == "HBC" ) {
			sp = ~/\n/g;
		}

		var items = sp.split(sches);
		for (item in items) {
			if (item != "" && item != "\n") {
				Sys.println('"'+item+'"');

				var start_time = (bc_name == "ABC") ? makeStartTime(item) : makeStartTimeHBC(item);
				var   end_time = (bc_name == "ABC") ? makeEndTime(item) : makeEndTimeHBC(item);
				var   location = (bc_name == "ABC") ? getLocation(item) : getLocationHBC(item);

				Sys.println('start_time: $start_time');
				Sys.println('  end_time: $end_time');
				Sys.println('  location: $location');

/*				trace(*/
				client.requestJSONforGoogle("https://www.googleapis.com/calendar/v3/calendars/hmitubor@gmail.com/events"
					+ "?key=" + Secret.client_key,
					true,
					'{
 "start": {
  $start_time
 },
 "end": {
  $end_time
 },
 "location": "$location",
 "summary": "$bc_name"
}') /*)*/;
			}
		}

		return;

		//GET request
		trace(client.requestJSONforGoogle("https://www.googleapis.com/calendar/v3/calendars/hmitubor@gmail.com"));

		//POST request
		var start_time = DateTools.format(new Date(2014, 10, 3, 18, 00, 00), "%Y-%m-%dT%T+09:00");
		var   end_time = DateTools.format(new Date(2014, 10, 3, 18, 30, 00), "%Y-%m-%dT%T+09:00");
		
		trace(client.requestJSONforGoogle("https://www.googleapis.com/calendar/v3/calendars/hmitubor@gmail.com/events"
					+ "?key=" + Secret.client_key,
					true,
					'{
 "start": {
  "dateTime": "$start_time"
 },
 "end": {
  "dateTime": "$end_time"
 },
 "location": "三ッ堀 裕之",
 "summary": "HBC"
}'));
	}
}
