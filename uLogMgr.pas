{*******************************************************}
{                                                       }
{       ͬ��������                                      }
{       ��Ȩ���� (C) 2017 ����ʤ����Ϣϵͳ���޹�˾      }

{���ߣ��޻���                                           }
{˵��:                                                  }
{      ��־������



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
    FLock: TCriticalSection; //Ϊ�˲�������ʳ�ͻ  ͬ��ʹ���ٽ���
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
    property LogLevel: Integer read FLogLevel write FLogLevel;  //��־�ȼ�
    property FileSizeLimit: Integer read FFileSizeLimit write FFileSizeLimit; //��־�ļ���С
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
  ������:    TLogger.HandleLog
  ����:      ����
  ����:      2017.09.15
  ����:      Sender: TObject; aType: Integer; S: string
  ����ֵ:    ��
  ˵��:      ������־

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
  ������:    TLogger.InternalAddLog
  ����:      ����
  ����:      2017.09.15
  ����:      PS: PString
  ����ֵ:    ��
  ˵��:      ��־д���ļ�

-------------------------------------------------------------------------------}
begin
  if Assigned(FFileStream) then
  begin
    PS^ := PS^ + #13#10;
    try // simon  ����try
      FLock.Enter;
      FFileStream.Seek(0, soFromEnd); // simon �����������Ƶ����� ����
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
  ������:    TLogger.RenewLogFile
  ����:      ����
  ����:      2017.09.15
  ����:      ��
  ����ֵ:    ��
  ˵��:      ���������ļ�

-------------------------------------------------------------------------------}
begin
  FPrevFileName := FPrevPath + FormatDateTime('YYYYMMDDHHMMSSZZZ', Now) + FFileShortName + '.log';
  Windows.CopyFile(PChar(FFileName), PChar(FPrevFileName), False);
  FFileStream.Size := 0;
end;

procedure TLogger.WndProc(var Msg: TMessage);
{-------------------------------------------------------------------------------
  ������:    TLogger.WndProc
  ����:      ����
  ����:      2017.09.15
  ����:      var Msg: TMessage
  ����ֵ:    ��
  ˵��:      ����Ϣ����������־

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
  ������:    TLogger.SetFileName
  ����:      ����
  ����:      2017.09.15
  ����:      AValue: string
  ����ֵ:    ��
  ˵��:      �����ļ�
	
-------------------------------------------------------------------------------}
begin
  FFileName := AValue;
  //FPrevFileName := FFileName + '.prev';
  ForceDirectories(ExtractFilePath(FFileName));
end;

procedure TLogger.SetActive(AValue: Boolean);
{-------------------------------------------------------------------------------
  ������:    TLogger.SetActive
  ����:      ����
  ����:      2017.09.15
  ����:      AValue: Boolean
  ����ֵ:    ��
  ˵��:      ����

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
      FFileStream := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyWrite); //��д��������������Զ�ȡ���ļ���������д
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
  ������:    TLogger.WriteError
  ����:      ����
  ����:      2017.09.15
  ����:      Sender: TObject; UserCode, ErrorMessage, Info: WideString
  ����ֵ:    ��
  ˵��:      д������־

-------------------------------------------------------------------------------}
begin
  HandleLog(Sender, -1, Format('userCode:%s;error: %s  info:%s', [UserCode, ErrorMessage, Info]));
end;

end.

