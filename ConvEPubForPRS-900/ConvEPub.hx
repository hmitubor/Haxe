package;

import Unzip;
import Zip;

import sys.io.File;
import sys.FileSystem.*;
import haxe.io.Path;
import haxe.io.Path.*;
import FileTools.*;

class ConvEPub {
  public static function main() : Void
  {
    if ( Sys.args().length == 0 ) {
      Sys.print("no input");
      return;
    }

    for ( target in Sys.args() ) {
      if ( extension(target) != "epub" ) {
	Sys.print("skip 'target' ...");
	continue;
      }

      // filename.epub -> tmpdir = filename
      var tmpdir = withoutDirectory( withoutExtension( target ));

      var unzip = new Unzip(target);
      unzip.unzip( tmpdir );

      // move to tmpdir
      Sys.setCwd(tmpdir);

      //
      // やっつけ
      //
      var files = new List<Path>();
      makeAllFileList(".", files);

      var found = false;

      for ( file in files ) {
	if ( extension(file.toString()) == "opf" ) {
	  trace( file.toString() );

	  var opf = File.getContent(file.toString());
	  var ptk = ~/Push to Kindle/gi;
	  var ymk = ~/Yama-Kei Publishers/gi;

	  if ( ptk.match(opf) ) {
	    convPushToKindle();
	    found = true;
	    break;
	  }
	  else if ( ymk.match(opf) ) {
	    convYamakei();
	    found = true;
	    break;
	  }
	}
      }

      if ( found ) {
	zip(tmpdir);
	Sys.setCwd("../");
      }
      else {
	Sys.println('Cancel $target...');
	Sys.setCwd("../");
	deleteAll(tmpdir);
      }
    }
  }

  private static function zip(target:String):Void {
    var paths  = new List<Path>();
    makeAllFileList(".", paths);
    var zip = new Zip( withExtension("../" + target, "epub") );
    for( i in paths ) {
      zip.addFile(i.toString());
    }
    zip.zip();
  }

  //
  // Push to Kindle 用の変換
  //
  private static function convPushToKindle():Void {
    var css_dir = "css";

    var css_list = readDirectory(css_dir);
    for( file in css_list ) {
      if ( extension(file) == "css") {
	convCSS( addTrailingSlash(css_dir) + file );
      }
    }

    var html_list = readDirectory(".");
    for (file in html_list) {
      if ( extension(file) == "html" ) {
	var html_out = File.write(file+"_tmp");
	html_out.writeString(~/ebook\.css\?v1/.replace(File.getContent(file),
						       "ebook.css") );
	html_out.flush();
	html_out.close();
	rename(file+"_tmp", file);
      }

    }
  }

  //
  // 山と渓谷社 用の変換
  //
  private static function convYamakei():Void {
    var css_dir = "OEBPS/Styles";

    var css_list = readDirectory(css_dir);
    for( file in css_list ) {
      if ( extension(file) == "css") {
	convCSS( addTrailingSlash(css_dir) + file );
      }
    }
  }

  private static function convCSS(css:String) : Void
  {
    var input = File.getContent(css);

    // 既に変換済みであればスキップ
    var chk_reg = ~/TakaoExMincho/gi;
    if ( chk_reg.match(input) ) {
      return;
    }

    var tmp = css + "2";
    var output = File.write(tmp, false);
    output.writeString("@font-face {\n"
		       + "    font-family: \"TakaoExMincho\";\n"
		       + "    src: url(res:///Data/fonts/TakaoExMincho.ttf)\n"
		       + "}\n"
		       + "\n"
		       + "@font-face {\n"
		       + "    font-family: \"TakaoExGothic\";\n"
		       + "    src: url(res:///Data/fonts/TakaoExGothic.ttf)\n"
		       + "}\n"
		       + "\n"
		       + "@font-face {\n"
		       + "    font-family: \"IPAMonaGothic\";\n"
		       + "    src: url(res:///Data/fonts/ipag-mona.ttf)\n"
		       + "}\n"
		       + "\n"
		       + "body {\n"
		       + "    padding: 0.2em;\n"
		       + "    font-family: \"TakaoExMincho\", serif;\n"
		       + "    line-height: 120%\n"
		       + "}\n"
		       + "\n");

    var reg_ff = ~/font-family: (.*), ([^;]*);/g;
    var reg_bd = ~/margin-bottom: *0\.5em;/g;

    var out = reg_bd.replace(reg_ff.replace(input,
					    "font-family: \"TakaoExMincho\", $2;"),
			     "margin-bottom:0.5em; font-weight: bold;");

    output.writeString( out+"\n");

    output.flush();
    output.close();

    rename(tmp, css);
  }

}