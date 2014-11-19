package;

import haxe.crypto.Base64;
import haxe.crypto.Hmac;
import haxe.Http;
import haxe.io.Bytes;
import oauth.Tokens;
import oauth.Request;

/**
 * Send a request to the API.
 * 
 * @author Sam MacPherson
 */
class Request2 extends Request {

    public override function send ():String {
        var h = new Http(uri());
#if js
        h.async = false;
#end
        h.setHeader("Authorization", composeHeader());
        if (data != null) {
            //h.setHeader("Content-Type", "application/x-www-form-urlencoded");
            h.setHeader("Content-Type", "application/json");
            h.setPostData(postDataStr2());
        }
        var ret = '';
        h.onData = function(d) ret = d;
        h.request(post);
        return ret;
    }

    function postDataStr2 ():String {
        var buf = new StringBuf();
        buf.add(data);
        return buf.toString();
    }

}
