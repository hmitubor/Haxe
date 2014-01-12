package;

import BloomFilter;

class BloomFilterTest {
  function new() {}

  public static function main():Void {

    var args = Sys.args();
    if ( args.length < 1 ) {
      Sys.println("not enough arguments!");
      Sys.println("command FILE M(=100) K(=3)");
      return;
    }

    var m: Int = (args.length < 2) ? 100 : Std.parseInt(args[1]);
    var k: Int = (args.length < 3) ? 3 : Std.parseInt(args[2]);
    var bf = new BloomFilter(m, k);
    var mp = new Map<String, Bool>();

    Sys.println("file = " + args[0]);
    var input = sys.io.File.getContent(args[0]).toLowerCase();
    input = StringTools.replace(input, "\n", " ");
    input = StringTools.replace(input, ".", "");
    input = StringTools.replace(input, ",", "");
    var words = input.split(" ");

    for (word in words) {
      if (word.length > 0) {
	Sys.println('$word => '
		    + ((bf.check_filter(word)) ? "true" : "false")
		    + ", "
		    + (mp.exists(word) ? "true" : "false"));

	bf.add_filter(word);
	mp.set(word, true);
      }
    }
    Sys.println("");
  }
}
