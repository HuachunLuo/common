unit SecureUtils;

interface
{$WARN  UNSAFE_CAST OFF}
{$WARN  UNSAFE_TYPE OFF}
{$WARN  UNSAFE_CODE OFF}
{$HINTS OFF}
{$WARN  UNSAFE_CODE OFF}
uses uZlib;

{$I CMPLRSET.INC}

function SecureContent(S: string): string;
function UnsecureContent(S: string): string;

function SecureConfig(S: string): string;
function UnsecureConfig(S: string): string;

const
  FLAG_ENCRYPT = $01;
  FLAG_COMPRESS = $02;
  COMPRESS_NEEDED_LEN = 128;

implementation

uses XUtils;

const
  sBrowerAgent = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)';
  ENCRYPT_KEY = sBrowerAgent;

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
  for I := 0 to SL - 1 do
  begin
    PB^ := Char(Integer(PB^) xor Integer(PK^));
    Inc(PB);
    Dec(PK);
    if (PK = PKM) then Inc(PK); // omit middle char
    if (PK = PKH) then // omit first char
    begin
      PK := PKH; Inc(PK, KL - 1);
    end;
  end;
  Result := S;
end;

function SecureContent(S: string): string;
var
  Flag: Integer;
begin
  Result := S;
  Flag := 0;
  if Length(Result) > COMPRESS_NEEDED_LEN then
  begin
    Result := ZlibCompress(Result);
    Flag := Flag or FLAG_COMPRESS;
  end;
  Result := EncryptCoder(Result, ENCRYPT_KEY);
  Flag := Flag or FLAG_ENCRYPT;
  Result := Result + Char(Flag);
end;

function UnsecureContent(S: string): string;
var
  Flag, SL: Integer;
begin
  Result := S;
  SL := Length(Result);
  if SL < 1 then Exit;
  Flag := Integer(Result[SL]);
  Delete(Result, SL, 1);

  if FLAG_ENCRYPT = (Flag and FLAG_ENCRYPT) then
    Result := EncryptCoder(Result, ENCRYPT_KEY);

  if FLAG_COMPRESS = (Flag and FLAG_COMPRESS) then
    Result := ZlibDecompress(Result);
end;

function SecureConfig(S: string): string;
begin
  Result := Base64Encode(SimpleEncrypt(S));
end;

function UnsecureConfig(S: string): string;
begin
  Result := SimpleEncrypt(Base64Decode(S));
end;
{$WARN  UNSAFE_CAST ON}
{$WARN  UNSAFE_TYPE ON}
{$WARN  UNSAFE_CODE ON}
{$HINTS ON}
{$WARN  UNSAFE_CODE ON}
end.

