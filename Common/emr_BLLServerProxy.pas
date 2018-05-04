{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit emr_BLLServerProxy;

interface

uses
  Classes, diocp_tcp_blockClient, emr_MsgPack;

type
  TBLLServerProxy = class(TObject)
  private
    FReconnect: Boolean;
    FTcpClient: TDiocpBlockTcpClient;
    FDataStream: TMemoryStream;
    procedure CheckConnect;
    function SendStream(pvStream: TStream): Integer;

    /// <summary>
    /// ��ȡָ���Ĳ���
    /// </summary>
    function Param(const AParamName: string): TMsgPack;
  protected
    FMsgPack: TMsgPack;
    function GetHost: string;
    procedure SetHost(const AHost: string);
    function GetPort: Integer;
    procedure SetPort(const APort: Integer);
    function GetActive: Boolean;
    function GetCmd: Integer;
    procedure SetCmd(const Value: Integer);
    function GetBackDataSet: Boolean;
    procedure SetBackDataSet(const Value: Boolean);

    function GetBatch: Boolean;
    procedure SetBatch(const Value: Boolean);

    function GetOnErrorEvent: TOnErrorEvent;
    procedure SetOnErrorEvent(Value: TOnErrorEvent);
    function GetTimeOut: Integer;
    procedure SetTimeOut(const Value: Integer);
    //
    function SendDataBuffer(buf:Pointer; len:Cardinal): Cardinal; stdcall;
    function RecvDataBuffer(buf:Pointer; len:Cardinal): Cardinal; stdcall;
    function PeekDataBuffer(buf:Pointer; len:Cardinal): Cardinal; stdcall;
  public
    constructor Create; virtual;
    constructor CreateEx(const AHost: string; const APort: Integer;
      AReconnect: Boolean = True);
    destructor Destroy; override;

    function Connected: Boolean;
    procedure ReConnectServer;
    function SendDataStream: Integer;
    function RecvDataStream: Boolean;

    /// <summary>
    /// �����˴��ݿͻ��˵�������
    /// </summary>
    /// <param name="AMsgPack"></param>
    /// <returns>����˴���˴ε����Ƿ�ɹ�(����ʾ�������Ӧ�ͻ��˵��óɹ�����������ִ�еĽ��)</returns>
    function DispatchPack(const AMsgPack: TMsgPack): Boolean; overload;
    function DispatchPack: Boolean; overload;

    /// <summary>
    /// ��ſͻ��˵��÷���˷���ʱSql�����ֶβ���
    /// </summary>
    function ExecParam: TMsgPack;

    /// <summary>
    /// ��ſͻ��˵��÷���˷���ʱSql�����滻����
    /// </summary>
    /// <returns></returns>
    function ReplaceParam: TMsgPack;

    /// <summary>
    /// �����˵��õķ������һ��Ҫ���ص��ֶ�
    /// </summary>
    procedure AddBackField(const AFieldName: string);

    /// <summary>
    /// ��ȡ����˷������ص�ָ���ֶ�����
    /// </summary>
    function BackField(const AFieldName: string): TMsgPack;

    /// <summary>
    /// �ͻ��˵��õķ���˾��巽��ִ���Ƿ�ɹ�
    /// </summary>
    function MethodRunOk: Boolean;

    // ��¼�������Ӧ��������ʱ����Ϣ(BACKMSG)����Ӧ�ɹ�ʱ����ִ�н������ʱ����Ϣ(BLL_METHODMSG)
    function MethodError: string;

    // ��¼�������Ӧ�ɹ�ʱ����ִ�н�����ݼ��ĸ���
    function RecordCount: Integer;

    /// <summary> �����ص�ҵ�����ݼ�д���ڴ��� </summary>
    /// <param name="AStream">������ݼ�</param>
    procedure GetBLLDataSet(const AStream: TMemoryStream);

    //property MsgPack: TMsgPack read FMsgPack;
    property Host: string read GetHost write SetHost;
    property Port: Integer read GetPort write SetPort;
    //property TcpClient: TDiocpBlockTcpClient read FTcpClient;
    property DataStream: TMemoryStream read FDataStream;

    /// <summary>
    /// ÿ�ε��÷���ʱ����������(����������Ͽ���ʡ��Դ)
    /// </summary>
    property Reconnect: Boolean read FReconnect write FReconnect;
    property Active: Boolean read GetActive;
    property Cmd: Integer read GetCmd write SetCmd;
    /// <summary> ������Ƿ񷵻����ݼ� </summary>
    property BackDataSet: Boolean read GetBackDataSet write SetBackDataSet;

    /// <summary> �Ƿ������������� </summary>
    property Batch: Boolean read GetBatch write SetBatch;

    property TimeOut: Integer read GetTimeOut write SetTimeOut;
    property OnError: TOnErrorEvent read GetOnErrorEvent write SetOnErrorEvent;
  end;

implementation

{ TBLLServerProxy }

uses
  SysUtils, utils_zipTools, utils_byteTools, emr_BLLConst,
  DiocpError;

procedure TBLLServerProxy.AddBackField(const AFieldName: string);
begin
  Param(BLL_BACKFIELD).Add(AFieldName);
end;

function TBLLServerProxy.BackField(const AFieldName: string): TMsgPack;
begin
  Result := Param(BLL_BACKFIELD).O[AFieldName];
end;

procedure TBLLServerProxy.CheckConnect;
begin
  if (not FTcpClient.Active) then
    FTcpClient.Connect;
end;

function TBLLServerProxy.Connected: Boolean;
begin
  Result := FTcpClient.Active;
end;

constructor TBLLServerProxy.Create;
begin
  inherited Create;
  FReconnect := True;
  FTcpClient := TDiocpBlockTcpClient.Create(nil);
  FTcpClient.ReadTimeOut := 1000 * 60;  // ���ó�ʱ�ȴ�1����
  FDataStream := TMemoryStream.Create;
  FMsgPack := TMsgPack.Create;
end;

constructor TBLLServerProxy.CreateEx(const AHost: string;
  const APort: Integer; AReconnect: Boolean = True);
begin
  Create;
  FTcpClient.Host := AHost;
  FTcpClient.Port := APort;
  FReconnect := AReconnect;
end;

destructor TBLLServerProxy.Destroy;
begin
  FTcpClient.Disconnect;
  FTcpClient.Free;
  FDataStream.Free;
  FMsgPack.Free;
  inherited Destroy;
end;

function TBLLServerProxy.ExecParam: TMsgPack;
begin
  Result := Param(BLL_EXECPARAM);
end;

function TBLLServerProxy.DispatchPack: Boolean;
begin
  Result := DispatchPack(FMsgPack);
end;

function TBLLServerProxy.DispatchPack(const AMsgPack: TMsgPack): Boolean;
var
  vCmd: Integer;
begin
  vCmd := Cmd;  // ��ǰ��¼����ֹ�����ʧ��Ϣ
  CheckConnect;
  // ��ʼ������ʱ�õ��Ķ���
  FDataStream.Clear;
  // ���õ���ʱ������ֵ
  AMsgPack.ForcePathObject(BLL_PROXYTYPE).AsInteger := Ord(cptDBL);  // ��������
  AMsgPack.ForcePathObject(BLL_VER).AsInteger := BLLVERSION;  // ҵ��汾
  //AMsgPack.ForcePathObject(BLL_DEVICE).AsInteger := Ord(TDeviceType.cdtMobile);  // �豸����
  AMsgPack.EncodeToStream(FDataStream);  // ���ܴ���ĵ�������
  TZipTools.ZipStream(FDataStream, FDataStream);  // ѹ������ĵ�������
  SendDataStream;  // ���ݷ��͵������
  RecvDataStream;  // ��ȡ����˷�������
  TZipTools.UnZipStream(FDataStream, FDataStream);  // ��ѹ�����ص�����
  FDataStream.Position := 0;
  AMsgPack.DecodeFromStream(FDataStream);  // ���ܷ��ص�����
  Result := AMsgPack.Result;  // ����˴���˴ε����Ƿ�ɹ�(����ʾ�������Ӧ�ͻ��˵��óɹ�����������ִ�еĽ��)
  if not Result then  // ����˴���˴ε��ó���
  begin
    if AMsgPack.ForcePathObject(BACKMSG).AsString <> '' then  // ������Ϣ
    begin
      {raise Exception.Create('������쳣������[' + GetBLLMethodName(vCmd) + ']'
        + AMsgPack.ForcePathObject(BACKMSG).AsString);}
      Self.FMsgPack.ForcePathObject(BLL_ERROR).AsString := '������˴���'
        //+ sLineBreak + '������' + GetBLLMethodName(vCmd)
        + sLineBreak + AMsgPack.ForcePathObject(BACKMSG).AsString;
    end;
  end
  else  // ����ִ�з��ش�����Ϣ
  begin
    if AMsgPack.ForcePathObject(BLL_METHODMSG).AsString <> '' then
    begin
      Self.FMsgPack.ForcePathObject(BLL_ERROR).AsString := '��ִ�з�������'
        //+ sLineBreak + GetBLLMethodName(vCmd) + 'ʧ�ܣ�'
        + sLineBreak + AMsgPack.ForcePathObject(BLL_METHODMSG).AsString;
    end;
  end;

  if FReconnect then  // ����������Ͽ�����ʡ��Դ���Ժ�ɸ�Ϊ�����
    FTcpClient.Disconnect;;
end;

function TBLLServerProxy.GetActive: Boolean;
begin
  Result := FTcpClient.Active;
end;

function TBLLServerProxy.GetBackDataSet: Boolean;
begin
  Result := Param(BLL_BACKDATASET).AsBoolean;
end;

function TBLLServerProxy.GetBatch: Boolean;
begin
  Result := Param(BLL_BATCH).AsBoolean;
end;

procedure TBLLServerProxy.GetBLLDataSet(const AStream: TMemoryStream);
begin
  if FMsgPack.O[BLL_DATASET] <> nil then
    FMsgPack.O[BLL_DATASET].SaveBinaryToStream(AStream)
  else
    AStream.Size := 0;
end;

function TBLLServerProxy.GetCmd: Integer;
begin
  Result := FMsgPack.ForcePathObject(BLL_CMD).AsInteger
end;

function TBLLServerProxy.GetHost: string;
begin
  Result := FTcpClient.Host;
end;

function TBLLServerProxy.GetOnErrorEvent: TOnErrorEvent;
begin
  Result := FTcpClient.OnError;
end;

function TBLLServerProxy.GetPort: Integer;
begin
  Result := FTcpClient.Port;
end;

function TBLLServerProxy.GetTimeOut: Integer;
begin
  Result := FTcpClient.ReadTimeOut;
end;

function TBLLServerProxy.MethodError: string;
begin
  Result := Param(BLL_ERROR).AsString;
end;

function TBLLServerProxy.MethodRunOk: Boolean;
begin
  Result := Param(BLL_METHODRESULT).AsBoolean;
end;

function TBLLServerProxy.Param(const AParamName: string): TMsgPack;
begin
  Result := FMsgPack.ForcePathObject(AParamName);
end;

procedure TBLLServerProxy.ReConnectServer;
begin
  CheckConnect;
end;

function TBLLServerProxy.PeekDataBuffer(buf: Pointer; len: Cardinal): Cardinal;
begin
  if FReconnect then
  begin
    if not FTcpClient.Active then
      FTcpClient.Connect;
    try
      FTcpClient.Recv(buf, len);
      Result := len;
    except
      FTcpClient.Disconnect;
      raise;
    end;
  end
  else
  begin
    FTcpClient.Recv(buf, len);
    Result := len;
  end;
end;

function TBLLServerProxy.RecvDataBuffer(buf: Pointer; len: Cardinal): Cardinal;
begin
  if FReconnect then
  begin
    if not FTcpClient.Active then
      FTcpClient.Connect;
    try
      FTcpClient.Recv(buf, len);
      Result := len;
    except
      FTcpClient.Disconnect;
      raise;
    end;
  end
  else
  begin
    FTcpClient.Recv(buf, len);
    Result := len;
  end;
end;

function TBLLServerProxy.RecvDataStream: Boolean;
var
  lvBytes:TBytes;
  lvReadL, lvTempL:Integer;
  lvPACK_FLAG:Word;
  lvDataLen: Integer;
  lvVerifyValue, lvVerifyDataValue:Cardinal;
  lvPByte:PByte;
begin
  RecvDataBuffer(@lvPACK_FLAG, 2);

  if lvPACK_FLAG <> PACK_FLAG then  // ����İ�����
  begin
    FTcpClient.Disconnect;
    raise Exception.Create(strRecvException_ErrorFlag);
  end;

  //veri value
  RecvDataBuffer(@lvVerifyValue, SizeOf(lvVerifyValue));

  //headlen
  RecvDataBuffer(@lvReadL, SizeOf(lvReadL));
  lvDataLen := TByteTools.swap32(lvReadL);

  if lvDataLen > MAX_OBJECT_SIZE then  // �ļ�ͷ����,����İ�����
  begin
    FTcpClient.Disconnect;
    raise Exception.Create(strRecvException_ErrorData);
  end;

  SetLength(lvBytes,lvDataLen);
  lvPByte := PByte(@lvBytes[0]);
  lvReadL := 0;
  while lvReadL < lvDataLen do
  begin
    lvTempL := RecvDataBuffer(lvPByte, lvDataLen - lvReadL);
    if lvTempL = -1 then
    begin
      RaiseLastOSError;
    end;
    Inc(lvPByte, lvTempL);
    lvReadL := lvReadL + lvTempL;
  end;

{$IFDEF POSIX}
  lvVerifyDataValue := verifyData(lvBytes[0], lvDataLen);
{$ELSE}
  lvVerifyDataValue := verifyData(lvBytes[0], lvDataLen);
{$ENDIF}

  if lvVerifyDataValue <> lvVerifyValue then
    raise Exception.Create(strRecvException_VerifyErr);

  FDataStream.Clear;
  FDataStream.Write(lvBytes[0], lvDataLen);
  Result := true;
end;

function TBLLServerProxy.ReplaceParam: TMsgPack;
begin
  Result := Param(BLL_REPLACEPARAM);
end;

function TBLLServerProxy.RecordCount: Integer;
begin
  Result := Param(BLL_RECORDCOUNT).AsInteger;
end;

function TBLLServerProxy.SendDataBuffer(buf: Pointer; len: Cardinal): Cardinal;
begin
  if FReconnect then
  begin
    if not FTcpClient.Active then
      FTcpClient.Connect;
    try
      Result := FTcpClient.SendBuffer(buf, len);
    except
      FTcpClient.Disconnect;
      raise;
    end;
  end
  else
  begin
    Result := FTcpClient.SendBuffer(buf, len);
  end;
end;

function TBLLServerProxy.SendDataStream: Integer;
var
  lvPACK_FLAG: WORD;
  lvDataLen, lvWriteIntValue: Integer;
  lvBuf: TBytes;
  lvStream: TMemoryStream;
  lvVerifyValue: Cardinal;
begin
  lvPACK_FLAG := PACK_FLAG;

  lvStream := TMemoryStream.Create;
  try
    FDataStream.Position := 0;

    if FDataStream.Size > MAX_OBJECT_SIZE then
      raise Exception.CreateFmt(strSendException_TooBig, [MAX_OBJECT_SIZE]);

    lvStream.Write(lvPACK_FLAG, 2);  // ��ͷ

    lvDataLen := FDataStream.Size;

    // stream data
    SetLength(lvBuf, lvDataLen);
    FDataStream.Read(lvBuf[0], lvDataLen);
    //veri value
    lvVerifyValue := verifyData(lvBuf[0], lvDataLen);

    lvStream.Write(lvVerifyValue, SizeOf(lvVerifyValue));

    lvWriteIntValue := TByteTools.swap32(lvDataLen);

    // stream len
    lvStream.Write(lvWriteIntValue, SizeOf(lvWriteIntValue));

    // send pack
    lvStream.write(lvBuf[0], lvDataLen);

    Result := SendStream(lvStream);
  finally
    lvStream.Free;
  end;
end;

function TBLLServerProxy.SendStream(pvStream: TStream): Integer;
var
  lvBufBytes: array[0..BUF_BLOCK_SIZE - 1] of byte;
  l, j, r, lvTotal: Integer;
  P: PByte;
begin
  Result := 0;
  if pvStream = nil then Exit;
  if pvStream.Size = 0 then Exit;
  lvTotal :=0;

  pvStream.Position := 0;
  repeat
    //FillMemory(@lvBufBytes[0], SizeOf(lvBufBytes), 0);
    l := pvStream.Read(lvBufBytes[0], SizeOf(lvBufBytes));
    if (l > 0) then
    begin
      P := PByte(@lvBufBytes[0]);
      j := l;
      while j > 0 do
      begin
        r := SendDataBuffer(P, j);
        if r = -1 then
          RaiseLastOSError;
        Inc(P, r);
        Dec(j, r);
      end;
      lvTotal := lvTotal + l;
    end
    else
      Break;
  until (l = 0);
  Result := lvTotal;
end;

procedure TBLLServerProxy.SetBackDataSet(const Value: Boolean);
begin
  Param(BLL_BACKDATASET).AsBoolean := Value;
end;

procedure TBLLServerProxy.SetBatch(const Value: Boolean);
begin
  Param(BLL_BATCH).AsBoolean := Value;
end;

procedure TBLLServerProxy.SetCmd(const Value: Integer);
begin
  FMsgPack.ForcePathObject(BLL_CMD).AsInteger := Value;
end;

procedure TBLLServerProxy.SetHost(const AHost: string);
begin
  FTcpClient.Host := AHost;
end;

procedure TBLLServerProxy.SetOnErrorEvent(Value: TOnErrorEvent);
begin
  FTcpClient.OnError := Value;
end;

procedure TBLLServerProxy.SetPort(const APort: Integer);
begin
  FTcpClient.Port := APort;
end;

procedure TBLLServerProxy.SetTimeOut(const Value: Integer);
begin
  FTcpClient.ReadTimeOut := Value;
end;

end.
