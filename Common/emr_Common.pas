{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit emr_Common;

interface

uses
  Winapi.Windows, Classes, SysUtils, Vcl.ComCtrls, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  System.Generics.Collections, emr_BLLServerProxy, FunctionIntf, frm_Hint,
  System.Rtti, TypInfo, Vcl.Grids;

const
  // ����ע���Сд���޸ĺ�Ҫ����sqlite���ж�Ӧ���ֶδ�Сдһ��
  // ���ز���
  PARAM_LOCAL_MSGHOST = 'MsgHost';    // ��Ϣ������IP
  PARAM_LOCAL_MSGPORT = 'MsgPort';    // ��Ϣ�������˿�
  PARAM_LOCAL_BLLHOST = 'BLLHost';    // ҵ�������IP
  PARAM_LOCAL_BLLPORT = 'BLLPort';    // ҵ��������˿�
  PARAM_LOCAL_UPDATEHOST = 'UpdateHost';  // ���·�����IP
  PARAM_LOCAL_UPDATEPORT = 'UpdatePort';  // ���·������˿�
  //PARAM_LOCAL_DEPTCODE = 'DeptCode';  // ����
  PARAM_LOCAL_VERSIONID = 'VersionID';  // �汾��
  //PARAM_LOCAL_PLAYSOUND = 'PlaySound';  // �����������
  // ����˲���
  //PARAM_GLOBAL_HOSPITAL = 'Hospital';  // ҽԺ

const
  EMRSTYLE_TOOTH = -1001;  // ���ݹ�ʽ THCStyle.Custom - 1
  EMRSTYLE_FANGJIAO = -1002;  // ���ǹ�ʽ THCStyle.Custom - 2
  EMRSTYLE_YUEJING = -1003;  // �¾���ʽ

type
  TClientParam = class(TObject)  // �ͻ��˲���(��Winƽ̨ʹ��)
  private
    FMsgServerIP, FBLLServerIP: string;
    FMsgServerPort, FBLLServerPort: Word;
    FTimeOut, FVersionID: Cardinal;
  public
    /// <summary> ��Ϣ������IP </summary>
    property MsgServerIP: string read FMsgServerIP write FMsgServerIP;

    /// <summary> ҵ�������IP </summary>
    property BLLServerIP: string read FBLLServerIP write FBLLServerIP;

    /// <summary> ��Ϣ�������˿� </summary>
    property MsgServerPort: Word read FMsgServerPort write FMsgServerPort;

    /// <summary> ҵ��������˿� </summary>
    property BLLServerPort: Word read FBLLServerPort write FBLLServerPort;

    /// <summary> ��Ӧ��ʱʱ�� </summary>
    property TimeOut: Cardinal read FTimeOut write FTimeOut;

    /// <summary> ���ؿͻ��˰汾 </summary>
    property VersionID: Cardinal read FVersionID write FVersionID;
  end;

  TDataSetInfo = class(TObject)  // ���ݼ���Ϣ
  public
    const
      // ���ݼ�
      /// <summary> ���ݼ����� </summary>
      CLASS_PAGE = 1;
      /// <summary> ���ݼ�ҳü </summary>
      CLASS_HEADER = 2;
      /// <summary> ���ݼ�ҳ�� </summary>
      CLASS_FOOTER = 3;

      // ʹ�÷�Χ 1�ٴ� 2���� 3�ٴ�������
      /// <summary> ģ��ʹ�÷�Χ �ٴ� </summary>
      USERANG_CLINIC = 1;
      /// <summary> ģ��ʹ�÷�Χ ���� </summary>
      USERANG_NURSE = 2;
      /// <summary> ģ��ʹ�÷�Χ �ٴ������� </summary>
      USERANG_CLINICANDNURSE = 3;

      // סԺor���� 1סԺ 2���� 3סԺ������
      /// <summary> סԺ </summary>
      INOROUT_IN = 1;
      /// <summary> ���� </summary>
      INOROUT_OUT = 2;
      /// <summary> סԺ������ </summary>
      INOROUT_INOUT = 3;
  public
    ID, PID,
    GroupClass,  // ģ����� 1���� 2ҳü 3ҳ��
    GroupType,  // ģ������ 1���ݼ�ģ�� 2������ģ��
    UseRang,  // ʹ�÷�Χ 1�ٴ� 2���� 3�ٴ�������
    InOrOut  // סԺor���� 1סԺ 2���� 3סԺ������
      : Integer;
    GroupCode, GroupName: string;

    const
      /// <summary> ���̼�¼ </summary>
      Proc = 13;
      /// <summary> �ճ����̼�¼ </summary>
      NorProc = 60;
  end;

  THCThread = class(TThread)
  private
    FOnExecute: TNotifyEvent;
    procedure DoExecute;
  protected
    procedure Execute; override;
  public
    constructor Create;
    property OnExecute: TNotifyEvent read FOnExecute write FOnExecute;
  end;

  TClientCache = class(TObject)
  private
    FDataSetElementDT, FDataElementDT: TFDMemTable;
    FClientParam: TClientParam;
    FRunPath: string;
    FDataSetInfos: TObjectList<TDataSetInfo>;
    /// <summary> �ڴ�����Ԫ�� </summary>
    procedure GetDataElementTable;
    /// <summary> �ڴ����ݼ���Ϣ </summary>
    procedure GetDataSetTable;
  public
    constructor Create;
    destructor Destroy; override;

    procedure GetCacheData;
    /// <summary> ����ָ�������ݼ�ID�����ذ���������Ԫ��Ϣ </summary>
    procedure GetDataSetElement(const ADesID: Integer);
    function FindDataElementByIndex(const ADeIndex: string): Boolean;
    function GetDataSetInfo(const ADesID: Integer): TDataSetInfo;
    property DataElementDT: TFDMemTable read FDataElementDT;
    property DataSetElementDT: TFDMemTable read FDataSetElementDT;
    property ClientParam: TClientParam read FClientParam;
    property DataSetInfos: TObjectList<TDataSetInfo> read FDataSetInfos;
    property RunPath: string read FRunPath write FRunPath;
  end;

  TBLLServerReadyEvent = reference to procedure(const ABLLServerReady: TBLLServerProxy);
  TBLLServerRunEvent = reference to procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil);

  TOnErrorEvent = procedure(const AErrCode: Integer; const AParam: string) of object;

  TBLLServer = class(TObject)  // ҵ������
  public
    /// <summary>
    /// ����һ������˴���
    /// </summary>
    /// <returns></returns>
    class function GetBLLServerProxy: TBLLServerProxy;

    /// <summary>
    /// ��ȡ�����ʱ��
    /// </summary>
    /// <returns></returns>
    class function GetServerDateTime: TDateTime;

    /// <summary>
    /// ��ȡȫ��ϵͳ����
    /// </summary>
    /// <param name="AParamName"></param>
    /// <returns></returns>
    function GetParam(const AParamName: string): string;

    /// <summary>
    /// ��ȡҵ�������Ƿ���ָ��ʱ���ڿ���Ӧ
    /// </summary>
    /// <param name="AMesc"></param>
    /// <returns></returns>
    function GetBLLServerResponse(const AMesc: Word): Boolean;
  end;

  /// <summary> ��֤״̬ ʧ�ܡ�ͨ�����˺Ų�Ψһ��ͻ </summary>
  TCertificateState = (cfsError, cfsPass, cfsConflict);

  TCertificate = class(TObject)
  public
    ID, Password: string;
    State: TCertificateState;  // ��֤״̬
  end;

  /// <summary> ������Ϣ </summary>
  {TConsultation = class(TObject)
  public
    ID: Integer;
    Apl_UserID: Integer;
    Apl_DT: TDateTime;
    PatID: string;
    PatDeptID: Integer;
    Coslt_DT: TDateTime;
    Coslt_Place: string;
    Coslt_Abstract: string;
  end;

  TConsultationNotify = class(TObject)
  public
    Apl_UserID: Integer;
    Apl_UserName: string;
    Apl_PatID: string;
    Apl_PatName: string;
    Apl_PatDeptName: string;
    Invitee_DeptID: Integer;
  end;

  /// <summary> ����������Ϣ </summary>
  TConsultationInvitee = class(TObject)

  end;}

  TCustomUserInfo = class(TObject)
  strict private
    FID: string;  // �û�ID
    FName: string;  // �û���
    FDeptID: string;  // �û���������ID
    FDeptName: string;  // �û�������������
  protected
    procedure Clear; virtual;
    procedure SetUserID(const Value: string); virtual;
  public
    function FieldByName(const AFieldName: string): TValue; virtual;
    property ID: string read FID write SetUserID;
    property &Name: string read FName write FName;
    property DeptID: string read FDeptID write FDeptID;
    property DeptName: string read FDeptName write FDeptName;
  end;

  TUserInfo = class(TCustomUserInfo)  // ��¼�û���Ϣ
  private
    FGroupDeptIDs: string;  // �û����й������Ӧ����
    FFunCDS: TFDMemTable;
    procedure IniUserInfo;  //�����û�������Ϣ
    procedure IniFuns;  // ����ָ���û����н�ɫ��Ӧ�Ĺ���
    procedure IniGroupDepts;  // ����ָ���û����й������Ӧ�Ŀ���
  protected
    procedure SetUserID(const Value: string); override;  // �û����н�ɫ��Ӧ�Ĺ���
    procedure Clear; override;
    /// <summary>
    /// �жϵ�ǰ�û��Ƿ���ĳ����Ȩ�ޣ���������ж�ADeptID�Ƿ��ڵ�ǰ�û�ʹ�øù���Ҫ��Ŀ��ҷ�Χ
    /// ��APerID�Ƿ��ǵ�ǰ�û�
    /// </summary>
    /// <param name="AFunID">����ID</param>
    /// <param name="ADeptID">����ID</param>
    /// <param name="APerID">�û�ID</param>
    /// <returns>True: �д�Ȩ��</returns>
    function FunAuth(const AFunID, ADeptID: Integer; const APerID: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function FieldByName(const AFieldName: string): TValue; override;

    {���ڲ�ͬҽԺά���Ĺ��ܲ�ͬ��������ݿ���ͬһ����ID��Ӧ�Ŀ����ǲ�ͬ�Ĺ��ܣ�
       ���Դ��벻���ù���ID��Ϊ�����ж��Ƿ���Ȩ�ޣ���ʹ�ÿ����õĿؼ�����������}
    /// <summary>
    /// ���ݲ�������ID���������ж�ָ������ǿؼ��๦���Ƿ���Ȩ��(�����ڽ��о���������¼�ʱ�ж��û�����Ȩ��)
    /// </summary>
    /// <param name="AFormAuthControls">����������Ȩ�޹���Ŀؼ�����Ӧ�Ĺ���ID</param>
    /// <param name="AControlName">�ؼ�����</param>
    /// <param name="ADeptID">����</param>
    /// <param name="APerID">������</param>
    /// <returns>True: ��Ȩ�޲���</returns>
    function FormUnControlAuth(const AFormAuthControls: TFDMemTable; const AControlName: string;
      const ADeptID: Integer; const APerID: string): Boolean;

    /// <summary>
    /// ����ָ���Ŀ���ID����������Ϣ����ָ��������Ȩ�޿��ƿؼ���״̬(�����ڻ����л���ʱ�����û�����ѡ�л��ߵ�Ȩ�����ô���ؼ�״̬)
    /// </summary>
    /// <param name="AForm">����</param>
    /// <param name="ADeptID">����ID</param>
    /// <param name="APersonID">������</param>
    procedure SetFormAuthControlState(const AForm: TComponent; const ADeptID: Integer; const APersonID: string);

    /// <summary> ��ȡָ����������Ȩ�޿��ƵĿؼ���Ϣ����ӵ�ǰ�û�Ȩ����Ϣ(�������û���¼���򿪴����) </summary>
    /// <param name="AForm">����</param>
    /// <param name="AAuthControls">����������Ȩ�޿��ƵĿؼ����ؼ���Ӧ�Ĺ���ID</param>
    procedure IniFormControlAuthInfo(const AForm: TComponent; const AAuthControls: TFDMemTable);

    property FunCDS: TFDMemTable read FFunCDS;
    property GroupDeptIDs: string read FGroupDeptIDs;
  end;

  TPatientInfo = class(TObject)
  private
    FPatID, FInpNo, FBedNo, FName, FSex, FAge, FDeptName: string;
    FDeptID: Cardinal;
    FInDateTime, FInDeptDateTime: TDateTime;
    FCareLevel,  // ������
    FVisitID  // סԺ����
      : Byte;
  public
    procedure Assign(const ASource: TPatientInfo);
    function FieldByName(const AFieldName: string): TValue;
    class procedure SetProposal(const AInsertList, AItemList: TStrings);
    //
    property PatID: string read FPatID write FPatID;
    property &Name: string read FName write FName;
    property Sex: string read FSex write FSex;
    property Age: string read FAge write FAge;
    property BedNo: string read FBedNo write FBedNo;
    property InpNo: string read FInpNo write FInpNo;
    property InDateTime: TDateTime read FInDateTime write FInDateTime;
    property InDeptDateTime: TDateTime read FInDeptDateTime write FInDeptDateTime;
    property CareLevel: Byte read FCareLevel write FCareLevel;
    property VisitID: Byte read FVisitID write FVisitID;
    property DeptID: Cardinal read FDeptID write FDeptID;
    property DeptName: string read FDeptName write FDeptName;
  end;

  TRecordDataSetInfo = class(TObject)
  private
    FDesPID: Cardinal;
  public
    property DesPID: Cardinal read FDesPID write FDesPID;
  end;

  TRecordInfo = class(TObject)  // �ܷ�� TTemplateDeSetInfo �ϲ���
  private
    FID,
    FDesID  // ���ݼ�ID
      : Cardinal;
    //FSignature: Boolean;  // �ͷ��Ѿ�ǩ��
    FRecName: string;
    FDT, FLastDT: TDateTime;
  public
    class procedure SetProposal(const AInsertList, AItemList: TStrings);
    property ID: Cardinal read FID write FID;
    property DesID: Cardinal read FDesID write FDesID;
    property RecName: string read FRecName write FRecName;
    property DT: TDateTime read FDT write FDT;
    property LastDT: TDateTime read FLastDT write FLastDT;
  end;

  TServerInfo = class(TObject)
  private
    FDateTime: TDateTime;
  public
    function FieldByName(const AFieldName: string): TValue;
    property DateTime: TDateTime read FDateTime write FDateTime;
  end;

  TTemplateInfo = class(TObject)  // ģ����Ϣ
    ID, Owner, OwnerID, DesID: Integer;
    NameEx: string;
  end;

  TUpdateHint = procedure(const AHint: string) of object;
  THintProcesEvent = reference to procedure(const AUpdateHint: TUpdateHint);

  procedure HintFormShow(const AHint: string; const AHintProces: THintProcesEvent);

  /// <summary> ͨ������ָ��ҵ�����ִ��ҵ��󷵻صĲ�ѯ���� </summary>
  /// <param name="ABLLServerReady">׼������ҵ��</param>
  /// <param name="ABLLServerRun">����ִ��ҵ��󷵻ص�����</param>
  procedure BLLServerExec(const ABLLServerReady: TBLLServerReadyEvent; const ABLLServerRun: TBLLServerRunEvent);

  /// <summary> ��ȡ����˵�ǰ���µĿͻ��˰汾�� </summary>
  /// <param name="AVerID">�汾ID(��Ҫ���ڱȽϰ汾)</param>
  /// <param name="AVerStr">�汾��(��Ҫ������ʾ�汾��Ϣ)</param>
  procedure GetLastVersion(var AVerID: Integer; var AVerStr: string);

  /// <summary> ����ָ���ĸ�ʽ������� </summary>
  /// <param name="AFormatStr">��ʽ</param>
  /// <param name="ASize">����</param>
  /// <returns>��ʽ��������</returns>
  function FormatSize(const AFormatStr: string; const ASize: Int64): string;

  procedure Certification(const ACertificate: TCertificate);
  function TreeNodeIsTemplate(const ANode: TTreeNode): Boolean;
  function TreeNodeIsRecordDataSet(const ANode: TTreeNode): Boolean;
  function TreeNodeIsRecord(const ANode: TTreeNode): Boolean;
  procedure GetTemplateContent(const ATempID: Cardinal; const AStream: TStream);
  procedure GetRecordContent(const ARecordID: Cardinal; const AStream: TStream);
  function SignatureInchRecord(const ARecordID: Integer; const AUserID: string): Boolean;
  function GetInchRecordSignature(const ARecordID: Integer): Boolean;

  procedure SaveStringGridRow(var ARow, ATopRow: Integer; const AGrid: TStringGrid);
  procedure RestoreStringGridRow(const ARow, ATopRow: Integer; const AGrid: TStringGrid);
  procedure DeleteGridRow(const AGrid: TStringGrid; const ARow: Integer = -1);
  function MD5(const AText: string): string;
  function IsPY(const AChar: Char): Boolean;
  function GetValueAsString(const AValue: TValue): string;

var
  ClientCache: TClientCache;
  //EmrFormatSettings: TFormatSettings;

implementation

uses
  Variants, emr_MsgPack, emr_Entry, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.StorageBin,
  IdHashMessageDigest;

function MD5(const AText: string): string;
var
  vMD5: TIdHashMessageDigest5;
begin
  vMD5 := TIdHashMessageDigest5.Create;
  try
    Result := vMD5.HashStringAsHex(AText);
  finally
    vMD5.Free;
  end;
end;

function IsPY(const AChar: Char): Boolean;
begin
  Result := AChar in ['a'..'z', 'A'..'Z'];
end;

function GetValueAsString(const AValue: TValue): string;
begin
  if AValue.TypeInfo.Name = 'TDateTime' then
    Result := FormatDateTime('YYYY-MM-DD HH:mm', AValue.AsType<TDatetime>)
  else
    Result := AValue.AsString;
end;

procedure Certification(const ACertificate: TCertificate);
begin
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)  // ��ȡ��¼�û�����Ϣ
    begin
      ABLLServerReady.Cmd := BLL_CERTIFICATE;  // �˶Ե�¼��Ϣ
      //vExecParam.I[BLL_VER] := 1;  // ҵ��汾
      ABLLServerReady.ExecParam.S[TUser.ID] := ACertificate.ID;
      ABLLServerReady.ExecParam.S[TUser.Password] := ACertificate.Password;

      ABLLServerReady.AddBackField(BLL_RECORDCOUNT);
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
      begin
        raise Exception.Create(ABLLServer.MethodError);
        Exit;
      end;

      if ABLLServer.BackField(BLL_RECORDCOUNT).AsInteger = 1 then
        ACertificate.State := cfsPass
      else
      if ABLLServer.BackField(BLL_RECORDCOUNT).AsInteger = 0 then
        ACertificate.State := cfsError
      else
      if ABLLServer.BackField(BLL_RECORDCOUNT).AsInteger > 1 then
        ACertificate.State := cfsConflict;
    end);
end;

procedure HintFormShow(const AHint: string; const AHintProces: THintProcesEvent);
var
  vFrmHint: TfrmHint;
begin
  vFrmHint := TfrmHint.Create(nil);
  try
    vFrmHint.Show;
    vFrmHint.UpdateHint(AHint);

    if Assigned(AHintProces) then
      AHintProces(vFrmHint.UpdateHint);
  finally
    FreeAndNil(vFrmHint);
  end;
end;

function SignatureInchRecord(const ARecordID: Integer; const AUserID: string): Boolean;
begin
  Result := False;

  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_INCHRECORDSIGNATURE;  // סԺ����ǩ��
      ABLLServerReady.ExecParam.I['RID'] := ARecordID;
      ABLLServerReady.ExecParam.S['UserID'] := AUserID;
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        raise Exception.Create(ABLLServer.MethodError);
    end);

  Result := True;
end;

function GetInchRecordSignature(const ARecordID: Integer): Boolean;
var
  vSignatureCount: Integer;
begin
  Result := False;
  vSignatureCount := 0;

  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETINCHRECORDSIGNATURE;  // ��ȡסԺ����ǩ����Ϣ
      ABLLServerReady.ExecParam.I['RID'] := ARecordID;
      ABLLServerReady.BackDataSet := True;
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        raise Exception.Create(ABLLServer.MethodError);

      if AMemTable <> nil then
        vSignatureCount := AMemTable.RecordCount;
    end);

  Result := vSignatureCount > 0;
end;

function TreeNodeIsTemplate(const ANode: TTreeNode): Boolean;
begin
  Result := (ANode <> nil) and (TObject(ANode.Data) is TTemplateInfo);
end;

function TreeNodeIsRecordDataSet(const ANode: TTreeNode): Boolean;
begin
  Result := (ANode <> nil) and (TObject(ANode.Data) is TRecordDataSetInfo);
end;

function TreeNodeIsRecord(const ANode: TTreeNode): Boolean;
begin
  Result := (ANode <> nil) and (TObject(ANode.Data) is TRecordInfo);
end;

procedure GetTemplateContent(const ATempID: Cardinal; const AStream: TStream);
begin
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETTEMPLATECONTENT;  // ��ȡģ������ӷ����ģ��
      ABLLServerReady.ExecParam.I['TID'] := ATempID;
      ABLLServerReady.AddBackField('content');
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        raise Exception.Create(ABLLServer.MethodError);

      ABLLServer.BackField('content').SaveBinaryToStream(AStream);
    end);
end;

procedure GetRecordContent(const ARecordID: Cardinal; const AStream: TStream);
begin
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETINCHRECORDCONTENT;  // ��ȡģ������ӷ����ģ��
      ABLLServerReady.ExecParam.I['RID'] := ARecordID;
      ABLLServerReady.AddBackField('content');
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        raise Exception.Create(ABLLServer.MethodError);

      ABLLServer.BackField('content').SaveBinaryToStream(AStream);
    end);
end;

procedure GetLastVersion(var AVerID: Integer; var AVerStr: string);
var
  vVerID: Integer;
  vVerStr: string;
begin
  vVerID := 0;
  vVerStr := '';
  BLLServerExec(
    procedure(const ABllServerReady: TBLLServerProxy)
    begin
      ABllServerReady.Cmd := BLL_GETLASTVERSION;  // ��ȡҪ���������°汾��
      ABllServerReady.AddBackField('id');
      ABllServerReady.AddBackField('Version');
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then
        raise Exception.Create(ABLLServer.MethodError);

      vVerID := ABLLServer.BackField('id').AsInteger;  // �汾ID
      vVerStr := ABLLServer.BackField('Version').AsString;  // �汾��
    end);
  AVerID := vVerID;
  AVerStr := vVerStr;
end;

function FormatSize(const AFormatStr: string; const ASize: Int64): string;
begin
  Result := '';
  if ASize < 1024 then  // �ֽ�
    Result := ASize.ToString + 'B'
  else
  if (ASize >= 1024) and (ASize < 1024 * 1024) then  // KB
    Result := FormatFloat(AFormatStr, ASize / 1024) + 'KB'
  else  // MB
    Result := FormatFloat(AFormatStr, ASize / (1024 * 1024)) + 'MB';
end;

procedure SaveStringGridRow(var ARow, ATopRow: Integer; const AGrid: TStringGrid);
begin
  ARow := AGrid.Row;
  ATopRow := AGrid.TopRow;
end;

procedure RestoreStringGridRow(const ARow, ATopRow: Integer; const AGrid: TStringGrid);
begin
  if ATopRow > AGrid.FixedRows - 1 then  // Ϊ0ʱ�ٸ�ֵTopRow���ظ�2�б���
    AGrid.TopRow := ATopRow;

  if ARow > 0 then
  begin
    if ARow > AGrid.RowCount - 1 then
      AGrid.Row := AGrid.RowCount - 1
    else
      AGrid.Row := ARow;
  end;
end;

procedure DeleteGridRow(const AGrid: TStringGrid; const ARow: Integer = -1);
var
  i, j, vRow: Integer;
begin
  if ARow < 0 then
    vRow := AGrid.Row
  else
    vRow := ARow;

  if vRow > AGrid.FixedRows - 1 then
  begin
    for i := vRow to AGrid.RowCount - 2 do
    begin
      for j := 0 to AGrid.ColCount - 1 do
        AGrid.Cells[j, i] := AGrid.Cells[j, i + 1];
    end;

    AGrid.RowCount := AGrid.RowCount - 1;
  end;
end;

{ TUserInfo }

procedure TUserInfo.Clear;
begin
  inherited Clear;
  FGroupDeptIDs := '';
  if not FFunCDS.IsEmpty then  // �������
    FFunCDS.EmptyDataSet;
end;

constructor TUserInfo.Create;
begin
  FFunCDS := TFDMemTable.Create(nil);
end;

destructor TUserInfo.Destroy;
begin
  FFunCDS.Free;
  inherited;
end;

function TUserInfo.FieldByName(const AFieldName: string): TValue;
begin
  Result := inherited FieldByName(AFieldName);
end;

function TUserInfo.FormUnControlAuth(const AFormAuthControls: TFDMemTable;
  const AControlName: string; const ADeptID: Integer;
  const APerID: string): Boolean;
begin

end;

function TUserInfo.FunAuth(const AFunID, ADeptID: Integer;
  const APerID: string): Boolean;
begin
  Result := False;
end;

procedure TUserInfo.IniFormControlAuthInfo(const AForm: TComponent;
  const AAuthControls: TFDMemTable);
//var
//  i: Integer;
begin
  // �Ƚ��ؼ���Ȩ�������ͷŷ�ֹ��һ�ε���ϢӰ�챾�ε���
//  for i := 0 to AForm.ComponentCount - 1 do
//  begin
//    if (AForm.Components[i] is TControl) and ((AForm.Components[i] as TControl).TagObject <> nil) then
//      (AForm.Components[i] as TControl).TagObject.Free;
//  end;
//
//  if not AAuthControls.IsEmpty then  // ������е�Ȩ�޿ؼ�����
//    AAuthControls.EmptyDataSet;
//
//  BLLServerExec(
//    procedure(const ABLLServer: TBLLServerProxy)
//    var
//      vExecParam: TMsgPack;
//    begin
//      ABLLServer.Cmd := BLL_GETCONTROLSAUTH;  // ��ȡָ��������������Ȩ�޿��ƵĿؼ�
//      vExecParam := ABLLServer.ExecParam;
//      vExecParam.S['FormName'] := AForm.Name;  // ������
//      ABLLServer.BackDataSet := True;
//    end,
//    procedure(const ABLLServer: TBLLServerProxy)
//
//    var
//      vHasAuth: Boolean;
//      vControl: TControl;
//      vCustomFunInfo: TCustomFunInfo;
//    begin
//      if not ABLLServer.MethodRunOk then
//        raise Exception.Create('�쳣����ȡ������Ȩ�޿��ƿؼ�����');
//
//      if not VarIsEmpty(ABLLServer.BLLDataSet) then  // ����Ȩ�޿��ƵĿؼ�����Ϊ��Ȩ��״̬
//      begin
//        AAuthControls.Data := ABLLServer.BLLDataSet;  // �洢��ǰ����������Ȩ�޹���Ŀؼ����ؼ���Ӧ�Ĺ���ID
//        AAuthControls.First;
//        while not AAuthControls.Eof do
//        begin
//          vHasAuth := False;
//          vControl := GetControlByName(AForm, AAuthControls.FieldByName('ControlName').AsString);
//          if vControl <> nil then  // �ҵ���Ȩ�޿��ƵĿؼ�
//          begin
//            // ���ƿؼ���״̬
//            if not GUserInfo.FunCDS.IsEmpty then  // ��ǰ�û��й���Ȩ������
//            begin
//              if GUserInfo.FunCDS.Locate('FunID', AAuthControls.FieldByName('FunID').AsInteger,
//                [TLocateOption.loCaseInsensitive])
//              then  // ��ǰ�û��д˹��ܵ�Ȩ��
//              begin
//                // ���ݵ�ǰ�û�ʹ�ô˹��ܵ�Ȩ�޷�Χ���ÿؼ���Ȩ������
//                if vControl.TagObject <> nil then  // ����ؼ���Ȩ�����������ͷ�
//                  vControl.TagObject.Free;
//
//                // ����ǰ�û�ʹ�øÿؼ���Ȩ�޷�Χ�󶨵��ؼ���
//                vCustomFunInfo := TCustomFunInfo.Create;
//                vCustomFunInfo.FunID := AAuthControls.FieldByName('FunID').AsInteger;
//                vCustomFunInfo.VisibleType := AAuthControls.FieldByName('VisibleType').AsInteger;
//                vCustomFunInfo.RangeID := GUserInfo.FunCDS.FieldByName('RangeID').AsInteger;
//                vCustomFunInfo.RangeDepts := GUserInfo.FunCDS.FieldByName('RangeDept').AsString;
//                vControl.TagObject := vCustomFunInfo;
//
//                vHasAuth := True;
//              end;
//            end;
//
//            if vHasAuth then  // �й��ܵ�Ȩ��
//            begin
//              vControl.Visible := True;
//              vControl.Enabled := True;
//            end
//            else  // ��ǰ�û��޴˹��ܵ�Ȩ��
//            begin
//              if AAuthControls.FieldByName('VisibleType').AsInteger = 0 then  // ��Ȩ��ʱ����ʾ
//                vControl.Visible := False
//              else
//              if AAuthControls.FieldByName('VisibleType').AsInteger = 1 then  // ��Ȩ��ʱ������
//              begin
//                vControl.Visible := True;
//                vControl.Enabled := False;
//              end;
//            end;
//          end;
//
//          AAuthControls.Next;
//        end;
//      end;
//    end);
end;

procedure TUserInfo.IniFuns;
begin
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETUSERFUNS;  // ��ȡ�û����õ����й���
      ABLLServerReady.ExecParam.S[TUser.ID] := ID;
      ABLLServerReady.BackDataSet := True;
    end,
    procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServerRun.MethodRunOk then
        raise Exception.Create(ABLLServerRun.MethodError); // Exit;  // ShowMessage(ABLLServer.MethodError);

      if AMemTable <> nil then
      begin
        FFunCDS.Close;
        FFunCDS.Data := AMemTable.Data;
      end;
    end);
end;

procedure TUserInfo.IniGroupDepts;
begin
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETUSERGROUPDEPTS;  // ��ȡָ���û����й������Ӧ�Ŀ���
      ABLLServerReady.ExecParam.S[TUser.ID] := ID;
      ABLLServerReady.BackDataSet := True;
    end,
    procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServerRun.MethodRunOk then
        raise Exception.Create(ABLLServerRun.MethodError);  //Exit;  // ShowMessage(ABLLServer.MethodError);

      if AMemTable <> nil then
      begin
        AMemTable.First;
        while not AMemTable.Eof do  // ��������
        begin
          if FGroupDeptIDs = '' then
            FGroupDeptIDs := AMemTable.FieldByName(TUser.DeptID).AsString
          else
            FGroupDeptIDs := FGroupDeptIDs + ',' + AMemTable.FieldByName(TUser.DeptID).AsString;

          AMemTable.Next;
        end;
      end;
    end);
end;

procedure TUserInfo.IniUserInfo;
begin
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETUSERINFO;  // ��ȡָ���û�����Ϣ
      ABLLServerReady.ExecParam.S[TUser.ID] := ID;  // �û�ID

      ABLLServerReady.AddBackField(TUser.NameEx);
      ABLLServerReady.AddBackField(TUser.DeptID);
      ABLLServerReady.AddBackField(TUser.DeptName);
    end,

    procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServerRun.MethodRunOk then
        raise Exception.Create(ABLLServerRun.MethodError);  //Exit;

      Name := ABLLServerRun.BackField(TUser.NameEx).AsString;  // �û�����
      DeptID := ABLLServerRun.BackField(TUser.DeptID).AsString;  // ��������ID
      DeptName := ABLLServerRun.BackField(TUser.DeptName).AsString;  // ����
    end);
end;

procedure TUserInfo.SetFormAuthControlState(const AForm: TComponent;
  const ADeptID: Integer; const APersonID: string);
//var
//  i: Integer;
//  vControl: TControl;
begin
//  for i := 0 to AForm.ComponentCount - 1 do  // ������������пؼ�
//  begin
//    if AForm.Components[i] is TControl then
//    begin
//      vControl := AForm.Components[i] as TControl;
//      if vControl.TagObject <> nil then
//      begin
//        if Self.FunAuth((vControl.TagObject as TCustomFunInfo).FunID, ADeptID, APersonID) then  // ��Ȩ��
//        begin
//          vControl.Visible := True;
//          vControl.Enabled := True;
//        end
//        else  // û��Ȩ��
//        begin
//          if (vControl.TagObject as TCustomFunInfo).VisibleType = 0 then  // ��Ȩ�ޣ����ɼ�
//            vControl.Visible := False
//          else
//          if (vControl.TagObject as TCustomFunInfo).VisibleType = 1 then  // ��Ȩ�ޣ�������
//          begin
//            vControl.Visible := True;
//            vControl.Enabled := False;
//          end;
//        end;
//      end;
//    end;
//  end;
end;

procedure TUserInfo.SetUserID(const Value: string);
begin
  Clear;
  inherited SetUserID(Value);
  if ID <> '' then
  begin
    IniUserInfo;    // ȡ�û�������Ϣ
    IniGroupDepts;  // ȡ�������Ӧ�����п���
    IniFuns;        // ȡ��ɫ��Ӧ�����й��ܼ���Χ
  end;
end;

{ TBLLServer }

procedure BLLServerExec(const ABLLServerReady: TBLLServerReadyEvent; const ABLLServerRun: TBLLServerRunEvent);
var
  vBLLSrvProxy: TBLLServerProxy;
  vMemTable: TFDMemTable;
  vMemStream: TMemoryStream;
begin
  vBLLSrvProxy := TBLLServer.GetBLLServerProxy;
  try
    ABLLServerReady(vBLLSrvProxy);  // ���õ���ҵ��
    if vBLLSrvProxy.DispatchPack then  // �������Ӧ�ɹ�
    begin
      if vBLLSrvProxy.BackDataSet then  // �������ݼ�
      begin
        vMemTable := TFDMemTable.Create(nil);
        vMemStream := TMemoryStream.Create;
        try
          vBLLSrvProxy.GetBLLDataSet(vMemStream);
          vMemStream.Position := 0;
          vMemTable.LoadFromStream(vMemStream, TFDStorageFormat.sfBinary);
        finally
          FreeAndNil(vMemStream);
        end;
      end
      else
        vMemTable := nil;

      ABLLServerRun(vBLLSrvProxy, vMemTable);  // ����ִ��ҵ��󷵻صĲ�ѯ����
    end;
  finally
    if vMemTable <> nil then
      FreeAndNil(vMemTable);
    FreeAndNil(vBLLSrvProxy);
  end;
end;

class function TBLLServer.GetBLLServerProxy: TBLLServerProxy;
begin
  Result := TBLLServerProxy.CreateEx(ClientCache.ClientParam.BLLServerIP,
    ClientCache.ClientParam.BLLServerPort);
  Result.TimeOut := ClientCache.ClientParam.TimeOut;
  Result.ReConnectServer;
end;

function TBLLServer.GetBLLServerResponse(const AMesc: Word): Boolean;
var
  vServerProxy: TBLLServerProxy;
begin
  Result := False;
  vServerProxy := TBLLServerProxy.CreateEx(ClientCache.ClientParam.BLLServerIP,
    ClientCache.ClientParam.BLLServerPort);
  try
    vServerProxy.TimeOut := AMesc;
    vServerProxy.ReConnectServer;
    Result := vServerProxy.Active;
  finally
    FreeAndNil(vServerProxy);
  end;
end;

function TBLLServer.GetParam(const AParamName: string): string;
var
  vBLLSrvProxy: TBLLServerProxy;
  vExecParam: TMsgPack;
begin
  vBLLSrvProxy := GetBLLServerProxy;
  try
    vBLLSrvProxy.Cmd := BLL_COMM_GETPARAM;  // ���û�ȡ����˲�������
    vExecParam := vBLLSrvProxy.ExecParam;  // ���ݵ�����˵Ĳ������ݴ�ŵ��б�
    vExecParam.S['Name'] := AParamName;
    vBLLSrvProxy.AddBackField('value');

    if vBLLSrvProxy.DispatchPack then  // ִ�з����ɹ�(��������ִ�еĽ��������ʾ����˳ɹ��յ��ͻ��˵��������Ҵ������)
      Result := vBLLSrvProxy.BackField('value').AsString;
  finally
    vBLLSrvProxy.Free;
  end;
end;

class function TBLLServer.GetServerDateTime: TDateTime;
var
  vBLLSrvProxy: TBLLServerProxy;
begin
  vBLLSrvProxy := GetBLLServerProxy;
  try
    vBLLSrvProxy.Cmd := BLL_SRVDT;  // ���û�ȡ�����ʱ�书��
    vBLLSrvProxy.AddBackField('dt');

    if vBLLSrvProxy.DispatchPack then  // ִ�з����ɹ�(��������ִ�еĽ��������ʾ����˳ɹ��յ��ͻ��˵��������Ҵ������)
      Result := vBLLSrvProxy.BackField('dt').AsDateTime;
  finally
    vBLLSrvProxy.Free;
  end;
end;

{ TCustomUserInfo }

procedure TCustomUserInfo.Clear;
begin
  FID := '';
  FName := '';
  FDeptID := '';
  FDeptName := '';
end;

function TCustomUserInfo.FieldByName(const AFieldName: string): TValue;
var
  vRttiContext: TRttiContext;
  vRttiType: TRttiType;
begin
  vRttiType := vRttiContext.GetType(TCustomUserInfo);
  Result := vRttiType.GetProperty(AFieldName).GetValue(Self);
end;

procedure TCustomUserInfo.SetUserID(const Value: string);
begin
  if FID <> Value then
    FID := Value;
end;

{ TPatientInfo }

procedure TPatientInfo.Assign(const ASource: TPatientInfo);
begin
  FInpNo := ASource.InpNo;
  FBedNo := ASource.BedNo;
  FName := ASource.Name;
  FSex := ASource.Sex;
  FAge := ASource.Age;
  FDeptID := ASource.DeptID;
  FDeptName := ASource.DeptName;
  FPatID := ASource.PatID;
  FInDateTime := ASource.InDateTime;
  FInDeptDateTime := ASource.InDeptDateTime;
  FCareLevel := ASource.CareLevel;
  FVisitID := ASource.VisitID;
end;

function TPatientInfo.FieldByName(const AFieldName: string): TValue;
var
  vRttiContext: TRttiContext;
  vRttiType: TRttiType;
begin
  vRttiType := vRttiContext.GetType(TPatientInfo);
  Result := vRttiType.GetProperty(AFieldName).GetValue(Self);
end;

class procedure TPatientInfo.SetProposal(const AInsertList, AItemList: TStrings);
begin
  AInsertList.Add('PatID');
  AItemList.Add('property \column{}\style{+B}PatID\style{-B}: string;  // ���߱��');
  AInsertList.Add('Name');
  AItemList.Add('property \column{}\style{+B}Name\style{-B}: string;  // ����');
  AInsertList.Add('Sex');
  AItemList.Add('property \column{}\style{+B}Sex\style{-B}: string;  // �Ա�');
  AInsertList.Add('Age');
  AItemList.Add('property \column{}\style{+B}Age\style{-B}: string;  // ����(����λ)');
  AInsertList.Add('BedNo');
  AItemList.Add('property \column{}\style{+B}BedNo\style{-B}: string;  // ����');
  AInsertList.Add('InpNo');
  AItemList.Add('property \column{}\style{+B}InpNo\style{-B}: string;  // סԺ��');
  AInsertList.Add('InDateTime');
  AItemList.Add('property \column{}\style{+B}InDateTime\style{-B}: TDateTime;  // ��Ժʱ��');
  AInsertList.Add('InDeptDateTime');
  AItemList.Add('property \column{}\style{+B}InDeptDateTime\style{-B}: TDateTime;  // ���ʱ��');
  AInsertList.Add('CareLevel');
  AItemList.Add('property \column{}\style{+B}CareLevel\style{-B}: Byte;  // ������');
  AInsertList.Add('VisitID');
  AItemList.Add('property \column{}\style{+B}VisitID\style{-B}: Byte;  // ���');
  AInsertList.Add('DeptID');
  AItemList.Add('property \column{}\style{+B}DeptID\style{-B}: Cardinal;  // ��ǰ����ID');
  AInsertList.Add('DeptName');
  AItemList.Add('property \column{}\style{+B}DeptName\style{-B}: string;  // ��ǰ����');
end;

{ TClientCache }

constructor TClientCache.Create;
begin
//  GetLocaleFormatSettings(GetUserDefaultLCID, EmrFormatSettings);
//  EmrFormatSettings.DateSeparator := '-';
//  EmrFormatSettings.TimeSeparator := ':';
//  EmrFormatSettings.ShortDateFormat := 'yyyy-MM-dd';
//  EmrFormatSettings.ShortTimeFormat := 'hh:mm:ss';

  FRunPath := ExtractFilePath(ParamStr(0));
  FDataSetElementDT := TFDMemTable.Create(nil);
  FDataElementDT := TFDMemTable.Create(nil);
  FClientParam := TClientParam.Create;
  FDataSetInfos := TObjectList<TDataSetInfo>.Create;
end;

destructor TClientCache.Destroy;
begin
  FreeAndNil(FDataSetElementDT);
  FreeAndNil(FDataElementDT);
  FreeAndNil(FClientParam);
  FreeAndNil(FDataSetInfos);
  inherited Destroy;
end;

function TClientCache.FindDataElementByIndex(const ADeIndex: string): Boolean;
var
  vIndex: Integer;
begin
  Result := False;
  if TryStrToInt(ADeIndex, vIndex) then
    Result := DataElementDT.Locate('deid', vIndex);
end;

procedure TClientCache.GetCacheData;
begin
  GetDataElementTable;
  GetDataSetTable;
end;

procedure TClientCache.GetDataSetTable;
begin
  FDataSetInfos.Clear;

  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETDATAELEMENTSETROOT;  // ��ȡ���ݼ�(��Ŀ¼)��Ϣ
      ABLLServerReady.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    var
      vDataSetInfo: TDataSetInfo;
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
      begin
        raise Exception.Create(ABLLServer.MethodError);
        Exit;
      end;

      if AMemTable <> nil then
      begin
        with AMemTable do
        begin
          First;
          while not Eof do
          begin
            vDataSetInfo := TDataSetInfo.Create;
            vDataSetInfo.ID := FieldByName('id').AsInteger;
            vDataSetInfo.PID := FieldByName('pid').AsInteger;
            vDataSetInfo.GroupClass := FieldByName('Class').AsInteger;
            vDataSetInfo.GroupType := FieldByName('Type').AsInteger;
            vDataSetInfo.GroupName := FieldByName('Name').AsString;
            FDataSetInfos.Add(vDataSetInfo);

            Next;
          end;
        end;
      end;
    end);
end;

procedure TClientCache.GetDataSetElement(const ADesID: Integer);
var
  vBLLSrvProxy: TBLLServerProxy;
  vExecParam: TMsgPack;
  vMemStream: TMemoryStream;
begin
  if not DataSetElementDT.IsEmpty then
    DataSetElementDT.EmptyDataSet;

  vBLLSrvProxy := TBLLServer.GetBLLServerProxy;
  try
    vBLLSrvProxy.Cmd := BLL_GETDATASETELEMENT;  // ��ȡ����Ԫ�б�
    vExecParam := vBLLSrvProxy.ExecParam;
    vExecParam.I['DsID'] := ADesID;  // �û�ID

    vBLLSrvProxy.AddBackField('DeID');
    vBLLSrvProxy.AddBackField('KX');
    vBLLSrvProxy.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
    if vBLLSrvProxy.DispatchPack then  // �������Ӧ�ɹ�
    begin
      if vBLLSrvProxy.BackDataSet then  // �������ݼ�
      begin
        vMemStream := TMemoryStream.Create;
        try
          vBLLSrvProxy.GetBLLDataSet(vMemStream);
          vMemStream.Position := 0;
          DataSetElementDT.LoadFromStream(vMemStream, TFDStorageFormat.sfBinary);
        finally
          FreeAndNil(vMemStream);
        end;
      end;
    end;
  finally
    FreeAndNil(vBLLSrvProxy);
  end;

  {BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    var
      vExecParam: TMsgPack;
    begin
      ABLLServerReady.Cmd := BLL_GETDATASETELEMENT;  // ��ȡָ���û�����Ϣ
      vExecParam := ABLLServerReady.ExecParam;
      vExecParam.I['DsID'] := ADesID;  // �û�ID

      ABLLServerReady.AddBackField('DeID');
      ABLLServerReady.AddBackField('KX');
      ABLLServerReady.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
    end,

    procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    var
      vMs: TMemoryStream;
    begin
      if not ABLLServerRun.MethodRunOk then
        raise Exception.Create(ABLLServerRun.MethodError);  //Exit;

      if AMemTable <> nil then
      begin
        vMs := TMemoryStream.Create;
        try
          AMemTable.SaveToStream(vMs);
          vMs.Position := 0;
          DataSetElementDT.LoadFromStream(vMs);
        finally
          vMs.Free;
        end;
        //DTDataSetElement.CopyDataSet(AMemTable, [coStructure, coRestart, coAppend]);
      end;
    end);}
end;

procedure TClientCache.GetDataElementTable;
var
  vBLLSrvProxy: TBLLServerProxy;
  vMemStream: TMemoryStream;
begin
  if not FDataElementDT.IsEmpty then
    FDataElementDT.EmptyDataSet;

  FDataElementDT.Filtered := False;

  vBLLSrvProxy := TBLLServer.GetBLLServerProxy;
  try
    vBLLSrvProxy.Cmd := BLL_GETDATAELEMENT;  // ��ȡ����Ԫ�б�
    vBLLSrvProxy.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
    if vBLLSrvProxy.DispatchPack then  // �������Ӧ�ɹ�
    begin
      if vBLLSrvProxy.BackDataSet then  // �������ݼ�
      begin
        vMemStream := TMemoryStream.Create;
        try
          vBLLSrvProxy.GetBLLDataSet(vMemStream);
          vMemStream.Position := 0;
          FDataElementDT.LoadFromStream(vMemStream, TFDStorageFormat.sfBinary);
        finally
          FreeAndNil(vMemStream);
        end;
      end;
    end;
  finally
    FreeAndNil(vBLLSrvProxy);
  end;

  {BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETDATAELEMENT;  // ��ȡ����Ԫ�б�
      ABLLServerReady.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
    end,
    procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    var
      vMs: TMemoryStream;
      i: Integer;
      vField: TField;
    begin
      if not ABLLServerRun.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        raise Exception.Create(ABLLServerRun.MethodError);

      if Assigned(AMemTable) then
      begin
        for i := 0 to AMemTable.Fields.Count - 1 do
        begin
          vField := TField.Create(nil);

          DataElementDT.Fields.Add(AMemTable.Fields[i]);
        end;
        //DTDE.CopyDataSet(AMemTable, [coStructure, coRestart, coAppend]);
        //DataElementDT.CommitUpdates;
      end;
    end); }
end;

function TClientCache.GetDataSetInfo(const ADesID: Integer): TDataSetInfo;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to FDataSetInfos.Count - 1 do
  begin
    if FDataSetInfos[i].ID = ADesID then
    begin
      Result := FDataSetInfos[i];
      Break;
    end;
  end;
end;

{ THCThread }

constructor THCThread.Create;
begin
  inherited Create(True);
  Self.FreeOnTerminate := False;
end;

procedure THCThread.DoExecute;
begin
  if Assigned(FOnExecute) then
    FOnExecute(Self);
end;

procedure THCThread.Execute;
begin
  while not Terminated do
  begin
    DoExecute;
    Sleep(1);
  end;
end;

{ TServerInfo }

function TServerInfo.FieldByName(const AFieldName: string): TValue;
var
  vRttiContext: TRttiContext;
  vRttiType: TRttiType;
begin
  vRttiType := vRttiContext.GetType(TServerInfo);
  Result := vRttiType.GetProperty(AFieldName).GetValue(Self);
end;

{ TRecordInfo }

class procedure TRecordInfo.SetProposal(const AInsertList, AItemList: TStrings);
begin
  AInsertList.Add('ID');
  AItemList.Add('property \column{}\style{+B}ID\style{-B}: Cardinal;  // ����ID');
  AInsertList.Add('DesID');
  AItemList.Add('property \column{}\style{+B}DesID\style{-B}: Cardinal;  // �������ݼ�ID');
  AInsertList.Add('RecName');
  AItemList.Add('property \column{}\style{+B}RecName\style{-B}: string;  // ��������');
  AInsertList.Add('DT');
  AItemList.Add('property \column{}\style{+B}DT\style{-B}: TDateTime;  // ��������ʱ��');
  AInsertList.Add('LastDT');
  AItemList.Add('property \column{}\style{+B}LastDT\style{-B}: TDateTime;  // ������󴴽�ʱ��');
end;

end.
