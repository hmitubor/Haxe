package;

import oauth.Client;
import oauth.Tokens;
import oauth.OAuth2;
import Club;

typedef Secret = {
    var email: String;
    var access: OAuth2AccessToken;
    var refresh: RefreshToken;
}

class BDScheduler {
    static var secret_file	= "BDS_secret.json";
    static var scope_uri	= "https://www.googleapis.com/auth/calendar";
    static var oauth: Dynamic;
    static var secret: Secret;
    static var email: String;

    static function getAuthCode():String {
        //CLIENT Open window to show user the authentication screen
        var auth_url_ret = OAuth2.buildAuthUrl(
                oauth.installed.auth_uri, 
                oauth.installed.client_id, 
                { redirectUri: oauth.installed.redirect_uris[0],
                    scope: scope_uri,
                    state: OAuth2.nonce() });
        Sys.println(auth_url_ret);

        Sys.print("your email: ");
        email = Sys.stdin().readLine();

        Sys.print("auth_code : ");
        return Sys.stdin().readLine();
    }

    static function makeClientViaAccessToken(accessToken:String, refreshToken:String):Client2 {
        return MyOAuth2.connect(new oauth.Consumer(oauth.installed.client_id, oauth.installed.client_secret),
                new OAuth2AccessToken(secret.access.token, secret.access.expires),
                new RefreshToken(secret.refresh.token));
    }

    static function makeClientViaAuthCode(auth_code:String):Client2 {
        var consumer = MyOAuth2.connect(new oauth.Consumer(
                    oauth.installed.client_id,
                    oauth.installed.client_secret)
                );
        return consumer.getAccessToken2(oauth.installed.token_uri, auth_code, oauth.installed.redirect_uris[0]);
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

    static function readToken(): Bool {
        if ( !sys.FileSystem.exists(secret_file) ) {
            return false;
        }

        var fi = sys.io.File.read(secret_file, false);
        secret = haxe.Json.parse( fi.readAll().toString() );
        fi.close();

        email = secret.email;
//        trace( secret.email );
//        trace( secret.access.token );
//        trace( secret.refresh.token );
        return true;
    }

    static function writeToken(client: Client): Void {
        var access_token: OAuth2AccessToken = cast(client.accessToken, OAuth2AccessToken);
        secret = {email: email,
                  access: new OAuth2AccessToken(access_token.token, access_token.expires),
                  refresh: new RefreshToken(client.refreshToken.token) };

        var fo = sys.io.File.write(secret_file, false);
        fo.writeString( haxe.Json.stringify(secret) );
        fo.close();
    }

    static function readOAuthFile(): Bool {
        var oauth_file = "BDS.json";
        if ( !sys.FileSystem.exists(oauth_file) ) {
            return false;
        }

        var fi = sys.io.File.read(oauth_file, false);
        oauth = haxe.Json.parse( fi.readAll().toString() );
        fi.close();

        return true;
    }

    static function main():Void {

        if ( !readOAuthFile() ) {
            Sys.println("error: no BDS.json found.");
            return;
        }

        var client = if ( readToken() ) {
            makeClientViaAccessToken(secret.access.token, secret.refresh.token);
        }
        else {
            makeClientViaAuthCode( getAuthCode() );
        }

        client.refreshAccessToken(oauth.installed.token_uri);

        //showToken( client );
        writeToken( client );

        Sys.println("\nPlease input schedule:");
        var sches = Sys.stdin().readAll().toString();
        var club = ClubFactory.create(sches);
        if ( club == null ) {
            Sys.println("error: unknown schedule input.");
            return;
        }

        var sp = club.getSeparater();
        var items = sp.split(sches);
        for (item in items) {
            if (item != "" && item != "\n") {
//                Sys.println('"'+item+'"');

                var start_time = club.makeStartTime(item);
                var   end_time = club.makeEndTime(item);
                var   location = club.getLocation(item);

                Sys.println('start_time: $start_time');
                Sys.println('  end_time: $end_time');
                Sys.println('  location: $location');

                client.requestJSONforGoogle("https://www.googleapis.com/calendar/v3/calendars/"
                        + secret.email 
                        + "/events"
                        + "?key=" + oauth.installed.client_id,
                        true,
                        '{
"start": {
  $start_time
},
"end": {
  $end_time
},
"location": "$location",
"summary": "$club.name"
}');
            }
        }

       return;
    }
}
