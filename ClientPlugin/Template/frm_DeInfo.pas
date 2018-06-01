{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit frm_DeInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmDeInfo = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    edtCode: TEdit;
    edtName: TEdit;
    edtPY: TEdit;
    edtDefine: TEdit;
    edtType: TEdit;
    edtFormat: TEdit;
    edtUnit: TEdit;
    lbl9: TLabel;
    edtDomainID: TEdit;
    btnSave: TButton;
    cbbFrmtp: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
    FDeID: Integer;
  public
    { Public declarations }
    property DeID: Integer read FDeID write FDeID;
  end;

implementation

uses
  emr_Common, emr_BLLConst, emr_BLLServerProxy, FireDAC.Comp.Client, EmrElementItem;

{$R *.dfm}

function GetFrmptText(const AFrmpt: string): string;
begin
  if AFrmpt = TDeFrmtp.Radio then
    Result := '��ѡ'
  else
  if AFrmpt = TDeFrmtp.Multiselect then
    Result := '��ѡ'
  else
  if AFrmpt = TDeFrmtp.Number then
    Result := '��ֵ'
  else
  if AFrmpt = TDeFrmtp.String then
    Result := '�ı�'
  else
  if AFrmpt = TDeFrmtp.Date then
    Result := '����'
  else
  if AFrmpt = TDeFrmtp.Time then
    Result := 'ʱ��'
  else
  if AFrmpt = TDeFrmtp.DateTime then
    Result := '����ʱ��'
  else
    Result := '';
end;

function GetFrmpt(const AText: string): string;
begin
  if AText = '��ѡ' then
    Result := TDeFrmtp.Radio
  else
  if AText = '��ѡ' then
    Result := TDeFrmtp.Multiselect
  else
  if AText = '��ֵ' then
    Result := TDeFrmtp.Number
  else
  if AText = '�ı�' then
    Result := TDeFrmtp.String
  else
  if AText = '����' then
    Result := TDeFrmtp.Date
  else
  if AText = 'ʱ��' then
    Result := TDeFrmtp.Time
  else
  if AText = '����ʱ��' then
    Result := TDeFrmtp.DateTime
  else
    Result := '';
end;

procedure TfrmDeInfo.btnSaveClick(Sender: TObject);
var
  vDomainID, vCMD: Integer;
begin
  if Trim(edtName.Text) = '' then
  begin
    ShowMessage('������д����Ԫ���ƣ�');
    Exit;
  end;

  if not TryStrToInt(edtDomainID.Text, vDomainID) then
  begin
    ShowMessage('������д��ֵ����תΪ������');
    Exit;
  end;

  if FDeID > 0 then  // �޸�
    vCMD := BLL_SETDEINFO
  else  // �½�
    vCMD := BLL_NEWDE;

  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := vCMD;

      if FDeID > 0 then  // �޸�
        ABLLServerReady.ExecParam.I['DeID'] := FDeID;

      ABLLServerReady.ExecParam.S['decode'] := edtCode.Text;
      ABLLServerReady.ExecParam.S['dename'] := edtName.Text;
      ABLLServerReady.ExecParam.S['py'] := edtPY.Text;
      ABLLServerReady.ExecParam.S['dedefine'] := edtDefine.Text;
      ABLLServerReady.ExecParam.S['detype'] := edtType.Text;
      ABLLServerReady.ExecParam.S['deformat'] := edtFormat.Text;
      ABLLServerReady.ExecParam.S['deunit'] := edtUnit.Text;
      ABLLServerReady.ExecParam.S['frmtp'] := GetFrmpt(cbbFrmtp.Text);
      ABLLServerReady.ExecParam.I['domainid'] := vDomainID;
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then
        ShowMessage(ABLLServer.MethodError)
      else
        ShowMessage('����ɹ���');
    end);

  if FDeID = 0 then  // �½���ر�
    Close;

  Self.ModalResult := mrOk;
end;

procedure TfrmDeInfo.FormShow(Sender: TObject);
begin
  if FDeID > 0 then
  begin
    Caption := '����Ԫά��-' + FDeID.ToString;

    HintFormShow('���ڻ�ȡ����Ԫ��Ϣ...', procedure(const AUpdateHint: TUpdateHint)
    begin
      BLLServerExec(
        procedure(const ABLLServerReady: TBLLServerProxy)
        begin
          ABLLServerReady.Cmd := BLL_GETDEINFO;  // ��ȡ����Ԫ��Ϣ
          ABLLServerReady.ExecParam.I['DeID'] := FDeID;
          ABLLServerReady.BackDataSet := True;
        end,
        procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
        begin
          if ABLLServer.MethodRunOk then  //
          begin
            if AMemTable <> nil then
            begin
              edtCode.Text := AMemTable.FieldByName('decode').AsString;
              edtName.Text := AMemTable.FieldByName('dename').AsString;
              edtPY.Text := AMemTable.FieldByName('py').AsString;
              edtDefine.Text := AMemTable.FieldByName('dedefine').AsString;
              edtType.Text := AMemTable.FieldByName('detype').AsString;
              edtFormat.Text := AMemTable.FieldByName('deformat').AsString;
              edtUnit.Text := AMemTable.FieldByName('deunit').AsString;
              cbbFrmtp.ItemIndex := cbbFrmtp.Items.IndexOf(GetFrmptText(AMemTable.FieldByName('frmtp').AsString));
              edtDomainID.Text := AMemTable.FieldByName('domainid').AsString;
            end;
          end
          else
            ShowMessage(ABLLServer.MethodError);
        end);
    end);
  end
  else
    Caption := '�½�����Ԫ'
end;

end.
