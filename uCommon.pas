unit uCommon;

interface

uses
  SysUtils, Classes, Controls, windows;

type
  TCommon = class(TPersistent)
  private
    function GetAdapterInfo(Lana: Char; var S: string; Sep: string): Boolean;
    function GetCurrentPath: string;
    procedure GetVersionFromFile(aFileName: string; var aMajor, aMinor, aRelease, aBuild: Integer);
  public
    function Base64Decode(S: string): string;
    function Base64Encode(const S: string): string;
    function BooleanToStr(const ABoolean: Boolean; const TrueStr, FalseStr: string): string; overload;
    function BooleanToStr(const ABoolean: Boolean; const TrueStr, FalseStr: string; var m: Integer): string; overload;
    function Decode(Source: string): string;
    function DTI8(const _Date: TDate): Integer;
    function DTS19(const _Date: TDateTime): string;
    function DTS8(const _Date: TDate): string;
    function Encode(Source: string): string;
    function GetAppVersionText: string;
    function GetHDSerial(var S: string; RootPathName: string = 'C:\'): Boolean;
    function GetLocalIP: string;
    function GetMACAddress(var S: string; Sep: string = '-'): Boolean;
    function GetModulePathName: string;
    function I8TD(const _IDATE: Integer): TDate;
    function ITD(const AIntDate: Integer): TDateTime;
    function NEWID: string;
    procedure PingServer(const AIP: string);
    function S8TD(_SDate: string): TDate;
    function SimpleEncrypt(S: string): string;
    property CurrentPath: string read GetCurrentPath;
  end;

implementation

uses
  NB30X, WinSock, ActiveX, dialogs;

{
*********************************** TCommon ************************************
}

function IsNetworkAlive(varlpdwFlagsLib: Integer): Integer; stdcall; external 'SENSAPI.DLL';

const
  NETWORK_ALIVE_LAN = 1;  //通过局域网上网

const
  NETWORK_ALIVE_WAN = 2;  //通过广域网上网

const
  NETWORK_ALIVE_AOL = 4;  //仅对98/95有效判断是否联上美国网络

procedure ShowNetWorkState();
{-------------------------------------------------------------------------------
  过程名:    ShowNetWorkState
  作者:      robert
  日期:      2018.01.24
  参数:      
  返回值:    无
  说明:      判断网络是否连接
	
-------------------------------------------------------------------------------}
var
  falg: integer;
  Bos: boolean;
begin
  Bos := false;
  IsNetworkAlive(falg);
  case falg of
    NETWORK_ALIVE_LAN:
      begin
        Showmessage('通过局域网上网。');
        Bos := true;
      end;
    NETWORK_ALIVE_WAN:
      begin
        Showmessage('通过广域网上网。');
        Bos := true;
      end;
    NETWORK_ALIVE_AOL:
      begin
        Showmessage('联上美国的网络。');  //仅对98/95有效所以一般不用判断NETWORK_ALIVE_AOL
        Bos := true;
      end;
  else
    Showmessage('没有联网。');
  end;  //case
  if Bos then
    Showmessage('你现在是联网状态！')
  else
    Showmessage('你现在是离线状态！');
end;

function InetIsOffline(Flag: Integer): Boolean; stdcall; external 'URL.DLL';

function isNetifOffLine: Boolean;
{-------------------------------------------------------------------------------
  过程名:    isNetifOffLine
  作者:      robert
  日期:      2018.01.24
  参数:      无
  返回值:    Boolean
  说明:      该函数返回TRUE说明本地系统没有连接到INTERNET。
附:
大多数装有IE或OFFICE97的系统都有此DLL可供调用。
InetIsOffline
BOOL InetIsOffline(
DWORD dwFlags,
);
	
-------------------------------------------------------------------------------}
begin
  Result := InetIsOffline(0);

  if Result then
    ShowMessage('没有连接到网络')
  else
    ShowMessage('已经连接到网络');
end;

function TCommon.Base64Decode(S: string): string;
const
  Base64TB: array[0..127] of Char = (#255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #255, #062, #255, #255, #255, #063, #052, #053, #054, #055, #056, #057, #058, #059, #060, #061, #255, #255, #255, #255, #255, #255, #255, #000, #001, #002, #003, #004, #005, #006, #007, #008, #009, #010, #011, #012, #013, #014, #015, #016, #017, #018, #019, #020, #021, #022, #023, #024, #025, #255, #255, #255, #255, #255, #255, #026, #027, #028, #029, #030, #031, #032, #033, #034, #035, #036, #037, #038, #039, #040, #041, #042, #043, #044, #045, #046, #047, #048, #049, #050, #051, #255, #255, #255, #255, #255);
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
  A := 0;
  B := 0;
  SetString(Result, nil, SL);
  SP := PChar(S);
  DP := PChar(Result);
  for I := 0 to SL - 1 do
  begin
    CH := Base64TB[Ord(SP^)];
    if (SP^ >= #128) or (CH = #255) then
      Break;
    A := (A shl 6) or Integer(CH);
    Inc(B, 6);
    if B >= 8 then
    begin
      Dec(B, 8);
      DP^ := Chr((A shr B) and $FF);
      Inc(DP);
    end;
    Inc(SP);
  end;
  SetLength(Result, DP - PChar(Result));
end;

function TCommon.Base64Encode(const S: string): string;
const
  Base64Table: array[0..63] of Char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + 'abcdefghijklmnopqrstuvwxyz' + '0123456789+/';
  Base64Pad = '=';

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
    RP^ := Base64Table[Integer(P[0]) shr 2];
    Inc(RP);
    RP^ := Base64Table[((Integer(P[0]) and $03) shl 4) + (Integer(P[1]) shr 4)];
    Inc(RP);
    RP^ := Base64Table[((Integer(P[1]) and $0f) shl 2) + (Integer(P[2]) shr 6)];
    Inc(RP);
    RP^ := Base64Table[Integer(P[2]) and $3F];
    Inc(RP);
    Inc(P, 3);
    L := L - 3;
  end; // while
  if L <> 0 then
  begin
    RP^ := Base64Table[Integer(P[0]) shr 2];
    Inc(RP);
    if L > 1 then
    begin
      RP^ := Base64Table[((Integer(P[0]) and $03) shl 4) + Integer(P[1]) shr 4];
      Inc(RP);
      RP^ := Base64Table[(Integer(P[1]) and $0F) shl 2];
      Inc(RP);
      RP^ := Base64Pad;
      Inc(RP);
    end
    else
    begin
      RP^ := Base64Table[(Integer(P[0]) and $03) shl 4];
      Inc(RP);
      RP^ := Base64Pad;
      Inc(RP);
      RP^ := Base64Pad;
      Inc(RP);
    end;
  end;
  SetLength(Result, RP - PChar(Result));
end;

function TCommon.BooleanToStr(const ABoolean: Boolean; const TrueStr, FalseStr: string): string;
begin
  Result := TrueStr;
  if not ABoolean then
    Result := FalseStr;
end;

function TCommon.BooleanToStr(const ABoolean: Boolean; const TrueStr, FalseStr: string; var m: Integer): string;
begin
  Result := TrueStr;
  if not ABoolean then
  begin
    Result := FalseStr;
    Inc(m);
  end;
end;


function TCommon.Decode(Source: string): string;
{-------------------------------------------------------------------------------
  过程名:    TCommon.Decode
  作者:      robert
  日期:      2018.01.24
  参数:      Source: string
  返回值:    string
  说明:      解密字符串
-------------------------------------------------------------------------------}
begin
  Result := SimpleEncrypt(Base64Decode(Source));
end;

function TCommon.DTI8(const _Date: TDate): Integer;
var
  Y, M, Dy: Word;

  {-------------------------------------------------------------------------------
    过程名:    TBaseMgr.DTI8
    作者:      robert
    日期:      2017.08.11
    参数:      const _Date: TDate
    返回值:    Integer
    说明:      将一个标准的日期转换为8位数字
  -------------------------------------------------------------------------------}

begin
  DecodeDate(_Date, Y, M, Dy);
  Result := Y * 10000 + M * 100 + Dy;
end;

function TCommon.DTS19(const _Date: TDateTime): string;

  {-------------------------------------------------------------------------------
    过程名:    TBaseMgr.DTS19
    作者:      robert
    日期:      2017.08.11
    参数:      const _Date: TDateTime
    返回值:    string
    说明:      将一个日期转换为19位字符串
  -------------------------------------------------------------------------------}

begin
  Result := FormatDateTime('YYYYMMDDHHMMSSZZZ', _Date);
end;

function TCommon.DTS8(const _Date: TDate): string;

  {-------------------------------------------------------------------------------
    过程名:    TBaseMgr.DTS8
    作者:      robert
    日期:      2017.08.11
    参数:      const _Date: TDate
    返回值:    string
    说明:       将一个日期转换为8位字符串
  -------------------------------------------------------------------------------}

begin
  Result := IntToStr(DTI8(_Date));
end;



function TCommon.Encode(Source: string): string;
{-------------------------------------------------------------------------------
  过程名:    TCommon.Encode
  作者:      robert
  日期:      2018.01.24
  参数:      Source: string
  返回值:    string
  说明:      加密字符串	
-------------------------------------------------------------------------------}
begin
  Result := Base64Encode(SimpleEncrypt(Source));
end;

function TCommon.GetAdapterInfo(Lana: Char; var S: string; Sep: string): Boolean;
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

  S := IntToHex(Byte(Adapter.adapter_address[0]), 2) + Sep + IntToHex(Byte(Adapter.adapter_address[1]), 2) + Sep + IntToHex(Byte(Adapter.adapter_address[2]), 2) + Sep + IntToHex(Byte(Adapter.adapter_address[3]), 2) + Sep + IntToHex(Byte(Adapter.adapter_address[4]), 2) + Sep + IntToHex(Byte(Adapter.adapter_address[5]), 2);

  Result := True;
end;

function TCommon.GetAppVersionText: string;
var
  Ma, Mi, Re, Bu: Integer;

  {-------------------------------------------------------------------------------
    过程名:    TSystemMgr.GetAppVersionText
    作者:      robert
    日期:      2017.08.11
    参数:      无
    返回值:    string
    说明:      取得当前应用程序的版本
  -------------------------------------------------------------------------------}

begin
  GetVersionFromFile(GetModulePathName, Ma, Mi, Re, Bu);
  Result := Format('%d.%d.%d.%d', [Ma, Mi, Re, Bu]);
end;

function TCommon.GetCurrentPath: string;
begin
  Result := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
end;

function TCommon.GetHDSerial(var S: string; RootPathName: string = 'C:\'): Boolean;
var
  VNB, FSN: array[0..MAX_PATH] of Char;
  SR, MCL, FSF: DWORD;

  {-------------------------------------------------------------------------------
    过程名:    TSystemMgr.GetHDSerial
    作者:      robert
    日期:      2017.08.11
    参数:      var S: string; RootPathName: string
    返回值:    Boolean
    说明:      取得当前应用程序的版本系列号
  -------------------------------------------------------------------------------}

begin
  if GetVolumeInformation(PChar(RootPathName), @VNB, MAX_PATH, @SR, MCL, FSF, @FSN, MAX_PATH) then
  begin
    S := IntToStr(SR);
    Result := True;
  end
  else
  begin
    S := '0';
    Result := False;
  end;
end;

function TCommon.GetLocalIP: string;
var
  hostent: PHostEnt;
  ip: string;
  addr: PChar;
  buffer: array[0..63] of char;
  ginitdata: twsadata;

  {-------------------------------------------------------------------------------
    过程名:    TSystemMgr.GetLocalIP
    作者:      robert
    日期:      2017.08.11
    参数:      无
    返回值:    string
    说明:      取得本地IP地址
  -------------------------------------------------------------------------------}

begin
  Result := '';
  try
    wsastartup(2, ginitdata);
    gethostname(buffer, sizeof(buffer));
    hostent := gethostbyname(buffer);
    if hostent = nil then
      exit;
    addr := hostent^.h_addr_list^;
    ip := format('%d.%d.%d.%d', [byte(addr[0]), byte(addr[1]), byte(addr[2]), byte(addr[3])]);
    Result := ip;
  finally
    wsacleanup;
  end;
end;

function TCommon.GetMACAddress(var S: string; Sep: string = '-'): Boolean;
var
  AdapterList: TLanaEnum;
  NCB: TNCB;

  {-------------------------------------------------------------------------------
    过程名:    TSystemMgr.GetMACAddress
    作者:      robert
    日期:      2017.08.11
    参数:      var S: string; Sep: string
    返回值:    Boolean
    说明:      取得MAC地址
  -------------------------------------------------------------------------------}

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

function TCommon.GetModulePathName: string;
var
  L: Integer;

  {-------------------------------------------------------------------------------
    过程名:    TSystemMgr.GetModulePathName
    作者:      robert
    日期:      2017.08.11
    参数:      无
    返回值:    string
    说明:      取得当前应用程序模块名称
  -------------------------------------------------------------------------------}

begin
  SetString(Result, nil, MAX_PATH);
  L := GetModuleFileName(HInstance, PChar(Result), MAX_PATH);
  SetLength(Result, L);
end;



procedure TCommon.GetVersionFromFile(aFileName: string; var aMajor, aMinor, aRelease, aBuild: Integer);
{-------------------------------------------------------------------------------
  过程名:    TCommon.GetVersionFromFile
  作者:      robert
  日期:      2018.01.24
  参数:      aFileName: string; var aMajor, aMinor, aRelease, aBuild: Integer
  返回值:    无
  说明:      从文件取得版本号	
-------------------------------------------------------------------------------}
type
  PVS_FIXEDFILEINFO = ^VS_FIXEDFILEINFO;
var
  h: Cardinal;        // a handle, ignore
  nSize: Cardinal;    // version info size
  pData: Pointer;     // version info data
  pffiData: PVS_FIXEDFILEINFO;  // fixed file info data
  nffiSize: Cardinal; // fixed file info size

begin
  aMajor := 0;
  aMinor := 0;
  aRelease := 0;
  aBuild := 0;
  if FileExists(aFileName) then
    aBuild := 1;

  nSize := GetFileVersionInfoSize(PChar(aFileName), h);
  if nSize = 0 then
    Exit;
  GetMem(pData, nSize);
  try
    GetFileVersionInfo(PChar(aFileName), h, nSize, pData);
    if VerQueryValue(pData, '\', Pointer(pffiData), nffiSize) then
    begin
      aMajor := (pffiData^.dwFileVersionMS) shr 16;
      aMinor := (pffiData^.dwFileVersionMS) and $FFFF;
      aRelease := (pffiData^.dwFileVersionLS) shr 16;
      aBuild := (pffiData^.dwFileVersionLS) and $FFFF;
    end;
  finally
    FreeMem(pData);
  end;
end;

function TCommon.I8TD(const _IDATE: Integer): TDate;
var
  Y, M, D: Word;

  {-------------------------------------------------------------------------------
    过程名:    TBaseMgr.ITD
    作者:      robert
    日期:      2017.08.11
    参数:      _IDATE: Integer
    返回值:    TDate
    说明:      将一个8位的数字型日期转为日期型
  -------------------------------------------------------------------------------}

begin
  if _IDATE <= 0 then
  begin
    Result := _IDATE;
    Exit;
  end;
  Y := _IDATE div 10000;
  M := _IDATE mod 10000 div 100;
  D := _IDATE mod 100;
  Result := EncodeDate(Y, M, D);
end;

function TCommon.ITD(const AIntDate: Integer): TDateTime;
var
  Y, M, D: Word;

  {-------------------------------------------------------------------------------
    过程名:    TSystemMgr.ITD
    作者:      吴凤钢
    日期:      2017.08.02
    参数:      const AIntDate: Integer
    返回值:    TDateTime
    说明:      传入一个8位的数字日期格式,返回时间格式的值
  -------------------------------------------------------------------------------}

begin
  if AIntDate <= 0 then
  begin
    Result := Date;
    Exit;
  end;
  Y := AIntDate div 10000;
  M := AIntDate mod 10000 div 100;
  D := AIntDate mod 100;
  Result := EncodeDate(Y, M, D);
end;



function TCommon.NEWID: string;
{-------------------------------------------------------------------------------
  过程名:    TCommon.NEWID
  作者:      robert
  日期:      2018.01.24
  参数:      无
  返回值:    string
  说明:      新建一个ID值； guid格式	
-------------------------------------------------------------------------------}
var
  MyGUID: TGUID;
  MyWideChar: array[0..100] of WideChar;
begin
  CoCreateGUID(MYGUID);

  StringFromGUID2(MYGUID, MyWideChar, 39);
  Result := WideChartoString(MyWideChar);
end;

procedure TCommon.PingServer(const AIP: string);

  {-------------------------------------------------------------------------------
    过程名:    TSystemMgr.PingServer
    作者:      吴凤钢
    日期:      2017.08.02
    参数:      const AIP: string
    返回值:    无
    说明:      传入一个IP地址，PING这个地址，并将结果保存
  -------------------------------------------------------------------------------}

begin
end;

function TCommon.S8TD(_SDate: string): TDate;

  {-------------------------------------------------------------------------------
    过程名:    TBaseMgr.S8TD
    作者:      robert
    日期:      2017.08.11
    参数:      _SDate: String
    返回值:    TDate
    说明:      将一个8字符串转换为日期
  -------------------------------------------------------------------------------}

begin
  Result := I8TD(StrToInt(_SDate));
end;


function TCommon.SimpleEncrypt(S: string): string;
{-------------------------------------------------------------------------------
  过程名:    TCommon.SimpleEncrypt
  作者:      robert
  日期:      2018.01.24
  参数:      S: string
  返回值:    string
  说明:      加密字符串	
-------------------------------------------------------------------------------}
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
    Result[I] := Char(Integer(S[I]) xor Integer(THE_KEY[J]));
    Dec(J);
    if J = 0 then
      J := KeyL;
  end;
end;

end.

