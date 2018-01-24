unit uZlib;

interface
{$WARN  UNSAFE_CAST OFF}
{$WARN  UNSAFE_TYPE OFF}
{$WARN  UNSAFE_CODE OFF}
{$HINTS OFF}
{$WARN  UNSAFE_CODE OFF}
uses SysUtils,Windows,Dialogs;

{$I CMPLRSET.INC}

type
  TZLevel = (zcNone, zcFastest, zcDefault, zcMax);

  EZLibError = class(Exception);
  EZCompressionError = class(EZLibError);
  EZDecompressionError = class(EZLibError);

  function ZlibCompress(const S: string; Level: TZLevel = zcDefault): string;
  function ZlibDecompress(const S: string; Level: TZLevel = zcDefault): string;

implementation


const
  ZLIB_VERSION = '1.1.4';
	ZLIB_DLL		= 'zlib.dll';
  
type
  TZAlloc = function (opaque: Pointer; items, size: Integer): Pointer; stdcall;
  TZFree  = procedure (opaque, block: Pointer); stdcall;

  TZStream = packed record
    next_in  : Pointer;     // next input byte
    avail_in : Longint;   // number of bytes available at next_in
    total_in : Longint;   // total nb of input bytes read so far

    next_out : Pointer;     // next output byte should be put here
    avail_out: Longint;   // remaining free space at next_out
    total_out: Longint;   // total nb of bytes output so far

    msg      : PChar;     // last error message, NULL if no error
    state    : Pointer;   // not visible by applications

    zalloc   : TZAlloc;   // used to allocate the internal state
    zfree    : TZFree;    // used to free the internal state
    opaque   : Pointer;   // private data object passed to zalloc and zfree

    data_type: Integer;   // best guess about the data type: ascii or binary
    adler    : Longint;   // adler32 value of the uncompressed data
    reserved : Longint;   // reserved for future use
  end;

const
  Z_NO_FLUSH      = 0;
  Z_PARTIAL_FLUSH = 1;
  Z_SYNC_FLUSH    = 2;
  Z_FULL_FLUSH    = 3;
  Z_FINISH        = 4;

  Z_OK            = 0;
  Z_STREAM_END    = 1;
  Z_NEED_DICT     = 2;
  Z_ERRNO         = (-1);
  Z_STREAM_ERROR  = (-2);
  Z_DATA_ERROR    = (-3);
  Z_MEM_ERROR     = (-4);
  Z_BUF_ERROR     = (-5);
  Z_VERSION_ERROR = (-6);

  Z_NO_COMPRESSION       =   0;
  Z_BEST_SPEED           =   1;
  Z_BEST_COMPRESSION     =   9;
  Z_DEFAULT_COMPRESSION  = (-1);

  Z_FILTERED            = 1;
  Z_HUFFMAN_ONLY        = 2;
  Z_DEFAULT_STRATEGY    = 0;

  Z_BINARY   = 0;
  Z_ASCII    = 1;
  Z_UNKNOWN  = 2;

  Z_DEFLATED = 8;
	Z_NULL			= nil;

  _z_errmsg: array[0..9] of PChar = (
    'need dictionary',      // Z_NEED_DICT      (2)
    'stream end',           // Z_STREAM_END     (1)
    '',                     // Z_OK             (0)
    'file error',           // Z_ERRNO          (-1)
    'stream error',         // Z_STREAM_ERROR   (-2)
    'data error',           // Z_DATA_ERROR     (-3)
    'insufficient memory',  // Z_MEM_ERROR      (-4)
    'buffer error',         // Z_BUF_ERROR      (-5)
    'incompatible version', // Z_VERSION_ERROR  (-6)
    ''
  );

  ZLevels: array [TZLevel] of Shortint = (
    Z_NO_COMPRESSION,
    Z_BEST_SPEED,
    Z_DEFAULT_COMPRESSION,
    Z_BEST_COMPRESSION
  );

  {
function zlibVersion: PChar; stdcall; external ZLIB_DLL;
function deflateInit_(var strm: TZStream; level: Integer; version: PChar; recsize: Integer): Integer; stdcall; external ZLIB_DLL;
function deflate(var strm: TZStream; flush: Integer): Integer; stdcall; external ZLIB_DLL;
function deflateEnd(var strm: TZStream): Integer; stdcall; external ZLIB_DLL;
function inflateInit_(var strm: TZStream; version: PChar; recsize: Integer): Integer; stdcall; external ZLIB_DLL;
function inflate(var strm: TZStream; flush: Integer): Integer; stdcall; external ZLIB_DLL;
function inflateEnd(var strm: TZStream): Integer; stdcall; external ZLIB_DLL;
function inflateReset(var strm: TZStream): Integer; stdcall; external ZLIB_DLL;
   }
var
	zlibVersion: function: PChar; stdcall;
	deflateInit_: function(var strm: TZStream; level: Integer; version: PChar; recsize: Integer): Integer; stdcall;
	deflate: function(var strm: TZStream; flush: Integer): Integer; stdcall;
	deflateEnd: function(var strm: TZStream): Integer; stdcall;
	inflateInit_: function(var strm: TZStream; version: PChar; recsize: Integer): Integer; stdcall;
	inflate: function(var strm: TZStream; flush: Integer): Integer; stdcall;
	inflateEnd: function(var strm: TZStream): Integer; stdcall;
	inflateReset: function(var strm: TZStream): Integer; stdcall;

{ aux funcs }

function DeflateInit(var stream: TZStream; level: Integer): Integer;
begin
  result := DeflateInit_(stream,level,ZLIB_VERSION, SizeOf(TZStream));
end;

function InflateInit(var stream: TZStream): Integer;
begin
  result := InflateInit_(stream,ZLIB_VERSION,SizeOf(TZStream));
end;

function ZCompressCheck(code: Integer): Integer;
begin
  result := code;

  if code < 0 then
  begin
    raise EZCompressionError.Create(_z_errmsg[2 - code]);
  end;
end;

function ZDecompressCheck(code: Integer): Integer;
begin
  Result := code;

  if code < 0 then
  begin
    raise EZDecompressionError.Create(_z_errmsg[2 - code]);
  end;
end;

procedure ZlibCompress_(const inBuffer: Pointer; inSize: Integer;
	out outBuffer: Pointer; out outSize: Integer; Level: TZLevel);
const
  delta = 256;
var
	ZStream: TZStream;
begin
	FillChar(ZStream,SizeOf(TZStream),0);
  outSize := ((inSize + (inSize div 10) + 12) + 255) and not 255;
  GetMem(outBuffer,outSize);
  try
    ZStream.next_in := inBuffer;
    ZStream.avail_in := inSize;
    ZStream.next_out := outBuffer;
    ZStream.avail_out := outSize;
    ZCompressCheck(DeflateInit(ZStream, ZLevels[Level]));
    try
      while ZCompressCheck(deflate(ZStream,Z_FINISH)) <> Z_STREAM_END do
      begin
        Inc(outSize,delta);
        ReallocMem(outBuffer,outSize);
        ZStream.next_out := PChar(Integer(outBuffer) + ZStream.total_out);
        ZStream.avail_out := delta;
      end;
    finally
      ZCompressCheck(deflateEnd(ZStream));
    end;
    ReallocMem(outBuffer,ZStream.total_out);
    outSize := ZStream.total_out;
  except
    FreeMem(outBuffer);
    raise;
  end;
end;

procedure ZlibDecompress_(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer; outEstimate: Integer = 0);
var
  delta  : Integer;
	ZStream: TZStream;
begin
  FillChar(ZStream,SizeOf(TZStream),0);
  delta := (inSize + 255) and not 255;
  if outEstimate = 0 then
    outSize := delta
  else
    outSize := outEstimate;

  GetMem(outBuffer,outSize);
//  GetMem(outBuffer,1024);
//  GetMem(TempBuffer,outSize);
  try
    ZStream.next_in := inBuffer;
    ZStream.avail_in := inSize;
    ZStream.next_out := outBuffer;
    ZStream.avail_out := outSize;
    ZDecompressCheck(InflateInit(ZStream));
    try
      while ZDecompressCheck(inflate(ZStream,Z_NO_FLUSH)) <> Z_STREAM_END do
      begin
        Inc(outSize,delta);
        ReallocMem(outBuffer,outSize);
        ZStream.next_out := PChar(Integer(outBuffer) + ZStream.total_out);
        ZStream.avail_out := delta;
      end;
    finally
      ZDecompressCheck(inflateEnd(ZStream));
    end;
    ReallocMem(outBuffer,ZStream.total_out);
    outSize := ZStream.total_out; 
  except
    FreeMem(outBuffer);
    raise;
  end;
end;

function ZlibCompress(const S: string; Level: TZLevel): string;
var
  Buffer: Pointer;
  Size  : Integer;
begin
 	Buffer := nil;
	try
   	ZlibCompress_(PChar(S), Length(S), Buffer, Size, Level);
   	SetLength(Result, Size);
   	Move(Buffer^, Result[1], Size);
  finally
	 FreeMem(Buffer);
  end;
end;

function ZlibDecompress(const S: string; Level: TZLevel): string;
var
  Buffer: Pointer;
  Size  : Integer;
begin
  Size := 0;
	Buffer := nil;
	try
  	ZlibDecompress_(PChar(S), Length(S), Buffer, Size);
  	SetString(Result, nil, Size);
  	Move(Buffer^, PChar(Result)^, Size);
  finally
	  FreeMem(Buffer);
  end;
end;

var
  GDLLHandle: THandle;
  
type
  TGetFuncAddress = function(hModule: THandle; nNo: Integer): Pointer; stdcall;

function GetABSPathName(S: string): string;
begin
  {$WARNINGS OFF}
  if IsLibrary then
  begin
    SetString(Result, nil, MAX_PATH);
    Windows.GetModuleFileName(HInstance, PChar(Result), Length(Result));
    SetLength(Result, StrLen(PChar(Result)));

    Result := IncludeTrailingBackSlash(ExtractFilePath(Result)) + S;

  end else
    Result := IncludeTrailingBackSlash(ExtractFilePath(ParamStr(0))) + S;

    {$WARNINGS ON}
end;

procedure LoadZlibDLL;
  procedure GetFunc(var p: Pointer; fn: string);
  begin
    p := GetProcAddress(GDLLHandle, PChar(fn));
    if p = nil then
      ShowMessage('unable to load ' + fn);
  end;
begin
  GDLLHandle := LoadLibrary(PChar(GetABSPathName(ZLIB_DLL)));
  if GDLLHandle <> 0 then
  begin
    GetFunc(@zlibVersion, 'zlibVersion');
    GetFunc(@deflateInit_, 'deflateInit_');
    GetFunc(@deflate, 'deflate');
    GetFunc(@deflateEnd, 'deflateEnd');
    GetFunc(@inflateInit_, 'inflateInit_');
    GetFunc(@inflate, 'inflate');
    GetFunc(@inflateEnd, 'inflateEnd');
    GetFunc(@inflateReset, 'inflateReset');
  end;
end;

initialization
  LoadZlibDLL;

finalization
  if GDLLHandle <> 0 then
    FreeLibrary(GDLLHandle);
{$WARN  UNSAFE_CAST ON}
{$WARN  UNSAFE_TYPE ON}
{$WARN  UNSAFE_CODE ON}
{$HINTS ON}
{$WARN  UNSAFE_CODE ON}    
end.

