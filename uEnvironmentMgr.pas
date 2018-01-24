{*******************************************************

       ͬ��������

       ��Ȩ���� (C) 2017 ����ʤ����Ϣϵͳ���޹�˾

���ߣ�LuoHuaChun
���ڣ�2017/2/24
˵�����˵�Ԫ�������ϵͳ����ʹ�õ������л��������ñ�����


*******************************************************}

unit uEnvironmentMgr;

interface

uses
  SysUtils, Classes, IniFiles, SecureUtils;

type
  TConnectionParam = class(TObject)
  private
    FAddr: string;
    FDbName: string;
    FPassWord: string;
    FPort: Integer;
    FProvider: string;
    FUserName: string;
  public
    constructor Create; overload;
    constructor Create(const _Provider, _Addr: string; _Port: Integer; const _DbName, _UserName, _PassWord: string); overload;
    function ToString: string;
    property Addr: string read FAddr write FAddr;
    property DbName: string read FDbName write FDbName;
    property PassWord: string read FPassWord write FPassWord;
    property Port: Integer read FPort write FPort;
    property Provider: string read FProvider write FProvider;
    property UserName: string read FUserName write FUserName;
  end;

  TEnvironmentMgr = class(TPersistent)
  private
    FXML, FXMLCusTab: TIniFile;
    function GetAppPath: string;
    function GetAutoStart: Boolean;
    function GetDbInfoAddr: string;
    function GetDbInfoName: string;
    function GetDbinfoPassWord: string;
    function GetDbinfoPort: Integer;
    function GetDbinfoProvider: string;
    function GetDbinfoUser: string;
    function GetDblogAddr: string;
    function GetDBLogDbName: string;
    function GetDBlogPassword: string;
    function GetDBlogPort: Integer;
    function GetDbLogProvider: string;
    function GetDBlogUserName: string;
    function GetDBTimeOut: Integer;
    function GetLogLevel: Integer;
    function GetPort: Integer;
    function GetMaxSession: Integer;
    procedure SetAutoStart(const Value: Boolean);
    procedure SetDbInfoAddr(const Value: string);
    procedure SetDbInfoName(const Value: string);
    procedure SetDbinfoPassWord(const Value: string);
    procedure SetDbinfoPort(const Value: Integer);
    procedure SetDbinfoProvider(const Value: string);
    procedure SetDbinfoUser(const Value: string);
    procedure SetDblogAddr(const Value: string);
    procedure SetDBLogDbName(const Value: string);
    procedure SetDBlogPassword(const Value: string);
    procedure SetDBlogPort(const Value: Integer);
    procedure SetDbLogProvider(const Value: string);
    procedure SetDBlogUserName(const Value: string);
    procedure SetDBTimeOut(const Value: Integer);
    procedure SetLogLevel(const Value: Integer);
    procedure SetPort(const Value: Integer);
    procedure SetMaxSession(Const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function check: Boolean;
    property AppPath: string read GetAppPath;
    property AutoStart: Boolean read GetAutoStart write SetAutoStart;
    property DbInfoAddr: string read GetDbInfoAddr write SetDbInfoAddr;
    property DbInfoName: string read GetDbInfoName write SetDbInfoName;
    property DbinfoPassWord: string read GetDbinfoPassWord write SetDbinfoPassWord;
    property DbinfoPort: Integer read GetDbinfoPort write SetDbinfoPort;
    property DbinfoProvider: string read GetDbinfoProvider write SetDbinfoProvider;
    property DbinfoUser: string read GetDbinfoUser write SetDbinfoUser;
    property DblogAddr: string read GetDblogAddr write SetDblogAddr;
    property DBLogDbName: string read GetDBLogDbName write SetDBLogDbName;
    property DBlogPassword: string read GetDBlogPassword write SetDBlogPassword;
    property DBlogPort: Integer read GetDBlogPort write SetDBlogPort;
    property DbLogProvider: string read GetDbLogProvider write SetDbLogProvider;
    property DBlogUserName: string read GetDBlogUserName write SetDBlogUserName;
    property DBTimeOut: Integer read GetDBTimeOut write SetDBTimeOut;
    property LogLevel: Integer read GetLogLevel write SetLogLevel;
    property Port: Integer read GetPort write SetPort;
    property MaxSession: Integer read GetMaxSession write SetMaxSession;
    procedure SelCusTabLastUpdate(const ACID: string; const AValue: string);
    function GetCusTabLastUpdate(const ACID: string): string;
  end;

implementation
uses uConst;


{
******************************* TEvnironmentMgr ********************************
}
constructor TEnvironmentMgr.Create;
begin
  if not FileExists(ChangeFileExt(ParamStr(0), '.ini')) then
  begin
    with TStringlist.Create do
    begin
      Text := '[COMMON]' + #13#10 +
      'AUTOSTART=' + #13#10 +
      'MAXSESSION=30' + #13#10 +
      'DBTIMEOUT=1' + #13#10 + 'PORT=7773' + #13#10 + '[DBINFO]' + #13#10 + 'DBINFOPROVIDER=' + #13#10 + 'DBINFOADDR=' + #13#10 + 'DBINFOPORT=' + #13#10 + 'DBINFONAME=' + #13#10 + 'DBINFOUSER=' + #13#10 + 'DBINFOPASSWORD=' + #13#10 + '[DBLOG]' + #13#10 + 'DBLOGPROVIDER=' + #13#10 + 'DBLOGADDR=' + #13#10 + 'DBLOGPORT=' + #13#10 + 'DBLOGNAME=' + #13#10 + 'DBLOGUSER=' + #13#10 + 'DBLOGPASSWORD=';
      SaveToFile(ChangeFileExt(ParamStr(0), '.ini'));
      Free;
    end;
  end;
  FXML := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
end;

destructor TEnvironmentMgr.Destroy;
begin
  FreeAndNil(FXMLCusTab);
  FreeAndNil(FXML);
  inherited Destroy;
end;

function TEnvironmentMgr.check: Boolean;
var
  i: Integer;
begin
  Result := False;
  i := 0;

  try
//    writeLog(Format('���Ͽ�����[%s]...', [DbinfoProvider]) + BooleanToStr(Trim(DbinfoProvider) <> '', '��', '��', i));
//    writeLog(Format('���Ͽ��ַ[%s]...', [DbInfoAddr]) + BooleanToStr(Trim(DbInfoAddr) <> '', '��', '��', i));
//    writeLog(Format('���Ͽ�˿�[%d]...', [DbInfoPort]) + BooleanToStr(DbInfoPort <> 0, '��', '��', i));
//    writeLog(Format('���Ͽ�����[%s]...', [DbInfoName]) + BooleanToStr(Trim(DbInfoName) <> '', '��', '��', i));
//    writeLog(Format('���Ͽ��û�[%s]...', [DbinfoUser]) + BooleanToStr(Trim(DbinfoUser) <> '', '��', '��', i));
//    writeLog(Format('���Ͽ����[******]...', [DbinfoPassWord]) + BooleanToStr(Trim(DbinfoPassWord) <> '', '��', '��', i));
//
//    writeLog('');
//
//    writeLog(Format('��־������[%s]...', [DbLogProvider]) + BooleanToStr(Trim(DbLogProvider) <> '', '��', '��', i));
//    writeLog(Format('��־���ַ[%s]...', [DblogAddr]) + BooleanToStr(Trim(DblogAddr) <> '', '��', '��', i));
//    writeLog(Format('��־��˿�[%d]...', [DBlogPort]) + BooleanToStr(DBlogPort <> 0, '��', '��', i));
//    writeLog(Format('��־������[%s]...', [DBLogDbName]) + BooleanToStr(Trim(DBLogDbName) <> '', '��', '��', i));
//    writeLog(Format('��־���û�[%s]...', [DBlogUserName]) + BooleanToStr(Trim(DBlogUserName) <> '', '��', '��', i));
//    writeLog(Format('��־�����[******]...', [DBlogPassword]) + BooleanToStr(Trim(DBlogPassword) <> '', '��', '��', i));
//
//    writeLog(Format('--------------------------------------', []));
//
//    writeLog(Format('����˿�[%d]...', [Port]) + BooleanToStr(Port <> 0, '��', '��', i));
//    writeLog(Format('��ʱʱ��[%d]...', [DBTimeOut]) + BooleanToStr(DBTimeOut <> 0, '��', '��', i));

  except
//    writeLog('��黷����������!');
  end;

  Result := i = 0;

end;

function TEnvironmentMgr.GetAppPath: string;
begin
  Result := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)));
end;

function TEnvironmentMgr.GetAutoStart: Boolean;
var
  I: Integer;
begin
  I := FXML.ReadInteger(SCOMMON, SAUTOSTART, 1);
  if I = 1 then
    Result := True
  else
    Result := False;
end;

function TEnvironmentMgr.GetDbInfoAddr: string;
begin
  Result := FXML.ReadString(SDBINFO, SDBINFOADDR, '');
end;

function TEnvironmentMgr.GetDbInfoName: string;
begin
  Result := FXML.ReadString(SDBINFO, SDBINFONAME, '');
end;

function TEnvironmentMgr.GetDbinfoPassWord: string;
begin
  Result := UnsecureConfig(FXML.ReadString(SDBINFO, SDBINFOPASSWORD, ''));
end;

function TEnvironmentMgr.GetDbinfoPort: Integer;
begin
  Result := FXML.ReadInteger(SDBINFO, SDBINFOPORT, 0);
end;

function TEnvironmentMgr.GetDbinfoProvider: string;
begin
  Result := FXML.ReadString(SDBINFO, SDBInfoProvider, '');
end;

function TEnvironmentMgr.GetDbinfoUser: string;
begin
  Result := FXML.ReadString(SDBINFO, SDBINFOUSER, '');
end;

function TEnvironmentMgr.GetDblogAddr: string;
begin
  Result := FXML.ReadString(SDBLOG, SLOGADDR, '');
end;

function TEnvironmentMgr.GetDBLogDbName: string;
begin
  Result := FXML.ReadString(SDBLOG, SLOGNAME, '');
end;

function TEnvironmentMgr.GetDBlogPassword: string;
begin
  Result := UnsecureConfig(FXML.ReadString(SDBLOG, SLOGPASSWORD, ''));
end;

function TEnvironmentMgr.GetDBlogPort: Integer;
begin
  Result := FXML.ReadInteger(SDBLOG, SLOGPORT, 1433);
end;

function TEnvironmentMgr.GetDbLogProvider: string;
begin
  Result := FXML.ReadString(SDBLOG, sDbLogProvideR, '');
end;

function TEnvironmentMgr.GetDBlogUserName: string;
begin
  Result := FXML.ReadString(SDBLOG, SLOGUSER, '');
end;

function TEnvironmentMgr.GetDBTimeOut: Integer;
begin
  Result := FXML.ReadInteger(SCOMMON, SDBTimeOut, 6);
end;

function TEnvironmentMgr.GetPort: Integer;
begin
  Result := FXML.ReadInteger(SCOMMON, SPORT, 7773);
end;

function TEnvironmentMgr.GetMaxSession: Integer;
begin
  Result := FXML.ReadInteger(SCOMMON, SMAXSESSION, 30);
end;

procedure TEnvironmentMgr.SetAutoStart(const Value: Boolean);
begin
  if Value then
    FXML.WriteInteger(SCOMMON, SAUTOSTART, 1)
  else
    FXML.WriteInteger(SCOMMON, SAUTOSTART, 0);
end;

procedure TEnvironmentMgr.SetDbInfoAddr(const Value: string);
begin
  FXML.WriteString(SDBINFO, SDBINFOADDR, Value);
end;

procedure TEnvironmentMgr.SetDbInfoName(const Value: string);
begin
  FXML.WriteString(SDBINFO, SDBINFONAME, Value);
end;

procedure TEnvironmentMgr.SetDbinfoPassWord(const Value: string);
begin
  FXML.WriteString(SDBINFO, SDBINFOPASSWORD, SecureConfig(Value));
end;

procedure TEnvironmentMgr.SetDbinfoPort(const Value: Integer);
begin
  FXML.WriteInteger(SDBINFO, SDBINFOPORT, Value);
end;

procedure TEnvironmentMgr.SetDbinfoProvider(const Value: string);
begin
  FXML.WriteString(SDBINFO, SDBInfoProvider, Value);
end;

procedure TEnvironmentMgr.SetDbinfoUser(const Value: string);
begin
  FXML.WriteString(SDBINFO, SDBINFOUSER, Value);
end;

procedure TEnvironmentMgr.SetDblogAddr(const Value: string);
begin
  FXML.WriteString(SDBLOG, SLOGADDR, Value);
end;

procedure TEnvironmentMgr.SetDBLogDbName(const Value: string);
begin
  FXML.WriteString(SDBLOG, SLOGNAME, Value);
end;

procedure TEnvironmentMgr.SetDBlogPassword(const Value: string);
begin
  FXML.WriteString(SDBLOG, SLOGPASSWORD, SecureConfig(Value));
end;

procedure TEnvironmentMgr.SetDBlogPort(const Value: Integer);
begin
  FXML.WriteInteger(SDBLOG, SLOGPORT, Value);
end;

procedure TEnvironmentMgr.SetDbLogProvider(const Value: string);
begin
  FXML.WriteString(SDBLOG, sDbLogProvider, Value);
end;

procedure TEnvironmentMgr.SetDBlogUserName(const Value: string);
begin
  FXML.WriteString(SDBLOG, SLOGUSER, Value);
end;

procedure TEnvironmentMgr.SetDBTimeOut(const Value: Integer);
begin
  FXML.WriteInteger(SCOMMON, SDBTimeOut, Value);
end;

procedure TEnvironmentMgr.SetPort(const Value: Integer);
begin
  FXML.WriteInteger(SCOMMON, SPORT, Value);
end;

procedure TEnvironmentMgr.SetMaxSession(Const Value: Integer);
begin
  FXML.WriteInteger(SCOMMON, SMAXSESSION, Value);
end;

procedure TEnvironmentMgr.SelCusTabLastUpdate(const ACID: string; const AValue: string);
{-------------------------------------------------------------------------------
    ������:    TEvnironmentMgr.SelCusTabLastUpdate
    ����:      ����
    ����:      2017.08.02
    ����:      const ACID: string;const AValue: string
    ����ֵ:    ��
    ˵��:      ����һ���ͻ��ţ�������������ʱ�� ����
-------------------------------------------------------------------------------}
begin
  FXMLCusTab.WriteString(SCOMMON, ACID, AValue);
end;

function TEnvironmentMgr.GetCusTabLastUpdate(const ACID: string): string;
{-------------------------------------------------------------------------------
    ������:    TEvnironmentMgr.GetCusTabLastUpdate
    ����:      ����
    ����:      2017.08.02
    ����:      const ACID: string;const AValue: string
    ����ֵ:    ��
    ˵��:      ����һ���ͻ��ţ���ȡ������������ʱ��
-------------------------------------------------------------------------------}
begin
  Result := FXMLCusTab.Readstring(SCOMMON, ACID, '');
end;

function TEnvironmentMgr.GetLogLevel: Integer;
begin
  Result := FXML.ReadInteger(SCOMMON, SLOGLEVEL, 0);
end;

procedure TEnvironmentMgr.SetLogLevel(const Value: Integer);
begin
  FXML.WriteInteger(SCOMMON, SLOGLEVEL, Value);
end;

{
******************************* TConnectionParam *******************************
}
constructor TConnectionParam.Create;
begin
  inherited;
  // TODO -cMM: TConnectionParam.Create default body inserted
end;

constructor TConnectionParam.Create(const _Provider, _Addr: string; _Port: Integer; const _DbName, _UserName, _PassWord: string);
begin
  FAddr := _Addr;
  FProvider := _Provider;
  FPort := _Port;
  FDbName := _DbName;
  FPassWord := _PassWord;
  FUserName := _UserName;
end;

function TConnectionParam.ToString: string;
begin
  Result := Format('%s %s %d %s %s %s', [Provider, Addr, Port, DbName, UserName, PassWord]);
end;

end.

