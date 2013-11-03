import Sys.*;
import sys.io.File;

class Cat {
  //function new() { super(); }
  static function main():Void {
    //
    // cat を実装
    //
    var args = args();
    var path:String;

    if ( args.length == 0 ) {
      var stdin = stdin();
      print("input filename: ");
      path = stdin.readLine();
    }
    else {
      println( args[0] );
      path = args[0];
    }

    var fi = sys.io.File.read(path, false);
    while ( !fi.eof() ) {
      println( fi.readLine() );
    }
  }
}
