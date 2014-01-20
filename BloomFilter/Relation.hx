package;

import BloomFilter;

class Relation {
	public static function main(): Void {
		var args = Sys.args();
		if ( args.length < 2 ) {
			Sys.println("not enough arguments!");
			Sys.println("command FILE M(=100) K(=3)");
			return;
		}

		var m: Int = (args.length < 3) ? 100 : Std.parseInt(args[2]);
		var k: Int = (args.length < 4) ? 3 : Std.parseInt(args[3]);

		var node1 = new BloomFilter(m, k);
		var node2 = new BloomFilter(m, k);

		make_filter(node1, args[0]);
		make_filter(node2, args[1]);

//		node1.show_filter();
//		node2.show_filter();

		var cnt = 0;
		for (i in 0...node1.filter.length) {
//			if ( (node1.filter[i] && node2.filter[i]) || !(node1.filter[i] || node2.filter[i])) {
			if ( node1.filter[i] && node2.filter[i]) {
				cnt++;
			}
		}

		Sys.println('$cnt / $m');
	}

	public static function make_filter(filter, file) {
		Sys.println("file = " + file);
		var input = sys.io.File.getContent(file).toLowerCase();
		input = StringTools.replace(input, "\n", " ");
		input = StringTools.replace(input, ".", "");
		input = StringTools.replace(input, ",", "");
		var words = input.split(" ");

		for (word in words) {
			if (word.length > 0) {
				filter.add_filter(word);
			}
		}
	}
}

