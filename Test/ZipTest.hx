package;

import Zip;

class ZipTest {
  static function main() {
    var z = new Zip("ZipTest.zip");
    z.addFile("xxx");
    z.zip();
  }
}
