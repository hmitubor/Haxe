package;
import FileTools;

import sys.io.File.*;
import haxe.io.Path.*;
import sys.FileSystem.*;
import Sys.*;
import Unzip;

using StringTools;

class UnzipTest {
  static function main():Void {
    var path = "../w_yk_20130912.epub";

    var zip = new Unzip(path);
    // zip.view();

    // zip 展開
    var target_dir = "zip_tmp";
    zip.unzip( target_dir );

    // delete 
    // FileTools.deleteAll( zip_tmp );
  }
}
