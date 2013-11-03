package;
import FileTools;

import sys.io.File.*;
import haxe.io.Path.*;
import sys.FileSystem.*;
import Sys.*;
import MyReader;

using StringTools;

class Unzip {
  var zip_file:String;

  public function new(filename:String) {
    zip_file = filename;
  }

  public function view():Void {
    var zipfile = sys.io.File.read(zip_file, true);
    //    var zip = new haxe.zip.Reader(zipfile);
    var zip = new MyReader(zipfile);
    var lists = zip.read();

    // zip list
    for ( list in lists ) {
      println( list.fileName + "\t"
	       + list.fileSize + "\t"
	       + ((list.fileName.endsWith("/")) ? "Dir" : "File") );
    }    
  }

  public function unzip(target_dir:String):Void {

    // カレントに展開されると嫌なので、フォルダを作る
    if ( exists( target_dir ) ) {
      // ファイルが残っていると消せないので
      // 全部消すためにクラスを作ってみた。
      FileTools.deleteAll( target_dir );
    }
    createDirectory( target_dir );
    
    var zipfile = sys.io.File.read(zip_file, true);
    //    var zip = new haxe.zip.Reader(zipfile);
    var zip = new MyReader(zipfile);
    var lists = zip.read();

    for ( list in lists ) {
      println( list.fileName );

      if ( list.fileName.endsWith("/") && list.fileSize == 0 ) {
	createDirectory( addTrailingSlash(target_dir) + list.fileName );
      }
      else {
	var target = addTrailingSlash(target_dir) + list.fileName;
	if ( !exists( directory( target)) ) {
	  createDirectory( directory(target) );
	}
	saveBytes(target, haxe.zip.Reader.unzip(list));
      }
    }    
  }
}
