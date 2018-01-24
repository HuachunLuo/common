{*******************************************************}
{                                                       }
{       同步服务器                                      }
{       版权所有 (C) 2017 精诚胜龙信息系统有限公司      }

{作者：罗华春                                           }
{说明:                                                  }
{      日志管理器



                                                       }
{*******************************************************}


unit uLogMgr;

interface

uses
  Windows, Messages, Classes, SysUtils, StdCtrls, Forms, SyncObjs;
type
  TLogger = class
  private
    FActive, FSynchronize: Boolean;
    FFileStream: TFileStream;
    FLock: TCriticalSection; //为了不引起访问冲突  同步使用临界区
    FHandle: HWND;
    FLogLevel: Integer;
    FFileName, FPrevFileName,FPrevPath,FFileShortName: string;
    FFileSizeLimit: Integer;
    procedure SetFileName(AValue: string);
    procedure WndProc(var Msg: TMessage);
    procedure InternalAddLog(PS: PString);
    procedure SetActive(AValue: Boolean);
    procedure RenewLogFile;
  public
    constructor Create; overload;
    constructor Create(const _FileName: string); overload;
    destructor Destroy; override;
    procedure HandleLog(Sender: TObject; aType: Integer; S: string);
    procedure WriteError(Sender: TObject;  UserCode, ErrorMessage, Info: WideString);
    property Active: Boolean read FActive write SetActive;
    property FileName: string read FFileName write SetFileName;
    property LogLevel: Integer read FLogLevel write FLogLevel;  //日志等级
    property FileSizeLimit: Integer read FFileSizeLimit write FFileSizeLimit; //日志文件大小
    property Synchronize: Boolean read FSynchronize write FSynchronize;
  end;

implementation

uses
  XUtils, FileCtrl, Dialogs, Controls;

const
  UWM_INTERNALADDLOG = WM_USER + 1;

{ TLogger }

constructor TLogger.Create;
begin
  inherited;
  FHandle := AllocateHWnd(WndProc);
  SetParent(FHandle, Application.Handle);
  FLogLevel := 0;
  FFileSizeLimit := 500000;
  FileName := ChangeFileExt(GetModulePathName, '.log');
  FFileShortName := ChangeFileExt(ExtractFileName(FileName), '');
  FPrevPath := ExtractFilePath(FileName) + 'Logs\';
  if not DirectoryExists(FPrevPath) then
    ForceDirectories(FPrevPath);
  Active := True;
end;

constructor TLogger.Create(const _FileName: string);
begin
  FHandle := AllocateHWnd(WndProc);
  SetParent(FHandle, Application.Handle);
  FLogLevel := 0;
  FFileSizeLimit := 500000;
  FileName := _FileName;
  FFileShortName := 'Error';
  FPrevPath := ExtractFilePath(FileName) + 'ErrorLogs\';
  if not DirectoryExists(FPrevPath) then
    ForceDirectories(FPrevPath);
  Active := True;
end;

destructor TLogger.Destroy;
begin
  Active := False;
  DeallocateHWnd(FHandle);
  inherited;
end;

procedure TLogger.HandleLog(Sender: TObject; aType: Integer; S: string);
{-------------------------------------------------------------------------------
  过程名:    TLogger.HandleLog
  作者:      吴凤钢
  日期:      2017.09.15
  参数:      Sender: TObject; aType: Integer; S: string
  返回值:    无
  说明:      处理日志

-------------------------------------------------------------------------------}
begin
  S := Format('%s:%s (%d) %s', [Sender.ClassName, FormatDateTime('yymmdd hh:mm:ss.zzz', Now), aType, S]);
  if aType <= FLogLevel then
  begin
    if FSynchronize then
      SendMessage(FHandle, UWM_INTERNALADDLOG, 0, LPARAM(@S))
    else
      InternalAddLog(@S);
  end;
end;

procedure TLogger.InternalAddLog(PS: PString);
{-------------------------------------------------------------------------------
  过程名:    TLogger.InternalAddLog
  作者:      吴凤钢
  日期:      2017.09.15
  参数:      PS: PString
  返回值:    无
  说明:      日志写入文件

-------------------------------------------------------------------------------}
begin
  if Assigned(FFileStream) then
  begin
    PS^ := PS^ + #13#10;
    try // simon  尝试try
      FLock.Enter;
      FFileStream.Seek(0, soFromEnd); // simon 从流创建处移到这里 试试
      FFileStream.Write(PChar(PS^)^, Length(PS^));
      if FFileStream.Size > FFileSizeLimit then
        RenewLogFile;
    finally
      FLock.Leave;
    end;
  end;
end;

procedure TLogger.RenewLogFile;
{-------------------------------------------------------------------------------
  过程名:    TLogger.RenewLogFile
  作者:      吴凤钢
  日期:      2017.09.15
  参数:      无
  返回值:    无
  说明:      重新生成文件

-------------------------------------------------------------------------------}
begin
  FPrevFileName := FPrevPath + FormatDateTime('YYYYMMDDHHMMSSZZZ', Now) + FFileShortName + '.log';
  Windows.CopyFile(PChar(FFileName), PChar(FPrevFileName), False);
  FFileStream.Size := 0;
end;

procedure TLogger.WndProc(var Msg: TMessage);
{-------------------------------------------------------------------------------
  过程名:    TLogger.WndProc
  作者:      吴凤钢
  日期:      2017.09.15
  参数:      var Msg: TMessage
  返回值:    无
  说明:      按消息条件处理日志

-------------------------------------------------------------------------------}
begin
  with Msg do
  begin
    if Msg = UWM_INTERNALADDLOG then
      InternalAddLog(PString(LParam))
    else
      Result := DefWindowProc(FHandle, Msg, wParam, lParam);
  end;
end;

procedure TLogger.SetFileName(AValue: string);
{-------------------------------------------------------------------------------
  过程名:    TLogger.SetFileName
  作者:      吴凤钢
  日期:      2017.09.15
  参数:      AValue: string
  返回值:    无
  说明:      生产文件
	
-------------------------------------------------------------------------------}
begin
  FFileName := AValue;
  //FPrevFileName := FFileName + '.prev';
  ForceDirectories(ExtractFilePath(FFileName));
end;

procedure TLogger.SetActive(AValue: Boolean);
{-------------------------------------------------------------------------------
  过程名:    TLogger.SetActive
  作者:      吴凤钢
  日期:      2017.09.15
  参数:      AValue: Boolean
  返回值:    无
  说明:      激活

-------------------------------------------------------------------------------}
begin
  if FActive <> AValue then
  begin
    if AValue then
    begin
      Assert(FFileName <> '');
      if not FileExists(FFileName) then
        FileClose(FileCreate(FFileName));

      FLock := TCriticalSection.Create; 
      FFileStream := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyWrite); //排写共享，其他程序可以读取该文件，但不可写
    end
    else
    begin
      FreeAndNil(FFileStream);
      FLock.Free;
    end;
    FActive := AValue;
  end;
end;

procedure TLogger.WriteError(Sender: TObject;  UserCode, ErrorMessage, Info: WideString);
{-------------------------------------------------------------------------------
  过程名:    TLogger.WriteError
  作者:      吴凤钢
  日期:      2017.09.15
  参数:      Sender: TObject; UserCode, ErrorMessage, Info: WideString
  返回值:    无
  说明:      写错误日志

-------------------------------------------------------------------------------}
begin
  HandleLog(Sender, -1, Format('userCode:%s;error: %s  info:%s', [UserCode, ErrorMessage, Info]));
end;

end.

