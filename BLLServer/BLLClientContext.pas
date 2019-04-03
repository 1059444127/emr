unit BLLClientContext;

interface

uses
  SysUtils, Classes, Windows, Math, diocp_tcp_server, emr_MsgPack, StreamProtocol;

type
  TRemoteServer = class(TObject)
  private
    FHost: string;
    FPort: Integer;
  public
    constructor CreateEx(const AHost: string; const APort: Integer);
    property Host: string read FHost write FHost;
    property Port: Integer read FPort write FPort;
  end;


  TOnContextActionEvent = procedure(const AProxyType: TProxyType;
    const AResult: Boolean; const ATick: Cardinal; const AContext: TIocpClientContext) of object;

  TBLLClientContext = class(TIocpClientContext)
  private
    FLastErrCode: Integer;  // �������
    FLastErrParam: string;  // ��������ʱ�� ip�Ͷ˿�
    FStreamObject: TDiocpStreamObject;
    FOnContextAction: TOnContextActionEvent;
    function RemoteServerExecMethod(const AMsgPack: TMsgPack): Boolean;
  protected
    procedure DoCleanUp; override;
    procedure OnDisconnected; override;
    procedure OnConnected; override;
    procedure OnRecvBuffer(buf: Pointer; len: Cardinal; ErrCode: WORD); override;
    procedure InvokeServiceMethod(const AProxyType: TProxyType; const AMsgPack: TMsgPack);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure DoServerError(const AErrCode: Integer; const AParam: string);
    /// <summary>
    ///   ���ݴ���
    /// </summary>
    /// <param name="pvObject"> (TDiocpStreamObject) </param>
    procedure DoContextAction(const ARequestContent: TMemoryStream);
    procedure WriteObject(pvObject: TMemoryStream);

    property OnContextAction: TOnContextActionEvent read FOnContextAction write FOnContextAction;
  end;

var
  GRemoteServer: TRemoteServer;

implementation

uses
  BLLServerMethods, emr_BLLServerProxy, utils_zipTools, DiocpError;

constructor TBLLClientContext.Create;
begin
  inherited Create;
  FStreamObject := TDiocpStreamObject.Create();
end;

destructor TBLLClientContext.Destroy;
begin
  FreeAndNil(FStreamObject);
  inherited Destroy;
end;

procedure TBLLClientContext.DoCleanUp;
begin
  inherited DoCleanUp;
  FStreamObject.Clear;
end;

procedure TBLLClientContext.DoContextAction(const ARequestContent: TMemoryStream);
var
  vMsgPack: TMsgPack;
  vStreamTemp: TMemoryStream;
  vTick: Cardinal;
  vProxyType: TProxyType;
begin
  // �˷���������ʱ�Ѿ���TIOCPCoderClientContext.DoExecuteRequest�����߳�ͬ��
  vMsgPack := TMsgPack.Create;
  try
    vStreamTemp := TMemoryStream.Create;
    try
      try
        vTick := GetTickCount;
        ARequestContent.Position := 0;
        TZipTools.UnZipStream(ARequestContent, vStreamTemp);  // ��ѹ�������е���Ϣ��vStreamMsgPack
        vStreamTemp.Position := 0;
        vMsgPack.DecodeFromStream(vStreamTemp);  // ���������е���Ϣ
        vProxyType := TProxyType(vMsgPack.ForcePathObject(BLL_PROXYTYPE).AsInteger);  // �������ַ������
        InvokeServiceMethod(vProxyType, vMsgPack);  // �ַ�DBL��Ӧҵ��ķ���
      except  // �����쳣��Ϣ
        on E:Exception do
        begin
          vMsgPack.Clear;
          vMsgPack.ForcePathObject(BACKRESULT).AsBoolean := False;
          vMsgPack.ForcePathObject(BACKMSG).AsString := E.Message;
        end;
      end;
      // ׼���������ú�����ݽ��
      vStreamTemp.Size := 0;
      vMsgPack.EncodeToStream(vStreamTemp);  // ��������
      vStreamTemp.Position := 0;
      TZipTools.ZipStream(vStreamTemp, ARequestContent);  // ѹ������
      ARequestContent.Position := 0;
      WriteObject(ARequestContent);  // ���͵��ͻ���
      // ֪ͨ�ⲿ
      if Assigned(FOnContextAction) then
        FOnContextAction(vProxyType, vMsgPack.Result, GetTickCount - vTick, Self);
    finally
      vStreamTemp.Free;
    end;
  finally
    vMsgPack.Free;
  end;
end;

procedure TBLLClientContext.DoServerError(const AErrCode: Integer;
  const AParam: string);
begin
  FLastErrCode := AErrCode;
  FLastErrParam := AParam;
end;

procedure TBLLClientContext.InvokeServiceMethod(const AProxyType: TProxyType;
  const AMsgPack: TMsgPack);
begin
  if GRemoteServer <> nil then  // ���������
    RemoteServerExecMethod(AMsgPack)
  else
  begin
    if AProxyType = cptDBL then
      BLLServerMethod.Execute(AMsgPack);
  end;
end;

function TBLLClientContext.RemoteServerExecMethod(const AMsgPack: TMsgPack): Boolean;

  procedure DoSrvProxyError(const AErrCode: Integer; const AParam: string);
  var
    vErrorInfo: string;
  begin
    vErrorInfo := GetDiocpErrorMessage(AErrCode);
    if vErrorInfo = '' then
      vErrorInfo := SysErrorMessage(GetLastError);
    AMsgPack.Clear;
    AMsgPack.ForcePathObject(BACKRESULT).AsBoolean := False;
    AMsgPack.ForcePathObject(BACKMSG).AsString := vErrorInfo;
  end;

var
  vDBLSrvProxy: TBLLServerProxy;
  //M: TMethod;
begin
  Result := False;
  vDBLSrvProxy := TBLLServerProxy.CreateEx(GRemoteServer.Host, GRemoteServer.Port);
  try
    {M.Data := vDBLSrvProxy;
    M.Code := @DoSrvProxyError;
    TypInfo.SetMethodProp(vDBLSrvProxy, 'OnError', M); }
    vDBLSrvProxy.OnError := DoServerError;
    vDBLSrvProxy.ReConnectServer;
    if vDBLSrvProxy.Active then  // ������ӳɹ�
      Result := vDBLSrvProxy.DispatchPack(AMsgPack);
    if not Result then
      DoSrvProxyError(FLastErrCode, FLastErrParam);
  finally
    vDBLSrvProxy.Free;
  end;
end;

procedure TBLLClientContext.OnConnected;
begin

end;

procedure TBLLClientContext.OnDisconnected;
begin

end;

procedure TBLLClientContext.OnRecvBuffer(buf: Pointer; len: Cardinal;
    ErrCode: WORD);
var
  i, r:Integer;
  lvPtr:PByte;
begin
  try
    i:= 0;
    lvPtr := PByte(buf);
    while i < len do
    begin
      r := FStreamObject.InputBuffer(lvPtr^);
      if r = -2 then
      begin
        Self.RequestDisconnect(Format('�������ߴ�(%d)', [FStreamObject.ContentLength]));
        FStreamObject.Clear;
        Break;
      end
      else
      if r = 1 then
      begin
        DoContextAction(FStreamObject.Content);  // ����
        FStreamObject.Clear;
      end
      else
      if r = -1 then
      begin
        Self.RequestDisconnect('�쳣���ݰ�(-1)');
        FStreamObject.Clear;
        Break;
      end;
      Inc(i);
      Inc(lvPtr);
    end;
  except
    on E:Exception do
    begin
      Self.RequestDisconnect('�����߼������쳣:' + e.Message);
    end;
  end;
end;

procedure TBLLClientContext.WriteObject(pvObject: TMemoryStream);
var
  lvBlock:array[0..MAX_BLOCK_SIZE-1] of Byte;
  r : Integer;
  lvStreamObject:TDiocpStreamObject;
begin
  lvStreamObject := TDiocpStreamObject.Create;
  try
    lvStreamObject.WrapContent(pvObject);
    lvStreamObject.ResetReadPosition;
    while True do
    begin
      r := lvStreamObject.ReadBlock(@lvBlock[0], MAX_BLOCK_SIZE);
      if r = 0 then
        Break;
      PostWSASendRequest(@lvBlock[0], r);
    end;
  finally
    lvStreamObject.Free;
  end;
end;

{ TRemoteServer }

constructor TRemoteServer.CreateEx(const AHost: string; const APort: Integer);
begin
  inherited Create;
  FHost := AHost;
  FPort := APort;
end;

end.
