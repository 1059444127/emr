unit frm_BLLServer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, diocp_tcp_server;

type
  TfrmBLLServer = class(TForm)
    mmMain: TMainMenu;
    mniN1: TMenuItem;
    mniStart: TMenuItem;
    mniStop: TMenuItem;
    pgc: TPageControl;
    tsState: TTabSheet;
    ts2: TTabSheet;
    pnl1: TPanel;
    chkLog: TCheckBox;
    btnClear: TButton;
    btnSave: TButton;
    mmoMsg: TMemo;
    mniN2: TMenuItem;
    mniSet: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mniSetClick(Sender: TObject);
    procedure mniStartClick(Sender: TObject);
    procedure mniStopClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FTcpServer: TDiocpTcpServer;

    /// <summary> �������÷����� </summary>
    procedure ReCreateServer;

    procedure RefreshUIState;
    procedure DoBLLServerMethodExecuteLog(const ALog: string);
  public
    { Public declarations }
  end;

var
  frmBLLServer: TfrmBLLServer;

implementation

uses
  uFMMonitor, BLLClientContext, BLLServerMethods, BLLServerParam,
  emr_DataBase, emr_BLLDataBase, frm_Set;

{$R *.dfm}

procedure TfrmBLLServer.btnClearClick(Sender: TObject);
begin
  mmoMsg.Clear;
end;

procedure TfrmBLLServer.DoBLLServerMethodExecuteLog(const ALog: string);
begin
  if chkLog.Checked then
    mmoMsg.Lines.Add(sLineBreak + '==============' + FormatDateTime('YYYY-MM-DD HH:mm:ss', Now) + '=============='
     + sLineBreak + ALog);
end;

procedure TfrmBLLServer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FTcpServer.Active then
  begin
    if MessageDlg('ȷ��Ҫֹͣ���ر�hpsҵ�����ˣ��رպ�ͻ��˲��ܴ���ҵ��',
      mtWarning, [mbYes, mbNo], 0) = mrYes
    then
    begin
      FTcpServer.SafeStop;
      CanClose := True;
    end
    else
      CanClose := False;
  end;
end;

procedure TfrmBLLServer.FormCreate(Sender: TObject);
begin
  pgc.ActivePageIndex := 0;
  FTcpServer := TDiocpTcpServer.Create(Self);
  FTcpServer.CreateDataMonitor;  // �������м�����
  FTcpServer.WorkerCount := 3;
  FTcpServer.RegisterContextClass(TBLLClientContext);
  TFMMonitor.CreateAsChild(tsState, FTcpServer);
  //
  BLLServerMethod := TBLLServerMethod.Create;
  BLLServerMethod.OnExecuteLog := DoBLLServerMethodExecuteLog;
end;

procedure TfrmBLLServer.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FTcpServer);
  FreeAndNil(BLLServerParams);
  FreeAndNil(BLLServerMethod);
  FreeAndNil(frameDB);
  FreeAndNil(frameBLLDB);
end;

procedure TfrmBLLServer.mniSetClick(Sender: TObject);
var
  vfrmSet: TfrmSet;
begin
  vfrmSet := TfrmSet.Create(Self);
  try
    vfrmSet.FileName := ExtractFilePath(ParamStr(0)) + 'emrBLLServer.ini';
    vfrmSet.ShowModal;
    if FTcpServer.Active then  // ����������
      ReCreateServer;  // �������������÷����
  finally
    FreeAndNil(vfrmSet);
  end;
end;

procedure TfrmBLLServer.mniStartClick(Sender: TObject);
begin
  try
    ReCreateServer;  // ���÷�����

    pgc.ActivePageIndex := 1;  // �л������ҳ������ͻ������Ӻ���治���л�bug
    FTcpServer.Port := 12830;
    FTcpServer.Active := true;
    RefreshUIState;
  except
    on E: Exception do
    begin
      Caption := '����ʧ�ܣ�' + E.Message;
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
    end;
  end;
end;

procedure TfrmBLLServer.mniStopClick(Sender: TObject);
begin
  FTcpServer.SafeStop;
  RefreshUIState;
end;

procedure TfrmBLLServer.ReCreateServer;
begin
  if BLLServerParams = nil then
    BLLServerParams := TBLLServerParams.Create(ExtractFilePath(ParamStr(0)) + 'emrBLLServer.ini');

  if BLLServerParams.RemoteActive then  // ָ�����ⲿ��������
  begin
    if GRemoteServer = nil then  // �������ⲿ������
      GRemoteServer := TRemoteServer.CreateEx(BLLServerParams.RemoteBLLIP, BLLServerParams.RemoteBLLPort);
    if frameDB <> nil then  // ������������ݿ����Ӷ���
      frameDB.DisConnect;
    if frameBLLDB <> nil then  // ������ҵ�����ݿ����ӹ������
      frameBLLDB.DisConnect;
  end
  else  // ������Ϊ��������
  begin
    if frameDB = nil then  // ����������ݿ����Ӷ���
      frameDB := TDataBase.Create(Self);

    if frameBLLDB = nil then  // �������ҵ�����ݿ����ӹ������
      frameBLLDB := TBLLDataBase.Create;

    if not frameDB.Connected then
    begin
      frameDB.DBType := dbSqlServer;
      frameDB.Server := BLLServerParams.DataBaseServer;
      frameDB.DBName := BLLServerParams.DataBaseName;
      frameDB.Username := BLLServerParams.DataBaseUsername;
      frameDB.Password := BLLServerParams.DataBasePassword;
      frameDB.Connect;
    end;

    FreeAndNil(GRemoteServer);
  end;
end;

procedure TfrmBLLServer.RefreshUIState;
begin
  mniStart.Enabled := not FTcpServer.Active;
  if FTcpServer.Active then
    Caption := 'emrҵ��(BLL)�����[����]' + FTcpServer.DefaultListenAddress + ' �˿�:' + IntToStr(FTcpServer.Port)
  else
    Caption := 'emrҵ��(BLL)�����[ֹͣ]';
  mniStop.Enabled := FTcpServer.Active;
end;

end.
