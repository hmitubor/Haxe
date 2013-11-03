import Sys.*;

class Stdin {
  static function main() : Void {
    var stdin = stdin();
    
    print("please input something: ");
    var string = stdin.readLine();
    
    println('You input "$string"');
  }
}