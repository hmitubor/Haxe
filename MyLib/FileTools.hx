package;

import sys.FileSystem.*;
import haxe.zip.Entry;
import haxe.io.Path;

class FileTools {
  public static function deleteAll(target:String):Void {
    // . や .. は怖いので除外する。
    if (target == "." || target == "..") {
      return;
    }
    // 存在しない場合は無視
    if (!exists(target)) {
      return;
    }

    // ディレクトリなら、
    if (isDirectory(target)) {
      // 中を調べて
      var contents = readDirectory(target);
      if (contents.length == 0) {
	// 空なら消す
	trace("delete_dir : " + target);
	deleteDirectory(target);
      }
      else {
	// 中身があれば再帰で順番に消去
	for (content in contents) {
	  deleteAll(Path.addTrailingSlash(target)+content);
	}
	// その後自分も消去
	deleteAll(target);
      }
    }
    else {
      // ファイルならそのまま削除
      trace("delete_file: " + target);
      deleteFile(target);
    }
  }

  public static function makeEntry(path:String):Entry {
    if ( !exists(path) ) {
      throw "not exist file or directory!";
    }
    else if ( isDirectory(path) ) {
      throw "directory!";
    }

    var fs = stat(path);
    
    var src = sys.io.File.getBytes(path);

    var entry:Entry = {
        fileTime : fs.ctime,
	fileSize : fs.size,
	fileName : path,
	extraFields : null,
	dataSize : 0,
	data : src,
	crc32 : haxe.crypto.Crc32.make(src),
	compressed : false,
    }

    haxe.zip.Tools.compress(entry, 6);

    trace("############################");
    trace("filename: " + entry.fileName);
    trace("filetime: " + entry.fileTime);
    trace("filesize: " + entry.fileSize);
    trace("datasize: " + entry.dataSize);
    trace("");

    return entry;
  }

  public static function makeAllFileList(target:String, lists:List<Path>):Void{
    // .. は不要なので除外する。
    if (target == "..") {
      return;
    }
    // 存在しない場合は無視
    if (!exists(target)) {
      return;
    }

    // ディレクトリなら、
    if (isDirectory(target)) {
      target = Path.addTrailingSlash(target);

      // 中を調べて
      var contents = readDirectory(target);
      if (contents.length == 0) {
	lists.add( new Path(target) );
      }
      else {
	// 中身があれば再帰で順番にたどる
	for (content in contents) {
	  if ( target == "./" ) {
	    target = "";
	  }
	  makeAllFileList(target+content, lists);
	}
      }
    }
    else {
      // ファイルならそのままリストに追加
      lists.add( new Path(target) );
    }
  }
}
