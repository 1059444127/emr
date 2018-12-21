{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit frm_PatientList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, emr_Common, StdCtrls, Vcl.Grids, Vcl.Menus,
  System.Generics.Collections, frm_PatientRecord;

type
  TShowPatientRecord = procedure(const APatInfo: TPatientInfo) of object;

  TfrmPatientList = class(TForm)
    sgdPatient: TStringGrid;
    procedure sgdPatientDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FOnShowPatientRecord: TShowPatientRecord;
    procedure GetPatient;
  public
    { Public declarations }
    UserInfo: TUserInfo;
    property OnShowPatientRecord: TShowPatientRecord read FOnShowPatientRecord write FOnShowPatientRecord;
  end;

implementation

uses
  emr_BLLConst, emr_BLLServerProxy, frm_DoctorLevel,
  emr_MsgPack, emr_Entry, emr_PluginObject, FireDAC.Comp.Client;

{$R *.dfm}

procedure TfrmPatientList.FormShow(Sender: TObject);
begin
  GetPatient;
end;

procedure TfrmPatientList.GetPatient;
begin
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)  // ��ȡ����
    var
      vReplaceParam: TMsgPack;
    begin
      ABLLServerReady.Cmd := BLL_HIS_GETINPATIENT;  // ��ȡ����
      vReplaceParam := ABLLServerReady.ReplaceParam;
      vReplaceParam.S[TUser.DeptID] := UserInfo.GroupDeptIDs;
      ABLLServerReady.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    var
      vRow: Integer;
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
      begin
        ShowMessage(ABLLServer.MethodError);
        Exit;
      end;

        sgdPatient.RowCount := AMemtable.RecordCount + 1;
        sgdPatient.Cells[0, 0] := '����';
        sgdPatient.Cells[1, 0] := 'סԺ��';
        sgdPatient.Cells[2, 0] := '����';
        sgdPatient.Cells[3, 0] := '�Ա�';
        sgdPatient.Cells[4, 0] := '����';
        sgdPatient.Cells[5, 0] := '��Ժʱ��';
        sgdPatient.Cells[6, 0] := '���';
        sgdPatient.Cells[7, 0] := '����';
        sgdPatient.Cells[8, 0] := '������';
        sgdPatient.Cells[9, 0] := '���߱��';
        sgdPatient.Cells[10, 0] := '���';
        vRow := 1;
        with AMemtable do  // ����RefreshPatientItem������ʱvDataSet���ǵ�ǰ�б�û�У������ӵĻ���
        begin
          First;
          while not Eof do
          begin
            sgdPatient.Cells[0, vRow] := FieldByName('BedNO').AsString;
            sgdPatient.Cells[1, vRow] := FieldByName('InpNo').AsString;
            sgdPatient.Cells[2, vRow] := FieldByName('Name').AsString;
            sgdPatient.Cells[3, vRow] := FieldByName('Sex').AsString;
            sgdPatient.Cells[4, vRow] := FieldByName('Age').AsString;
            sgdPatient.Cells[5, vRow] := FieldByName('InDate').AsString;
            sgdPatient.Cells[6, vRow] := FieldByName('Diagnosis').AsString;
            sgdPatient.Cells[7, vRow] := FieldByName('IllState').AsString;
            sgdPatient.Cells[8, vRow] := FieldByName('CareLevel').AsString;
            sgdPatient.Cells[9, vRow] := FieldByName('PatID').AsString;
            sgdPatient.Cells[10, vRow] := FieldByName('VisitID').AsString;
            sgdPatient.Cells[11, vRow] := FieldByName('DeptName').AsString;

            Inc(vRow);
            Next;
          end;
        end;
    end);
end;

procedure TfrmPatientList.sgdPatientDblClick(Sender: TObject);
var
  vPatientInfo: TPatientInfo;
begin
  if (sgdPatient.Cells[0, sgdPatient.Row] <> '') and Assigned(FOnShowPatientRecord) then
  begin
    vPatientInfo := TPatientInfo.Create;
    try
      vPatientInfo.BedNo := sgdPatient.Cells[0, sgdPatient.Row];
      vPatientInfo.InpNo := sgdPatient.Cells[1, sgdPatient.Row];
      vPatientInfo.Name := sgdPatient.Cells[2, sgdPatient.Row];
      vPatientInfo.Sex := sgdPatient.Cells[3, sgdPatient.Row];
      vPatientInfo.Age := sgdPatient.Cells[4, sgdPatient.Row];
      vPatientInfo.InHospDateTime := StrToDateTime(sgdPatient.Cells[5, sgdPatient.Row]);
      vPatientInfo.PatID := StrToInt(sgdPatient.Cells[9, sgdPatient.Row]);
      vPatientInfo.VisitID := StrToInt(sgdPatient.Cells[10, sgdPatient.Row]);
      vPatientInfo.DeptName := sgdPatient.Cells[11, sgdPatient.Row];

      FOnShowPatientRecord(vPatientInfo);
    finally
      FreeAndNil(vPatientInfo);
    end;
  end;
end;

end.
