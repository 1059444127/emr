{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit frm_login;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, FunctionIntf, Vcl.StdCtrls, Vcl.Dialogs;

type
  TfrmLogin = class(TForm)
    btnOk: TButton;
    lbl1: TLabel;
    edtUserID: TEdit;
    edtPassword: TEdit;
    btnCancel: TButton;
    lbl2: TLabel;
    lblSet: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lblSetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FUserID: string;
    FOnFunctionNotify: TFunctionNotifyEvent;
  public
    { Public declarations }
  end;

  procedure PluginShowLoginForm(AIFun: IFunBLLFormShow);
  procedure PluginCloseLoginForm;

var
  frmLogin: TfrmLogin;
  PlugInID: string;

implementation

uses
  PluginConst, FunctionConst, FunctionImp, emr_Common, emr_BLLServerProxy,
  emr_MsgPack, emr_PluginObject, emr_Entry, IdHashMessageDigest,
  FireDAC.Comp.Client, frm_ConnSet;

{$R *.dfm}

procedure PluginShowLoginForm(AIFun: IFunBLLFormShow);
var
  vUserInfo: IPlugInUserInfo;
begin
  if FrmLogin = nil then
    FrmLogin := Tfrmlogin.Create(nil);

  FrmLogin.FOnFunctionNotify := AIFun.OnNotifyEvent;

  FrmLogin.ShowModal;

  if FrmLogin.ModalResult = mrOk then
  begin
    vUserInfo := TPlugInUserInfo.Create;
    vUserInfo.UserID := FrmLogin.FUserID;
    FrmLogin.FOnFunctionNotify(PlugInID, FUN_USERINFO, vUserInfo);  // �����������¼�û���
  end;

  FrmLogin.FOnFunctionNotify(PlugInID, FUN_BLLFORMDESTROY, nil);  // �ͷ�ҵ������Դ
end;

procedure PluginCloseLoginForm;
begin
  if FrmLogin <> nil then
    FreeAndNil(FrmLogin);
end;

procedure TfrmLogin.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmLogin.btnOkClick(Sender: TObject);
begin
  HintFormShow('���ڵ�¼...', procedure(const AUpdateHint: TUpdateHint)
  begin
    BLLServerExec(
      procedure(const ABLLServerReady: TBLLServerProxy)  // ��ȡ��¼�û�����Ϣ
      var
        vExecParam: TMsgPack;
        vPAWMD5: TIdHashMessageDigest5;
      begin
        ABLLServerReady.Cmd := BLL_LOGIN;  // �˶Ե�¼��Ϣ
        vExecParam := ABLLServerReady.ExecParam;
        vExecParam.S[TUser.ID] := edtUserID.Text;
        vPAWMD5 :=  TIdHashMessageDigest5.Create;
        try
          vExecParam.S[TUser.Password] := vPAWMD5.HashStringAsHex(edtPassword.Text);
        finally
          vPAWMD5.Free;
        end;

        ABLLServerReady.AddBackField(TUser.ID);
      end,
      procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
      begin
        if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        begin
          ShowMessage(ABLLServer.MethodError);
          Exit;
        end;
        if ABLLServer.RecordCount = 1 then
        begin
          FUserID := ABLLServer.BackField(TUser.ID).AsString;
          Self.ModalResult := mrOk;
        end
        else
        if ABLLServer.RecordCount = 0 then
          ShowMessage('��¼ʧ�ܣ���Ч���û����ߴ�������룡')
        else
        if ABLLServer.RecordCount > 1 then
          ShowMessage('��¼ʧ�ܣ����ڶ����ͬ���û��������Աȷ��');
      end);
  end);
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  PlugInID := PLUGIN_LOGIN;
  //SetWindowLong(Handle, GWL_EXSTYLE, (GetWindowLong(handle, GWL_EXSTYLE) or WS_EX_APPWINDOW));
end;

procedure TfrmLogin.FormShow(Sender: TObject);
var
  vObjectInfo: IPlugInObjectInfo;
begin
  // ��ȡ�ͻ��������
  vObjectInfo := TPlugInObjectInfo.Create;
  FOnFunctionNotify(PluginID, FUN_CLIENTCACHE, vObjectInfo);
  ClientCache := TClientCache(vObjectInfo.&Object);
end;

procedure TfrmLogin.lblSetClick(Sender: TObject);
var
  vFrmConnSet: TfrmConnSet;
begin
  vFrmConnSet := TfrmConnSet.Create(Self);
  try
    vFrmConnSet.edtBLLServerIP.Text := ClientCache.ClientParam.BLLServerIP;
    vFrmConnSet.edtBLLServerPort.Text := ClientCache.ClientParam.BLLServerPort.ToString;
    vFrmConnSet.edtMsgServerIP.Text := ClientCache.ClientParam.MsgServerIP;
    vFrmConnSet.edtMsgServerPort.Text := ClientCache.ClientParam.MsgServerPort.ToString;
    vFrmConnSet.edtUpdateServerIP.Text := ClientCache.ClientParam.UpdateServerIP;
    vFrmConnSet.edtUpdateServerPort.Text := ClientCache.ClientParam.UpdateServerPort.ToString;
    vFrmConnSet.ShowModal;
  finally
    FreeAndNil(vFrmConnSet);
  end;
end;

end.
