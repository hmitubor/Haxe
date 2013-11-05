package;
import haxe.zip.Entry;
import haxe.zip.Reader;

class MyReader extends Reader {
  public function new(i) { super(i);}

  public override function readEntryHeader() : Entry {
    var i = this.i;
    var h = i.readInt32();
    if( h == 0x02014B50 || h == 0x06054B50 )
      return null;
    if( h != 0x04034B50 )
      throw "Invalid Zip Data";
    var version = i.readUInt16();
    var flags = i.readUInt16();
    var utf8 = flags & 0x800 != 0;
    //    if( (flags & 0xF7F7) != 0 )
    //      throw "Unsupported flags "+flags;
    var compression = i.readUInt16();
    var compressed = (compression != 0);
    //    if( compressed && compression != 8 )
    //      throw "Unsupported compression "+compression;
    var mtime = readZipDate();
    var crc32 : Null<Int> = i.readInt32();
    var csize = i.readInt32();
    var usize = i.readInt32();
    var fnamelen = i.readInt16();
    var elen = i.readInt16();
    var fname = i.readString(fnamelen);
    var fields = readExtraFields(elen);
    if( utf8 )
      fields.push(FUtf8);
    var data = null;
    // we have a data descriptor that store the real crc/sizes
    // after the compressed data, let's wait for it
    if( (flags & 8) != 0 )
      crc32 = null;
    return {
    fileName : fname,
	fileSize : usize,
	fileTime : mtime,
	compressed : compressed,
	dataSize : csize,
	data : data,
	crc32 : crc32,
	extraFields : fields,
	};
  }

}
