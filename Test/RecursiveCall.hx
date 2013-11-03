import Sys.*;

class RecursiveCall {
  static function main():Void {
    //
    // 再起呼出し
    //
    var i = 13;
    var f = fact(i);
    println( 'fact($i) = $f');
  }

  static public function fact(n:Int):Int {
    if (n==0) {
      return 1;
    }
    else {
      return n*fact(n-1);
    }
  }
}