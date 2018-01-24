unit XUtils;

{$WARN  UNSAFE_CAST OFF}
{$WARN  UNSAFE_TYPE OFF}
{$WARN  UNSAFE_CODE OFF}
{$HINTS OFF}
{$WARN  UNSAFE_CODE OFF}


interface

uses Windows, Messages, Classes, SysUtils;

const
	UWM_SHOWMAINFORM = WM_USER + 100;

type
	TDoubleDynArr = array of Double;
  TIntegerDynArr = array of Integer;
  TBoolDynArr = array of Boolean;
  TDateTimeDynArr = array of TDateTime;
  TLongDateDynArr = TIntegerDynArr;

function IsAppRunning(AClassName, AWndName: string; ABringUp: Boolean = True): Boolean;
function GetModulePathName: string;
procedure SetAppCurWorkingDir;
function GetAppCurWorkingDir: string;

function GetFileNamesFromDir(ADir: string; SL: TStrings; Attr: Integer = faAnyFile): Boolean;
function GetAppendFileStream(AFN: string; var AFileStream: TFileStream): Boolean;
function GetConfigPathName(AExt: string = '.ini'): string;
function GetAppPath: string;
function GetAppVersionText: string;
function IsBeginWith(ABeginStr: string; S: string): Boolean;
function IsBeginWithNoCase(ABeginStr: string; S: string): Boolean;
function StringSaveToFile(S: string; FN: string): Boolean;
function StringLoadFromFile(FN: string): string;
function StringsToNetStringText(SL: TStrings): string;
procedure StringsFromNetStringText(SL: TStrings; NSText: string);
function SimpleEncrypt(S: string): string;
function StringToken(var S: string; Delimiter: string): string;
function StringCompareNoCase(const S1, S2: string): Integer;

procedure Trace(const S: string);
function NowGMT: TDateTime;
function AddLengthBeforeString(S: string): string;
function StringReplaceOnce(S, F, T: string): string;
procedure NetStringsToStrings(NS: string; SL: TStrings);
function StringsToNetStrings(SL: TStrings): string;
function VarRecToStr(Value: TVarRec): string;
function OptimaStatusString(AStatusCode: Integer): string;
function EncodeBinary(S: string): string;
function DecodeBinary(S: string): string;
function Base64Encode(const S: string): string;
function Base64Decode(S: string): string;
function URLDecode(const S: string): string;
function StrToFloatDef(const S: string; const Default: Extended): Extended;
function CompareDouble(V1, V2: Double; Eps: Double = 0.001): Integer;
function FormatDouble(Value: Double): string;
function GetRegistryValue(ARootKey: HKEY; AKeyName, AName: string): string;
procedure ShowTaskBar(Value: Boolean);
function GetMACAddress(var S: string; Sep: string = '-'): Boolean;
function GetHDSerial(var S: string; RootPathName: string = 'C:\'): Boolean;
function IsBusinessDBQuery(SQL:string):Boolean;
function IsSelectStatement(const S: string): Boolean;
function IsInsertStatement(const S: string): Boolean;

type
	TStringListEx = class(TStringList)
  private
    function GetTabText: string;
    procedure SetTabText(Value: string);
    function GetSafeCommaText: string;
    procedure SetSafeCommaText(Value: string);
    function GetValueFromIndex(Index: Integer): string;
    procedure SetValueFromIndex(Index: Integer; Value: string);
    function GetAsDoubleArray: string;
    procedure SetAsDoubleArray(Value: string);
    function GetAsDoubleDynArr: TDoubleDynArr;
    procedure SetAsDoubleDynArr(Value: TDoubleDynArr);
  public
  	procedure SortByName;
    function FindByName(N: string; var Index: Integer): Boolean;
		property TabText: string read GetTabText write SetTabText;
    property SafeCommaText: string read GetSafeCommaText write SetSafeCommaText;
    property ValueFromIndex[Index: Integer]: string read GetValueFromIndex write SetValueFromIndex;
    property AsDoubleArray: string read GetAsDoubleArray write SetAsDoubleArray;
    property AsDoubleDynArr: TDoubleDynArr read GetAsDoubleDynArr write SetAsDoubleDynArr;
  end;
  
  TStringMap = class(TObject)
  private
    FStrings: TStrings;
    FOwnsObjects: Boolean;
    function GetNames(Index: Integer): string;
    procedure SetNames(Index: Integer; Value: string);
    function GetValues(AName: string): string;
    procedure SetValues(AName: string; Value: string);
    function GetObjects(Index: Integer): TObject;
    procedure SetObjects(Index: Integer; Value: TObject);
    function GetValueFromIndex(Index: Integer): string;
    procedure SetValueFromIndex(Index: Integer; Value: string);
    function GetCount: Integer;
  public
		constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromFile(AFN: string);
    procedure SaveToFile(AFN: string);
		function Extract(AName: string): TObject;
    procedure Delete(Index: Integer);
		procedure Remove(AName: string);
    function Add(AName: string; AValue: string): Integer;
    function AddObject(AName: string; AValue: string; AObject: TObject = nil): Integer;
    procedure SortByName;
    function Find(AName: string; var Index: Integer): Boolean;
    property Names[Index: Integer]: string read GetNames write SetNames;
    property Values[AName: string]: string read GetValues write SetValues; default;
    property Objects[Index: Integer]: TObject read GetObjects write SetObjects;
    property ValueFromIndex[Index: Integer]: string read GetValueFromIndex write SetValueFromIndex;
    property Count: Integer read GetCount;
    property Strings: TStrings read FStrings;
  end;
  
implementation

uses FileCtrl, Registry, NB30X;

function PCharEx(S: string): PChar;
begin
  if Length(S) = 0 then Result := nil
  else Result := PChar(S);
end;

function IsAppRunning(AClassName, AWndName: string; ABringUp: Boolean = True): Boolean;
var
	H: HWND;
begin
	Result := False;
	H := FindWindow(PCharEx(AClassName), PCharEx(AWndName));
  if H <> 0 then
  begin
  	Result := True;
		if ABringUp then
    begin
			SendMessage(H, UWM_SHOWMAINFORM, 0, 0);
    end;
  end;
end;

procedure SetAppCurWorkingDir;
var
	S: string;
begin
	S := ExcludeTrailingBackslash(ExtractFilePath(GetModulePathName));
  SetCurrentDirectory(PChar(S));
end;

function GetAppCurWorkingDir: string;
var
	L: Integer;
begin
	SetString(Result, nil, MAX_PATH);
  L := GetCurrentDirectory(MAX_PATH, PChar(Result));
  SetLength(Result, L);
end;

function GetModulePathName: string;
var
	L: Integer;
begin
	SetString(Result, nil, MAX_PATH);
	L := GetModuleFileName(HInstance, PChar(Result), MAX_PATH);
  SetLength(Result, L);
end;

function GetAppendFileStream(AFN: string; var AFileStream: TFileStream): Boolean;
var
	H: Integer;
begin
	Result := False;
  if not FileExists(AFN) then
  begin
  	H := FileCreate(AFN);
    if H = -1 then Exit;
    FileClose(H);
  end;
  AFileStream := TFileStream.Create(AFN, fmOpenReadWrite or fmShareDenyWrite);
  AFileStream.Seek(0, soFromEnd);
  Result := True;
end;

function GetFileNamesFromDir(ADir: string; SL: TStrings; Attr: Integer = faAnyFile): Boolean;
var
  SR: TSearchRec;
	procedure CheckAndAdd;
  begin
		if (SR.Name = '.') or (SR.Name = '..') then Exit;
		if SR.Attr = faDirectory then SL.AddObject(SR.Name, TObject(1))
    else SL.Add(SR.Name);
  end;
begin
	Result := False;
  if not DirectoryExists(ADir) then
  	Exit;

  SL.Clear;
  if FindFirst(ADir, Attr, SR) = 0 then
  begin
  	CheckAndAdd;
    while FindNext(SR) = 0 do
      CheckAndAdd;
      
    FindClose(sr);
  end;

end;

function GetConfigPathName(AExt: string): string;
begin
	Result := ChangeFileExt(GetModulePathName, AExt);
end;

procedure GetVersionFromFile(aFileName: string; var aMajor, aMinor, aRelease, aBuild: Integer);
type
 PVS_FIXEDFILEINFO = ^VS_FIXEDFILEINFO;
var
 	h : Cardinal;        // a handle, ignore
  nSize : Cardinal;    // version info size
  pData : Pointer;     // version info data
  pffiData : PVS_FIXEDFILEINFO;  // fixed file info data
  nffiSize : Cardinal; // fixed file info size
begin
	aMajor   := 0;
  aMinor   := 0;
  aRelease := 0;
  aBuild   := 0;
	if FileExists(aFileName) then
     aBuild := 1;

	nSize := GetFileVersionInfoSize(PChar(aFileName), h);
  if nSize = 0 then
    Exit;
  GetMem( pData, nSize );
  try
    GetFileVersionInfo(PChar( aFileName ), h, nSize, pData);
    if VerQueryValue( pData, '\', Pointer( pffiData ), nffiSize) then
    begin
      aMajor   := ( pffiData^.dwFileVersionMS ) SHR 16;
      aMinor   := ( pffiData^.dwFileVersionMS ) AND $FFFF;
      aRelease := ( pffiData^.dwFileVersionLS ) SHR 16;
      aBuild   := ( pffiData^.dwFileVersionLS ) AND $FFFF;
     end;
  finally
    FreeMem(pData);
  end;
end;

function GetAppVersionText: string;
var
	Ma,Mi,Re,Bu: Integer;
begin
	GetVersionFromFile(GetModulePathName, Ma,Mi,Re,Bu);
  Result := Format('%d.%d.%d.%d', [Ma, Mi, Re, Bu]);
end;

function IsBeginWith(ABeginStr: string; S: string): Boolean;
begin
	Result := 0 = StrLComp(PChar(ABeginStr), PChar(S), Length(ABeginSTr));
end;

function IsBeginWithNoCase(ABeginStr: string; S: string): Boolean;
begin
	Result := 0 = StrLIComp(PChar(ABeginStr), PChar(S), Length(ABeginSTr));
end;

function StringSaveToFile(S: string; FN: string): Boolean;
var
	H: THandle;
  LH, LL: Cardinal;
begin
  Result := False;

	H := CreateFile(PChar(FN), GENERIC_WRITE,
  	FILE_SHARE_READ, nil,
    CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL, 0);

  if H = INVALID_HANDLE_VALUE then
  	Exit
  else
		try
    	LL := Length(S);
      if not WriteFile(H, PChar(S)^, LL, LH, nil) then
      	RaiseLastWin32Error;
    finally
			CloseHandle(H);
    end;

  Result := True;
end;

function StringLoadFromFile(FN: string): string;
const
	BufLen = 2048;
var
	H: THandle;
  Buf: array [0..BufLen-1] of Char;
  RL, BL, BRD: Cardinal;
  P: PChar;
  R: LongBool;
begin
	Result := '';
	H := CreateFile(PChar(FN), GENERIC_READ,
  	FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
    OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL, 0);

  if H = INVALID_HANDLE_VALUE then
  	RaiseLastWin32Error
  else
		try
			RL := 0;
      BL := BufLen;
			while True do
      begin
        R := ReadFile(H, Buf, BL, BRD, nil);
        if not R then
        	RaiseLastWin32Error;
        if BRD = 0 then
        	Break; // EOF

        SetLength(Result, RL + BRD);
        P := PChar(Result);
        Inc(P, RL);
				Move(Buf, P^, BRD);
				Inc(RL, BRD);
      end;
    finally
			CloseHandle(H);
    end;
end;

type
  PInteger = ^Integer;

function StringsToNetStringText(SL: TStrings): string;
var
  I, L, TL: Integer;
  P: PChar;
  S: string;
begin
  Result := '';
  TL := 0;
  for I := 0 to SL.Count -1 do
    Inc(TL, Length(SL[I]) + SizeOf(Integer));

  SetString(Result , nil, TL);

  P := PChar(Result);
  for I := 0 to SL.Count -1 do
  begin
    S := SL[I];
    L := Length(S);
    PInteger(P)^ := L;
    Inc(P, SizeOf(Integer));
    System.Move(PChar(S)^, P^, L);
    Inc(P, L);
  end;
end;

procedure StringsFromNetStringText(SL: TStrings; NSText: string);
var
  P: PChar;
  L, TL: Integer;
  S: string;
begin
  SL.Clear;
  TL := Length(NSText);
  P := PChar(NSText);

  while TL > 0 do
  begin
    L := PInteger(P)^;
    Inc(P, SizeOf(Integer));
    SetString(S, nil, L);
    System.Move(P^, PChar(S)^, L);
    Inc(P, L);
    Dec(TL, L + SizeOf(Integer));
    SL.Add(S);
  end;
end;

function GetAppPath: string;
begin
	Result := ExcludeTrailingBackslash(ExtractFilePath(GetModulePathName));
end;

function SimpleEncrypt(S: string): string;
const
	THE_KEY = 'System$Utils$Char';
var
	I, J, StrL, KeyL: Integer;
begin
	KeyL := Length(THE_KEY);
  StrL := Length(S);
	SetString(Result, nil, StrL);
 	J := KeyL;
  for I := 1 to StrL do
  begin
    Result[I] := Char( Integer(S[I]) xor Integer(THE_KEY[J]) );
    Dec(J);
    if J = 0 then
      J := KeyL;
  end;
end;

function StringToken(var S: string; Delimiter: string): string;
var
  I: Integer;
begin
  I := AnsiPos(Delimiter, S);
  if I <> 0 then
  begin
    Result := Copy(S, 1, I - 1);
    Delete(S, 1, I + Length(Delimiter) -1);
  end else
  begin
    Result := S;
    S := '';
  end;
end;

function StringCompareNoCase(const S1, S2: string): Integer;
begin
	Result := StrIComp(PChar(S1), PChar(S2));
end;

procedure Trace(const S: string);
begin
  OutputDebugString(PChar(S));
end;

function NowGMT: TDateTime;
var
  SystemTime: TSystemTime;
begin
  GetSystemTime(SystemTime);
  with SystemTime do
    Result := EncodeDate(wYear, wMonth, wDay) +
      EncodeTime(wHour, wMinute, wSecond, wMilliseconds);
end;

function AddLengthBeforeString(S: string): string;
var
	L: Integer;
  P: PChar;
begin
  L := Length(S);
  SetString(Result, nil, L + SizeOf(Integer));
  P := PChar(Result);
  PInteger(P)^ := L; Inc(P, SizeOf(Integer));
  System.Move(PChar(S)^, P^, L);
end;

function StringReplaceOnce(S, F, T: string): string;
var
	I: Integer;
begin
	I := Pos(F, S);
  if I = 0 then Result := S
  else begin
  	Result := Copy(S, 1, I - 1) + T + Copy(S, I + Length(F), MaxInt);
    UniqueString(Result);
  end;
end;

procedure NetStringsToStrings(NS: string; SL: TStrings);
var
	L, NSL: Integer;
  S: string;
  P: PChar;
begin
	SL.Clear;
  P := PChar(NS);
	NSL := Length(NS);
  while NSL >= SizeOf(Integer) do
  begin
		L := PInteger(P)^; Inc(P, SizeOf(Integer)); Dec(NSL, SizeOf(Integer));
    if L = 0 then
    	S := ''
    else
    begin
			SetString(S, nil, L);
			System.Move(P^, PChar(S)^, L);
    	Inc(P, L); Dec(NSL, L);
    end;
    SL.Add(S);
  end;
end;

function StringsToNetStrings(SL: TStrings): string;
var
	I, L, NSL: Integer;
  S: string;
  P: PChar;
begin
	NSL := 0;
  for I := 0 to SL.Count -1 do
		NSL := NSL + Length(SL[I]) + SizeOf(Integer);

  if NSL = 0 then Exit;

  SetString(Result, nil, NSL);
  P := PChar(Result);
  for I := 0 to SL.Count -1 do
  begin
  	S := SL[I];
    L := Length(S);
    PInteger(P)^ := L; Inc(P, SizeOf(Integer));
    if L > 0 then
    begin
	    System.Move(PChar(S)^, P^, L); Inc(P, L);
    end;
  end;
end;

function VarRecToStr(Value: TVarRec): string;
const
  BoolChars: array[Boolean] of Char = ('F', 'T');
begin
	Result := '';
	with Value do
		case VType of
        vtInteger:    Result := IntToStr(VInteger);
        vtBoolean:    Result := BoolChars[VBoolean];
        vtChar:       Result := VChar;
        vtExtended:   Result := FloatToStr(VExtended^);

        vtString:     Result := VString^;
        vtPChar:      Result := VPChar;
        vtObject:     Result := VObject.ClassName;
        vtClass:      Result := VClass.ClassName;
        vtAnsiString: Result := string(VAnsiString);
        vtCurrency:   Result := CurrToStr(VCurrency^);
        vtVariant:    Result := string(VVariant^);
        vtInt64:      Result := IntToStr(VInt64^);
    end;
end;

function StatusString(StatusCode: Integer): string;
begin
  case StatusCode of
    100: Result := 'Continue';
    101: Result := 'Switching Protocols';
    200: Result := 'OK';
    201: Result := 'Created';
    202: Result := 'Accepted';
    203: Result := 'Non-Authoritative Information';
    204: Result := 'No Content';
    205: Result := 'Reset Content';
    206: Result := 'Partial Content';
    300: Result := 'Multiple Choices';
    301: Result := 'Moved Permanently';
    302: Result := 'Moved Temporarily';
    303: Result := 'See Other';
    304: Result := 'Not Modified';
    305: Result := 'Use Proxy';
    400: Result := 'Bad Request';
    401: Result := 'Unauthorized';
    402: Result := 'Payment Required';
    403: Result := 'Forbidden';
    404: Result := 'Not Found';
    405: Result := 'Method Not Allowed';
    406: Result := 'None Acceptable (Please Check Client Date And Time)';
    407: Result := 'Proxy Authentication Required';
    408: Result := 'Request Timeout';
    409: Result := 'Conflict';
    410: Result := 'Gone';
    411: Result := 'Length Required';
    412: Result := 'Unless True';
    500: Result := 'Internal Server Error';
    501: Result := 'Not Implemented';
    502: Result := 'Bad Gateway';
    503: Result := 'Service Unavailable';
    504: Result := 'Gateway Timeout';
  else
    Result := '';
  end
end;

function OptimaStatusString(AStatusCode: Integer): string;
begin
  case AStatusCode of
  700: Result := 'Optima Bad Request';
  701: Result := 'Optima Unauthorize';
  702: Result := 'Optima Client DataTime Incorrect';
  703: Result := 'Optima Backend Service Unavailable';
  906: Result := 'Response Length Not Match Content-Length';
  908: Result := 'Forced Timeout';
  else
    Result := StatusString(AStatusCode);
  end;
end;

function EncodeBinary(S: string): string;
var
  I, SL, RL, CN: Integer;
  SP, RP: PChar;
  C: Char;
begin
  CN := 0;
  SL := Length(S);
  SP := PChar(S);
  for I := 1 to SL do
  begin
  	C := SP^;
    if (C = #0) or (C = #1) or (C = #39) then Inc(CN);
    Inc(SP);
  end;

  RL := SL + CN;
  SetString(Result, nil, RL);

  SP := PChar(S);
  RP := PChar(Result);
  for I := 1 to SL do
  begin
  	C := SP^;
    if C = #0 then begin RP^ := #1; Inc(RP); RP^ := #1; end
    else if C = #1 then begin RP^ := #1; Inc(RP); RP^ := #2; end
    else if C = #39 then begin RP^ := #1; Inc(RP); RP^ := #3; end // '
    else
      RP^ := SP^;

    Inc(SP);
    Inc(RP);
  end;
end;

function DecodeBinary(S: string): string;
var
  L, RL: Integer;
  SP, SPE, RP: PChar;
  C: Char;
begin
  L := Length(S);
  SetString(Result, nil, L);
  SP := PChar(S); SPE := SP; Inc(SPE, L);
  RP := PChar(Result);
  RL := 0;
  while SP <> SPE do
  begin
    if SP^ = #1 then
    begin
      Inc(SP);
      C := SP^;
      if C = #1 then RP^ := #0
      else if C = #2 then RP^ := #1
      else if C = #3 then RP^ := #39
      else break; // dead
    end else
    begin
      RP^ := SP^;
    end;
    Inc(SP);
    Inc(RP);
    Inc(RL);
  end; // while

  SetLength(Result, RL);
end;

const
  Base64Table: array [0..63] of Char =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
    'abcdefghijklmnopqrstuvwxyz' +
    '0123456789+/';

  Base64Pad = '=';

function Base64Encode(const S: string): string;
  function EstimateLength(Value: Integer): Integer;
  begin
    Result := (Value + 3 - Value mod 3) * 4 div 3 + 1;
  end;
var
  L: Integer;
  P, RP: PChar;
begin
	L := Length(S);
  if L = 0 then
		Exit;

  L := Length(S);
  SetLength(Result, EstimateLength(L));
  P := PChar(S);
  RP := PChar(Result);
  while L > 2 do
  begin
    RP^ := Base64Table[Integer(P[0]) shr 2]; Inc(RP);
    RP^ := Base64Table[((Integer(P[0]) and $03) shl 4) + (Integer(P[1]) shr 4)]; Inc(RP);
    RP^ := Base64Table[((Integer(P[1]) and $0f) shl 2) + (Integer(P[2]) shr 6)]; Inc(RP);
    RP^ := Base64Table[Integer(P[2]) and $3F]; Inc(RP);
    Inc(P, 3);
    L := L - 3;
  end; // while
  if L <> 0 then
  begin
    RP^ := Base64Table[Integer(P[0]) shr 2];  Inc(RP);
    if L > 1 then
    begin
      RP^ := Base64Table[((Integer(P[0]) and $03) shl 4) + Integer(P[1]) shr 4]; Inc(RP);
      RP^ := Base64Table[(Integer(P[1]) and $0F) shl 2]; Inc(RP);
      RP^ := Base64Pad; Inc(RP);
    end else
    begin
      RP^ := Base64Table[(Integer(P[0]) and $03) shl 4]; Inc(RP);
      RP^ := Base64Pad; Inc(RP);
      RP^ := Base64Pad; Inc(RP);
    end;
  end;
  SetLength(Result, RP - PChar(Result));
end;

function Base64Decode(S: string): string;
const
  Base64TB: array[0..127] of Char =
  (
    #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255,
    #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255,
    #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #062, #255, #255, #255, #063,
    #052, #053, #054, #055, #056, #057, #058, #059, #060, #061, #255, #255, #255, #255, #255, #255,
    #255, #000, #001, #002, #003, #004, #005, #006, #007, #008, #009, #010, #011, #012, #013, #014,
    #015, #016, #017, #018, #019, #020, #021, #022, #023, #024, #025, #255, #255, #255, #255, #255,
    #255, #026, #027, #028, #029, #030, #031, #032, #033, #034, #035, #036, #037, #038, #039, #040,
    #041, #042, #043, #044, #045, #046, #047, #048, #049, #050, #051, #255, #255, #255, #255, #255
  );
var
  SP, DP: PChar;
  CH: Char;
  A, B, I, SL: Integer;
begin
	SL := Length(S);
  if SL = 0 then
  begin
  	Result := '';
		Exit;
	end;
  A := 0; B := 0;
  SetString(Result, nil, SL);
  SP := PChar(S);
  DP := PChar(Result);
  for I := 0 to SL -1 do
  begin
    CH := Base64TB[Ord(SP^)];
    if (SP^ >= #128) or (CH = #255) then
      Break;
    A := (A shl 6) or Integer(CH);
    Inc(B, 6);
    if B >= 8 then
    begin
      Dec(B, 8);
      DP^ := Chr( (A shr B) and $FF );
      Inc(DP);
    end;
    Inc(SP);
  end;
  SetLength(Result, DP - PChar(Result));
end;

function URLDecode(const S: string): string;
var
  Sp, Rp, Cp: PChar;
  SL: Integer;
begin
	SL := Length(S);
  if SL = 0 then
		Exit;

  SetLength(Result, SL);
  Sp := PChar(S);
  Rp := PChar(Result);
  while Sp^ <> #0 do
  begin
    if not (Sp^ in ['+','%']) then
      Rp^ := Sp^
    else
      if Sp^ = '+' then
        Rp^ := ' '
      else
      begin
        inc(Sp);
        if Sp^ = '%' then
          Rp^ := '%'
        else
        begin
          Cp := Sp;
          Inc(Sp);
          Rp^ := Chr(StrToInt(Format('$%s%s',[Cp^, Sp^])));
        end;
      end;
    Inc(Rp);
    Inc(Sp);
  end;
  SetLength(Result, Rp - PChar(Result));
end;

function StrToFloatDef(const S: string; const Default: Extended): Extended;
begin
  if not TextToFloat(PChar(S), Result, fvExtended) then
    Result := Default;
end;

function CompareDouble(V1, V2: Double; Eps: Double): Integer;
var
	D, DP: Double;
begin
  D := V1 - V2;
	if D < 0 then DP := -1 * D else DP := D;
  if DP < Eps then Result := 0
  else if D > 0 then Result := -1
  else Result := 1;
end;

function FormatDouble(Value: Double): string;
begin
  if 0 = CompareDouble(Value, Trunc(Value)) then
    Result := IntToStr(Round(Value))
  else
    Result := FormatFloat('0.###',Value);
end;

function GetRegistryValue(ARootKey: HKEY; AKeyName, AName: string): string;
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create(KEY_READ);
  try
    Registry.RootKey := ARootKey;
    Registry.OpenKey(AKeyName, False);
    Result := Registry.ReadString(AName);
  finally
    Registry.Free;
  end;
end;

{TStringListEx}
function SortByNameCompFunc(S1, S2: string): Integer;
var
  P1, P2: PChar;
begin
  P1 := PChar(S1); P2 := PChar(S2);
  while True do
  begin
  	Result := Ord(P1^) - Ord(P2^);
    if (Result <> 0) then Exit;
    if ((P1^ = #0)or(P1^ = '=')) and (not((P2^ = #0)or(P2^ = '='))) then
    begin
    	Result := -1;
    	Exit;
    end
    else if (not((P1^ = #0)or(P1^ = '='))) and ((P2^ = #0)or(P2^ = '=')) then
    begin
			Result := 1;
    	Exit;
    end;
    Inc(P1); Inc(P2);
	end;
end;

function SortByNameFunc(List: TStringList; Index1, Index2: Integer): Integer;
begin
	Result := SortByNameCompFunc(List[Index1],List[Index2]);
end;

function EncryptCoder(S: string; Key: string): string;
var
  PK, PKH, PKM, PB: PChar;
  SL, KL, I: Integer;
begin
  Assert(Length(Key) > 3);
  SL := Length(S);
  KL := Length(Key);
  PKH := PChar(Key);
  PK := PKH; Inc(PK, KL - 2); // omit last char
  PKM := PKH; Inc(PKM, KL div 2);
  PB := PChar(S);
  for I := 0 to SL -1 do
  begin
    PB^ := Char( Integer(PB^) xor Integer(PK^) );
    Inc(PB);
    Dec(PK);
    if (PK = PKM) then Inc(PK); // omit middle char
    if (PK = PKH) then // omit first char
    begin
      PK := PKH; Inc(PK, KL -1);
    end;
  end;
  Result := S;
end;

procedure ShowTaskBar(Value: Boolean);
const
	TASKBAR_WND = 'Shell_TrayWnd';
var
	HTaskBar: HWND;
begin
	HTaskBar := FindWindow(PChar(TASKBAR_WND), nil);
  if Value then ShowWindow(HTaskBar, SW_RESTORE)
  else ShowWindow(HTaskBar, SW_HIDE);
end;

function GetAdapterInfo(Lana: Char; var S: string; Sep: string): Boolean;
var
  Adapter: TAdapterStatus;
  NCB: TNCB;
begin
	Result := False;
  FillChar(NCB, SizeOf(NCB), 0);
  NCB.ncb_command := Char(NCBRESET);
  NCB.ncb_lana_num := Lana;
  if Netbios(@NCB) <> Char(NRC_GOODRET) then
  	Exit;

  FillChar(NCB, SizeOf(NCB), 0);
  NCB.ncb_command := Char(NCBASTAT);
  NCB.ncb_lana_num := Lana;
  NCB.ncb_callname := '*';

  FillChar(Adapter, SizeOf(Adapter), 0);
  NCB.ncb_buffer := @Adapter;
  NCB.ncb_length := SizeOf(Adapter);

  if Netbios(@NCB) <> Char(NRC_GOODRET) then
	  Exit;

  S :=
  IntToHex(Byte(Adapter.adapter_address[0]), 2) + Sep +
  IntToHex(Byte(Adapter.adapter_address[1]), 2) + Sep +
  IntToHex(Byte(Adapter.adapter_address[2]), 2) + Sep +
  IntToHex(Byte(Adapter.adapter_address[3]), 2) + Sep +
  IntToHex(Byte(Adapter.adapter_address[4]), 2) + Sep +
  IntToHex(Byte(Adapter.adapter_address[5]), 2);

  Result := True;
end;

function GetMACAddress(var S: string; Sep: string): Boolean;
var
  AdapterList: TLanaEnum;
  NCB: TNCB;
begin
  FillChar(NCB, SizeOf(NCB), 0);
  NCB.ncb_command := Char(NCBENUM);
  NCB.ncb_buffer := @AdapterList;
  NCB.ncb_length := SizeOf(AdapterList);
  Netbios(@NCB);
  if Byte(AdapterList.length) > 0 then
  	Result := GetAdapterInfo(AdapterList.lana[0], S, Sep)
  else
  	Result := False;
end;

function GetHDSerial(var S: string; RootPathName: string): Boolean;
var
  VNB, FSN: array[0..MAX_PATH] of Char;
  SR, MCL, FSF: DWORD;
begin
  if GetVolumeInformation(PChar(RootPathName), @VNB, MAX_PATH, @SR, MCL, FSF, @FSN, MAX_PATH) then
  begin
    S := IntToStr(SR); Result := True;
  end else
  begin
    S := '0'; Result := False;
  end;
end;


{TStringListEx}
procedure TStringListEx.SortByName;
begin
	CustomSort(SortByNameFunc);
end;

function TStringListEx.FindByName(N: string; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := SortByNameCompFunc(Strings[I], N);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
      end;
    end;
  end;
  Index := L;
end;

function TStringListEx.GetTabText: string;
var
	RL, SL, I: Integer;
  S: string;
  PR: PChar;
begin
	RL := 0;
  for I := 0 to Count -1 do
  	Inc(RL, Length(Strings[I]) + 1);

  SetLength(Result, RL);
  if RL = 0 then Exit;

  PR := PChar(Result);
  for I := 0 to Count -1 do
  begin
  	S := Strings[I];
    SL := Length(S);
  	System.Move(PR^, PChar(S)^, SL);
    Inc(PR, SL);
    PR^ := #9;
    Inc(PR);
  end;
  System.Delete(Result, RL, 1);
end;

procedure TStringListEx.SetTabText(Value: string);
var
	S: string;
begin
	Self.Clear;
  if Length(Value) = 0 then
  	Exit;

  if Value[Length(Value)] = #9 then
  	Value := Value + #9;
    
	while True do
  begin
		S := StringToken(Value, #9);
   	Self.Add(S);
    if Length(Value) = 0 then Break;
  end;
end;

function TStringListEx.GetSafeCommaText: string;
var
	RL: Integer;
begin
	Result := CommaText;
  RL := Length(Result);
  if Result[RL] = ',' then
  	Result := Result + '""';
end;

procedure TStringListEx.SetSafeCommaText(Value: string);
begin
	Self.Clear;
  if Length(Value) = 0 then
  	Exit;

  if Value[Length(Value)] = ',' then
  	Value := Value + '""';

  Self.CommaText := Value;
end;

function TStringListEx.GetValueFromIndex(Index: Integer): string;
begin
	Result := Strings[Index];
  StringToken(Result, '=');
end;

procedure TStringListEx.SetValueFromIndex(Index: Integer; Value: string);
begin
	Strings[Index] := Format('%s=%s',[Names[Index],Value]);
end;

function TStringListEx.GetAsDoubleArray: string;
var
	I: Integer;
	PD: PDouble;
begin
  SetLength(Result, SizeOf(Double) * Self.Count);
  PD := PDouble(PChar(Result));
  for I := 0 to Self.Count -1 do
  begin
  	PD^ := StrToFloatDef(Self[I], 0);
    Inc(PD);
  end;
end;

procedure TStringListEx.SetAsDoubleArray(Value: string);
var
	I,DC: Integer;
	PD: PDouble;
begin
	DC := Length(Value) div SizeOf(Double);
  PD := PDouble(PChar(Value));
  Self.Clear;
	for I := 0 to DC -1 do
  begin
  	Self.Add(FormatDouble(PD^));
  	Inc(PD);
  end;
end;

function TStringListEx.GetAsDoubleDynArr: TDoubleDynArr;
var
	I: Integer;
begin
  SetLength(Result, Self.Count);
  for I := 0 to Self.Count -1 do
  	Result[I] := StrToFloatDef(Self[I], 0);
end;

procedure TStringListEx.SetAsDoubleDynArr(Value: TDoubleDynArr);
var
	I: Integer;
begin
  Self.Clear;
	for I := 0 to Length(Value) -1 do
  	Self.Add(FormatDouble(Value[I]));
end;

{TStringMap}

constructor TStringMap.Create;
begin
	inherited Create;
  FStrings := TStringList.Create;
end;

destructor TStringMap.Destroy;
begin
	FStrings.Free;
	inherited Destroy;
end;

procedure TStringMap.Clear;
var
	I: Integer;
begin
	if FOwnsObjects then
  	for I := 0 to Count -1 do
    	FStrings.Objects[I].Free;

	FStrings.Clear;
end;

function TStringMap.Extract(AName: string): TObject;
var
	I: Integer;
begin
	if Find(AName, I) then
  begin
  	Result :=	FStrings.Objects[I];
    FStrings.Delete(I);
  end else
  	Result := nil;
end;

procedure TStringMap.Remove(AName: string);
var
	I: Integer;
begin
	if Find(AName, I) then
  begin
  	if FOwnsObjects then
    	FStrings.Objects[I].Free;

		FStrings.Delete(I);
  end;
end;

procedure TStringMap.Delete(Index: Integer);
begin
	if FOwnsObjects then
  	FStrings.Objects[Index].Free;

	FStrings.Delete(Index);
end;

function TStringMap.GetNames(Index: Integer): string;
begin
	Result := FStrings[Index];
	Result := StringToken(Result, '=');
end;

procedure TStringMap.SetNames(Index: Integer; Value: string);
var
  S: string;
begin
	S := FStrings[Index];
  StringToken(S, '=');
  FStrings[Index] := Value + '=' + S;
end;

function TStringMap.GetValues(AName: string): string;
var
	I: Integer;
begin
	if Find(AName, I) then Result := GetValueFromIndex(I)
  else Result := '';
end;

procedure TStringMap.SetValues(AName: string; Value: string);
begin
	Add(AName, Value);
end;

function TStringMap.GetValueFromIndex(Index: Integer): string;
begin
	Result := FStrings[Index];
	StringToken(Result, '=');
end;

procedure TStringMap.SetValueFromIndex(Index: Integer; Value: string);
var
	S, N: string;
begin
	S := FStrings[Index];
  N := StringToken(S, '=');
  FStrings[Index] := N + '=' + Value;
end;

function TStringMap.GetCount: Integer;
begin
	Result := FStrings.Count;
end;

function TStringMap.Add(AName: string; AValue: string): Integer;
begin
	if Find(AName, Result) then
  	FStrings[Result] := AName + '=' + AValue
  else
  	FStrings.Insert(Result, AName + '=' + AValue);
end;

function TStringMap.AddObject(AName: string; AValue: string; AObject: TObject): Integer;
begin
	Result := Add(AName, AValue);
  FStrings.Objects[Result] := AObject;
end;

function TStringMap.GetObjects(Index: Integer): TObject;
begin
	Result := FStrings.Objects[Index];
end;

procedure TStringMap.SetObjects(Index: Integer; Value: TObject);
begin
	FStrings.Objects[Index] := Value;
end;

function StringMapCompareName(S1, S2: string): Integer;
var
	P1, P2: PChar;
begin
	P1 := PChar(S1); P2 := PChar(S2);
  while True do
  begin
    if (P1^ = '=') then
    begin
    	if (P2^ = #0) or (P2^ = '=') then Result := 0
      else Result := -1;
			Exit;
    end;

    if (P2^ = '=') then
    begin
    	if (P1^ = #0) or (P1^ = '=') then Result := 0
      else Result := 1;
			Exit;
    end;
    
  	Result := Ord(P1^) - Ord(P2^);
	  if (Result <> 0) or (P1^ = #0) or (P2^ = #0) then
  		Exit;

		Inc(P1); Inc(P2);
  end;
end;

function TStringMap.Find(AName: string; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := StringMapCompareName(FStrings[I], AName);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        L := I; // no duplicate
      end;
    end;
  end;
  Index := L;
end;

function StringsSortFunc(List: TStringList; Index1, Index2: Integer): Integer;
begin
	Result := StringMapCompareName(List[Index1], List[Index2]);
end;

procedure TStringMap.SortByName;
begin
	TStringList(FStrings).CustomSort(StringsSortFunc);
end;

procedure TStringMap.LoadFromFile(AFN: string);
begin
	FStrings.Clear;
  try
  	if FileExists(AFN) then
    begin
			FStrings.LoadFromFile(AFN);
  		SortByName;
    end;
  except
// FIXME
  end;
end;

procedure TStringMap.SaveToFile(AFN: string);
begin
	FStrings.SaveToFile(AFN);
end;


const
  FK_TABLE='FK';
  EXCEPTBY='SDBDLL_MASTER';
  EXCEPTCREATE='CREATE';
  EXCEPTDROP='CREATE';
function IsBusinessDBQuery(SQL:string):Boolean;
var
  S1,S2:string;
begin
  S1 := UpperCase(SQL);
  S2 := StringToken(S1,FK_TABLE);
  Result := S1<>'';
end;

const
	SELECT_STATEMENT_BEGIN = 'select';
	INSERT_STATEMENT_BEGIN = 'insert';
  REPLACE_STATEMENT_BEGIN = 'replace';

function IsSelectStatement(const S: string): Boolean;
begin
	Result := 0 = StrLIComp(PChar(SELECT_STATEMENT_BEGIN), PChar(Trim(S)), Length(SELECT_STATEMENT_BEGIN));
end;

function IsInsertStatement(const S: string): Boolean;
begin
	Result := (0 = StrLIComp(PChar(INSERT_STATEMENT_BEGIN), PChar(S), Length(INSERT_STATEMENT_BEGIN)))
   or (0 = StrLIComp(PChar(REPLACE_STATEMENT_BEGIN), PChar(S), Length(REPLACE_STATEMENT_BEGIN)));
end;

{$WARN  UNSAFE_CAST ON}
{$WARN  UNSAFE_TYPE ON}
{$WARN  UNSAFE_CODE ON}
{$HINTS ON}
{$WARN  UNSAFE_CODE ON}

end.
