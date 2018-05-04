{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit frm_TemplateList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.Grids;

type
  TfrmTemplateList = class(TForm)
    pnl1: TPanel;
    tvTemplate: TTreeView;
    spl1: TSplitter;
    pnl2: TPanel;
    edtRecordName: TEdit;
    btnOK: TButton;
    sgdTempList: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure tvTemplateChange(Sender: TObject; Node: TTreeNode);
  private
    { Private declarations }
    FTemplateID, FDesID: Integer;
    FRecordName: string;
    procedure ClearTemplateGroup;
    procedure GetTemplateGroup;
    procedure ClearTemplateList;
  public
    { Public declarations }
    /// <summary> ѡ���ģ��ID </summary>
    property TemplateID: Integer read FTemplateID write FTemplateID;

    /// <summary> ѡ���ģ���Ӧ�����ݼ�DesID </summary>
    property DesID: Integer read FDesID write FDesID;

    /// <summary> ѡ���ģ������ </summary>
    property RecordName: string read FRecordName write FRecordName;
  end;

var
  frmTemplateList: TfrmTemplateList;

implementation

uses
  emr_Common, emr_BLLServerProxy, emr_BLLConst, FireDAC.Comp.Client;

{$R *.dfm}

procedure TfrmTemplateList.btnOKClick(Sender: TObject);
begin
  if sgdTempList.Row > 0 then
  begin
    FTemplateID := sgdTempList.Cells[3, sgdTempList.Row].ToInteger;
    FRecordName := edtRecordName.Text;
    if Trim(edtRecordName.Text) <> '' then
    begin
      Close;
      Self.ModalResult := mrOk;
    end
    else
    begin
      ShowMessage('����д��ȷ�Ĳ������ƣ�');
      edtRecordName.SetFocus;
    end;
  end
  else
    ShowMessage('��ѡ��ģ�壡');
end;

procedure TfrmTemplateList.ClearTemplateGroup;
var
  i: Integer;
  vNode: TTreeNode;
begin
  for i := 0 to tvTemplate.Items.Count - 1 do
  begin
    vNode := tvTemplate.Items[i];
    if vNode <> nil then
    begin
      if TreeNodeIsTemplate(vNode) then
        TTemplateInfo(vNode.Data).Free
      else
        TDeSetInfo(vNode.Data).Free;
    end;
  end;

  tvTemplate.Items.Clear;
end;

procedure TfrmTemplateList.ClearTemplateList;
begin
  sgdTempList.FixedRows := 0;
  sgdTempList.RowCount := 1;
  edtRecordName.Text := '';
  sgdTempList.Row := 0;
  FDesID := 0;
  FRecordName := '';
end;

procedure TfrmTemplateList.FormShow(Sender: TObject);
begin
  GetTemplateGroup;
  sgdTempList.Cells[0, 0] := '����';
  sgdTempList.Cells[1, 0] := '����';
  sgdTempList.Cells[2, 0] := '����ID';
  sgdTempList.Cells[3, 0] := 'ID';

  sgdTempList.ColWidths[0] := 200;
  sgdTempList.ColWidths[1] := 0;
  sgdTempList.ColWidths[2] := 0;
  sgdTempList.ColWidths[3] := 50;
end;

procedure TfrmTemplateList.GetTemplateGroup;
begin
  ClearTemplateGroup;

  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETDATAELEMENTSETALL;  // ��ȡ���ݼ�(ȫĿ¼)��Ϣ
      ABLLServerReady.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)

      {$REGION 'GetParentNode'}
      function GetParentNode(const APID: Integer): TTreeNode;
      var
        i: Integer;
      begin
        Result := nil;
        for i := 0 to tvTemplate.Items.Count - 1 do
        begin
          if tvTemplate.Items[i].Data <> nil then
          begin
            if TDeSetInfo(tvTemplate.Items[i].Data).ID = APID then
            begin
              Result := tvTemplate.Items[i];
              Break;
            end;
          end;
        end;
      end;
      {$ENDREGION}

    var
      //vNode: TTreeNode;
      vDeSetInfo: TDeSetInfo;
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
      begin
        ShowMessage(ABLLServer.MethodError);
        Exit;
      end;

      if AMemTable <> nil then
      begin
        tvTemplate.Items.BeginUpdate;
        try
          with AMemTable do
          begin
            First;
            while not Eof do
            begin
              if ((FieldByName('UseRang').AsInteger = TDeSetInfo.USERANG_CLINIC)  // �ٴ�
                  or (FieldByName('UseRang').AsInteger = TDeSetInfo.USERANG_CLINICANDNURSE)  // �ٴ��ͻ���
                 )
                and ((FieldByName('InOrOut').AsInteger = TDeSetInfo.INOROUT_IN)  // סԺ
                     or (FieldByName('InOrOut').AsInteger = TDeSetInfo.INOROUT_INOUT)  // סԺ������
                    )
              then
              begin
                vDeSetInfo := TDeSetInfo.Create;
                vDeSetInfo.ID := FieldByName('id').AsInteger;
                vDeSetInfo.PID := FieldByName('pid').AsInteger;
                vDeSetInfo.GroupClass := FieldByName('Class').AsInteger;
                vDeSetInfo.GroupType := FieldByName('Type').AsInteger;
                vDeSetInfo.GroupName := FieldByName('Name').AsString;
                vDeSetInfo.UseRang := FieldByName('UseRang').AsInteger;
                vDeSetInfo.InOrOut := FieldByName('InOrOut').AsInteger;

                if vDeSetInfo.PID <> 0 then
                begin
                  tvTemplate.Items.AddChildObject(GetParentNode(vDeSetInfo.PID),
                    vDeSetInfo.GroupName, vDeSetInfo)
                end
                else
                  tvTemplate.Items.AddObject(nil, vDeSetInfo.GroupName, vDeSetInfo);
              end;

              Next;
            end;
          end;
        finally
          tvTemplate.Items.EndUpdate;
        end;
      end;
    end);
end;

procedure TfrmTemplateList.tvTemplateChange(Sender: TObject; Node: TTreeNode);
begin
  ClearTemplateList;

  if tvTemplate.Selected.Count = 0 then
  begin
    FDesID := TDeSetInfo(Node.Data).ID;

    if FDesID = 60 then  // �ճ����̼�¼
      FRecordName := Node.Text + ' ' + FormatDateTime('YYYY-MM-DD HH:mm:SS', TBLLServer.GetServerDateTime)
    else
      FRecordName := Node.Text;

    edtRecordName.Text := FRecordName;

    BLLServerExec(
      procedure(const ABLLServerReady: TBLLServerProxy)
      begin
        ABLLServerReady.Cmd := BLL_GETTEMPLATELIST;  // ��ȡָ�����ݼ���Ӧ��ģ��
        ABLLServerReady.ExecParam.I['desID'] := FDesID;
        ABLLServerReady.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
      end,
      procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
      var
        i: Integer;
      begin
        if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        begin
          ShowMessage(ABLLServer.MethodError);
          Exit;
        end;

        if AMemTable <> nil then
        begin
          if AMemTable.RecordCount > 0 then
          begin
            sgdTempList.RowCount := AMemTable.RecordCount + 1;
            sgdTempList.FixedRows := 1;
            i := 1;

            with AMemTable do
            begin
              First;
              while not Eof do
              begin
                sgdTempList.Cells[0, i] := FieldByName('tname').AsString;
                sgdTempList.Cells[1, i] := FieldByName('Owner').AsString;
                sgdTempList.Cells[2, i] := FieldByName('OwnerID').AsString;
                sgdTempList.Cells[3, i] := FieldByName('id').AsString;
                Inc(i);

                Next;
              end;
            end;
          end;
        end;
      end);
  end;
end;

end.
