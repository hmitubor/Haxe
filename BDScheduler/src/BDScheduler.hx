package;

//import oauth.OAuth2;
import oauth.Client;
import oauth.Tokens;

class BDScheduler {
	static var auth_url = "https://accounts.google.com/o/oauth2/auth";
	static var token_url = "https://accounts.google.com/o/oauth2/token";
	static var client_key = "864839047331-9cmf8rebl3mckrd3gm4sjr1cm5qmqefv.apps.googleusercontent.com";
	static var client_secret = "pZz5u_vP4YJY_Orkhn1MmDlY";
	static var redirect_uris = "urn:ietf:wg:oauth:2.0:oob";
	static var scope_uri = "https://www.googleapis.com/auth/calendar";
//	static var auth_code = "4/7JAdiE4iq8XcPklnz6B8zs3V3RxzttsR66pBKQI7jvY.YiOKtADOBPobBrG_bnfDxpKqcx_YkgI";

	static function getAuthCode():String {
	//CLIENT Open window to show user the authentication screen
		var auth_url_ret = oauth.OAuth2.buildAuthUrl(auth_url, client_key, 
				{ redirectUri:redirect_uris,
					scope:scope_uri,
					state:oauth.OAuth2.nonce() });
		Sys.println(auth_url_ret);

		Sys.print("auth_code : ");
		return Sys.stdin().readLine();
	}

	static function makeClientViaAccessToken(accessToken:String, refreshToken:String):Client2 {
		var expires = 3600;
		return MyOAuth2.connect(new oauth.Consumer(client_key, client_secret),
					new OAuth2AccessToken(accessToken, expires),
					new RefreshToken(refreshToken));
	}

	static function makeClientViaAuthCode(authCode:String):Client2 {
		var consumer = MyOAuth2.connect(new oauth.Consumer(client_key, client_secret));
		return consumer.getAccessToken2(token_url, authCode, redirect_uris);
	}

	static function showToken(client:Client) {
		var oauth2_tmp:OAuth2AccessToken = cast(client.accessToken, OAuth2AccessToken);
		Sys.println(oauth2_tmp.token);
		Sys.println(oauth2_tmp.expires);
		Sys.println(client.refreshToken.token);
	}

	static function main():Void {
		Sys.println("hello");

		var now = Date.now();
		var ddd = new Date(now.getFullYear(), 10, 3, 8, 30, 00);
		Sys.println( DateTools.format(ddd, "%Y-%m-%dT%TZ") );

//		var client = makeClientViaAuthCode( getAuthCode() );

		var acc_token = "ya29.tAAhYIN8MASkE-UCSdchMdFVt5NVzFNvQqLWNn5nMoF9GqGkiyT3s8vBYGXxaBBmJae0-uejAqeKBw";
		var ref_token = "1/T2Eu63fQMULbaVwJiip8YqjGB4Me0FW_I25tNbEYFww";
		var client = makeClientViaAccessToken(acc_token, ref_token);
	
		//SERVER Get a new access token if the old one has expired
		client.refreshAccessToken(token_url);

		showToken( client );

		//GET request
		trace(client.requestJSONforGoogle("https://www.googleapis.com/calendar/v3/calendars/hmitubor@gmail.com"));

		//POST request
		var start_time = DateTools.format(new Date(2014, 10, 3, 18, 00, 00), "%Y-%m-%dT%T+09:00");
		var   end_time = DateTools.format(new Date(2014, 10, 3, 18, 30, 00), "%Y-%m-%dT%T+09:00");
		
		trace(client.requestJSONforGoogle("https://www.googleapis.com/calendar/v3/calendars/hmitubor@gmail.com/events"
					+ "?key=" + client_key,
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
