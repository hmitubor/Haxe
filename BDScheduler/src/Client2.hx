package;

import haxe.Json;
import oauth.Tokens;
import oauth.Client;
import oauth.Request;

/**
 * Make calls to an API on behalf of a user.
 * 
 * @author Sam MacPherson
 */
class Client2 extends Client {
	
        public override function getAccessToken2 (uri:String, code:String, redirectUri:String, ?post:Bool = true):Client2 {
                if (!version.match(V2)) throw "Cannot call an OAuth 2 method from a non-OAuth 2 flow.";
                var result = jsonToMap(requestJSON(uri, post, { code:code, client_id:consumer.key, client_secret:consumer.secret, redirect_uri:redirectUri, grant_type:"authorization_code" }));
							                
                if (!result.exists("access_token")) throw "Failed to get access token.";
									                
                var c = new Client2(version, consumer);
                c.accessToken = new OAuth2AccessToken(result.get("access_token"), Std.parseInt(result.get("expires_in")));
                if (result.exists("refresh_token")) c.refreshToken = new RefreshToken(result.get("refresh_token"));
	        return c;
        }

	public override function request (uri:String, ?post:Bool = false, ?postData:Dynamic):String {
		var req = new Request(version, uri, consumer, accessToken, post, postData);
		if (version == V1) req.sign();
		//return req.send();
		var tmp = req.send();
trace(tmp);
		return tmp;
	}

	public function request_for_google (uri:String, ?post:Bool = false, ?postData:Dynamic):String {
		var req = new Request2(version, uri, consumer, accessToken, post, postData);
		if (version == V1) req.sign();
		//return req.send();
		var tmp = req.send();
trace(tmp);
		return tmp;
	}
	
	public inline function requestJSONforGoogle (uri:String, ?post:Bool = false, ?postData:Dynamic):Dynamic {
                return Json.parse(request_for_google(uri, post, postData));
        }

}
