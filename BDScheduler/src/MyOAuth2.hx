package;

import haxe.crypto.Md5;
import oauth.Tokens;
import oauth.OAuth2;
import oauth.Consumer;

/**
 * OAuth 2 main entry point.
 * 
 * @author Renaud Bardet
 * @author Sam MacPherson
 */

class MyOAuth2 extends OAuth2 {

	public static function connect (consumer:Consumer, ?accessToken:OAuth2AccessToken, ?refreshToken:RefreshToken):Client2 {
		var c = new Client2(V2, consumer);
		c.accessToken = accessToken;
		c.refreshToken = refreshToken;
		return c;
	}
}
