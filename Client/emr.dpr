program emr;

{$IFDEF not DEBUG}
  {$IF CompilerVersion >= 21.0}
    {$WEAKLINKRTTI ON}
    {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
  {$IFEND}
{$ENDIF}

uses
  Vcl.Forms,
  System.Classes,
  System.SysUtils,
  System.UITypes,
  Vcl.Dialogs,
  Winapi.Windows,
  Winapi.ShellAPI,
  emr_UpDownLoadClient,
  emr_Common,
  frm_Hint,
  frm_ConnSet,
  frm_Emr in 'frm_Emr.pas' {frmEmr},
  frm_DM in '..\Common\frm_DM.pas' {dm: TDataModule};

{$R *.res}

var
  vFrmHint: TfrmHint;

{$REGION 'DownLoadUpdateExe����Update.exe�ļ�'}
function DownLoadUpdateExe: Boolean;
var
  vFileStream: TFileStream;
  vUpDownLoadClient: TUpDownLoadClient;
begin
  Result := False;
  vUpDownLoadClient := TUpDownLoadClient.Create;
  try
    vUpDownLoadClient.Host := ClientCache.ClientParam.UpdateServerIP;  // ���·�����IP
    vUpDownLoadClient.Port := ClientCache.ClientParam.UpdateServerPort;  // ���·������˿�
    try
      vUpDownLoadClient.Connect;
    except
      ShowMessage('�쳣����������������ʧ�ܣ�����('
        + ClientCache.ClientParam.UpdateServerIP + ':'
        + ClientCache.ClientParam.UpdateServerPort.ToString + ')��');

      Exit;
    end;

    if vUpDownLoadClient.Connected then  // ���Ӹ��·������ɹ�
    begin
      vFileStream := TFileStream.Create(ExtractFilePath(ParamStr(0)) + 'update.exe', fmCreate or fmShareDenyWrite);
      try
        if vUpDownLoadClient.DownLoadFile('update.exe', vFileStream,
          procedure(const AReciveSize, AFileSize: Integer)
          begin
            vFrmHint.UpdateHint('�������ظ��³������Ժ�...' + Round(AReciveSize / AFileSize * 100).ToString + '%');
          end)
        then  // ����update.exe�ɹ�
          Result := True
        else
          raise Exception.Create('�쳣�����������ļ�update.exeʧ�ܣ�' + vUpDownLoadClient.CurError);
      finally
        vFileStream.Free;
      end;
    end
    else
    begin
      raise Exception.Create('�쳣����������������ʧ�ܣ�����('
        + ClientCache.ClientParam.UpdateServerIP + ':'
        + ClientCache.ClientParam.UpdateServerPort.ToString + ')��');
    end;
  finally
    vUpDownLoadClient.Free;
  end;
end;
{$ENDREGION}

var
  vLastVerID, vClientVersionID: Integer;
  vLastVerStr: string;
  vFrmConnSet: TfrmConnSet;
begin
  Application.Initialize;
  Application.Title := '���Ӳ���';
  Application.MainFormOnTaskbar := False;

  vFrmHint := TfrmHint.Create(nil);
  try
    vFrmHint.Show;
    vFrmHint.UpdateHint('��������emr�������Ժ�...');

    if not Assigned(ClientCache) then
      ClientCache := TClientCache.Create;

    dm := Tdm.Create(nil);
    GetClientParam;  // ��ȡ���ز���

    // У������
    try
      GetLastVersion(vLastVerID, vLastVerStr);  // ����˵�ǰ���µĿͻ��˰汾��
      vClientVersionID := StrToIntDef(dm.GetParamStr('VersionID'), 0);  // ���ؿͻ��˰汾��

      if vClientVersionID <> vLastVerID then  // �汾��һ��
      begin
        if vClientVersionID > vLastVerID then  // �ͻ��˰���ڷ���˵�ǰ���µĿͻ��˰汾��
          ShowMessage('�ͻ��˰���ڷ���˰汾���������ף�')
        else
        if vClientVersionID < vLastVerID then  // ��Ҫ����
        begin
          if DownLoadUpdateExe then  // ����Update.exe�ļ����ڲ��ᴦ����������ʧ��ʱ��ʾ��Ϣ
          begin
            vFrmHint.UpdateHint('�����������³������Ժ�...');
            ShellExecute(GetDesktopWindow, nil, 'update.exe', nil, nil, SW_SHOWNORMAL);  // ����Update.exe���³���
          end;
        end;

        FreeAndNil(dm);
        if Assigned(ClientCache) then
          FreeAndNil(ClientCache);

        Exit;
      end;
    except
      on E: Exception do
      begin
        if MessageDlg('emrϵͳ�ͻ������������쳣��' + E.Message + ' �Ƿ���������ý��棿',
          TMsgDlgType.mtError, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes
        then
        begin
          Application.CreateForm(TFrmConnSet, vFrmConnSet);  // �����������ý���
          Application.Run;
        end;

        FreeAndNil(vFrmConnSet);
        FreeAndNil(dm);
        if Assigned(ClientCache) then
          FreeAndNil(ClientCache);

        Exit;
      end;
    end;

    vFrmHint.UpdateHint('���ڼ��ػ��棬���Ժ�...');
    ClientCache.GetCacheData;

    Application.CreateForm(TfrmEmr, frmEmr);
  finally
    FreeAndNil(vFrmHint);
  end;

  if frmEmr.LoginPluginExecute then  // ��¼�ɹ�
    Application.Run;

  FreeAndNil(frmEmr);
  FreeAndNil(dm);
  if Assigned(ClientCache) then
    FreeAndNil(ClientCache);
end.
