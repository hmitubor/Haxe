package;

import haxe.crypto.Md5;

class BloomFilter {
  public var filter(get, null): Array<Bool>;
  var m: Int;
  var k: Int;

  public function get_filter() {
    return filter;
  }
  
  public static function main():Void {
    var m = 100;
    var k = 3;
    var bf = new BloomFilter(m, k);

    bf.add_filter("hello");
    bf.check_filter("hello");
  }

  public function new(m: Int, k: Int) {
    this.m = m;
    this.k = k;
    init_filter();
  }

  public function init_filter():Void {
    if ( filter == null ) {
      filter = new Array<Bool>();
    }

    while (filter.length > 0) {
      filter.shift();
    }

    for (i in 0...m) {
      filter.push(false);
    }

    trace("init_filter(): make bloom filter which length = "
		+ filter.length);
  }

  public function add_filter(input: String):Void {
    var f = make_filter(input);

    for (i in f) {
      filter[i] = true;
    }
  }

  public function check_filter(input: String):Bool {
    var f = make_filter(input);

    var ret:Bool = true;

    for (i in f) {
      ret = ret && filter[i];
    }

    return ret;
  }

  private function make_filter(input: String):Array<Int> {
    var md5 = Md5.encode(input);
    trace('$input => "$md5"');

    var ret = new Array<Int>();

    for (i in 0...k) {
      var hash_str = "0x" + md5.substr(i*4, 4);

      var hash = Std.parseInt(hash_str) % m;
      trace('hash[$i] = "$hash_str" => $hash');
      
      ret.push(hash);
    }
    
    return ret;
  }

  public function show_filter():Void {
    for (i in filter) {
      Sys.print( (i) ? "1" : "0" );
    }

    Sys.println("");
  }

}
