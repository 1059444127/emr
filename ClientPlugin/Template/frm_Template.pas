{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit frm_Template;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FunctionIntf, FunctionImp,
  Vcl.ComCtrls, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList, Vcl.Menus, Data.DB,
  Vcl.StdCtrls, Vcl.Grids, emr_Common, frm_Record, FireDAC.Comp.Client;

type
  TfrmTemplate = class(TForm)
    spl1: TSplitter;
    pgRecordEdit: TPageControl;
    tsHelp: TTabSheet;
    tvTemplate: TTreeView;
    il: TImageList;
    pm: TPopupMenu;
    mniNewTemp: TMenuItem;
    mniDeleteTemp: TMenuItem;
    pmpg: TPopupMenu;
    mniN1: TMenuItem;
    pnl1: TPanel;
    sgdDE: TStringGrid;
    spl2: TSplitter;
    sgdCV: TStringGrid;
    spl3: TSplitter;
    pmde: TPopupMenu;
    mniInsertAsDG: TMenuItem;
    pnl2: TPanel;
    edtPY: TEdit;
    mniViewItem: TMenuItem;
    mniInsert: TMenuItem;
    pmM: TPopupMenu;
    mniEditItemLink: TMenuItem;
    mniDeleteItemLink: TMenuItem;
    pnl3: TPanel;
    lblDE: TLabel;
    mniN5: TMenuItem;
    mniInsertAsDE: TMenuItem;
    mniN2: TMenuItem;
    lblDeHint: TLabel;
    mniN6: TMenuItem;
    mniEdit: TMenuItem;
    mniNew: TMenuItem;
    mniDelete: TMenuItem;
    mniRefresh: TMenuItem;
    mniNewItem: TMenuItem;
    mniEditItem: TMenuItem;
    mniDeleteItem: TMenuItem;
    mniN10: TMenuItem;
    mniN3: TMenuItem;
    mniInsertAsEdit: TMenuItem;
    mniInsertAsCombobox: TMenuItem;
    mniN4: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tvTemplateDblClick(Sender: TObject);
    procedure tvTemplateExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure mniNewTempClick(Sender: TObject);
    procedure pmPopup(Sender: TObject);
    procedure mniDeleteTempClick(Sender: TObject);
    procedure pgRecordEditMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mniN1Click(Sender: TObject);
    procedure sgdDEDblClick(Sender: TObject);
    procedure mniInsertAsDGClick(Sender: TObject);
    procedure mniViewItemClick(Sender: TObject);
    procedure pmdePopup(Sender: TObject);
    procedure mniInsertClick(Sender: TObject);
    procedure mniEditItemLinkClick(Sender: TObject);
    procedure mniInsertAsDEClick(Sender: TObject);
    procedure edtPYKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mniN2Click(Sender: TObject);
    procedure tvTemplateCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure mniEditClick(Sender: TObject);
    procedure mniNewClick(Sender: TObject);
    procedure mniDeleteClick(Sender: TObject);
    procedure mniRefreshClick(Sender: TObject);
    procedure mniNewItemClick(Sender: TObject);
    procedure mniEditItemClick(Sender: TObject);
    procedure pmMPopup(Sender: TObject);
    procedure mniDeleteItemClick(Sender: TObject);
    procedure mniN3Click(Sender: TObject);
    procedure mniDeleteItemLinkClick(Sender: TObject);
    procedure mniInsertAsComboboxClick(Sender: TObject);
  private
    { Private declarations }
    FUserInfo: TUserInfo;
    FDomainID: Integer;  // ��ǰ�鿴��ֵ��ID
    FOnFunctionNotify: TFunctionNotifyEvent;
    procedure ClearTemplateDeSet;
    procedure ShowTemplateDeSet;
    procedure ShowAllDataElement;
    procedure ShowDataElement;
    function GetRecordEditPageIndex(const ATempID: Integer): Integer;
    function GetActiveRecord: TfrmRecord;
    procedure GetDomainItem(const ADomainID: Integer);
    //
    procedure CloseRecordEditPage(const APageIndex: Integer;
      const ASaveChange: Boolean = True);
    procedure DoSaveTempContent(Sender: TObject);
    procedure DoRecordChangedSwitch(Sender: TObject);
  public
    { Public declarations }
  end;

  procedure PluginShowTemplateForm(AIFun: IFunBLLFormShow);
  procedure PluginCloseTemplateForm;

var
  frmTemplate: TfrmTemplate;
  PluginID: string;

implementation

uses
  PluginConst, FunctionConst, emr_BLLServerProxy, emr_MsgPack,
  emr_Entry, emr_PluginObject, EmrElementItem, EmrGroupItem, HCCommon, TemplateCommon,
  EmrView, frm_ItemContent, frm_TemplateInfo, frm_DeInfo, frm_DomainItem, frm_Domain;

{$R *.dfm}

procedure PluginShowTemplateForm(AIFun: IFunBLLFormShow);
begin
  if not Assigned(frmTemplate) then
    frmTemplate := TfrmTemplate.Create(nil);

  frmTemplate.FOnFunctionNotify := AIFun.OnNotifyEvent;
  frmTemplate.Show;
end;

procedure PluginCloseTemplateForm;
begin
  if Assigned(frmTemplate) then
    FreeAndNil(frmTemplate);
end;

procedure TfrmTemplate.ClearTemplateDeSet;

  {procedure ClearTemplateGroupNode(const ANode: TTreeNode);
  var
    i: Integer;
  begin
    for i := 0 to ANode.Count - 1 do
      ClearTemplateGroupNode(ANode.Item[i]);

    if TObject(ANode.Data) is TTemplateGroupInfo then
      TTemplateGroupInfo(ANode.Data).Free
    else
      TTemplateInfo(ANode.Data).Free;
  end;}

var
  i: Integer;
  vNode: TTreeNode;
begin
  for i := 0 to tvTemplate.Items.Count - 1 do
  begin
    //ClearTemplateGroupNode(tvTemplate.Items[i]);
    vNode := tvTemplate.Items[i];
    if vNode <> nil then
    begin
      if TreeNodeIsTemplate(vNode) then
        TTemplateInfo(vNode.Data).Free
      else
        TDataSetInfo(vNode.Data).Free;
    end;
  end;

  tvTemplate.Items.Clear;
end;

procedure TfrmTemplate.CloseRecordEditPage(const APageIndex: Integer;
  const ASaveChange: Boolean = True);
var
  i: Integer;
  vPage: TTabSheet;
  vFrmRecord: TfrmRecord;
begin
  if APageIndex >= 0 then
  begin
    vPage := pgRecordEdit.Pages[APageIndex];

    for i := 0 to vPage.ControlCount - 1 do
    begin
      if vPage.Controls[i] is TfrmRecord then
      begin
        if ASaveChange then  // ��Ҫ���䶯
        begin
          vFrmRecord := (vPage.Controls[i] as TfrmRecord);
          if vFrmRecord.EmrView.IsChanged then  // �б䶯
          begin
            if MessageDlg('�Ƿ񱣴�ģ�� ' + TTemplateInfo(vFrmRecord.ObjectData).NameEx + ' ��',
              mtWarning, [mbYes, mbNo], 0) = mrYes
            then
            begin
              DoSaveTempContent(vFrmRecord);
            end;
          end;
        end;

        vPage.Controls[i].Free;
        Break;
      end;
    end;

    vPage.Free;

    if APageIndex > 0 then
      pgRecordEdit.ActivePageIndex := APageIndex - 1;
  end;
end;

procedure TfrmTemplate.DoRecordChangedSwitch(Sender: TObject);
var
  vText: string;
begin
  if (Sender is TfrmRecord) then
  begin
    if (Sender as TfrmRecord).Parent is TTabSheet then
    begin
      if (Sender as TfrmRecord).EmrView.IsChanged then
        vText := TTemplateInfo((Sender as TfrmRecord).ObjectData).NameEx + '*'
      else
        vText := TTemplateInfo((Sender as TfrmRecord).ObjectData).NameEx;

      ((Sender as TfrmRecord).Parent as TTabSheet).Caption := vText;
    end;
  end;
end;

procedure TfrmTemplate.DoSaveTempContent(Sender: TObject);
var
  vSM: TMemoryStream;
  vTempID: Integer;
begin
  vSM := TMemoryStream.Create;
  try
    (Sender as TfrmRecord).EmrView.SaveToStream(vSM);

    vTempID := TTemplateInfo((Sender as TfrmRecord).ObjectData).ID;

    BLLServerExec(
      procedure(const ABLLServerReady: TBLLServerProxy)  // ��ȡ����
      begin
        ABLLServerReady.Cmd := BLL_SAVETEMPLATECONTENT;  // ��ȡģ������б�
        ABLLServerReady.ExecParam.I['tid'] := TTemplateInfo((Sender as TfrmRecord).ObjectData).ID;
        ABLLServerReady.ExecParam.ForcePathObject('content').LoadBinaryFromStream(vSM);
      end,
      procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
      begin
        if ABLLServer.MethodRunOk then  // ����˷�������ִ�гɹ�
          ShowMessage('����ɹ���')
        else
          ShowMessage(ABLLServer.MethodError);
      end);
  finally
    FreeAndNil(vSM);
  end;
end;

procedure TfrmTemplate.edtPYKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  function IsPY(const AChar: Char): Boolean;
  begin
    Result := AChar in ['a'..'z', 'A'..'Z'];
  end;

begin
  if Key = VK_RETURN then
  begin
    ClientCache.DataElementDT.FilterOptions := [foCaseInsensitive{�����ִ�Сд, foNoPartialCompare��֧��ͨ���(*)����ʾ�Ĳ���ƥ��}];
    if edtPY.Text = '' then
      ClientCache.DataElementDT.Filtered := False
    else
    begin
      ClientCache.DataElementDT.Filtered := False;
      if IsPY(edtPY.Text[1]) then
        ClientCache.DataElementDT.Filter := 'py like ''%' + edtPY.Text + '%'''
      else
        ClientCache.DataElementDT.Filter := 'dename like ''%' + edtPY.Text + '%''';
      ClientCache.DataElementDT.Filtered := True;
    end;

    ShowDataElement;
  end;
end;

procedure TfrmTemplate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FOnFunctionNotify(PluginID, FUN_BLLFORMDESTROY, nil);  // �ͷ�ҵ������Դ
  FOnFunctionNotify(PluginID, FUN_MAINFORMSHOW, nil);  // ��ʾ������
end;

procedure TfrmTemplate.FormCreate(Sender: TObject);
begin
  FDomainID := 0;
  PluginID := PLUGIN_TEMPLATE;
  //SetWindowLong(Handle, GWL_EXSTYLE, (GetWindowLong(handle, GWL_EXSTYLE) or WS_EX_APPWINDOW));
  FUserInfo := TUserInfo.Create;
end;

procedure TfrmTemplate.FormDestroy(Sender: TObject);
var
  i, j: Integer;
begin
  ClearTemplateDeSet;

  for i := 0 to pgRecordEdit.PageCount - 1 do
  begin
    for j := 0 to pgRecordEdit.Pages[i].ControlCount - 1 do
    begin
      if pgRecordEdit.Pages[i].Controls[j] is TfrmRecord then
      begin
        pgRecordEdit.Pages[i].Controls[j].Free;
        Break;
      end;
    end;
  end;

  FreeAndNil(FUserInfo);
end;

procedure TfrmTemplate.FormShow(Sender: TObject);
var
  vUserInfo: IPluginUserInfo;
  vObjectInfo: IPlugInObjectInfo;
begin
  sgdDE.RowCount := 1;
  sgdDE.Cells[0, 0] := '��';
  sgdDE.Cells[1, 0] := '����';
  sgdDE.Cells[2, 0] := '����';
  sgdDE.Cells[3, 0] := 'ƴ��';
  sgdDE.Cells[4, 0] := '����';
  sgdDE.Cells[5, 0] := 'ֵ��';

  sgdCV.RowCount := 1;
  sgdCV.Cells[0, 0] := 'ֵ';
  sgdCV.Cells[1, 0] := '����';
  sgdCV.Cells[2, 0] := 'ƴ��';
  sgdCV.Cells[3, 0] := 'id';

  // ��ȡ�ͻ��������
  vObjectInfo := TPlugInObjectInfo.Create;
  FOnFunctionNotify(PluginID, FUN_CLIENTCACHE, vObjectInfo);
  ClientCache := TClientCache(vObjectInfo.&Object);

  // ��ǰ��¼�û�ID
  vUserInfo := TPluginUserInfo.Create;
  FOnFunctionNotify(PluginID, FUN_USERINFO, vUserInfo);  // ��ȡ�������¼�û���
  FUserInfo.ID := vUserInfo.UserID;
  //
  FOnFunctionNotify(PluginID, FUN_MAINFORMHIDE, nil);  // ����������

  ShowTemplateDeSet;  // ��ȡ����ʾģ�����ݼ���Ϣ
  ShowAllDataElement;  // ��ʾ����Ԫ��Ϣ
end;

function TfrmTemplate.GetActiveRecord: TfrmRecord;
var
  vPage: TTabSheet;
  i: Integer;
begin
  Result := nil;

  vPage := pgRecordEdit.ActivePage;
  for i := 0 to vPage.ControlCount - 1 do
  begin
    if vPage.Controls[i] is TfrmRecord then
    begin
      Result := (vPage.Controls[i] as TfrmRecord);
      Break;
    end;
  end;
end;

procedure TfrmTemplate.ShowAllDataElement;
begin
  edtPY.Clear;
  sgdDE.RowCount := 1;
  sgdCV.RowCount := 1;
  ShowDataElement;
end;

procedure TfrmTemplate.GetDomainItem(const ADomainID: Integer);
var
  vTopRow, vRow: Integer;
begin
  if ADomainID > 0 then
  begin
    SaveStringGridRow(vRow, vTopRow, sgdCV);

    HintFormShow('���ڻ�ȡѡ��...', procedure(const AUpdateHint: TUpdateHint)
    begin
      BLLServerExec(
        procedure(const ABLLServerReady: TBLLServerProxy)
        begin
          ABLLServerReady.Cmd := BLL_GETDOMAINITEM;  // ��ȡֵ��ѡ��
          ABLLServerReady.ExecParam.I['domainid'] := ADomainID;
          ABLLServerReady.BackDataSet := True;
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
            sgdCV.RowCount := AMemTable.RecordCount + 1;

            i := 1;

            with AMemTable do
            begin
              First;
              while not Eof do
              begin
                sgdCV.Cells[0, i] := FieldByName('devalue').AsString;
                sgdCV.Cells[1, i] := FieldByName('code').AsString;
                sgdCV.Cells[2, i] := FieldByName('py').AsString;
                sgdCV.Cells[3, i] := FieldByName('id').AsString;

                Next;
                Inc(i);
              end;
            end;

            if AMemTable.RecordCount > 0 then
              sgdCV.FixedRows := 1;

            RestoreStringGridRow(vRow, vTopRow, sgdCV);
          end;
        end);
    end);
  end;
end;

function TfrmTemplate.GetRecordEditPageIndex(const ATempID: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to pgRecordEdit.PageCount - 1 do
  begin
    if pgRecordEdit.Pages[i].Tag = ATempID then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TfrmTemplate.ShowTemplateDeSet;
begin
  ClearTemplateDeSet;

  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETDATAELEMENTSETALL;  // ��ȡ���ݼ�(ȫĿ¼)��Ϣ
      ABLLServerReady.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)

      function GetParentNode(const APID: Integer): TTreeNode;
      var
        i: Integer;
      begin
        Result := nil;
        for i := 0 to tvTemplate.Items.Count - 1 do
        begin
          if tvTemplate.Items[i].Data <> nil then
          begin
            if TDataSetInfo(tvTemplate.Items[i].Data).ID = APID then
            begin
              Result := tvTemplate.Items[i];
              Break;
            end;
          end;
        end;
      end;

    var
      vNode: TTreeNode;
      vDataSetInfo: TDataSetInfo;
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
              vDataSetInfo := TDataSetInfo.Create;
              vDataSetInfo.ID := FieldByName('id').AsInteger;
              vDataSetInfo.PID := FieldByName('pid').AsInteger;
              vDataSetInfo.GroupClass := FieldByName('Class').AsInteger;
              vDataSetInfo.GroupType := FieldByName('Type').AsInteger;
              vDataSetInfo.GroupName := FieldByName('Name').AsString;

              if vDataSetInfo.PID <> 0 then
              begin
                vNode := tvTemplate.Items.AddChildObject(GetParentNode(vDataSetInfo.PID),
                  vDataSetInfo.GroupName, vDataSetInfo)
              end
              else
                vNode := tvTemplate.Items.AddObject(nil, vDataSetInfo.GroupName, vDataSetInfo);

              vNode.HasChildren := True;

              Next;
            end;
          end;
        finally
          tvTemplate.Items.EndUpdate;
        end;
      end;
    end);
end;

procedure TfrmTemplate.ShowDataElement;
var
  vRow: Integer;
begin
  sgdDE.RowCount := 1;
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETDATAELEMENT;  // ��ȡ����Ԫ�б�
      ABLLServerReady.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�в��ɹ�
      begin
        ShowMessage(ABLLServer.MethodError);
        Exit;
      end;

      if AMemTable <> nil then
      begin
        vRow := 1;
        sgdDE.RowCount := AMemTable.RecordCount + 1;

        with AMemTable do
        begin
          First;
          while not Eof do
          begin
            sgdDE.Cells[0, vRow] := FieldByName('deid').AsString;;
            sgdDE.Cells[1, vRow] := FieldByName('dename').AsString;
            sgdDE.Cells[2, vRow] := FieldByName('decode').AsString;
            sgdDE.Cells[3, vRow] := FieldByName('py').AsString;
            sgdDE.Cells[4, vRow] := FieldByName('frmtp').AsString;
            sgdDE.Cells[5, vRow] := FieldByName('domainid').AsString;
            Inc(vRow);

            Next;
          end;
        end;
      end;
    end);
end;

procedure TfrmTemplate.mniDeleteTempClick(Sender: TObject);
var
  vTempID: Integer;
begin
  if TreeNodeIsTemplate(tvTemplate.Selected) then
  begin
    if MessageDlg('ȷ��Ҫɾ��ģ�� ' + TTemplateInfo(tvTemplate.Selected.Data).NameEx + ' ��',
      mtWarning, [mbYes, mbNo], 0) = mrYes
    then
    begin
      vTempID := TTemplateInfo(tvTemplate.Selected.Data).ID;

      BLLServerExec(
        procedure(const ABLLServerReady: TBLLServerProxy)  // ��ȡģ������ӷ����ģ��
        begin
          ABLLServerReady.Cmd := BLL_DELETETEMPLATE;  // �½�ģ��
          ABLLServerReady.ExecParam.I['tid'] := vTempID;
        end,
        procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
        begin
          if ABLLServer.MethodRunOk then  // ɾ���ɹ�
          begin
            tvTemplate.Items.Delete(tvTemplate.Selected);  // ɾ���ڵ�
            vTempID := GetRecordEditPageIndex(vTempID);
            if vTempID >= 0 then
              CloseRecordEditPage(vTempID, False);
          end
          else
            ShowMessage(ABLLServer.MethodError);
        end);
    end;
  end;
end;

procedure TfrmTemplate.mniInsertClick(Sender: TObject);
var
  vNode: TTreeNode;
  vFrmRecord: TfrmRecord;
  vSM: TMemoryStream;
  vEmrView: TEmrView;
  vGroupClass: Integer;
begin
  if TreeNodeIsTemplate(tvTemplate.Selected) then
  begin
    vFrmRecord := GetActiveRecord;

    if Assigned(vFrmRecord) then
    begin
      vNode := tvTemplate.Selected;

      vSM := TMemoryStream.Create;
      try
        GetTemplateContent(TTemplateInfo(vNode.Data).ID, vSM);

        while vNode.Parent <> nil do
          vNode := vNode.Parent;

        vGroupClass := TDataSetInfo(vNode.Data).GroupClass;
        case vGroupClass of
          TDataSetInfo.CLASS_DATA:  // ����
            begin
              vSM.Position := 0;
              vFrmRecord.EmrView.InsertStream(vSM);
            end;

          TDataSetInfo.CLASS_HEADER,  // ҳü��ҳ��
          TDataSetInfo.CLASS_FOOTER:
            begin
              vEmrView := TEmrView.Create(nil);
              try
                vEmrView.LoadFromStream(vSM);
                vSM.Clear;
                vEmrView.Sections[0].Header.SaveToStream(vSM);
                vSM.Position := 0;
                if vGroupClass = TDataSetInfo.CLASS_HEADER then
                  vFrmRecord.EmrView.ActiveSection.Header.LoadFromStream(vSM, vEmrView.Style, HC_FileVersionInt)
                else
                  vFrmRecord.EmrView.ActiveSection.Footer.LoadFromStream(vSM, vEmrView.Style, HC_FileVersionInt);

                vFrmRecord.EmrView.IsChanged := True;
                vFrmRecord.EmrView.UpdateView;
              finally
                FreeAndNil(vEmrView);
              end;
            end;
        end;
      finally
        FreeAndNil(vSM);
      end;
    end;
  end;
end;

procedure TfrmTemplate.mniRefreshClick(Sender: TObject);
begin
  HintFormShow('����ˢ������Ԫ...', procedure(const AUpdateHint: TUpdateHint)
  var
    vTopRow, vRow: Integer;
  begin
    SaveStringGridRow(vRow, vTopRow, sgdDE);
    ShowAllDataElement;  // ˢ������Ԫ��Ϣ
    RestoreStringGridRow(vRow, vTopRow, sgdDE);
  end);
end;

procedure TfrmTemplate.mniN1Click(Sender: TObject);
begin
  CloseRecordEditPage(pgRecordEdit.ActivePageIndex);
end;

procedure TfrmTemplate.mniN2Click(Sender: TObject);
var
  vFrmTemplateInfo: TfrmTemplateInfo;
begin
  if TreeNodeIsTemplate(tvTemplate.Selected) then
  begin
    vFrmTemplateInfo := TfrmTemplateInfo.Create(nil);
    try
      vFrmTemplateInfo.TempID := TTemplateInfo(tvTemplate.Selected.Data).ID;
      vFrmTemplateInfo.ShowModal;

      TTemplateInfo(tvTemplate.Selected.Data).NameEx := vFrmTemplateInfo.TempName;
      tvTemplate.Selected.Text := vFrmTemplateInfo.TempName;
    finally
      FreeAndNil(vFrmTemplateInfo);
    end;
  end;
end;

procedure TfrmTemplate.mniN3Click(Sender: TObject);
var
  vFrmDomain: TfrmDomain;
begin
  vFrmDomain := TfrmDomain.Create(nil);
  try
    vFrmDomain.ShowModal;
  finally
    FreeAndNil(vFrmDomain);
  end;
end;

procedure TfrmTemplate.mniInsertAsDGClick(Sender: TObject);
var
  vDeGroup: TDeGroup;
  vFrmRecord: TfrmRecord;
begin
  if sgdDE.Row < 0 then Exit;

  vFrmRecord := GetActiveRecord;

  if Assigned(vFrmRecord) then
  begin
    vDeGroup := TDeGroup.Create(vFrmRecord.EmrView.ActiveSectionTopLevelData);  // ֻΪ��¼����
    try
      vDeGroup[TDeProp.Index] := sgdDE.Cells[0, sgdDE.Row];

      if not vFrmRecord.EmrView.Focused then  // �ȸ����㣬���ڴ����괦��
        vFrmRecord.EmrView.SetFocus;

      vFrmRecord.EmrView.InsertDeGroup(vDeGroup);
    finally
      vDeGroup.Free;
    end;
  end
  else
    ShowMessage('δ���ִ򿪵�ģ�壡');
end;

procedure TfrmTemplate.mniEditItemLinkClick(Sender: TObject);
var
  vFrmItemContent: TfrmItemContent;
begin
  if sgdCV.Row < 1 then Exit;
  if sgdCV.Cells[3, sgdCV.Row] = '' then Exit;

  vFrmItemContent := TfrmItemContent.Create(nil);
  try
    vFrmItemContent.DomainItemID := StrToInt(sgdCV.Cells[3, sgdCV.Row]);
    vFrmItemContent.ShowModal;
  finally
    FreeAndNil(vFrmItemContent);
  end;
end;

procedure TfrmTemplate.mniEditClick(Sender: TObject);
var
  vFrmDeList: TfrmDeInfo;
begin
  if sgdDE.Row > 0 then
  begin
    vFrmDeList := TfrmDeInfo.Create(nil);
    try
      vFrmDeList.DeID := StrToInt(sgdDE.Cells[0, sgdDE.Row]);
      vFrmDeList.ShowModal;
      if vFrmDeList.ModalResult = mrOk then
        mniRefreshClick(Sender);
    finally
      FreeAndNil(vFrmDeList);
    end;
  end;
end;

procedure TfrmTemplate.mniEditItemClick(Sender: TObject);
var
  vFrmDomainItem: TfrmDomainItem;
begin
  if (sgdCV.Row > 0) and (FDomainID > 0) then
  begin
    vFrmDomainItem := TfrmDomainItem.Create(nil);
    try
      vFrmDomainItem.DomainID := FDomainID;
      vFrmDomainItem.ItemID := StrToInt(sgdCV.Cells[3, sgdCV.Row]);
      vFrmDomainItem.ShowModal;
      if vFrmDomainItem.ModalResult = mrOk then
        GetDomainItem(FDomainID);
    finally
      FreeAndNil(vFrmDomainItem);
    end;
  end;
end;

procedure TfrmTemplate.mniNewClick(Sender: TObject);
var
  vFrmDeList: TfrmDeInfo;
begin
  vFrmDeList := TfrmDeInfo.Create(nil);
  try
    vFrmDeList.DeID := 0;
    vFrmDeList.ShowModal;
    if vFrmDeList.ModalResult = mrOk then
      mniRefreshClick(Sender);
  finally
    FreeAndNil(vFrmDeList);
  end;
end;

procedure TfrmTemplate.mniNewItemClick(Sender: TObject);
var
  vFrmDomainItem: TfrmDomainItem;
begin
  if FDomainID > 0 then
  begin
    vFrmDomainItem := TfrmDomainItem.Create(nil);
    try
      vFrmDomainItem.DomainID := FDomainID;
      vFrmDomainItem.ItemID := 0;
      vFrmDomainItem.ShowModal;
      if vFrmDomainItem.ModalResult = mrOk then
        GetDomainItem(FDomainID);
    finally
      FreeAndNil(vFrmDomainItem);
    end;
  end;
end;

procedure TfrmTemplate.mniInsertAsComboboxClick(Sender: TObject);
var
  vDeCombobox: TDeCombobox;
  vFrmRecord: TfrmRecord;
begin
  if sgdDE.Row < 0 then Exit;

  vFrmRecord := GetActiveRecord;

  if Assigned(vFrmRecord) then
  begin
    vDeCombobox := TDeCombobox.Create(vFrmRecord.EmrView.ActiveSectionTopLevelData,
      sgdDE.Cells[1, sgdDE.Row]);
    vDeCombobox.SaveItem := False;
    vDeCombobox[TDeProp.Index] := sgdDE.Cells[0, sgdDE.Row];

    if not vFrmRecord.EmrView.Focused then  // �ȸ����㣬���ڴ����괦��
      vFrmRecord.EmrView.SetFocus;

    vFrmRecord.EmrView.InsertItem(vDeCombobox);
  end
  else
    ShowMessage('δ���ִ򿪵�ģ�壡');
end;

procedure TfrmTemplate.mniDeleteClick(Sender: TObject);
begin
  if sgdDE.Row >= 0 then
  begin
    if MessageDlg('ȷ��Ҫɾ������Ԫ��' + sgdDE.Cells[1, sgdDE.Row] + '����',
      mtWarning, [mbYes, mbNo], 0) = mrYes
    then
    begin
      if StrToInt(sgdDE.Cells[5, sgdDE.Row]) <> 0 then
      begin
      if MessageDlg('���' + sgdDE.Cells[1, sgdDE.Row] + '��Ӧ��ֵ��' + sgdDE.Cells[5, sgdDE.Row] + '������ʹ�ã���ע�⼰ʱɾ����',
        mtWarning, [mbYes, mbNo], 0) <> mrYes
      then
        Exit;
      end;

      BLLServerExec(
        procedure(const ABLLServerReady: TBLLServerProxy)
        begin
          ABLLServerReady.Cmd := BLL_DELETEDE;  // ɾ������Ԫ
          ABLLServerReady.ExecParam.I['DeID'] := StrToInt(sgdDE.Cells[0, sgdDE.Row]);
        end,
        procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
        begin
          if not ABLLServer.MethodRunOk then
            ShowMessage(ABLLServer.MethodError)
          else
          begin
            ShowMessage('ɾ���ɹ���');

            mniRefreshClick(Sender);
          end;
        end);
    end;
  end;
end;

procedure TfrmTemplate.mniDeleteItemClick(Sender: TObject);
var
  vDeleteOk: Boolean;
begin
  if sgdCV.Row >= 0 then
  begin
    if MessageDlg('ȷ��Ҫɾ��ѡ�' + sgdCV.Cells[0, sgdCV.Row] + '�����������������',
      mtWarning, [mbYes, mbNo], 0) = mrYes
    then
    begin
      vDeleteOk := True;

      // ɾ������
      vDeleteOk := DeleteDomainItemContent(StrToInt(sgdCV.Cells[3, sgdCV.Row]));
      if vDeleteOk then
        ShowMessage('ɾ��ѡ��������ݳɹ���')
      else
        ShowMessage(CommonLastError);

      if not vDeleteOk then Exit;

      // ɾ��ѡ��
      vDeleteOk := DeleteDomainItem(StrToInt(sgdCV.Cells[3, sgdCV.Row]));
      if vDeleteOk then
      begin
        ShowMessage('ɾ��ѡ��ɹ���');
        GetDomainItem(FDomainID);
      end
      else
        ShowMessage(CommonLastError);
    end;
  end;
end;

procedure TfrmTemplate.mniDeleteItemLinkClick(Sender: TObject);
begin
  if sgdCV.Row >= 0 then
  begin
    if MessageDlg('ȷ��Ҫɾ��ѡ�' + sgdCV.Cells[0, sgdCV.Row] + '��������������',
      mtWarning, [mbYes, mbNo], 0) = mrYes
    then
    begin
      if DeleteDomainItemContent(StrToInt(sgdCV.Cells[3, sgdCV.Row])) then
        ShowMessage('ɾ��ֵ��ѡ��������ݳɹ���')
      else
        ShowMessage(CommonLastError);
    end;
  end;
end;

procedure TfrmTemplate.mniInsertAsDEClick(Sender: TObject);
var
  vFrmRecord: TfrmRecord;
begin
  if sgdDE.Row < 0 then Exit;
  vFrmRecord := GetActiveRecord;
  if Assigned(vFrmRecord) then
  begin
    if not vFrmRecord.EmrView.Focused then  // �ȸ����㣬���ڴ����괦��
      vFrmRecord.EmrView.SetFocus;

    vFrmRecord.InsertDataElementAsDE(sgdDE.Cells[0, sgdDE.Row], sgdDE.Cells[1, sgdDE.Row]);
  end
  else
    ShowMessage('δ���ִ򿪵�ģ�壡');
end;

procedure TfrmTemplate.mniViewItemClick(Sender: TObject);
begin
  if sgdDE.Row > 0 then
  begin
    if sgdDE.Cells[5, sgdDE.Row] <> '' then
      FDomainID := StrToInt(sgdDE.Cells[5, sgdDE.Row])
    else
      FDomainID := 0;

    lblDE.Caption := sgdDE.Cells[1, sgdDE.Row];

    GetDomainItem(FDomainID);
  end;
end;

procedure TfrmTemplate.mniNewTempClick(Sender: TObject);
var
  vTName: string;
begin
  vTName := InputBox('�½�', 'ģ������', '');
  if vTName.Trim = '' then Exit;

  // �˵�����ʾʱ�Ѿ�ȷ��ѡ������ڵ�����
  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)  // ��ȡģ������ӷ����ģ��
    begin
      ABLLServerReady.Cmd := BLL_NEWTEMPLATE;  // �½�ģ��

      if TreeNodeIsTemplate(tvTemplate.Selected) then
        ABLLServerReady.ExecParam.I['desid'] := TTemplateInfo(tvTemplate.Selected.Data).DesID
      else
        ABLLServerReady.ExecParam.I['desid'] := TDataSetInfo(tvTemplate.Selected.Data).ID;
      ABLLServerReady.ExecParam.I['owner'] := 1;
      ABLLServerReady.ExecParam.I['ownerid'] := 0;
      ABLLServerReady.ExecParam.ForcePathObject('tname').AsString := vTName;
      //
      ABLLServerReady.AddBackField('tempid');
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    var
      vTempInfo: TTemplateInfo;
    begin
      if ABLLServer.MethodRunOk then  // �½�ģ��ִ�гɹ�
      begin
        vTempInfo := TTemplateInfo.Create;
        vTempInfo.ID := ABLLServer.BackField('tempid').AsInteger;
        vTempInfo.Owner := 1;
        vTempInfo.OwnerID := 0;
        vTempInfo.NameEx := vTName;
        tvTemplate.Selected := tvTemplate.Items.AddChildObject(tvTemplate.Selected, vTempInfo.NameEx, vTempInfo);
      end
      else
        ShowMessage(ABLLServer.MethodError);
    end);
end;

procedure TfrmTemplate.pgRecordEditMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  vTabIndex: Integer;
  vPt: TPoint;
begin
  if (Y < 20) and (Button = TMouseButton.mbRight) then  // Ĭ�ϵ� pgRecordEdit.TabHeight ��ͨ����ȡ����ϵͳ�����õ�����ȷ��
  begin
    vTabIndex := pgRecordEdit.IndexOfTabAt(X, Y);

    if pgRecordEdit.Pages[vTabIndex].Tag = 0 then Exit; // ����

    if (vTabIndex >= 0) and (vTabIndex = pgRecordEdit.ActivePageIndex) then
    begin
      vPt := pgRecordEdit.ClientToScreen(Point(X, Y));
      pmpg.Popup(vPt.X, vPt.Y);
    end;
  end;
end;

procedure TfrmTemplate.pmdePopup(Sender: TObject);
begin
  mniViewItem.Enabled := (sgdDE.Row > 0)
    and ((sgdDE.Cells[4, sgdDE.Row] = TDeFrmtp.Radio)
         or (sgdDE.Cells[4, sgdDE.Row] = TDeFrmtp.Multiselect));
  mniEdit.Enabled := sgdDE.Row > 0;
  mniDelete.Enabled := sgdDE.Row > 0;
  mniInsertAsDE.Enabled := sgdDE.Row > 0;
  mniInsertAsDG.Enabled := sgdDE.Row > 0;
end;

procedure TfrmTemplate.pmMPopup(Sender: TObject);
begin
  mniNewItem.Enabled := FDomainID > 0;
  mniEditItem.Visible := sgdCV.Row > 0;
  mniDeleteItem.Visible := sgdCV.Row > 0;
  mniEditItemLink.Visible := sgdCV.Row > 0;
  mniDeleteItemLink.Visible := sgdCV.Row > 0;
end;

procedure TfrmTemplate.pmPopup(Sender: TObject);
begin
  mniNewTemp.Enabled := not TreeNodeIsTemplate(tvTemplate.Selected);
  mniDeleteTemp.Enabled := not mniNewTemp.Enabled;
  mniInsert.Enabled := not mniNewTemp.Enabled;
end;

procedure TfrmTemplate.sgdDEDblClick(Sender: TObject);
begin
  mniInsertAsDEClick(Sender);
end;

procedure TfrmTemplate.tvTemplateCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if (not TreeNodeIsTemplate(Node)) and (TDataSetInfo(Node.Data).ID = 74) then  // ������
  begin
    tvTemplate.Canvas.Font.Style := [fsBold];
    tvTemplate.Canvas.Font.Color := clRed;
  end;
end;

procedure TfrmTemplate.tvTemplateDblClick(Sender: TObject);
var
  vPageIndex, vTempID: Integer;
  vPage: TTabSheet;
  vFrmRecord: TfrmRecord;
  vSM: TMemoryStream;
begin
  if TreeNodeIsTemplate(tvTemplate.Selected) then
  begin
    vTempID := TTemplateInfo(tvTemplate.Selected.Data).ID;
    vPageIndex := GetRecordEditPageIndex(vTempID);
    if vPageIndex >= 0 then
    begin
      pgRecordEdit.ActivePageIndex := vPageIndex;
      Exit;
    end;

    vSM := TMemoryStream.Create;
    try
      GetTemplateContent(vTempID, vSM);

      vFrmRecord := TfrmRecord.Create(nil);  // �����༭��
      vFrmRecord.ObjectData := tvTemplate.Selected.Data;
      if vSM.Size > 0 then
        vFrmRecord.EmrView.LoadFromStream(vSM);
    finally
      vSM.Free;
    end;

    if vFrmRecord <> nil then
    begin
      vPage := TTabSheet.Create(pgRecordEdit);
      vPage.Caption := tvTemplate.Selected.Text;
      vPage.Tag := vTempID;
      vPage.PageControl := pgRecordEdit;

      vFrmRecord.OnSave := DoSaveTempContent;
      vFrmRecord.OnChangedSwitch := DoRecordChangedSwitch;
      vFrmRecord.Parent := vPage;
      vFrmRecord.Align := alClient;
      vFrmRecord.Show;

      pgRecordEdit.ActivePage := vPage;

      vFrmRecord.EmrView.SetFocus;
    end;
  end;
end;

procedure TfrmTemplate.tvTemplateExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
  if Node.Count = 0 then
  begin
    BLLServerExec(
      procedure(const ABLLServerReady: TBLLServerProxy)
      begin
        ABLLServerReady.Cmd := BLL_GETTEMPLATELIST;  // ��ȡģ������ӷ����ģ��
        ABLLServerReady.ExecParam.I['desID'] := TDataSetInfo(Node.Data).ID;
        ABLLServerReady.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
      end,
      procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
      var
        vTempInfo: TTemplateInfo;
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
            if AMemTable.RecordCount > 0 then
            begin
              with AMemTable do
              begin
                First;
                while not Eof do
                begin
                  vTempInfo := TTemplateInfo.Create;
                  vTempInfo.ID := FieldByName('id').AsInteger;
                  vTempInfo.DesID := FieldByName('desid').AsInteger;
                  vTempInfo.Owner := FieldByName('Owner').AsInteger;
                  vTempInfo.OwnerID := FieldByName('OwnerID').AsInteger;
                  vTempInfo.NameEx := FieldByName('tname').AsString;
                  tvTemplate.Items.AddChildObject(Node, vTempInfo.NameEx, vTempInfo);

                  Next;
                end;
              end;
            end
            else
              Node.HasChildren := False;
          finally
            tvTemplate.Items.EndUpdate;
          end;
        end;
      end);
  end;
end;

end.
