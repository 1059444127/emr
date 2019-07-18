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

const
  /// <summary> ��ȡ��������ǰʱ�� </summary>
  BLL_SRVDT = 1;

  /// <summary> ִ��Sql��� </summary>
  BLL_EXECSQL = 2;

  /// <summary> ��ȡ���б�ͱ�˵�� </summary>
  BLL_GETAllTABLE = 3;

  BLL_BASE = 1000;  // ҵ������ʼֵ

  { ҵ����(��1000��ʼ) }
  /// <summary> ȫ���û� </summary>
  BLL_COMM_ALLUSER = BLL_BASE;

  /// <summary> ��֤�˺�����ƥ�� </summary>
  BLL_CERTIFICATE = BLL_BASE + 1;

  /// <summary> ��ȡָ���û���Ϣ </summary>
  BLL_GETUSERINFO = BLL_BASE + 2;

  /// <summary> ��ȡ�û��Ĺ����� </summary>
  BLL_GETUSERGROUPS = BLL_BASE + 3;

  /// <summary> ��ȡ�û��Ľ�ɫ </summary>
  BLL_GETUSERROLES = BLL_BASE + 4;

  /// <summary> ��ȡָ���û����õ����й��� </summary>
  BLL_GETUSERFUNS = BLL_BASE + 5;

  /// <summary> ��ȡָ���û����й������Ӧ�Ŀ��� </summary>
  BLL_GETUSERGROUPDEPTS = BLL_BASE + 6;

  /// <summary> ��ȡ���� </summary>
  BLL_COMM_GETPARAM = BLL_BASE + 7;

  /// <summary> ��ȡ����˻�������� </summary>
  BLL_GETCLIENTCACHE = BLL_BASE + 8;

  /// <summary> ��ȡָ��������������Ȩ�޿��ƵĿؼ� </summary>
  BLL_GETCONTROLSAUTH = BLL_BASE + 9;

  /// <summary> ��ȡҪ���������°汾�� </summary>
  BLL_GETLASTVERSION = BLL_BASE + 10;

  /// <summary> ��ȡҪ�������ļ� </summary>
  BLL_GETUPDATEINFO = BLL_BASE + 11;

  /// <summary> �ϴ�������Ϣ </summary>
  BLL_UPLOADUPDATEINFO = BLL_BASE + 12;

  /// <summary> ��ȡ��Ժ���� </summary>
  BLL_HIS_GETINPATIENT = BLL_BASE + 13;

  /// <summary> ��ȡ���ݼ�(��Ŀ¼)��Ϣ </summary>
  BLL_GETDATAELEMENTSETROOT = BLL_BASE + 14;

  /// <summary> ��ȡ���ݼ�(ȫĿ¼)��Ϣ </summary>
  BLL_GETDATAELEMENTSETALL = BLL_BASE + 15;

  /// <summary> ��ȡָ�����ݼ���Ӧ��ģ�� </summary>
  BLL_GETTEMPLATELIST = BLL_BASE + 16;

  /// <summary> �½�ģ�� </summary>
  BLL_NEWTEMPLATE = BLL_BASE + 17;

  /// <summary> ��ȡģ������ </summary>
  BLL_GETTEMPLATECONTENT = BLL_BASE + 18;

  /// <summary> ����ģ������ </summary>
  BLL_SAVETEMPLATECONTENT = BLL_BASE + 19;

  /// <summary> ɾ��ģ�弰���� </summary>
  BLL_DELETETEMPLATE = BLL_BASE + 20;

  /// <summary> ��ȡ����Ԫ </summary>
  BLL_GETDATAELEMENT = BLL_BASE + 21;

  /// <summary> ��ȡ����Ԫֵ��ѡ�� </summary>
  BLL_GETDOMAINITEM = BLL_BASE + 22;

  /// <summary> ��������Ԫѡ��ֵ���Ӧ������ </summary>
  BLL_SAVEDOMAINITEMCONTENT = BLL_BASE + 23;

  /// <summary> ��ȡ����Ԫѡ��ֵ���Ӧ������ </summary>
  BLL_GETDOMAINITEMCONTENT = BLL_BASE + 24;

  /// <summary> ɾ������Ԫѡ��ֵ���Ӧ������ </summary>
  BLL_DELETEDOMAINITEMCONTENT = BLL_BASE + 25;

  /// <summary> ��ȡָ����סԺ���߲����б� </summary>
  BLL_GETINCHRECORDLIST = BLL_BASE + 26;

  /// <summary> �½�סԺ���� </summary>
  BLL_NEWINCHRECORD = BLL_BASE + 27;

  /// <summary> ��ȡָ��סԺ�������� </summary>
  BLL_GETINCHRECORDCONTENT = BLL_BASE + 28;

  /// <summary> ����ָ��סԺ�������� </summary>
  BLL_SAVERECORDCONTENT = BLL_BASE + 29;

  /// <summary> ��ȡָ���������ݼ�(��Ŀ¼)��Ӧ�Ĳ������� </summary>
  BLL_GETDESETRECORDCONTENT = BLL_BASE + 30;

  /// <summary> ɾ��ָ����סԺ���� </summary>
  BLL_DELETEINCHRECORD = BLL_BASE + 31;

  /// <summary> ��ȡָ������Ԫ��������Ϣ </summary>
  BLL_GETDEPROPERTY = BLL_BASE + 32;

  /// <summary> סԺ����ǩ�� </summary>
  BLL_INCHRECORDSIGNATURE = BLL_BASE + 33;

  /// <summary> ��ȡסԺ����ǩ����Ϣ </summary>
  BLL_GETINCHRECORDSIGNATURE = BLL_BASE + 34;

  /// <summary> ��ȡģ����Ϣ </summary>
  BLL_GETTEMPLATEINFO = BLL_BASE + 35;

  /// <summary> �޸�ģ����Ϣ </summary>
  BLL_SETTEMPLATEINFO = BLL_BASE + 36;

  /// <summary> ��ȡָ������Ԫ��Ϣ </summary>
  BLL_GETDEINFO = BLL_BASE + 37;

  /// <summary> �޸�ָ������Ԫ��Ϣ </summary>
  BLL_SETDEINFO = BLL_BASE + 38;

  /// <summary> �½�����Ԫ </summary>
  BLL_NEWDE = BLL_BASE + 39;

  /// <summary> ɾ������Ԫ </summary>
  BLL_DELETEDE = BLL_BASE + 40;

  /// <summary> ��ȡָ����Ԫֵ��ѡ�� </summary>
  BLL_GETDOMAINITEMINFO = BLL_BASE + 41;

  /// <summary> �޸�����Ԫֵ��ѡ�� </summary>
  BLL_SETDOMAINITEMINFO = BLL_BASE + 42;

  /// <summary> �½�����Ԫֵ��ѡ�� </summary>
  BLL_NEWDOMAINITEM = BLL_BASE + 43;

  /// <summary> ɾ������Ԫֵ��ѡ�� </summary>
  BLL_DELETEDOMAINITEM = BLL_BASE + 44;

  /// <summary> ��ȡ����ֵ�� </summary>
  BLL_GETDOMAIN = BLL_BASE + 45;

  /// <summary> �½�ֵ�� </summary>
  BLL_NEWDOMAIN = BLL_BASE + 46;

  /// <summary> �޸�ֵ�� </summary>
  BLL_SETDOMAIN = BLL_BASE + 47;

  /// <summary> ɾ��ֵ�� </summary>
  BLL_DELETEDOMAIN = BLL_BASE + 48;

  /// <summary> ɾ��ֵ���Ӧ������ѡ�� </summary>
  BLL_DELETEDOMAINALLITEM = BLL_BASE + 49;

  /// <summary> ��ȡ���ݼ���������������Ԫ </summary>
  BLL_GETDATASETELEMENT = BLL_BASE + 50;
  {
  /// <summary> �½�סԺ������Ϣ </summary>
  BLL_BASE + 51;

  /// <summary> �½�����������Ϣ </summary>
  BLL_BASE + 52;

  /// <summary> ��ѯ����������Ϣ </summary>
  BLL_BASE + 53;

  /// <summary> �½�סԺ������� </summary>
  BLL_BASE + 54;   }

  /// <summary> ���没���ṹ���� </summary>
  BLL_SAVERECORDSTRUCTURE = BLL_BASE + 55;

  /// <summary> �޸Ĳ����ṹ���� </summary>
  BLL_UPDATERECORDSTRUCTURE = BLL_BASE + 56;

  /// <summary> ��ȡȡָ���Ĳ����ṹ���� </summary>
  BLL_GETRECORDSTRUCTURE = BLL_BASE + 57;

  /// <summary> ��ȡָ�����ݼ��ĺ��滻��Ϣ </summary>
  BLL_GetDataElementSetMacro = BLL_BASE + 58;

  /// <summary> ��ȡָ������ָ�����ݼ��Ĳ����ṹ���� </summary>
  BLL_GetPatDesStructure = BLL_BASE + 59;

  /// <summary> ��Ӳ���������Ϣ </summary>
  BLL_NewLockInRecord = BLL_BASE + 60;

  /// <summary> ��ȡָ���Ĳ�����ǰ�༭������Ϣ </summary>
  BLL_GetInRecordLock = BLL_BASE + 61;

  /// <summary> ɾ��ָ���Ĳ����༭������Ϣ </summary>
  BLL_DeleteInRecordLock = BLL_BASE + 62;

  /// <summary> ��ȡָ������Ԫ�Ŀ��ƽű� </summary>
  BLL_GetDataElementScript = BLL_BASE + 63;

  /// <summary> ����ָ������Ԫ�Ŀ��ƽű� </summary>
  BLL_SetDataElementScript = BLL_BASE + 64;

type
  TBLLServerProxy = class(TObject)
  private
    FReconnect: Boolean;
    FTcpClient: TDiocpBlockTcpClient;
    FDataStream: TMemoryStream;
    FErrCode: Integer;  // �������
    FErrMsg: string;  // ��������ʱ�� ip�Ͷ˿�
    procedure CheckConnect;
    function SendStream(pvStream: TStream): Integer;
    function SendDataStream: Integer;
    function RecvDataStream: Boolean;
    procedure DoError(const AErrCode: Integer; const AParam: string);
    /// <summary> ��ȡָ���Ĳ��� </summary>
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

    function GetTrans: Boolean;
    procedure SetTrans(const Value: Boolean);

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

    /// <summary> ����˴�������ʱ�Ƿ�ʹ������ </summary>
    property Trans: Boolean read GetTrans write SetTrans;

    property TimeOut: Integer read GetTimeOut write SetTimeOut;
    property ErrCode: Integer read FErrCode;
    property ErrMsg: string read FErrMsg;
  end;

implementation

uses
  SysUtils, utils_zipTools, utils_byteTools, DiocpError;

{ TBLLServerProxy }

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
  FErrCode := -1;
  FErrMsg := '';
  FReconnect := True;
  FTcpClient := TDiocpBlockTcpClient.Create(nil);
  FTcpClient.ReadTimeOut := 5000;  // ���ó�ʱ�ȴ�5��
  FTcpClient.OnError := DoError;
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

procedure TBLLServerProxy.DoError(const AErrCode: Integer; const AParam: string);
begin
  FErrCode := AErrCode;
  FErrMsg := AParam;
end;

function TBLLServerProxy.DispatchPack(const AMsgPack: TMsgPack): Boolean;
begin
  FErrCode := -1;
  FErrMsg := '';

  CheckConnect;
  // ��ʼ������ʱ�õ��Ķ���
  FDataStream.Clear;
  // ���õ���ʱ������ֵ
  if AMsgPack.I[BLL_VER] < 1 then
    AMsgPack.ForcePathObject(BLL_VER).AsInteger := 1;  // ҵ��汾
  //AMsgPack.ForcePathObject(BLL_DEVICE).AsInteger := Ord(TDeviceType.cdtMobile);  // �豸����
  AMsgPack.EncodeToStream(FDataStream);  // �������ĵ�������
  TZipTools.ZipStream(FDataStream, FDataStream);  // ѹ������ĵ�������
  SendDataStream;  // ���ݷ��͵������
  RecvDataStream;  // ��ȡ����˷�������
  TZipTools.UnZipStream(FDataStream, FDataStream);  // ��ѹ�����ص�����
  FDataStream.Position := 0;
  AMsgPack.DecodeFromStream(FDataStream);  // ������ص�����
  Result := AMsgPack.Result;  // ����˴���˴ε����Ƿ�ɹ�(����ʾ�������Ӧ�ͻ��˵��óɹ�����������ִ�еĽ��)
  if not Result then  // ����˴���˴ε��ó���
  begin
    if AMsgPack.ForcePathObject(BACKMSG).AsString <> '' then  // ������Ϣ
    begin
      FMsgPack.ForcePathObject(BLL_ERROR).AsString := '������˴���'
        + sLineBreak + AMsgPack.ForcePathObject(BACKMSG).AsString;
    end;
  end
  else  // ����ִ�з��ش�����Ϣ
  begin
    if AMsgPack.ForcePathObject(BLL_METHODMSG).AsString <> '' then
    begin
      FMsgPack.ForcePathObject(BLL_ERROR).AsString := '��ִ�з�������'
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

function TBLLServerProxy.GetPort: Integer;
begin
  Result := FTcpClient.Port;
end;

function TBLLServerProxy.GetTimeOut: Integer;
begin
  Result := FTcpClient.ReadTimeOut;
end;

function TBLLServerProxy.GetTrans: Boolean;
begin
  Result := Param(BLL_TRANS).AsBoolean;
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
  vBytes: TBytes;
  vReadLen, vTempLen: Integer;
  vPACK_FLAG: Word;
  vDataLen: Integer;
  vVerifyValue, vVerifyDataValue: Cardinal;
  vPByte: PByte;
begin
  RecvDataBuffer(@vPACK_FLAG, 2);

  if vPACK_FLAG <> PACK_FLAG then  // ����İ�����
  begin
    FTcpClient.Disconnect;
    raise Exception.Create(strRecvException_ErrorFlag);
  end;

  //veri value
  RecvDataBuffer(@vVerifyValue, SizeOf(vVerifyValue));

  //headlen
  RecvDataBuffer(@vReadLen, SizeOf(vReadLen));
  vDataLen := TByteTools.swap32(vReadLen);

  if vDataLen > MAX_OBJECT_SIZE then  // �ļ�ͷ���󣬴���İ�����
  begin
    FTcpClient.Disconnect;
    raise Exception.Create(strRecvException_ErrorData);
  end;

  SetLength(vBytes,vDataLen);
  vPByte := PByte(@vBytes[0]);
  vReadLen := 0;
  while vReadLen < vDataLen do
  begin
    vTempLen := RecvDataBuffer(vPByte, vDataLen - vReadLen);
    if vTempLen = -1 then
    begin
      RaiseLastOSError;
    end;
    Inc(vPByte, vTempLen);
    vReadLen := vReadLen + vTempLen;
  end;

{$IFDEF POSIX}
  vVerifyDataValue := verifyData(lvBytes[0], lvDataLen);
{$ELSE}
  vVerifyDataValue := verifyData(vBytes[0], vDataLen);
{$ENDIF}

  if vVerifyDataValue <> vVerifyValue then
    raise Exception.Create(strRecvException_VerifyErr);

  FDataStream.Clear;
  FDataStream.Write(vBytes[0], vDataLen);
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
  lvBufBytes: array[0..MAX_BLOCK_SIZE - 1] of byte;
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

procedure TBLLServerProxy.SetPort(const APort: Integer);
begin
  FTcpClient.Port := APort;
end;

procedure TBLLServerProxy.SetTimeOut(const Value: Integer);
begin
  FTcpClient.ReadTimeOut := Value;
end;

procedure TBLLServerProxy.SetTrans(const Value: Boolean);
begin
  Param(BLL_TRANS).AsBoolean := Value;
end;

end.
