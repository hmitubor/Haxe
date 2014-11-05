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

	static function main():Void {
		Sys.println("hello");

		var now = Date.now();
		var ddd = new Date(now.getFullYear(), 10, 3, 8, 30, 00);
		Sys.println( DateTools.format(ddd, "%Y-%m-%dT%TZ") );

//		var client = makeClientViaAuthCode( getAuthCode() );

		var client = makeClientViaAccessToken(Secret.acc_token, Secret.ref_token);
	
		//SERVER Get a new access token if the old one has expired
		client.refreshAccessToken(token_url);

		showToken( client );

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
