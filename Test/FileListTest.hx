package;

import FileTools.makeAllFileList;
import haxe.io.Path;

class FileListTest {
  static function main() {
    if ( Sys.args().length == 0 ) {
      Sys.println("no dir");
      return;
    }

    // 空のリストを作成
    var lp:List<Path> = new List();

    makeAllFileList(Sys.args()[0], lp);
    for ( a in lp ) {
      trace(a);
    }
  }
}
