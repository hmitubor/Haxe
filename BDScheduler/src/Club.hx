package;

class ClubFactory {
    public static function get_bc_name(sche: String): String {
        // ABC
        if (ClubABC.club_reg.match(sche)) {
            return "ABC";
        }

	// HBC
        if (ClubHBC.club_reg.match(sche)) {
            return "HBC";
        }

        // Suidou-yama
        if (ClubSDY.club_reg.match(sche)) {
            return "SDY";
        }

        return "";
    }

    public static function create(sche: String): Club {
        return switch ( get_bc_name(sche) ) {
            case "ABC": new ClubABC();
            case "HBC": new ClubHBC();
            case "SDY": new ClubSDY();
            default: {
                Sys.println("error: unknown schedule input.");
                return null;
            }
        }
    }
}

interface Club {
    public var name:String;
    public function getSeparater(): EReg;
    public function makeStartTime(item: String): String;
    public function makeEndTime(item: String): String;
    public function getLocation(item: String): String;
}

class ClubBase {
    public var name:String;
    public static var club_reg:EReg;

    private function getScheduleYear(month: Int): Int {
        return (month < Date.now().getMonth())
            ? Date.now().getFullYear() + 1
            : Date.now().getFullYear();
    }
}

class ClubABC extends ClubBase implements Club {
//    public static var club_reg = ~/[0-9]+:[0-9]+/;
    public static var club_reg = ~/☆[0-9]+\/[0-9]+/;

    public function new() {
        name = "ABC";
    }

    public function getSeparater(): EReg {
        return ~/^ *$/mg;
    }

    public function makeStartTime(item: String): String {
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

        var month   = Std.parseInt(date.matched(1)) - 1;
        var day     = Std.parseInt(date.matched(2));
        var year    = getScheduleYear(month);
        var hour    = (time.match(item)) ? Std.parseInt(time.matched(1)) : 0;
        var min     = (time.match(item)) ? Std.parseInt(time.matched(2)) : 0;
 
        return jsonItem + '"'
            + DateTools.format(new Date(year, month, day, hour, min, 00), format)
            + '"';
    }

    public function makeEndTime(item: String): String {
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

        var month   = Std.parseInt(date.matched(1)) - 1;
        var day     = Std.parseInt(date.matched(2));
        var year    = getScheduleYear(month);
        var hour    = (time.match(item)) ? Std.parseInt(time.matched(3)) : 0;
        var min     = (time.match(item)) ? Std.parseInt(time.matched(4)) : 0;
        
        return jsonItem + '"'
            + DateTools.format(new Date(year, month, day, hour, min, 00), format)
            + '"';
    }

    public function getLocation(item: String): String {
        var r = ~/\n/g;
        var parts = r.split(item);
        return (parts.length > 1) ? parts[2] : "";
    }
}

class ClubHBC extends ClubBase implements Club {
    public static var club_reg = ~/[0-9]+時-[0-9]+時/;

    public function new() {
        name = "HBC";
    }

    public function getSeparater(): EReg {
        return ~/\n/mg;
    }

    public function makeStartTime(item: String): String {
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

        var month   = Std.parseInt(date.matched(1)) - 1;
        var day     = Std.parseInt(date.matched(2));
        var year    = getScheduleYear(month);
        var hour    = (time.match(item)) ? Std.parseInt(time.matched(1)) : 0;
        var min     = 00;
 
         return jsonItem + '"'
            + DateTools.format(new Date(year, month, day, hour, min, 00), format)
            + '"';
    }

    public function makeEndTime(item: String): String {
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

        var month   = Std.parseInt(date.matched(1)) - 1;
        var day     = Std.parseInt(date.matched(2));
        var year    = getScheduleYear(month);
        var hour    = (time.match(item)) ? Std.parseInt(time.matched(2)) : 0;
        var min     = 00;
 
         return jsonItem + '"'
            + DateTools.format(new Date(year, month, day, hour, min, 00), format)
           + '"';
    }

    public function getLocation(item: String): String {
        var r = ~/ /g;
        var parts = r.split(item);
        return (parts.length > 1) ? parts[2] : "";
    }
}

class ClubSDY extends ClubBase implements Club {
    public static var club_reg = ~/[0-9]+月[0-9]+日\(金\t[0-9]+:[0-9]+～[0-9]+:[0-9]+\t/;

    public function new() {
        name = "水道山BC";
    }

    public function getSeparater(): EReg {
        return ~/\n/mg;
    }

    public function makeStartTime(item: String): String {
        var date = ~/([0-9]+)月([0-9]+)日\(金/;
        if (!date.match(item)) {
            return "";
        }

        var jsonItem = '"dateTime": ';
        var format = "%Y-%m-%dT%T+09:00";
        var time = ~/([0-9]+):([0-9]+)～([0-9]+):([0-9]+)/;
        if (!time.match(item)) {
            jsonItem = '"date": ';
            format = "%Y-%m-%d";
        }

        var month   = Std.parseInt(date.matched(1)) - 1;
        var day     = Std.parseInt(date.matched(2));
        var year    = getScheduleYear(month);
        var hour    = (time.match(item)) ? Std.parseInt(time.matched(1)) : 0;
        var min     = (time.match(item)) ? Std.parseInt(time.matched(2)) : 0;
 
         return jsonItem + '"'
            + DateTools.format(new Date(year, month, day, hour, min, 00), format)
            + '"';
    }

    public function makeEndTime(item: String): String {
        var date = ~/([0-9]+)月([0-9]+)日\(金/;
        if (!date.match(item)) {
            return "";
        }

        var jsonItem = '"dateTime": ';
        var format = "%Y-%m-%dT%T+09:00";
        var time = ~/([0-9]+):([0-9]+)～([0-9]+):([0-9]+)/;
        if (!time.match(item)) {
            jsonItem = '"date": ';
            format = "%Y-%m-%d";
        }

        var month   = Std.parseInt(date.matched(1)) - 1;
        var day     = Std.parseInt(date.matched(2));
        var year    = getScheduleYear(month);
        var hour    = (time.match(item)) ? Std.parseInt(time.matched(3)) : 0;
        var min     = (time.match(item)) ? Std.parseInt(time.matched(4)) : 0;
 
         return jsonItem + '"'
            + DateTools.format(new Date(year, month, day, hour, min, 00), format)
           + '"';
    }

    public function getLocation(item: String): String {
        var r = ~/\t/g;
        var parts = r.split(item);
        return (parts.length > 1) ? parts[2] : "";
    }
}
