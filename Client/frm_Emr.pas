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
  emr_Common, CFControl, CFListView, Vcl.StdCtrls, CFButtonEdit, CFGridEdit,
  Vcl.XPMan, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.AppEvnts;

type
  TfrmEmr = class(TForm)
    lstPlugin: TCFListView;
    xpmnfst: TXPManifest;
    appEvents: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstPluginDBlClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure appEventsIdle(Sender: TObject; var Done: Boolean);
  private
    { Private declarations }
    FPluginManager: IPluginManager;
    FUserInfo: TUserInfo;

    function Frame_CreateCacheTable(const ATableName, AFields: string; const ADelIfExists: Boolean = True): Boolean;
    procedure Frame_LoadAllCacheTable;

    /// <summary> �г����в�� </summary>
    procedure LoadPluginList;

    // ����ص��¼� ע���PluginFunctionIntf��TFunctionNotifyEvent����һ��
    procedure DoPluginNotify(const APluginID, AFunctionID: string; const APluginObject: IPluginObject);
  public
    { Public declarations }
    function LoginPluginExecute: Boolean;
  end;

  /// <summary> ����б���Ŀ��Ϣ </summary>
  TFunInfo = class(TObject)
    PlugInID: string;  // ��Ӧ�Ĳ��
    Fun: Pointer;  // ��Ӧ�Ĺ���
    //BuiltIn: Boolean;  // ���ò��
  end;

  /// <summary> ��ȡ���ز��� </summary>
  procedure GetClientParam;

var
  frmEmr: TfrmEmr;

implementation

uses
  frm_DM, PluginImp, FunctionImp, FunctionConst, PluginConst, emr_PluginObject,
  emr_BLLServerProxy, emr_MsgPack;

{$R *.dfm}

// ����ص��¼� ע���PluginFunctionIntf��TFunctionNotifyEvent����һ��
procedure PluginNotify(const APluginID, AFunctionID: string;
  const APluginObject: IPluginObject);
begin
  frmEmr.DoPluginNotify(APluginID, AFunctionID, APluginObject);
end;

procedure GetClientParam;
begin
  ClientCache.ClientParam.TimeOut := 3000;  // 3��
  ClientCache.ClientParam.BLLServerIP := dm.GetParamStr(PARAM_LOCAL_BLLHOST);  // ҵ�������
  ClientCache.ClientParam.BLLServerPort := dm.GetParamInt(PARAM_LOCAL_BLLPORT, 12830);  // ҵ��������˿�
  if ClientCache.ClientParam.BLLServerIP = '' then
    ClientCache.ClientParam.BLLServerIP := '127.0.0.1';  // 115.28.145.107

  ClientCache.ClientParam.MsgServerIP := dm.GetParamStr(PARAM_LOCAL_MSGHOST);  // ��Ϣ�����
  ClientCache.ClientParam.MsgServerPort := dm.GetParamInt(PARAM_LOCAL_MSGPORT, 12832);  // ��Ϣ�������˿�
  if ClientCache.ClientParam.MsgServerIP = '' then
    ClientCache.ClientParam.MsgServerIP := '127.0.0.1';

  ClientCache.ClientParam.UpdateServerIP := dm.GetParamStr(PARAM_LOCAL_UPDATEHOST);  // ����������
  ClientCache.ClientParam.UpdateServerPort := dm.GetParamInt(PARAM_LOCAL_UPDATEPORT, 12834);  // ���·������˿�
  if ClientCache.ClientParam.UpdateServerIP = '' then
    ClientCache.ClientParam.UpdateServerIP := '127.0.0.1';
end;

procedure TfrmEmr.appEventsIdle(Sender: TObject; var Done: Boolean);
//var
//  vIFun: ICustomFunction;
begin
//  vIFun := TCustomFunction.Create;
//  vIFun.ID := FUN_APPEVENTSIDLE;
//  FPluginManager.FunBroadcast(vIFun);
end;

procedure TfrmEmr.DoPluginNotify(const APluginID, AFunctionID: string;
  const APluginObject: IPluginObject);
var
  vIPlugin: IPlugin;
  vIFun: ICustomFunction;
begin
  vIPlugin := FPluginManager.GetPlugin(APluginID);  // ��ȡ��Ӧ�Ĳ��
  if vIPlugin <> nil then  // ��Ч���
  begin
    if AFunctionID = FUN_USERINFO then  // ��ȡ��ǰ�û���Ϣ
    begin
      if APluginID = PLUGIN_LOGIN then
        FUserInfo.ID := string((APluginObject as IPlugInObjectInfo).&object)
      else
        (APluginObject as IPlugInObjectInfo).&Object := FUserInfo;
    end
    else
    if AFunctionID = FUN_MAINFORMHIDE then  // ����������
    begin
      // ��ʹ��Hide��Visible=False��ֹ����д����������InitializeNewForm-
      // Screen.AddForm(Self)-Application.UpdateVisible;����������������ť��ʾ
      ShowWindow(Handle, SW_HIDE);
      //ShowWindow(Application.Handle, SW_HIDE);
    end
    else
    if AFunctionID = FUN_MAINFORMSHOW then  // ��ʾ������
    begin
      ShowWindow(Handle, SW_SHOW);
      //ShowWindow(Application.Handle, SW_SHOW);
    end
    else
    if AFunctionID = FUN_CLIENTCACHE then  // ��ȡ�ͻ��˻������
      (APluginObject as IPlugInObjectInfo).&Object := ClientCache
    else
    if AFunctionID = FUN_REFRESHCLIENTCACHE then  // ���»�ȡ�ͻ��˻���
      ClientCache.GetCacheData
    else
    if AFunctionID = FUN_LOCALDATAMODULE then  // ��ȡ�������ݿ����DataModule
      (APluginObject as IPlugInObjectInfo).&Object := dm
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

procedure TfrmEmr.FormShow(Sender: TObject);
begin
  Frame_LoadAllCacheTable;  // ���ػ����
end;

function TfrmEmr.Frame_CreateCacheTable(const ATableName, AFields: string; const ADelIfExists: Boolean): Boolean;
begin
  Result := False;

  if ADelIfExists then
  begin
    // �����Ѿ��л����ʱ��Ҫ��ɾ��
    dm.qryTemp.Open(Format('SELECT COUNT(*) AS tbcount FROM sqlite_master where type=''table'' and name=''%s''',
      [ATableName]));
    if dm.qryTemp.FieldByName('tbcount').AsInteger = 1 then  // �����Ѿ��л������
      dm.ExecSql('DROP TABLE ' + ATableName);  // ���±�����֮ǰ��ɾ��������
  end;

  // �ӷ���˲�ѯ��Ҫ����ı��ֶ�����
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    var
      vReplaceParam: TMsgPack;
    begin
      ABLLServerReady.Cmd := BLL_EXECSQL;
      vReplaceParam := ABLLServerReady.ReplaceParam;
      vReplaceParam.S['Sql'] := 'SELECT ' + AFields + ' FROM ' + ATableName;
      ABLLServerReady.BackDataSet := True;
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)

      {$REGION ' GetCreateTableSql ���ɴ������ر���� '}
      function GetCreateTableSql: string;
      var
        i: Integer;
        vField: string;
      begin
        Result := '';
        for i := 0 to AMemTable.FieldDefs.Count - 1 do
        begin
          vField := AMemTable.Fields[i].FieldName;  // �ֶ���
          case AMemTable.Fields[i].DataType of  // �ֶ�����
            ftSmallint: vField := vField + ' smallint';

            ftInteger, ftAutoInc: vField := vField + ' int';

            ftCurrency: vField := vField + ' money';

            ftFloat: vField := vField + ' float';

            ftLargeint: vField := vField + ' bigint';

            ftBoolean: vField := vField + ' bit';

            ftDate: vField := vField + ' date';

            ftSingle: vField := vField + ' real';

            ftString:  vField := vField + ' varchar(' + (AMemTable.Fields[i].DataSize - 1).ToString + ')';

            ftWideString: vField := vField + ' nvarchar(' + (AMemTable.Fields[i].DataSize / 2 - 1).ToString + ')';
          else
            vField := vField + ' nvarchar(50)';
          end;
          if AMemTable.Fields[i].ReadOnly then  // �ֶ�������
            vField := vField + ' primary key';
          if Result = '' then
            Result := vField
          else
            Result := Result + ', ' + vField;
        end;
        Result := 'CREATE TABLE ' + ATableName + ' (' + Result + ')';
      end;
      {$ENDREGION}

    begin
      if not ABLLServer.MethodRunOk then
      begin
        ShowMessage(ABLLServer.MethodError);
        Exit;
      end;

      dm.conn.ExecSQL(GetCreateTableSql);  // ������

      if AMemTable <> nil then  // ����˱�������
      begin
        dm.qryTemp.Open('SELECT * FROM ' + ATableName);  // �򿪱��ػ����
        dm.qryTemp.CopyDataSet(AMemTable);  // ��������
      end;
    end);

  Result := True;
end;

procedure TfrmEmr.Frame_LoadAllCacheTable;
begin
  HintFormShow('���ڸ��»����...', procedure(const AUpdateHint: TUpdateHint)
  begin
    BLLServerExec(
      procedure(const ABLLServerReady: TBLLServerProxy)
      begin
        ABLLServerReady.Cmd := BLL_GETCLIENTCACHE;  // ��ȡ����˻������Ϣ
        ABLLServerReady.BackDataSet := True;
      end,
      procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
      var
        vTableName: string;
        vHasCache: Boolean;
      begin
        if not ABLLServer.MethodRunOk then
        begin
          ShowMessage(ABLLServer.MethodError);
          Exit;
        end;

        if AMemTable <> nil then  // �л������Ϣ
        begin
          AMemTable.First;
          while not AMemTable.Eof do
          begin
            vTableName := AMemTable.FieldByName('tbName').AsString;  // ��������

            AUpdateHint('���»���� ' + vTableName);

            dm.qryTemp.Open(Format('SELECT id, tbName, dataVer FROM clientcache WHERE id = %d',
              [AMemTable.FieldByName('id').AsInteger]));  // ��ȡ�����ÿ��������ڱ��ص���Ϣ

            vHasCache := dm.qryTemp.RecordCount > 0;  // ���ػ�����˱�

            if dm.qryTemp.FieldByName('dataVer').AsInteger < AMemTable.FieldByName('dataVer').AsInteger then  // ���ذ汾С�ڷ���˻򱾵�û�иû����
            begin
              if Frame_CreateCacheTable(vTableName, AMemTable.FieldByName('tbField').AsString) then  // ���±��ػ��������
              begin
                if vHasCache then  // ���ػ�����˱�
                begin
                  dm.ExecSql(Format('UPDATE clientcache SET dataVer = %d WHERE id = %d',
                    [AMemTable.FieldByName('dataVer').AsInteger,
                     AMemTable.FieldByName('id').AsInteger]));
                end
                else  // ����û�л�����˱�
                begin
                  dm.ExecSql(Format('INSERT INTO clientcache (id, tbName, dataVer) VALUES (%d, ''%s'', %d)',
                    [AMemTable.FieldByName('id').AsInteger,
                     vTableName,
                     AMemTable.FieldByName('dataVer').AsInteger]));
                end;
              end;
            end;

            AMemTable.Next;
          end;
        end;
      end);
  end);
end;

procedure TfrmEmr.LoadPluginList;
var
  i, j: Integer;
  vIPlugin: IPlugin;
  vIFun: IPluginFunction;
  vFunInfo: TFunInfo;
  vListViewItem: TListViewItem;
  vRunPath: string;
begin
  // �������ò��
  vRunPath := ExtractFilePath(ParamStr(0));
  lstPlugin.BeginUpdate;
  try
    lstPlugin.Clear;
    FPluginManager.LoadPlugins(vRunPath + 'plugin', '.cpi');

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

          if FileExists(vRunPath + 'image\' + vIPlugin.ID + '.png') then
            vListViewItem.ImagePng.LoadFromFile(vRunPath + 'image\' + vIPlugin.ID + '.png');
        end;
      end;
    end;
  finally
    lstPlugin.EndUpdate;
  end;
end;

function TfrmEmr.LoginPluginExecute: Boolean;
var
  vIPlugin: IPlugin;
  vIFunBLLFormShow: IFunBLLFormShow;
begin
  Result := False;
  FUserInfo.ID := '';
  vIPlugin := FPluginManager.GetPlugin(PLUGIN_LOGIN);
  if Assigned(vIPlugin) then  // �е�¼���
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
begin
  if lstPlugin.Selected = nil then Exit;

  vIPlugin := FPluginManager.GetPlugin(TFunInfo(lstPlugin.Selected.ObjectEx).PlugInID);
  if Assigned(vIPlugin) then  // �в��
  begin
    HintFormShow('���ڼ���... ' + vIPlugin.Name, procedure(const AUpdateHint: TUpdateHint)
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

        AUpdateHint('����ִ��... ' + vIPlugin.Name + '-' + vIFun.Name);
        vIFun.ShowEntrance := vIFunSelect.ShowEntrance;
        vIFun.OnNotifyEvent := @PluginNotify;
        vIPlugin.ExecFunction(vIFun);
      end;
    end);
  end;
end;

end.
