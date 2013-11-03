package;

import sys.io.File.*;
import sys.io.FileOutput;
import haxe.zip.*;
import FileTools.makeEntry;

class Zip {
  var fo:FileOutput;
  var le:List<Entry>;

  public function new(path:String) {
    fo = write(path, true);
    le = new List();
  }

  public function zip():Void {
    var z = new haxe.zip.Writer(fo);
    z.write(le);
  }

  public function addFile(path:String):Void {
    le.add(makeEntry(path));
    trace(path);
  }

}
