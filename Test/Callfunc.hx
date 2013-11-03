import Sys.*;

class Callfunc {
  // function new() { super(); }

  static function main():Void {
    random(10);
  }

  static function random(n:Int):Void {
    //    var r = new neko.Random();
    for (a in 0...n) {
      //      Sys.println( a + ": " + r.int(10) );
      println( '$a: ' + Std.random(10) );
    }
  }
}
