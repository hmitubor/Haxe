package;

using haxe.ds.IntMap;

class Prime {
		static var upto = 10000000;

		static function main():Void {
			var arr = new IntMap<Bool>();

			for (i in 2...upto+1) {
				arr.set(i, is_prime(i));
			}

			var sum = 0;
			for (i in 1...upto+1) {
				sum += arr.get(i) ? 1 : 0;
			}

			Sys.println('Prime is $sum');
			//Sys.println(arr.toString());

		}

		static function is_prime(val:Int): Bool {
			var m = Math.floor(Math.sqrt(val));
			for (i in 2...m+1) {
				if (0 == val%i) {
					return false;
				}
			}

			return true;
		}
}
