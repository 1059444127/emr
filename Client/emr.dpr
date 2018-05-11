program emr;

{ �ر�RTTI������Ƽ���EXE�ļ��ߴ� }
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

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
  frm_DM,
  frm_Hint,
  frm_ConnSet,
  frm_Emr in 'frm_Emr.pas' {frmEmr};

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
    vUpDownLoadClient.Host := GClientParam.UpdateServerIP;  // ���·�����IP
    vUpDownLoadClient.Port := GClientParam.UpdateServerPort;  // ���·������˿�
    try
      vUpDownLoadClient.Connect;
    except
      ShowMessage('�쳣����������������ʧ�ܣ�����('
        + GClientParam.UpdateServerIP + ':'
        + GClientParam.UpdateServerPort.ToString + ')��');

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
        + GClientParam.UpdateServerIP + ':'
        + GClientParam.UpdateServerPort.ToString + ')��');
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

    Application.CreateForm(Tdm, dm);
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

        dm.Free;
        GClientParam.Free;
        Exit;
      end;
    except
      on E: Exception do
      begin
        if MessageDlg('emrϵͳ�ͻ������������쳣��' + E.Message + ' �Ƿ���������ý��棿',
          TMsgDlgType.mtError, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes
        then
        begin
          Application.CreateForm(TfrmConnSet, vFrmConnSet);  // �����������ý���
          Application.Run;
        end;

        dm.Free;
        GClientParam.Free;
        Exit;
      end;
    end;
  finally
    FreeAndNil(vFrmHint);
  end;

  Application.CreateForm(TfrmEmr, frmEmr);
  if frmEmr.LoginPluginExec then  // ��¼�ɹ�
    Application.Run;

  FreeAndNil(frmEmr);
  FreeAndNil(dm);
  FreeAndNil(GClientParam);
end.
