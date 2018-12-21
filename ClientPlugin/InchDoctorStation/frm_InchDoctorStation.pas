{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit frm_InchDoctorStation;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FunctionIntf, FunctionImp, emr_Common, StdCtrls, Vcl.Grids, Vcl.Menus,
  System.Generics.Collections, frm_PatientRecord, frm_PatientList, Vcl.Buttons,
  Vcl.ExtCtrls, frm_DataElement;

type
  TfrmInchDoctorStation = class(TForm)
    pnlBar: TPanel;
    mmMain: TMainMenu;
    mniN1: TMenuItem;
    mniN2: TMenuItem;
    mniPat: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mniN2Click(Sender: TObject);
  private
    { Private declarations }
    FPatRecIndex: Integer;
    FUserInfo: TUserInfo;
    FFrmPatList: TfrmPatientList;
    FfrmDataElement: TfrmDataElement;
    FPatRecFrms: TObjectList<TfrmPatientRecord>;
    FOnFunctionNotify: TFunctionNotifyEvent;
    // DataElement
    procedure DoInsertDataElementAsDE(const AIndex, AName: string);
    // PatientRecord
    procedure DoPatRecClose(Sender: TObject);
    function GetPatRecIndexByPatID(const APatID: Integer): Integer;
    function GetPatRecIndexByHandle(const AFormHandle: Integer): Integer;
    function GetToolButtonIndex(const ATag: Integer): Integer;
    procedure AddPatListForm;
    procedure DoSpeedButtonClick(Sender: TObject);
    procedure AddFormButton(const ACaption: string; const AHandle: THandle);
    procedure DoShowPatRec(const APatInfo: TPatientInfo);
  public
    { Public declarations }
  end;

  procedure PluginShowInchDoctorStationForm(AIFun: IFunBLLFormShow);
  procedure PluginCloseInchDoctorStationForm;

var
  FrmInchDoctorStation: TfrmInchDoctorStation;
  PluginID: string;

implementation

uses
  PluginConst, FunctionConst, emr_BLLConst, emr_BLLServerProxy, frm_DoctorLevel,
  emr_MsgPack, emr_Entry, emr_PluginObject, FireDAC.Comp.Client, frm_DM;

{$R *.dfm}

procedure PluginShowInchDoctorStationForm(AIFun: IFunBLLFormShow);
begin
  if FrmInchDoctorStation = nil then
    FrmInchDoctorStation := TfrmInchDoctorStation.Create(nil);

  FrmInchDoctorStation.FOnFunctionNotify := AIFun.OnNotifyEvent;
  FrmInchDoctorStation.Show;
end;

procedure PluginCloseInchDoctorStationForm;
begin
  if FrmInchDoctorStation <> nil then
    FreeAndNil(FrmInchDoctorStation);
end;

procedure TfrmInchDoctorStation.AddFormButton(const ACaption: string;
  const AHandle: THandle);
var
  vBtn: TSpeedButton;
  vMenuItem: TMenuItem;
begin
  if GetToolButtonIndex(AHandle) < 0 then  // Ŀǰû��
  begin
    vBtn := TSpeedButton.Create(Self);
    vBtn.Width := 64;
    vBtn.Align := alLeft;
    vBtn.Tag := AHandle;
    vBtn.GroupIndex := 1;
    vBtn.Flat := True;
    //vBtn.Down := True;
    vBtn.Caption := ACaption;
    vBtn.OnClick := DoSpeedButtonClick;
    vBtn.Parent := pnlBar;

    vMenuItem := TMenuItem.Create(mniPat);
    vMenuItem.Tag := AHandle;
    vMenuItem.GroupIndex := 1;
    vMenuItem.Caption := ACaption;
    vMenuItem.OnClick := DoSpeedButtonClick;
    mniPat.Add(vMenuItem);
  end;
end;

procedure TfrmInchDoctorStation.AddPatListForm;
var
  vMenuItem: TMenuItem;
begin
  if not Assigned(FFrmPatList) then
  begin
    FFrmPatList := TfrmPatientList.Create(Self);
    FFrmPatList.BorderStyle := bsNone;
    FFrmPatList.Align := alClient;
    FFrmPatList.Parent := Self;
    FFrmPatList.UserInfo := FUserInfo;
    FFrmPatList.OnShowPatientRecord := DoShowPatRec;
    FFrmPatList.Show;

    AddFormButton('�����б�', FFrmPatList.Handle);

    vMenuItem := TMenuItem.Create(mniPat);
    vMenuItem.Caption := '-';
    mniPat.Add(vMenuItem);
  end;
end;

procedure TfrmInchDoctorStation.DoSpeedButtonClick(Sender: TObject);
var
  i, vIndex, vHandle: Integer;
begin
  FPatRecIndex := -1;

  if Sender is TSpeedButton then
    vHandle := (Sender as TSpeedButton).Tag
  else
  if Sender is TMenuItem then
    vHandle := (Sender as TMenuItem).Tag;

  vIndex := GetPatRecIndexByHandle(vHandle);
  if vIndex >= 0 then
  begin
    if Sender is TSpeedButton then
    begin
      for i := 0 to pnlBar.ControlCount - 1 do
      begin
        if pnlBar.Controls[i] is TSpeedButton then
          (Sender as TSpeedButton).Down := False;
      end;

      (Sender as TSpeedButton).Down := True;
    end;

    Self.Controls[vIndex].BringToFront;

    if Self.Controls[vIndex] is TfrmPatientRecord then
      FPatRecIndex := vIndex;
  end;
end;

procedure TfrmInchDoctorStation.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FOnFunctionNotify(PluginID, FUN_BLLFORMDESTROY, nil);  // �ͷ�ҵ������Դ
  FOnFunctionNotify(PluginID, FUN_MAINFORMSHOW, nil);  // ��ʾ������
end;

procedure TfrmInchDoctorStation.FormCreate(Sender: TObject);
begin
  FPatRecIndex := -1;
  PluginID := PLUGIN_INCHDOCTORSTATION;
  //SetWindowLong(Handle, GWL_EXSTYLE, (GetWindowLong(handle, GWL_EXSTYLE) or WS_EX_APPWINDOW));
  FUserInfo := TUserInfo.Create;
  FPatRecFrms := TObjectList<TfrmPatientRecord>.Create;
end;

procedure TfrmInchDoctorStation.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FPatRecFrms);
  FreeAndNil(FFrmPatList);
  FreeAndNil(FUserInfo);
  if Assigned(FfrmDataElement) then
    FreeAndNil(FfrmDataElement);
end;

procedure TfrmInchDoctorStation.FormShow(Sender: TObject);
var
  vUserInfo: IPlugInUserInfo;
  vObjectInfo: IPlugInObjectInfo;
begin
  // ��ȡ�ͻ��������
  vObjectInfo := TPlugInObjectInfo.Create;
  FOnFunctionNotify(PluginID, FUN_CLIENTCACHE, vObjectInfo);
  ClientCache := TClientCache(vObjectInfo.&Object);

  // ��ǰ��¼�û�ID
  vUserInfo := TPlugInUserInfo.Create;
  FOnFunctionNotify(PluginID, FUN_USERINFO, vUserInfo);  // ��ȡ�������¼�û���
  FUserInfo.ID := vUserInfo.UserID;  // ��ֵID����Զ���ȡ������Ϣ

  // �������ݿ��������
  FOnFunctionNotify(PluginID, FUN_LOCALDATAMODULE, vObjectInfo);
  dm := Tdm(vObjectInfo.&Object);

  FOnFunctionNotify(PluginID, FUN_MAINFORMHIDE, nil);  // ����������

  AddPatListForm;  // ��ʾ�����б���
end;

function TfrmInchDoctorStation.GetPatRecIndexByHandle(
  const AFormHandle: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Self.ControlCount - 1 do
  begin
    if (Self.Controls[i] is TForm) then
    begin
      if (Self.Controls[i] as TForm).Handle = AFormHandle then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TfrmInchDoctorStation.GetPatRecIndexByPatID(
  const APatID: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FPatRecFrms.Count - 1 do
  begin
    if FPatRecFrms[i].PatientInfo.PatID = APatID then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TfrmInchDoctorStation.GetToolButtonIndex(const ATag: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to pnlBar.ControlCount - 1 do
  begin
    if pnlBar.Controls[i] is TSpeedButton then
    begin
      if (pnlBar.Controls[i] as TSpeedButton).Tag = ATag then
      begin
        Result := i;
        Exit;
      end;
    end;
  end;
end;

procedure TfrmInchDoctorStation.mniN2Click(Sender: TObject);
begin
  if not Assigned(FfrmDataElement) then
  begin
    FfrmDataElement := TfrmDataElement.Create(Self);
    FfrmDataElement.OnInsertAsDE := DoInsertDataElementAsDE;
  end;

  FfrmDataElement.Show;
end;

procedure TfrmInchDoctorStation.DoInsertDataElementAsDE(const AIndex, AName: string);
begin
  if FPatRecIndex >= 0 then
    FPatRecFrms[FPatRecIndex].InsertDataElementAsDE(AIndex, AName);
end;

procedure TfrmInchDoctorStation.DoPatRecClose(Sender: TObject);
var
  vIndex: Integer;
  i: Integer;
begin
  vIndex := FPatRecFrms.IndexOf(Sender as TfrmPatientRecord);
  if vIndex >= 0 then
  begin
    for i := 0 to pnlBar.ControlCount - 1 do
    begin
      if pnlBar.Controls[i] is TSpeedButton then
      begin
        if (pnlBar.Controls[i] as TSpeedButton).Tag = FPatRecFrms[vIndex].Handle then
        begin
          pnlBar.Controls[i].Free;
          Break;
        end;
      end;
    end;

    FPatRecFrms.Delete(vIndex);
  end;
end;

procedure TfrmInchDoctorStation.DoShowPatRec(const APatInfo: TPatientInfo);
var
  vIndex: Integer;
  vFrmPatRec: TfrmPatientRecord;
begin
  vIndex := GetPatRecIndexByPatID(APatInfo.PatID);
  if vIndex < 0 then
  begin
    vFrmPatRec := TfrmPatientRecord.Create(nil);
    vFrmPatRec.BorderStyle := bsNone;
    vFrmPatRec.Align := alClient;
    vFrmPatRec.Parent := Self;
    vFrmPatRec.UserInfo := FUserInfo;
    vFrmPatRec.OnCloseForm := DoPatRecClose;
    vFrmPatRec.PatientInfo.Assign(APatInfo);

    vIndex := FPatRecFrms.Add(vFrmPatRec);

    AddFormButton(APatInfo.Name + '-����', vFrmPatRec.Handle);

    vFrmPatRec.Show;
  end
  else
    FPatRecFrms[vIndex].BringToFront;

  FPatRecIndex := vIndex;
end;

end.
