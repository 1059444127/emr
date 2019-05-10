unit frm_BLLServer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, diocp_tcp_server, emr_MsgPack,
  System.Generics.Collections, BLLClientContext, emr_Common, emr_BLLServerProxy,
  emr_DBL, PluginIntf, PluginImp, FunctionIntf, FunctionImp, FunctionConst;

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
    mniPlugin: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mniSetClick(Sender: TObject);
    procedure mniStartClick(Sender: TObject);
    procedure mniStopClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    /// <summary> �������� </summary>
    FRemoteServer: TRemoteServer;
    FTcpServer: TDiocpTcpServer;
    FLogLocker: TObject;
    FDBL: TDBL;
    // ҵ������ض���
    FAgentLocker: TObject;
    FAgentQueue: TQueue<TBLLAgent>;
    FAgentQueueThread: THCThread;
    //
    FPluginManager: IPluginManager;  // ����б�
    FPluginLocker: TObject;
    /// <summary> �������÷����� </summary>
    procedure ReCreateServer;
    procedure RefreshUIState;
    //
    procedure LoadServerPlugin(Sender: TObject);
    procedure DoPluginReLoad(Sender: TObject);
    procedure DoPluginUnLoad(Sender: TObject);
    //
    procedure RemoteProcessAgent(var AAgent: TBLLAgent);
    procedure ProcessAgent(var AAgent: TBLLAgent);
    procedure ExecuteSBLMsgPack(const AMsgPack: TMsgPack);
    //
    procedure DoAgentQueueThreadExecute(Sender: TObject);
    procedure DoContextAction(const AStream: TStream; const AContext: TIocpClientContext);
    procedure OnContextConnected(AClientContext: TIocpClientContext);
    procedure DoLog(const ALog: string);
  public
    { Public declarations }
  end;

var
  frmBLLServer: TfrmBLLServer;

implementation

uses
  uFMMonitor, BLLServerParam, DiocpError, emr_DataBase, emr_BLLDataBase,
  frm_Set, utils_zipTools;

{$R *.dfm}

procedure TfrmBLLServer.btnClearClick(Sender: TObject);
begin
  mmoMsg.Clear;
end;

procedure TfrmBLLServer.DoLog(const ALog: string);
begin
  if chkLog.Checked then
  begin
    System.MonitorEnter(FLogLocker);
    try
      mmoMsg.Lines.Add(sLineBreak + '=============='
        + FormatDateTime('YYYY-MM-DD HH:mm:ss', Now)
        + '=============='
        + sLineBreak + ALog);
    finally
      System.MonitorExit(FLogLocker);
    end;
  end;
end;

procedure TfrmBLLServer.DoContextAction(const AStream: TStream; const AContext: TIocpClientContext);
var
  vBLLAgent: TBLLAgent;
begin
  System.MonitorEnter(FAgentLocker);
  try
    vBLLAgent := TBLLAgent.Create(AStream, AContext);
    FAgentQueue.Enqueue(vBLLAgent);  // �������
  finally
    System.MonitorExit(FAgentLocker);
  end;
end;

procedure TfrmBLLServer.DoAgentQueueThreadExecute(Sender: TObject);
var
  vAgent: TBLLAgent;
begin
  if FAgentQueue.Count = 0 then Exit;

  System.MonitorEnter(FAgentLocker);
  try
    vAgent := FAgentQueue.Dequeue;  // �Ӷ���ȡ������

    if FRemoteServer <> nil then  // ���������
      RemoteProcessAgent(vAgent)  // ��������˴���
    else  // �Ҿ����������
      ProcessAgent(vAgent);
  finally
    System.MonitorExit(FAgentLocker);
  end;
end;

procedure TfrmBLLServer.DoPluginReLoad(Sender: TObject);
var
  i, vPluginIndex: Integer;
  vParentMenuItem: TMenuItem;
begin
  if Sender is TMenuItem then  // �˵�����
  begin
    vPluginIndex := (Sender as TMenuItem).Tag;  // �����ʶ
    if vPluginIndex < FPluginManager.Count then  // ��Ч�ı�ʶ
    begin
      System.MonitorEnter(FPluginLocker);
      try
        IPlugin(FPluginManager.PluginList[vPluginIndex]).Load;  // ���¼���
      finally
        System.MonitorExit(FPlugInLocker);
      end;

      (Sender as TMenuItem).Enabled := False;  // �ɹ������¼��ز˵�������

      // �޸�ж�ز���˵�Ϊ����
      vParentMenuItem := (Sender as TMenuItem).Parent;
      for i := 0 to vParentMenuItem.Count - 1 do
      begin
        if (vParentMenuItem[i].Caption = 'ж��') and (vParentMenuItem[i].Tag = vPluginIndex) then
        begin
          vParentMenuItem[i].Enabled := True;
          Break;
        end;
      end;
    end;
  end;
end;

procedure TfrmBLLServer.DoPluginUnLoad(Sender: TObject);
var
  i, vPluginIndex: Integer;
  vParentMenuItem: TMenuItem;
begin
  if Sender is TMenuItem then  // �˵�����
  begin
    vPluginIndex := (Sender as TMenuItem).Tag;  // �����ʶ
    if vPluginIndex < FPluginManager.Count then  // ��Ч�ı�ʶ
    begin
      System.MonitorEnter(FPluginLocker);
      try
        IPlugin(FPluginManager.PluginList[vPluginIndex]).UnLoad;  // ж��
      finally
        System.MonitorExit(FPluginLocker);
      end;

      (Sender as TMenuItem).Enabled := False;  // ж�سɹ���ж�ز˵�������

      // �޸����¼��ز���˵�Ϊ����
      vParentMenuItem := (Sender as TMenuItem).Parent;
      for i := 0 to vParentMenuItem.Count - 1 do
      begin
        if (vParentMenuItem[i].Caption = '����') and (vParentMenuItem[i].Tag = vPluginIndex) then
        begin
          vParentMenuItem[i].Enabled := True;
          Break;
        end;
      end;
    end;
  end;
end;

procedure TfrmBLLServer.ExecuteSBLMsgPack(const AMsgPack: TMsgPack);
var
  i: Integer;
  vObjFun: IObjectFunction;
  vPlugin: IPlugin;
begin
  System.MonitorEnter(FPluginLocker);
  try
    if FPluginManager.Count = 0 then Exit;

    vObjFun := TObjectFunction.Create;
    vObjFun.ID := FUN_OBJECT_BLL;
    vObjFun.&Object := AMsgPack;

    for i := 0 to FPluginManager.Count - 1 do
    begin
      vPlugin := IPlugin(FPluginManager.PluginList[i]);
      if vPlugin.Enable then
      begin
        try
          vPlugin.ExecFunction(vObjFun);
        except
          on E: Exception do
          begin
            DoLog('���' + vPlugin.Name + '�����÷���' + vObjFun.ID + '�쳣��' + E.Message);
          end;
        end;
      end;
    end;
  finally
    System.MonitorExit(FPluginLocker);
  end;
end;

procedure TfrmBLLServer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FTcpServer.Active then
  begin
    if MessageDlg('ȷ��Ҫֹͣ���ر�emrҵ�����ˣ��رպ�ͻ��˲��ܴ���ҵ��',
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
var
  FHandle: Cardinal;
begin
  pgc.ActivePageIndex := 0;
  FRemoteServer := nil;
  FLogLocker := TObject.Create;
  FTcpServer := TDiocpTcpServer.Create(Self);
  FTcpServer.CreateDataMonitor;  // �������м�����
  FTcpServer.WorkerCount := 3;
  FTcpServer.RegisterContextClass(TBLLClientContext);
  FTcpServer.OnContextConnected := OnContextConnected;
  TFMMonitor.CreateAsChild(tsState, FTcpServer);
  //
  FAgentQueue := TQueue<TBLLAgent>.Create;
  FAgentLocker := TObject.Create;
  FAgentQueueThread := THCThread.Create;
  FAgentQueueThread.OnExecute := DoAgentQueueThreadExecute;
  //
//  FBLLQueue := TQueue<TBLLAgent>.Create;
//  FBLLLocker := TObject.Create;
//  FBLLQueueThread := THCThread.Create;
//  FBLLQueueThread.OnExecute := DoBLLQueueThreadExecute;
  //
  FDBL := TDBL.Create;
  FDBL.OnExecuteLog := DoLog;
  //
  FPluginLocker := TObject.Create;
  FPluginManager := TPluginManager.Create;
  LoadServerPlugin(nil);  // ���ط����ҵ����
end;

procedure TfrmBLLServer.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FTcpServer);
  FreeAndNil(BLLServerParams);
  FreeAndNil(FDBL);

  if not FAgentQueueThread.Suspended then
  begin
    FAgentQueueThread.Terminate;
    FAgentQueueThread.WaitFor;
  end;
  FreeAndNil(FAgentQueueThread);
  FreeAndNil(FAgentQueue);
  FreeAndNil(FAgentLocker);

  FPluginManager.UnLoadAllPlugin;
  FreeAndNil(FPluginLocker);


//  if not FBLLQueueThread.Suspended then
//  begin
//    FBLLQueueThread.Terminate;
//    FBLLQueueThread.WaitFor;
//  end;
//  FreeAndNil(FBLLQueueThread);
//  FreeAndNil(FBLLQueue);
//  FreeAndNil(FBLLLocker);
  FreeAndNil(FLogLocker);
end;

procedure TfrmBLLServer.LoadServerPlugin(Sender: TObject);
var
  i: Integer;
  vMenu, vSubMenu: TMenuItem;
begin
  System.MonitorEnter(FPluginLocker);
  try
    {to do: ֹͣ��������߳� }
    mniPlugin.Clear;
    FPluginManager.UnLoadAllPlugin;

    if not DirectoryExists(ExtractFilePath(ParamStr(0)) + 'plugin') then Exit;

    FPluginManager.LoadPlugins(ExtractFilePath(ParamStr(0)) + 'plugin', '.spi');

    for i := 0 to FPluginManager.Count - 1 do  // �����������Ӳ����Ӧ�Ĳ˵�
    begin
      vMenu := TMenuItem.Create(mniPlugIn);
      vMenu.Caption := IPlugIn(FPluginManager.PluginList[i]).Name;

      vSubMenu := TMenuItem.Create(vMenu);
      vSubMenu.Caption := 'ж��';
      vSubMenu.Tag := i;
      vSubMenu.OnClick := DoPluginUnLoad;
      vMenu.Add(vSubMenu);

      vSubMenu := TMenuItem.Create(vMenu);
      vSubMenu.Enabled := False;
      vSubMenu.Caption := '����';
      vSubMenu.Tag := i;
      vSubMenu.OnClick := DoPluginReLoad;
      vMenu.Add(vSubMenu);

      mniPlugIn.Add(vMenu);
    end;

    // ��������ɨ��˵�
    if mniPlugIn.Count > 0 then
    begin
      vSubMenu := TMenuItem.Create(mniPlugin);
      vSubMenu.Enabled := True;
      vSubMenu.Caption := '-';
      mniPlugin.Add(vSubMenu);
    end;

    vSubMenu := TMenuItem.Create(mniPlugin);
    vSubMenu.Enabled := True;
    vSubMenu.Caption := '����ɨ��';
    vSubMenu.OnClick := LoadServerPlugin;
    mniPlugin.Add(vSubMenu);
  finally
    System.MonitorExit(FPluginLocker);
  end;
end;

procedure TfrmBLLServer.mniSetClick(Sender: TObject);
var
  vfrmSet: TfrmSet;
begin
  vfrmSet := TfrmSet.Create(Self);
  try
    if FileExists(ExtractFilePath(ParamStr(0)) + 'emrBLLServer.ini') then
      vfrmSet.FileName := ExtractFilePath(ParamStr(0)) + 'emrBLLServer.ini'
    else
      vfrmSet.FileName := '';

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

    if FAgentQueueThread.Suspended then
      FAgentQueueThread.Suspended := False;

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
  FAgentQueueThread.Suspended := True;
  System.MonitorEnter(FAgentLocker);
  try
    FAgentQueue.Clear;
  finally
    System.MonitorExit(FAgentLocker);
  end;

  RefreshUIState;
end;

procedure TfrmBLLServer.OnContextConnected(AClientContext: TIocpClientContext);
begin
  TBLLClientContext(AClientContext).OnContextAction := DoContextAction;
end;

procedure TfrmBLLServer.ProcessAgent(var AAgent: TBLLAgent);
var
  vMsgPack: TMsgPack;
  vStream: TMemoryStream;
  vProxyType: TProxyType;
begin
  vMsgPack := TMsgPack.Create;
  try
    vStream := TMemoryStream.Create;
    try
      AAgent.Stream.Position := 0;
      TZipTools.UnZipStream(AAgent.Stream, vStream);  // ��ѹ��
      vStream.Position := 0;
      vMsgPack.DecodeFromStream(vStream);  // ���

      vProxyType := TProxyType(vMsgPack.ForcePathObject(BLL_EXECPARAM).I[BLL_PROXYTYPE]);  // �������ַ������
      case vProxyType of  // �ַ���Ӧ��ҵ��;
        cptDBL:  // ���ݿ���ҵ�����
          FDBL.ExecuteMsgPack(vMsgPack);

        cptSBL:  // �����֧�ֵ�ҵ��
          ExecuteSBLMsgPack(vMsgPack);
      end;

      vStream.Clear;
      vMsgPack.EncodeToStream(vStream);  // ���
      vStream.Position := 0;
      TZipTools.ZipStream(vStream, AAgent.Stream);  // ѹ������
      AAgent.Stream.Position := 0;
      TBLLClientContext(AAgent.Context).WriteObject(AAgent.Stream);  // ���͵��ͻ���
    finally
      vStream.Free;
    end;
  finally
    FreeAndNil(vMsgPack);
    FreeAndNil(AAgent);
  end;
end;

procedure TfrmBLLServer.ReCreateServer;
begin
  if BLLServerParams = nil then
    BLLServerParams := TBLLServerParams.Create(ExtractFilePath(ParamStr(0)) + 'emrBLLServer.ini');

  if BLLServerParams.RemoteActive then  // ָ�����ⲿ��������
  begin
    if FRemoteServer = nil then  // δ�������ⲿ������
      FRemoteServer := TRemoteServer.CreateEx(BLLServerParams.RemoteBLLIP, BLLServerParams.RemoteBLLPort);

    if FDBL.DB.Connected then
      FDBL.DB.DisConnect;
  end
  else  // ������Ϊ��������
  begin
    if not FDBL.DB.Connected then
    begin
      FDBL.DB.DBType := dbSqlServer;
      FDBL.DB.Server := BLLServerParams.DataBaseServer;
      FDBL.DB.DBName := BLLServerParams.DataBaseName;
      FDBL.DB.Username := BLLServerParams.DataBaseUsername;
      FDBL.DB.Password := BLLServerParams.DataBasePassword;
      FDBL.DB.Connect;
    end;

    FreeAndNil(FRemoteServer);
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

procedure TfrmBLLServer.RemoteProcessAgent(var AAgent: TBLLAgent);
var
  vMsgPack: TMsgPack;
  vStream: TMemoryStream;
  vCMD: Integer;
  vDBLSrvProxy: TBLLServerProxy;
  vErrorInfo: string;
begin
  vMsgPack := TMsgPack.Create;
  try
    vStream := TMemoryStream.Create;
    try
      AAgent.Stream.Position := 0;
      TZipTools.UnZipStream(AAgent.Stream, vStream);  // ��ѹ��
      vStream.Position := 0;
      vMsgPack.DecodeFromStream(vStream);  // �����н��
      vCMD := vMsgPack.I[BLL_CMD];

      try
        vDBLSrvProxy := TBLLServerProxy.CreateEx(FRemoteServer.Host, FRemoteServer.Port);
        try
          vDBLSrvProxy.ReConnectServer;
          if vDBLSrvProxy.Active then  // ������ӳɹ�
          begin
            if not vDBLSrvProxy.DispatchPack(vMsgPack) then
            begin
              vErrorInfo := GetDiocpErrorMessage(vDBLSrvProxy.ErrCode);
              if vErrorInfo = '' then
                vErrorInfo := SysErrorMessage(GetLastError);
              vMsgPack.Clear;
              vMsgPack.ForcePathObject(BLL_CMD).AsInteger := vCMD;
              vMsgPack.ForcePathObject(BACKRESULT).AsBoolean := False;
              vMsgPack.ForcePathObject(BACKMSG).AsString := vErrorInfo;
              DoLog('�����ⲿ�������' + vCMD.ToString + '��' + vErrorInfo);
            end;
          end;
        finally
          FreeAndNil(vDBLSrvProxy);
        end;
      except  // �����쳣��Ϣ
        on E:Exception do
        begin
          vMsgPack.Clear;
          vMsgPack.ForcePathObject(BLL_CMD).AsInteger := vCMD;
          vMsgPack.ForcePathObject(BACKRESULT).AsBoolean := False;
          vMsgPack.ForcePathObject(BACKMSG).AsString := E.Message;
          DoLog('�����ⲿ�������' + vCMD.ToString + '��' + E.Message);
        end;
      end;

      // ׼���������ú�����ݽ��
      vStream.Clear;
      vMsgPack.EncodeToStream(vStream);  // �������
      vStream.Position := 0;
      TZipTools.ZipStream(vStream, AAgent.Stream);  // ѹ������
      AAgent.Stream.Position := 0;
      TBLLClientContext(AAgent.Context).WriteObject(AAgent.Stream);  // ���͵��ͻ���
    finally
      FreeAndNil(vStream);
    end;
  finally
    FreeAndNil(vMsgPack);
    FreeAndNil(AAgent);
  end;
end;

end.
