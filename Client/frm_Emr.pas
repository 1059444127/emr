{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit frm_Emr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FunctionIntf, PluginIntf,
  emr_Common, CFControl, CFListView, Vcl.StdCtrls, CFButtonEdit, CFGridEdit;

type
  TfrmEmr = class(TForm)
    lstPlugin: TCFListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstPluginDBlClick(Sender: TObject);
  private
    { Private declarations }
    FPluginManager: IPluginManager;
    FUserInfo: TUserInfo;

    /// <summary> �г����в�� </summary>
    procedure LoadPluginList;

    // ����ص��¼� ע���PluginFunctionIntf��TFunctionNotifyEvent����һ��
    procedure DoPluginNotify(const APluginID, AFunctionID: ShortString; const APluginObject: IPluginObject);
  public
    { Public declarations }
    function LoginPluginExec: Boolean;
  end;

  /// <summary> ����б���Ŀ��Ϣ </summary>
  TFunInfo = class(TObject)
    PlugInID: ShortString;  // ��Ӧ�Ĳ��
    Fun: Pointer;  // ��Ӧ�Ĺ���
    //BuiltIn: Boolean;  // ���ò��
  end;

  /// <summary> ��ȡ���ز��� </summary>
  procedure GetClientParam;

var
  frmEmr: TfrmEmr;

implementation

uses
  frm_DM, PluginImp, FunctionImp, FunctionConst, PluginConst,emr_PluginObject;

{$R *.dfm}

// ����ص��¼� ע���PluginFunctionIntf��TFunctionNotifyEvent����һ��
procedure PluginNotify(const APluginID, AFunctionID: ShortString;
  const APluginObject: IPluginObject);
begin
  frmEmr.DoPluginNotify(APluginID, AFunctionID, APluginObject);
end;

procedure GetClientParam;
begin
  if GClientParam = nil then
  begin
    GClientParam := TClientParam.Create;
    GClientParam.TimeOut := 3000;  // 3��
  end;

  GClientParam.BLLServerIP := dm.GetParamStr(PARAM_LOCAL_BLLHOST);  // ҵ�������
  GClientParam.BLLServerPort := dm.GetParamInt(PARAM_LOCAL_BLLPORT, 12830);  // ҵ��������˿�
  if GClientParam.BLLServerIP = '' then
    GClientParam.BLLServerIP := '115.28.145.107';

  GClientParam.MsgServerIP := dm.GetParamStr(PARAM_LOCAL_MSGHOST);  // ��Ϣ�����
  GClientParam.MsgServerPort := dm.GetParamInt(PARAM_LOCAL_MSGPORT, 12832);  // ��Ϣ�������˿�
  if GClientParam.MsgServerIP = '' then
    GClientParam.MsgServerIP := '115.28.145.107';

  GClientParam.UpdateServerIP := dm.GetParamStr(PARAM_LOCAL_UPDATEHOST);  // ����������
  GClientParam.UpdateServerPort := dm.GetParamInt(PARAM_LOCAL_UPDATEPORT, 12834);  // ���·������˿�
  if GClientParam.UpdateServerIP = '' then
    GClientParam.UpdateServerIP := '115.28.145.107';
end;

procedure TfrmEmr.DoPluginNotify(const APluginID, AFunctionID: ShortString;
  const APluginObject: IPluginObject);
var
  vIPlugin: IPlugin;
  vIFun: ICustomFunction;
  vIUser: IUserInfo;
begin
  vIPlugin := FPluginManager.GetPlugin(APluginID);  // ��ȡ��Ӧ�Ĳ��
  if vIPlugin <> nil then  // ��Ч���
  begin
    if AFunctionID = FUN_USERINFO then  // ��ȡ��ǰ�û���Ϣ
    begin
      if APluginID = PLUGIN_LOGIN then
      begin
        FUserInfo.ID := (APluginObject as IUserInfo).UserID;
      end
      else
        (APluginObject as IUserInfo).UserID := FUserInfo.ID;
    end
    else
    if AFunctionID = FUN_MAINFORMHIDE then  // ����������
    begin
      // ��ʹ��Hide��Visible=False��ֹ����д����������InitializeNewForm-
      // Screen.AddForm(Self)-Application.UpdateVisible;����������������ť��ʾ
      ShowWindow(Handle, SW_HIDE);
      ShowWindow(Application.Handle, SW_HIDE);
    end
    else
    if AFunctionID = FUN_MAINFORMSHOW then  // ��ʾ������
    begin
      ShowWindow(Handle, SW_SHOW);
      ShowWindow(Application.Handle, SW_SHOW);
    end
    else
    if AFunctionID = FUN_BLLSERVERINFO then  // ��ȡҵ���������Ӳ���
    begin
      (APluginObject as IServerInfo).Host := GClientParam.BLLServerIP;
      (APluginObject as IServerInfo).Port := GClientParam.BLLServerPort;
      (APluginObject as IServerInfo).TimeOut := GClientParam.TimeOut;
    end
    else
    if AFunctionID = FUN_BLLSERVERINFO then  // ��ȡ��Ϣ��������Ӳ���
    begin
      (APluginObject as IServerInfo).Host := GClientParam.MsgServerIP;
      (APluginObject as IServerInfo).Port := GClientParam.MsgServerPort;
      (APluginObject as IServerInfo).TimeOut := GClientParam.TimeOut;
    end
    else
    if AFunctionID = FUN_UPDATESERVERINFO then  // ��ȡ������������Ӳ���
    begin
      (APluginObject as IServerInfo).Host := GClientParam.UpdateServerIP;
      (APluginObject as IServerInfo).Port := GClientParam.UpdateServerPort;
      (APluginObject as IServerInfo).TimeOut := GClientParam.TimeOut;
    end
    else  // δ֪��ֱ�ӻص������
    begin
      vIFun := TCustomFunction.Create;
      vIFun.ID := AFunctionID;
      vIPlugin.ExecFunction(vIFun);
    end;
  end;
end;

procedure TfrmEmr.FormCreate(Sender: TObject);
begin
  FPluginManager := TPluginManager.Create;
  FUserInfo := TUserInfo.Create;
  LoadPluginList;  // ��ȡ���в����Ϣ
end;

procedure TfrmEmr.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FUserInfo);  // Ϊʲô��FPluginManager := nil;��FreeAndNil(FUserInfo);�����˳�������أ�
end;

procedure TfrmEmr.LoadPluginList;
var
  i, j: Integer;
  vIPlugin: IPlugin;
  vIFun: IPluginFunction;
  vFunInfo: TFunInfo;
  vListViewItem: TListViewItem;
  vHandle: THandle;
begin
  // �������ò��
  lstPlugin.BeginUpdate;
  try
    lstPlugin.Clear;
    FPluginManager.LoadPlugins(ExtractFilePath(ParamStr(0)) + 'plugin', '.cpi');
    for i := 0 to FPluginManager.Count - 1 do
    begin
      vIPlugin := IPlugin(FPluginManager.PluginList[i]);
      //HintForm.ShowHint(vIPlugin.Name + '��' + vIPlugin.Comment, i);
      //
      for j := 0 to vIPlugin.FunctionCount - 1 do
      begin
        vIFun := vIPlugin.GetFunction(j);
        if vIFun.ShowEntrance then
        begin
          vFunInfo := TFunInfo.Create;
          //vFunInfo.BuiltIn := False;
          vFunInfo.PlugInID := vIPlugin.ID;
          vFunInfo.Fun := Pointer(vIPlugin.GetFunction(j));
          vListViewItem := lstPlugin.AddItem(vIPlugin.Name, vIPlugin.Comment + '(' + vIPlugin.Version + ')',
            nil, vFunInfo);

          vHandle := LoadLibrary(PChar(vIPlugin.FileName));
          try
            if FindResource(vHandle, 'PLUGINLOGO', RT_RCDATA) > 0 then
              vListViewItem.ImagePng.LoadFromResourceName(vHandle, 'PLUGINLOGO');
          finally
            FreeLibrary(vHandle);
          end;
        end;
      end;
    end;
  finally
    lstPlugin.EndUpdate;
  end;
end;

function TfrmEmr.LoginPluginExec: Boolean;
var
  vIPlugin: IPlugin;
  vIFunBLLFormShow: IFunBLLFormShow;
begin
  Result := False;
  FUserInfo.ID := '';
  vIPlugin := FPluginManager.GetPlugin(PLUGIN_LOGIN);
  if vIPlugin <> nil then  // �е�¼���
  begin
    vIFunBLLFormShow := TFunBLLFormShow.Create;
    vIFunBLLFormShow.AppHandle := Application.Handle;
    vIFunBLLFormShow.OnNotifyEvent := @PluginNotify;
    vIPlugin.ExecFunction(vIFunBLLFormShow);
    Result := FUserInfo.ID <> '';
  end;
end;

procedure TfrmEmr.lstPluginDBlClick(Sender: TObject);
var
  vIPlugin: IPlugin;
  vIFunSelect: IPluginFunction;
  vIFun: IFunBLLFormShow;
  vFunID: string;
begin
  if lstPlugin.Selected = nil then Exit;

  vIPlugin := FPluginManager.GetPlugin(TFunInfo(lstPlugin.Selected.ObjectEx).PlugInID);
  if vIPlugin <> nil then  // �в��
  begin
    HintFormShow('���ڼ���...' + vIPlugin.Name, procedure(const AUpdateHint: TUpdateHint)
    begin
      vIFunSelect := IPluginFunction(TFunInfo(lstPlugin.Selected.ObjectEx).Fun);  // ��ȡ�������
      if vIFunSelect <> nil then
      begin
        if vIFunSelect.ID = FUN_BLLFORMSHOW then
        begin
          vIFun := TFunBLLFormShow.Create;
          vIFun.AppHandle := Application.Handle;
          //(vIFun as IDBLFormFunction).UserID := FUserID;
        end
        else
          raise Exception.Create('�쳣����ʶ��Ĺ���ID[������lstEntPlugsDBlClick]��');

        AUpdateHint('�������� ' + vIPlugin.Name);
        vIFun.ShowEntrance := vIFunSelect.ShowEntrance;
        vIFun.OnNotifyEvent := @PluginNotify;
        vIPlugin.ExecFunction(vIFun);
      end;
    end);
  end;
end;

end.
