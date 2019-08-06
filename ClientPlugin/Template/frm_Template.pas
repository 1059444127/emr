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
    pgTemplate: TPageControl;
    tsHelp: TTabSheet;
    tvTemplate: TTreeView;
    il: TImageList;
    pmTemplate: TPopupMenu;
    mniNewTemplate: TMenuItem;
    mniDeleteTemplate: TMenuItem;
    pmpg: TPopupMenu;
    mniCloseTemplate: TMenuItem;
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
    mniInsertTemplate: TMenuItem;
    pmCV: TPopupMenu;
    mniEditItemLink: TMenuItem;
    mniDeleteItemLink: TMenuItem;
    pnl3: TPanel;
    lblDE: TLabel;
    mniN5: TMenuItem;
    mniInsertAsDE: TMenuItem;
    mniTemplateProperty: TMenuItem;
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
    mniDomain: TMenuItem;
    mniInsertAsEdit: TMenuItem;
    mniInsertAsCombobox: TMenuItem;
    mniN4: TMenuItem;
    mniCloseAll: TMenuItem;
    mniInsertAsDateTime: TMenuItem;
    mniInsertAsRadioGroup: TMenuItem;
    mniInsertAsCheckBox: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tvTemplateDblClick(Sender: TObject);
    procedure tvTemplateExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure mniNewTemplateClick(Sender: TObject);
    procedure pmTemplatePopup(Sender: TObject);
    procedure mniDeleteTemplateClick(Sender: TObject);
    procedure pgTemplateMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mniCloseTemplateClick(Sender: TObject);
    procedure sgdDEDblClick(Sender: TObject);
    procedure mniInsertAsDGClick(Sender: TObject);
    procedure mniViewItemClick(Sender: TObject);
    procedure pmdePopup(Sender: TObject);
    procedure mniInsertTemplateClick(Sender: TObject);
    procedure mniEditItemLinkClick(Sender: TObject);
    procedure mniInsertAsDEClick(Sender: TObject);
    procedure edtPYKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mniTemplatePropertyClick(Sender: TObject);
    procedure tvTemplateCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure mniEditClick(Sender: TObject);
    procedure mniNewClick(Sender: TObject);
    procedure mniDeleteClick(Sender: TObject);
    procedure mniNewItemClick(Sender: TObject);
    procedure mniEditItemClick(Sender: TObject);
    procedure pmCVPopup(Sender: TObject);
    procedure mniDeleteItemClick(Sender: TObject);
    procedure mniDomainClick(Sender: TObject);
    procedure mniDeleteItemLinkClick(Sender: TObject);
    procedure mniInsertAsComboboxClick(Sender: TObject);
    procedure mniCloseAllClick(Sender: TObject);
    procedure lblDeHintClick(Sender: TObject);
    procedure lblDEClick(Sender: TObject);
    procedure mniRefreshClick(Sender: TObject);
    procedure mniInsertAsDateTimeClick(Sender: TObject);
    procedure mniInsertAsRadioGroupClick(Sender: TObject);
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
    procedure CloseTemplatePage(const APageIndex: Integer;
      const ASaveChange: Boolean = True);
    procedure DoSaveTempContent(Sender: TObject);
    procedure DoRecordChangedSwitch(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
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
  Vcl.Clipbrd, PluginConst, FunctionConst, emr_BLLServerProxy, emr_MsgPack,
  emr_Entry, HCEmrElementItem, HCEmrGroupItem, HCCommon, TemplateCommon, CFBalloonHint,
  HCEmrView, frm_ItemContent, frm_TemplateInfo, frm_DeInfo, frm_DomainItem, frm_Domain;

{$R *.dfm}

procedure PluginShowTemplateForm(AIFun: IFunBLLFormShow);
begin
  if not Assigned(frmTemplate) then
    Application.CreateForm(TfrmTemplate, frmTemplate);

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

procedure TfrmTemplate.CloseTemplatePage(const APageIndex: Integer;
  const ASaveChange: Boolean = True);
var
  i: Integer;
  vPage: TTabSheet;
  vFrmRecord: TfrmRecord;
begin
  if APageIndex >= 0 then
  begin
    vPage := pgTemplate.Pages[APageIndex];

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
      pgTemplate.ActivePageIndex := APageIndex - 1;
  end;
end;

procedure TfrmTemplate.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  //Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
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
        ABLLServerReady.ExecParam.I['tid'] := vTempID;
        ABLLServerReady.ExecParam.ForcePathObject('content').LoadBinaryFromStream(vSM);
      end,
      procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
      begin
        if ABLLServer.MethodRunOk then  // ����˷�������ִ�гɹ�
        begin
          (Sender as TfrmRecord).EmrView.IsChanged := False;  // ������ĵ���ʶΪ���޸�
          ShowMessage('����ɹ���');
        end
        else
          ShowMessage(ABLLServer.MethodError);
      end);
  finally
    FreeAndNil(vSM);
  end;
end;

procedure TfrmTemplate.edtPYKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
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
  FOnFunctionNotify(PluginID, FUN_MAINFORMSHOW, nil);  // ��ʾ������
  FOnFunctionNotify(PluginID, FUN_BLLFORMDESTROY, nil);  // �ͷ�ҵ������Դ
end;

procedure TfrmTemplate.FormCreate(Sender: TObject);
begin
  FDomainID := 0;
  PluginID := PLUGIN_TEMPLATE;
  //SetWindowLong(Handle, GWL_EXSTYLE, (GetWindowLong(handle, GWL_EXSTYLE) or WS_EX_APPWINDOW));
end;

procedure TfrmTemplate.FormDestroy(Sender: TObject);
var
  i, j: Integer;
begin
  ClearTemplateDeSet;

  for i := 0 to pgTemplate.PageCount - 1 do
  begin
    for j := 0 to pgTemplate.Pages[i].ControlCount - 1 do
    begin
      if pgTemplate.Pages[i].Controls[j] is TfrmRecord then
      begin
        pgTemplate.Pages[i].Controls[j].Free;
        Break;
      end;
    end;
  end;
end;

procedure TfrmTemplate.FormShow(Sender: TObject);
var
  vObjFun: IObjectFunction;
begin
  sgdDE.RowCount := 1;
  sgdDE.Cells[0, 0] := '��';
  sgdDE.Cells[1, 0] := '����';
  sgdDE.Cells[2, 0] := '����';
  sgdDE.Cells[3, 0] := 'ƴ��';
  sgdDE.Cells[4, 0] := '����';
  sgdDE.Cells[5, 0] := 'ֵ��';

  sgdCV.RowCount := 1;
//  sgdCV.ColWidths[0] := 120;
//  sgdCV.ColWidths[1] := 40;
//  sgdCV.ColWidths[2] := 25;
//  sgdCV.ColWidths[3] := 35;
//  sgdCV.ColWidths[4] := 35;
  sgdCV.Cells[0, 0] := 'ֵ';
  sgdCV.Cells[1, 0] := '����';
  sgdCV.Cells[2, 0] := 'ƴ��';
  sgdCV.Cells[3, 0] := 'id';
  sgdCV.Cells[4, 0] := '��չ';

  // ��ȡ�ͻ��������
  vObjFun := TObjectFunction.Create;
  FOnFunctionNotify(PluginID, FUN_CLIENTCACHE, vObjFun);
  ClientCache := TClientCache(vObjFun.&Object);

  // ��ǰ��¼�û�ID
  FOnFunctionNotify(PluginID, FUN_USERINFO, vObjFun);  // ��ȡ�������¼�û���
  FUserInfo := TUserInfo(vObjFun.&Object);
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

  vPage := pgTemplate.ActivePage;
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
                if FieldByName('content').DataType = ftBlob then
                begin
                  if (FieldByName('content') as TBlobField).BlobSize > 0 then
                    sgdCV.Cells[4, i] := '...'
                  else
                    sgdCV.Cells[4, i] := '';
                end
                else
                  sgdCV.Cells[4, i] := '';

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
  for i := 0 to pgTemplate.PageCount - 1 do
  begin
    if pgTemplate.Pages[i].Tag = ATempID then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TfrmTemplate.lblDEClick(Sender: TObject);
begin
  mniViewItemClick(Sender);
end;

procedure TfrmTemplate.lblDeHintClick(Sender: TObject);
begin
  mniRefreshClick(Sender);
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
              vNode.ImageIndex := -1;
              vNode.SelectedIndex := -1;

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
  vRow := 1;
  sgdDE.RowCount := ClientCache.DataElementDT.RecordCount + 1;
  with ClientCache.DataElementDT do
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

  if sgdDE.RowCount > 1 then
    sgdDE.FixedRows := 1;
end;

procedure TfrmTemplate.mniDeleteTemplateClick(Sender: TObject);
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
          ABLLServerReady.Cmd := BLL_DELETETEMPLATE;  // ɾ��ģ��
          ABLLServerReady.ExecParam.I['tid'] := vTempID;
        end,
        procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
        begin
          if ABLLServer.MethodRunOk then  // ɾ���ɹ�
          begin
            tvTemplate.Items.Delete(tvTemplate.Selected);  // ɾ���ڵ�
            vTempID := GetRecordEditPageIndex(vTempID);
            if vTempID >= 0 then
              CloseTemplatePage(vTempID, False);
          end
          else
            ShowMessage(ABLLServer.MethodError);
        end);
    end;
  end;
end;

procedure TfrmTemplate.mniInsertTemplateClick(Sender: TObject);
var
  vNode: TTreeNode;
  vFrmRecord: TfrmRecord;
  vSM: TMemoryStream;
  vEmrView: THCEmrView;
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
          TDataSetInfo.CLASS_PAGE:  // ����
            begin
              vSM.Position := 0;
              vFrmRecord.EmrView.InsertStream(vSM);
            end;

          TDataSetInfo.CLASS_HEADER,  // ҳü��ҳ��
          TDataSetInfo.CLASS_FOOTER:
            begin
              vEmrView := THCEmrView.Create(nil);
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

procedure TfrmTemplate.mniCloseTemplateClick(Sender: TObject);
begin
  CloseTemplatePage(pgTemplate.ActivePageIndex);
end;

procedure TfrmTemplate.mniTemplatePropertyClick(Sender: TObject);
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

procedure TfrmTemplate.mniDomainClick(Sender: TObject);
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

procedure TfrmTemplate.mniCloseAllClick(Sender: TObject);
begin
  while pgTemplate.PageCount > 1 do
    CloseTemplatePage(pgTemplate.PageCount - 1);
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
      vDeGroup[TDeProp.Name] := sgdDE.Cells[1, sgdDE.Row];

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

procedure TfrmTemplate.mniInsertAsRadioGroupClick(Sender: TObject);
var
  vRadioGroup: TDeRadioGroup;
  vFrmRecord: TfrmRecord;
begin
  if sgdDE.Row < 0 then Exit;

  vFrmRecord := GetActiveRecord;

  if Assigned(vFrmRecord) then
  begin
    vRadioGroup := TDeRadioGroup.Create(vFrmRecord.EmrView.ActiveSectionTopLevelData);
    vRadioGroup[TDeProp.Index] := sgdDE.Cells[0, sgdDE.Row];
    // ȡ����Ԫ��ѡ�ѡ��̫��ʱ��ʾ�Ƿ񶼲���
    vRadioGroup.AddItem('ѡ��1');
    vRadioGroup.AddItem('ѡ��2');
    vRadioGroup.AddItem('ѡ��3');

    if not vFrmRecord.EmrView.Focused then  // �ȸ����㣬���ڴ����괦��
      vFrmRecord.EmrView.SetFocus;

    vFrmRecord.EmrView.InsertItem(vRadioGroup);
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
  vFrmDeInfo: TfrmDeInfo;
begin
  if sgdDE.Row > 0 then
  begin
    vFrmDeInfo := TfrmDeInfo.Create(nil);
    try
      vFrmDeInfo.DeID := StrToInt(sgdDE.Cells[0, sgdDE.Row]);
      vFrmDeInfo.ShowModal;
      if vFrmDeInfo.ModalResult = mrOk then
        mniRefreshClick(Sender);
    finally
      FreeAndNil(vFrmDeInfo);
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
  vFrmDeInfo: TfrmDeInfo;
begin
  vFrmDeInfo := TfrmDeInfo.Create(nil);
  try
    vFrmDeInfo.DeID := 0;
    vFrmDeInfo.ShowModal;
    if vFrmDeInfo.ModalResult = mrOk then
      mniRefreshClick(Sender);
  finally
    FreeAndNil(vFrmDeInfo);
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
        if MessageDlg('���' + sgdDE.Cells[1, sgdDE.Row] + '��Ӧ��ֵ��' + sgdDE.Cells[5, sgdDE.Row] + '������ʹ�ã���ע�⼰ʱɾ��������ɾ������Ԫ��',
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
    if MessageDlg('ȷ��Ҫɾ��ѡ�' + sgdCV.Cells[0, sgdCV.Row] + '���͸�ѡ���Ӧ����չ������',
      mtWarning, [mbYes, mbNo], 0) = mrYes
    then
    begin
      vDeleteOk := True;

      // ɾ����չ����
      vDeleteOk := DeleteDomainItemContent(StrToInt(sgdCV.Cells[3, sgdCV.Row]));
      if vDeleteOk then
        ShowMessage('ɾ��ѡ����չ���ݳɹ���')
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
    if MessageDlg('ȷ��Ҫɾ��ѡ�' + sgdCV.Cells[0, sgdCV.Row] + '������չ������',
      mtWarning, [mbYes, mbNo], 0) = mrYes
    then
    begin
      if DeleteDomainItemContent(StrToInt(sgdCV.Cells[3, sgdCV.Row])) then
        ShowMessage('ɾ��ֵ��ѡ����չ���ݳɹ���')
      else
        ShowMessage(CommonLastError);
    end;
  end;
end;

procedure TfrmTemplate.mniInsertAsDateTimeClick(Sender: TObject);
var
  vDateTime: TDeDateTimePicker;
  vFrmRecord: TfrmRecord;
begin
  if sgdDE.Row < 0 then Exit;

  vFrmRecord := GetActiveRecord;

  if Assigned(vFrmRecord) then
  begin
    vDateTime := TDeDateTimePicker.Create(vFrmRecord.EmrView.ActiveSectionTopLevelData, Now);
    vDateTime[TDeProp.Index] := sgdDE.Cells[0, sgdDE.Row];

    if not vFrmRecord.EmrView.Focused then  // �ȸ����㣬���ڴ����괦��
      vFrmRecord.EmrView.SetFocus;

    vFrmRecord.EmrView.InsertItem(vDateTime);
  end
  else
    ShowMessage('δ���ִ򿪵�ģ�壡');
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

    vFrmRecord.InsertDeItem(sgdDE.Cells[0, sgdDE.Row], sgdDE.Cells[1, sgdDE.Row]);
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

    GetDomainItem(FDomainID);
    lblDE.Caption := sgdDE.Cells[1, sgdDE.Row] + '(�� ' + IntToStr(sgdCV.RowCount - 1) + ' ��ѡ��)';
  end;
end;

procedure TfrmTemplate.mniNewTemplateClick(Sender: TObject);
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

procedure TfrmTemplate.mniRefreshClick(Sender: TObject);
begin
  HintFormShow('����ˢ������Ԫ...', procedure(const AUpdateHint: TUpdateHint)
  var
    vTopRow, vRow: Integer;
  begin
    FOnFunctionNotify(PluginID, FUN_REFRESHCLIENTCACHE, nil);  // ���»�ȡ�ͻ��˻���
    SaveStringGridRow(vRow, vTopRow, sgdDE);
    ShowAllDataElement;  // ˢ������Ԫ��Ϣ
    RestoreStringGridRow(vRow, vTopRow, sgdDE);
  end);
end;

procedure TfrmTemplate.pgTemplateMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  vTabIndex: Integer;
  vPt: TPoint;
begin
  if Y < 20 then  // Ĭ�ϵ� pgRecordEdit.TabHeight ��ͨ����ȡ����ϵͳ�����õ�����ȷ��
  begin
    vTabIndex := pgTemplate.IndexOfTabAt(X, Y);

    if pgTemplate.Pages[vTabIndex].Tag = 0 then Exit; // ����

    if (vTabIndex >= 0) and (vTabIndex = pgTemplate.ActivePageIndex) then
    begin
      if Button = TMouseButton.mbRight then
      begin
        vPt := pgTemplate.ClientToScreen(Point(X, Y));
        pmpg.Popup(vPt.X, vPt.Y);
      end
      else
      if ssDouble in Shift then
        CloseTemplatePage(pgTemplate.ActivePageIndex);
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

procedure TfrmTemplate.pmCVPopup(Sender: TObject);
begin
  mniNewItem.Enabled := FDomainID > 0;
  mniEditItem.Visible := sgdCV.Row > 0;
  mniDeleteItem.Visible := sgdCV.Row > 0;
  mniEditItemLink.Visible := sgdCV.Row > 0;
  mniDeleteItemLink.Visible := sgdCV.Row > 0;
end;

procedure TfrmTemplate.pmTemplatePopup(Sender: TObject);
begin
  mniNewTemplate.Enabled := not TreeNodeIsTemplate(tvTemplate.Selected);
  mniDeleteTemplate.Enabled := not mniNewTemplate.Enabled;
  mniInsertTemplate.Enabled := not mniNewTemplate.Enabled;
end;

procedure TfrmTemplate.sgdDEDblClick(Sender: TObject);
begin
  mniInsertAsDEClick(Sender);
end;

procedure TfrmTemplate.tvTemplateCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
//var
//  vRect: TRect;
begin
  //DefaultDraw := False;
  if (not TreeNodeIsTemplate(Node)) and (TDataSetInfo(Node.Data).ID = 74) then  // ������
  begin
    tvTemplate.Canvas.Font.Style := [fsBold];
    tvTemplate.Canvas.Font.Color := clRed;
  end;

//  vRect := Node.DisplayRect(False);
//  tvTemplate.Canvas.TextOut(vRect.Left + (Node.Level + 1) * 16, vRect.Top, Node.Text);
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
      pgTemplate.ActivePageIndex := vPageIndex;
      Exit;
    end;

    vSM := TMemoryStream.Create;
    try
      GetTemplateContent(vTempID, vSM);

      vFrmRecord := TfrmRecord.Create(nil);  // �����༭��
      vFrmRecord.EmrView.DesignMode := True;  // ���ģʽ
      vFrmRecord.ObjectData := tvTemplate.Selected.Data;
      if vSM.Size > 0 then
        vFrmRecord.EmrView.LoadFromStream(vSM);
    finally
      vSM.Free;
    end;

    if vFrmRecord <> nil then
    begin
      vPage := TTabSheet.Create(pgTemplate);
      vPage.Caption := tvTemplate.Selected.Text;
      vPage.Tag := vTempID;
      vPage.PageControl := pgTemplate;

      vFrmRecord.OnSave := DoSaveTempContent;
      vFrmRecord.OnChangedSwitch := DoRecordChangedSwitch;
      vFrmRecord.Parent := vPage;
      vFrmRecord.Align := alClient;
      vFrmRecord.Show;

      pgTemplate.ActivePage := vPage;

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
        vTpltNode: TTreeNode;
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
                  vTpltNode := tvTemplate.Items.AddChildObject(Node, vTempInfo.NameEx, vTempInfo);
                  vTpltNode.ImageIndex := 0;

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
