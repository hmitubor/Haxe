import Sys.*;

class PrintArgs {
  static function main(): Void {
    for ( arg in Sys.args() ) {
      println( arg );
    }
  }
}