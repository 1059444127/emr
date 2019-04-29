{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit EmrGridView;

interface

uses
  Windows, Classes, Controls, Vcl.Graphics, HCGridView, HCStyle, HCItem, HCTextItem,
  HCDrawItem, HCCustomData, HCRichData, HCViewData, HCSectionData, EmrElementItem,
  HCCommon, HCRectItem, EmrGroupItem, Generics.Collections, Winapi.Messages;

type
  TEmrGridView = class(THCGridView)
  private
    FLoading,
    FDesignMode,
    FTrace: Boolean;
    FTraceCount: Integer;
    FDeDoneColor, FDeUnDoneColor: TColor;
    FOnCanNotEdit: TNotifyEvent;
    procedure DoDeItemPaintBKG(const Sender: TObject; const ACanvas: TCanvas;
      const ADrawRect: TRect; const APaintInfo: TPaintInfo);
    procedure InsertEmrTraceItem(const AText: string);
    function CanNotEdit: Boolean;
  protected
    procedure DoSectionCreateItem(Sender: TObject); override;
    function DoSectionCreateStyleItem(const AData: THCCustomData;
      const AStyleNo: Integer): THCCustomItem; override;
    procedure DoSectionInsertItem(const Sender: TObject;
      const AData: THCCustomData; const AItem: THCCustomItem); override;
    procedure DoSectionRemoveItem(const Sender: TObject;
      const AData: THCCustomData; const AItem: THCCustomItem); override;
    function DoSectionCanEdit(const Sender: TObject): Boolean; override;
    /// <summary> �������� </summary>
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

    /// <summary> ������ѹ </summary>
    procedure KeyPress(var Key: Char); override;

    /// <summary> �����ı� </summary>
    /// <param name="AText">Ҫ������ַ���(֧�ִ�#13#10�Ļس�����)</param>
    /// <returns>True������ɹ�</returns>
    function DoInsertText(const AText: string): Boolean; override;

    /// <summary> �ĵ�ĳ�ڵ�Item������� </summary>
    /// <param name="AData">��ǰ���Ƶ�Data</param>
    /// <param name="ADrawItemIndex">Item��Ӧ��DrawItem���</param>
    /// <param name="ADrawRect">Item��Ӧ�Ļ�������</param>
    /// <param name="ADataDrawLeft">Data����ʱ��Left</param>
    /// <param name="ADataDrawBottom">Data����ʱ��Bottom</param>
    /// <param name="ADataScreenTop">����ʱ����Data��Topλ��</param>
    /// <param name="ADataScreenBottom">����ʱ����Data��Bottomλ��</param>
    /// <param name="ACanvas">����</param>
    /// <param name="APaintInfo">����ʱ��������Ϣ</param>
    procedure DoSectionDrawItemPaintAfter(const Sender: TObject;
      const AData: THCCustomData; const ADrawItemNo: Integer; const ADrawRect: TRect;
      const ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;

    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary> ��ȡ�ļ��� </summary>
    procedure LoadFromStream(const AStream: TStream); override;

    /// <summary> ����Item </summary>
    /// <param name="ATraverse">����ʱ��Ϣ</param>
    procedure TraverseItem(const ATraverse: TItemTraverse);

    /// <summary> ���������� </summary>
    /// <param name="ADeGroup">��������Ϣ</param>
    /// <returns>True������ɹ�</returns>
    function InsertDeGroup(const ADeGroup: TDeGroup): Boolean;

    /// <summary> ��������Ԫ </summary>
    /// <param name="ADeItem">����Ԫ��Ϣ</param>
    /// <returns>True������ɹ�</returns>
    function InsertDeItem(const ADeItem: TDeItem): Boolean;

    /// <summary> �½�����Ԫ </summary>
    /// <param name="AText">����Ԫ�ı�</param>
    /// <returns>�½��õ�����Ԫ</returns>
    function NewDeItem(const AText: string): TDeItem;

    /// <summary> ֱ�����õ�ǰ����Ԫ��ֵΪ��չ���� </summary>
    procedure SetActiveItemExtra(const AStream: TStream);

    /// <summary> ��ȡָ���������е��ı����� </summary>
    /// <param name="AData">ָ�����ĸ�Data���ȡ</param>
    /// <param name="ADeGroupStartNo">ָ�����������ʼItemNo</param>
    /// <param name="ADeGroupEndNo">ָ��������Ľ���ItemNo</param>
    /// <returns>����������</returns>
    function GetDataDeGroupText(const AData: THCViewData;
      const ADeGroupStartNo, ADeGroupEndNo: Integer): string;

    /// <summary> �ӵ�ǰ��������ʼλ����ǰ����ͬIndex������ </summary>
    /// <param name="AData">ָ�����ĸ�Data���ȡ</param>
    /// <param name="ADeGroupStartNo">ָ�����ĸ�λ�ÿ�ʼ��ǰ��</param>
    /// <returns>��ͬIndex������������</returns>
    function GetDataForwardDeGroupText(const AData: THCViewData;
      const ADeGroupStartNo: Integer): string;

    /// <summary> �滻ָ������������� </summary>
    /// <param name="AData">ָ�����ĸ�Data���ȡ</param>
    /// <param name="ADeGroupStartNo">���滻����������ʼλ��</param>
    /// <param name="AText">Ҫ�滻������</param>
    procedure SetDataDeGroupText(const AData: THCViewData;
      const ADeGroupStartNo: Integer; const AText: string);

    property DesignMode: Boolean read FDesignMode write FDesignMode;

    /// <summary> �Ƿ�������״̬ </summary>
    property Trace: Boolean read FTrace write FTrace;

    /// <summary> ��ǰ�ĵ����� </summary>
    property FileName;

    /// <summary> ��ǰ�ĵ���ʽ�� </summary>
    property Style;

    /// <summary> �Ƿ�ԳƱ߾� </summary>
    property SymmetryMargin;

    /// <summary> ��ǰ�������ҳ����� </summary>
    property ActivePageIndex;

    /// <summary> ��ǰԤ����ҳ��� </summary>
    property PagePreviewFirst;

    /// <summary> ��ҳ�� </summary>
    property PageCount;

    /// <summary> ��ǰ������ڽڵ���� </summary>
    property ActiveSectionIndex;

    /// <summary> ˮƽ������ </summary>
    property HScrollBar;

    /// <summary> ��ֱ������ </summary>
    property VScrollBar;

    /// <summary> ����ֵ </summary>
    property Zoom;

    /// <summary> ��ǰ�ĵ����н� </summary>
    property Sections;

    /// <summary> �Ƿ���ʾ��ǰ��ָʾ�� </summary>
    property ShowLineActiveMark;

    /// <summary> �Ƿ���ʾ�к� </summary>
    property ShowLineNo;

    /// <summary> �Ƿ���ʾ�»��� </summary>
    property ShowUnderLine;

    /// <summary> ��ǰ�ĵ��Ƿ��б仯 </summary>
    property IsChanged;

    property OnCanNotEdit: TNotifyEvent read FOnCanNotEdit write FOnCanNotEdit;
  published
    { Published declarations }

    /// <summary> �����µ�Item����ʱ���� </summary>
    property OnSectionCreateItem;

    /// <summary> �����µ�Item����ʱ���� </summary>
    property OnSectionItemInsert;

    /// <summary> Item���ƿ�ʼǰ���� </summary>
    property OnSectionDrawItemPaintBefor;

    /// <summary> Item������ɺ󴥷� </summary>
    property OnSectionDrawItemPaintAfter;

    /// <summary> ��ҳü����ʱ���� </summary>
    property OnSectionPaintHeader;

    /// <summary> ��ҳ�Ż���ʱ���� </summary>
    property OnSectionPaintFooter;

    /// <summary> ��ҳ�����ʱ���� </summary>
    property OnSectionPaintPage;

    /// <summary> ����ҳ����ǰ���� </summary>
    property OnSectionPaintWholePageBefor;

    /// <summary> ����ҳ���ƺ󴥷� </summary>
    property OnSectionPaintWholePageAfter;

    /// <summary> ��ֻ�������б仯ʱ���� </summary>
    property OnSectionReadOnlySwitch;

    /// <summary> ҳ�������ʾģʽ�����򡢺��� </summary>
    property PageScrollModel;

    /// <summary> ������ʾģʽ��ҳ�桢Web </summary>
    property ViewModel;

    /// <summary> �Ƿ���ݿ���Զ��������ű��� </summary>
    property AutoZoom;

    /// <summary> ����Section�Ƿ�ֻ�� </summary>
    property ReadOnly;

    /// <summary> ��갴��ʱ���� </summary>
    property OnMouseDown;

    /// <summary> ��굯��ʱ���� </summary>
    property OnMouseUp;

    /// <summary> ���λ�øı�ʱ���� </summary>
    property OnCaretChange;

    /// <summary> ��ֱ����������ʱ���� </summary>
    property OnVerScroll;

    /// <summary> �ĵ����ݱ仯ʱ���� </summary>
    property OnChange;

    /// <summary> �ĵ�Change״̬�л�ʱ���� </summary>
    property OnChangedSwitch;

    /// <summary> �����ػ濪ʼʱ���� </summary>
    property OnPaintViewBefor;

    /// <summary> �����ػ�����󴥷� </summary>
    property OnPaintViewAfter;

    property PopupMenu;

    property Align;
  end;

/// <summary> ע��HCEmrView�ؼ����ؼ���� </summary>
procedure Register;

implementation

uses
  SysUtils, Forms, Printers, HCTextStyle;

procedure Register;
begin
  RegisterComponents('HCEmrViewVCL', [TEmrView]);
end;

{ TEmrView }

function TEmrView.CanNotEdit: Boolean;
begin
  Result := (not Self.ActiveSection.ActiveData.CanEdit) or (not (Self.ActiveSectionTopLevelData as THCRichData).CanEdit);
  if Result and Assigned(FOnCanNotEdit) then
    FOnCanNotEdit(Self);
end;

constructor TEmrView.Create(AOwner: TComponent);
begin
  FLoading := False;
  FTrace := False;
  FTraceCount := 0;
  FDesignMode := False;
  HCDefaultTextItemClass := TDeItem;
  HCDefaultDomainItemClass := TDeGroup;
  inherited Create(AOwner);
  Self.Width := 100;
  Self.Height := 100;
  FDeDoneColor := clBtnFace;  // Ԫ����д�󱳾�ɫ
  FDeUnDoneColor := $0080DDFF;  // Ԫ��δ��дʱ����ɫ
end;

destructor TEmrView.Destroy;
begin
  inherited Destroy;
end;

procedure TEmrView.DoDeItemPaintBKG(const Sender: TObject; const ACanvas: TCanvas;
  const ADrawRect: TRect; const APaintInfo: TPaintInfo);
var
  vDeItem: TDeItem;
begin
  if not APaintInfo.Print then
  begin
    vDeItem := Sender as TDeItem;
    if vDeItem.IsElement then  // ������Ԫ
    begin
      if vDeItem.MouseIn or vDeItem.Active then  // �������͹��������
      begin
        if vDeItem.IsSelectPart or vDeItem.IsSelectComplate then
        begin

        end
        else
        begin
          if vDeItem[TDeProp.Name] <> vDeItem.Text then  // �Ѿ���д����
            ACanvas.Brush.Color := FDeDoneColor
          else  // û��д��
            ACanvas.Brush.Color := FDeUnDoneColor;

          ACanvas.FillRect(ADrawRect);
        end;
      end;
    end
    else  // ��������Ԫ
    if FDesignMode and vDeItem.EditProtect then
    begin
      ACanvas.Brush.Color := clBtnFace;
      ACanvas.FillRect(ADrawRect);
    end;
  end;
end;

function TEmrView.DoInsertText(const AText: string): Boolean;
begin
  Result := False;
  if CanNotEdit then Exit;  
  
  if FTrace then
  begin
    InsertEmrTraceItem(AText);
    Result := True;
  end
  else
    Result := inherited DoInsertText(AText);
end;

function TEmrView.DoSectionCanEdit(const Sender: TObject): Boolean;
var
  vViewData: THCViewData;
begin
  vViewData := Sender as THCViewData;
  if (vViewData.ActiveDomain <> nil) and (vViewData.ActiveDomain.BeginNo >= 0) then
    Result := not (vViewData.Items[vViewData.ActiveDomain.BeginNo] as TDeGroup).ReadOnly
  else
    Result := True;
end;

procedure TEmrView.DoSectionCreateItem(Sender: TObject);
begin
  if (not FLoading) and FTrace then
    (Sender as TDeItem).StyleEx := TStyleExtra.cseAdd;

  inherited DoSectionCreateItem(Sender);
end;

function TEmrView.DoSectionCreateStyleItem(const AData: THCCustomData;
  const AStyleNo: Integer): THCCustomItem;
begin
  case AStyleNo of
    THCStyle.Table:
      Result := TDeTable.Create(AData, 1, 1, 1);

    THCStyle.CheckBox:
      Result := TDeCheckBox.Create(AData, '��ѡ��', False);

    THCStyle.Edit:
      Result := TDeEdit.Create(AData, '');

    THCStyle.Combobox:
      Result := TDeCombobox.Create(AData, '');

    THCStyle.DateTimePicker:
      Result := TDeDateTimePicker.Create(AData, Now);

    THCStyle.RadioGroup:
      Result := TDeRadioGroup.Create(AData);
  else
    Result := nil;
  end;
end;

procedure TEmrView.DoSectionDrawItemPaintAfter(const Sender: TObject;
  const AData: THCCustomData; const ADrawItemNo: Integer; const ADrawRect: TRect;
  const ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vItem: THCCustomItem;
  vDeItem: TDeItem;
  vDrawAnnotate: THCDrawAnnotateDynamic;
begin
  if FTraceCount > 0 then  // ��ʾ��ע
  begin
    vItem := AData.Items[AData.DrawItems[ADrawItemNo].ItemNo];
    if vItem.StyleNo > THCStyle.Null then
    begin
      vDeItem := vItem as TDeItem;
      if (vDeItem.StyleEx <> TStyleExtra.cseNone) then  // �����ע
      begin
        vDrawAnnotate := THCDrawAnnotateDynamic.Create;
        vDrawAnnotate.DrawRect := ADrawRect;
        vDrawAnnotate.Title := vDeItem.GetHint;
        vDrawAnnotate.Text := AData.GetDrawItemText(ADrawItemNo);

        Self.AnnotatePre.AddDrawAnnotate(vDrawAnnotate);
        //Self.VScrollBar.AddAreaPos(AData.DrawItems[ADrawItemNo].Rect.Top, ADrawRect.Height);
      end;
    end;
  end;

  inherited DoSectionDrawItemPaintAfter(Sender, AData, ADrawItemNo, ADrawRect,
    ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
end;

procedure TEmrView.DoSectionInsertItem(const Sender: TObject;
  const AData: THCCustomData; const AItem: THCCustomItem);
var
  vDeItem: TDeItem;
begin
  if AItem is TDeItem then
  begin
    vDeItem := AItem as TDeItem;
    vDeItem.OnPaintBKG := DoDeItemPaintBKG;

    if vDeItem.StyleEx <> TStyleExtra.cseNone then
    begin
      Inc(FTraceCount);

      if not Self.AnnotatePre.Visible then
        Self.AnnotatePre.Visible := True;
    end;
  end;

  inherited DoSectionInsertItem(Sender, AData, AItem);
end;

procedure TEmrView.DoSectionRemoveItem(const Sender: TObject;
  const AData: THCCustomData; const AItem: THCCustomItem);
var
  vDeItem: TDeItem;
begin
  if AItem is TDeItem then
  begin
    vDeItem := AItem as TDeItem;

    if vDeItem.StyleEx <> TStyleExtra.cseNone then
    begin
      Dec(FTraceCount);

      if (FTraceCount = 0) and Self.AnnotatePre.Visible and (Self.AnnotatePre.Count = 0) then
        Self.AnnotatePre.Visible := False;
    end;
  end;

  inherited DoSectionRemoveItem(Sender, AData, AItem);
end;

function TEmrView.GetDataForwardDeGroupText(const AData: THCViewData;
  const ADeGroupStartNo: Integer): string;
var
  i, vBeginNo, vEndNo: Integer;
  vDeGroup: TDeGroup;
  vDeIndex: string;
begin
  Result := '';

  vBeginNo := -1;
  vEndNo := -1;
  vDeIndex := (AData.Items[ADeGroupStartNo] as TDeGroup)[TDeProp.Index];

  for i := 0 to ADeGroupStartNo - 1 do  // ����ʼ
  begin
    if AData.Items[i] is TDeGroup then
    begin
      vDeGroup := AData.Items[i] as TDeGroup;
      if vDeGroup.MarkType = TMarkType.cmtBeg then  // ������ʼ
      begin
        if vDeGroup[TDeProp.Index] = vDeIndex then  // ��Ŀ������ʼ
        begin
          vBeginNo := i;
          Break;
        end;
      end;
    end;
  end;

  if vBeginNo >= 0 then  // �ҽ���
  begin
    for i := vBeginNo + 1 to ADeGroupStartNo - 1 do
    begin
      if AData.Items[i] is TDeGroup then
      begin
        vDeGroup := AData.Items[i] as TDeGroup;
        if vDeGroup.MarkType = TMarkType.cmtEnd then  // �������
        begin
          if vDeGroup[TDeProp.Index] = vDeIndex then  // ��Ŀ�������
          begin
            vEndNo := i;
            Break;
          end;
        end;
      end;
    end;

    if vEndNo > 0 then
      Result := GetDataDeGroupText(AData, vBeginNo, vEndNo);
  end;
end;

function TEmrView.GetDataDeGroupText(const AData: THCViewData;
  const ADeGroupStartNo, ADeGroupEndNo: Integer): string;
var
  i: Integer;
begin
  Result := '';
  for i := ADeGroupStartNo + 1 to ADeGroupEndNo - 1 do
    Result := Result + AData.Items[i].Text;
end;

function TEmrView.InsertDeGroup(const ADeGroup: TDeGroup): Boolean;
begin
  Result := InsertDomain(ADeGroup);
end;

function TEmrView.InsertDeItem(const ADeItem: TDeItem): Boolean;
begin
  Result := Self.InsertItem(ADeItem);
end;

procedure TEmrView.InsertEmrTraceItem(const AText: string);
var
  vEmrTraceItem: TDeItem;
begin
  // ������Ӻۼ�Ԫ��
  vEmrTraceItem := TDeItem.CreateByText(AText);
  vEmrTraceItem.StyleNo := Self.CurStyleNo;
  vEmrTraceItem.ParaNo := Self.CurParaNo;
  vEmrTraceItem.StyleEx := TStyleExtra.cseAdd;

  Self.InsertItem(vEmrTraceItem);
end;

procedure TEmrView.KeyDown(var Key: Word; Shift: TShiftState);
var
  vData: THCRichData;
  vText, vCurTrace: string;
  vStyleNo, vParaNo: Integer;
  vDeItem: TDeItem;
  vCurItem: THCCustomItem;
  vCurStyleEx: TStyleExtra;
begin
  if FTrace then  // ����
  begin
    if IsKeyDownEdit(Key) then
    begin
      if CanNotEdit then Exit;
      
      vText := '';
      vCurTrace := '';
      vStyleNo := THCStyle.Null;
      vParaNo := THCStyle.Null;
      vCurStyleEx := TStyleExtra.cseNone;

      vData := Self.ActiveSectionTopLevelData as THCRichData;
      if vData.SelectExists then
      begin
        Self.DisSelect;
        Exit;
      end;

      if vData.SelectInfo.StartItemNo < 0 then Exit;

      if vData.Items[vData.SelectInfo.StartItemNo].StyleNo < THCStyle.Null then
      begin
        inherited KeyDown(Key, Shift);
        Exit;
      end;

      // ȡ��괦���ı�
      with vData do
      begin
        if Key = VK_BACK then  // ��ɾ
        begin
          if (SelectInfo.StartItemNo = 0) and (SelectInfo.StartItemOffset = 0) then  // ��һ����ǰ���򲻴���
            Exit
          else  // ���ǵ�һ����ǰ��
          if SelectInfo.StartItemOffset = 0 then  // ��ǰ�棬�ƶ���ǰһ������洦��
          begin
            if Items[SelectInfo.StartItemNo].Text <> '' then  // ��ǰ�в��ǿ���
            begin
              SelectInfo.StartItemNo := SelectInfo.StartItemNo - 1;
              SelectInfo.StartItemOffset := Items[SelectInfo.StartItemNo].Length;
              Self.KeyDown(Key, Shift);
            end
            else  // ���в�����ֱ��Ĭ�ϴ���
              inherited KeyDown(Key, Shift);

            Exit;
          end
          else  // ���ǵ�һ��Item��Ҳ������Item��ǰ��
          if Items[SelectInfo.StartItemNo] is TDeItem then  // �ı�
          begin
            vDeItem := Items[SelectInfo.StartItemNo] as TDeItem;
            vText := vDeItem.SubString(SelectInfo.StartItemOffset, 1);
            vStyleNo := vDeItem.StyleNo;
            vParaNo := vDeItem.ParaNo;
            vCurStyleEx := vDeItem.StyleEx;
            vCurTrace := vDeItem[TDeProp.Trace];
          end;
        end
        else
        if Key = VK_DELETE then  // ��ɾ
        begin
          if (SelectInfo.StartItemNo = Items.Count - 1)
            and (SelectInfo.StartItemOffset = Items[Items.Count - 1].Length)
          then  // ���һ��������򲻴���
            Exit
          else  // �������һ�������
          if SelectInfo.StartItemOffset = Items[SelectInfo.StartItemNo].Length then  // ����棬�ƶ�����һ����ǰ�洦��
          begin
            SelectInfo.StartItemNo := SelectInfo.StartItemNo + 1;
            SelectInfo.StartItemOffset := 0;
            Self.KeyDown(Key, Shift);

            Exit;
          end
          else  // �������һ��Item��Ҳ������Item�����
          if Items[SelectInfo.StartItemNo] is TDeItem then  // �ı�
          begin
            vDeItem := Items[SelectInfo.StartItemNo] as TDeItem;
            vText := vDeItem.SubString(SelectInfo.StartItemOffset + 1, 1);
            vStyleNo := vDeItem.StyleNo;
            vParaNo := vDeItem.ParaNo;
            vCurStyleEx := vDeItem.StyleEx;
            vCurTrace := vDeItem[TDeProp.Trace];
          end;
        end;
      end;

      // ɾ�����������Ժۼ�����ʽ����
      Self.BeginUpdate;
      try
        inherited KeyDown(Key, Shift);

        if FTrace and (vText <> '') then  // ��ɾ��������
        begin
          if (vCurStyleEx = TStyleExtra.cseAdd) and (vCurTrace = '') then Exit;  // �����δ��Ч�ۼ�����ֱ��ɾ��

          // ����ɾ���ַ���Ӧ��Item
          vDeItem := TDeItem.CreateByText(vText);
          vDeItem.StyleNo := vStyleNo;  // Style.CurStyleNo;
          vDeItem.ParaNo := vParaNo;  // Style.CurParaNo;

          if (vCurStyleEx = TStyleExtra.cseDel) and (vCurTrace = '') then  // ԭ����ɾ��δ��Ч�ۼ�
            vDeItem.StyleEx := TStyleExtra.cseNone  // ȡ��ɾ���ۼ�
          else  // ����ɾ���ۼ�
            vDeItem.StyleEx := TStyleExtra.cseDel;

          // ����ɾ���ۼ�Item
          vCurItem := vData.Items[vData.SelectInfo.StartItemNo];
          if vData.SelectInfo.StartItemOffset = 0 then  // ��Item��ǰ��
          begin
            if vDeItem.CanConcatItems(vCurItem) then // ���Ժϲ�
            begin
              vCurItem.Text := vDeItem.Text + vCurItem.Text;

              if Key = VK_DELETE then  // ��ɾ
                vData.SelectInfo.StartItemOffset := vData.SelectInfo.StartItemOffset + 1;

              Self.ActiveSection.ReFormatActiveItem;
            end
            else  // ���ܺϲ�
            begin
              vDeItem.ParaFirst := vCurItem.ParaFirst;
              vCurItem.ParaFirst := False;
              vData.InsertItem(vDeItem);
              if Key = VK_BACK then  // ��ɾ
                vData.SelectInfo.StartItemOffset := vData.SelectInfo.StartItemOffset - 1;
            end;
          end
          else
          if vData.SelectInfo.StartItemOffset = vCurItem.Length then  // ��Item�����
          begin
            if vCurItem.CanConcatItems(vDeItem) then // ���Ժϲ�
            begin
              vCurItem.Text := vCurItem.Text + vDeItem.Text;

              if Key = VK_DELETE then  // ��ɾ
                vData.SelectInfo.StartItemOffset := vData.SelectInfo.StartItemOffset + 1;

              Self.ActiveSection.ReFormatActiveItem;
            end
            else  // �����Ժϲ�
            begin
              vData.InsertItem(vDeItem);
              if Key = VK_BACK then  // ��ɾ
                vData.SelectInfo.StartItemOffset := vData.SelectInfo.StartItemOffset - 1;
            end;
          end
          else  // ��Item�м�
          begin
            vData.InsertItem(vDeItem);
            if Key = VK_BACK then  // ��ɾ
              vData.SelectInfo.StartItemOffset := vData.SelectInfo.StartItemOffset - 1;
          end;
        end;
      finally
        Self.EndUpdate;
      end;
    end
    else
      inherited KeyDown(Key, Shift);
  end
  else
    inherited KeyDown(Key, Shift);
end;

procedure TEmrView.KeyPress(var Key: Char);
var
  vData: THCCustomData;
begin
  if IsKeyPressWant(Key) then
  begin
    if CanNotEdit then Exit;
    
    if FTrace then
    begin
      vData := Self.ActiveSectionTopLevelData;

      if vData.SelectInfo.StartItemNo < 0 then Exit;

      if vData.SelectExists then
        Self.DisSelect
      else
        InsertEmrTraceItem(Key);

      Exit;
    end;
    
    inherited KeyPress(Key);
  end;
end;

procedure TEmrView.LoadFromStream(const AStream: TStream);
begin
  FLoading := True;
  try
    inherited LoadFromStream(AStream);
  finally
    FLoading := False;
  end;
end;

function TEmrView.NewDeItem(const AText: string): TDeItem;
begin
  Result := TDeItem.CreateByText(AText);
  if Self.CurStyleNo > THCStyle.Null then
    Result.StyleNo := Self.CurStyleNo
  else
    Result.StyleNo := 0;

  Result.ParaNo := Self.CurParaNo;
end;

procedure TEmrView.SetActiveItemExtra(const AStream: TStream);
var
  vFileFormat: string;
  vFileVersion: Word;
  vLang: Byte;
  vStyle: THCStyle;
  vTopData: THCRichData;
begin
  _LoadFileFormatAndVersion(AStream, vFileFormat, vFileVersion, vLang);  // �ļ���ʽ�Ͱ汾
  vStyle := THCStyle.Create;
  try
    vStyle.LoadFromStream(AStream, vFileVersion);
    Self.BeginUpdate;
    try
      Self.UndoGroupBegin;
      try
        vTopData := Self.ActiveSectionTopLevelData as THCRichData;
        Self.DeleteActiveDataItems(vTopData.SelectInfo.StartItemNo);
        ActiveSection.InsertStream(AStream, vStyle, vFileVersion);
      finally
        Self.UndoGroupEnd;
      end;
    finally
      Self.EndUpdate;
    end;
  finally
    FreeAndNil(vStyle);
  end;
end;

procedure TEmrView.SetDataDeGroupText(const AData: THCViewData;
  const ADeGroupStartNo: Integer; const AText: string);
var
  i, vIgnore, vEndNo: Integer;
begin
  // ��ָ����������Item��Χ
  vEndNo := -1;
  vIgnore := 0;

  for i := ADeGroupStartNo + 1 to AData.Items.Count - 1 do
  begin
    if AData.Items[i] is TDeGroup then
    begin
      if (AData.Items[i] as TDeGroup).MarkType = TMarkType.cmtEnd then
      begin
        if vIgnore = 0 then
        begin
          vEndNo := i;
          Break;
        end
        else
          Dec(vIgnore);
      end
      else
        Inc(vIgnore);
    end;
  end;

  if vEndNo >= 0 then  // �ҵ���Ҫ���õ�����
  begin
    Self.BeginUpdate;
    try
      // ѡ�У�ʹ�ò���ʱɾ����ǰ�������е�����
      AData.SetSelectBound(ADeGroupStartNo, OffsetAfter, vEndNo, OffsetBefor);
      AData.InsertText(AText);
    finally
      Self.EndUpdate
    end;
  end;
end;

procedure TEmrView.TraverseItem(const ATraverse: TItemTraverse);
var
  i: Integer;
begin
  if ATraverse.Areas = [] then Exit;

  for i := 0 to Self.Sections.Count - 1 do
  begin
    if not ATraverse.Stop then
    begin
      with Self.Sections[i] do
      begin
        if saHeader in ATraverse.Areas then
          Header.TraverseItem(ATraverse);

        if (not ATraverse.Stop) and (saPage in ATraverse.Areas) then
          PageData.TraverseItem(ATraverse);

        if (not ATraverse.Stop) and (saFooter in ATraverse.Areas) then
          Footer.TraverseItem(ATraverse);
      end;
    end;
  end;
end;

procedure TEmrView.WndProc(var Message: TMessage);
var
  Form: TCustomForm;
  ShiftState: TShiftState;
begin
  if (Message.Msg = WM_KEYDOWN) or (Message.Msg = WM_KEYUP) then
  begin
    if message.WParam in [VK_LEFT..VK_DOWN, VK_RETURN, VK_TAB] then
    begin
      Form := GetParentForm(Self);
      if Form = nil then
      begin
        if Application.Handle <> 0 then  // ��exe������
        begin
          if Message.WParam <> VK_RETURN then
          begin
            ShiftState := KeyDataToShiftState(TWMKey(Message).KeyData);
            Self.KeyDown(TWMKey(Message).CharCode, ShiftState);
            Exit;
          end;
        end
        else  // �������������
        begin
          if Message.WParam = VK_RETURN then
          begin
            ShiftState := KeyDataToShiftState(TWMKey(Message).KeyData);
            Self.KeyDown(TWMKey(Message).CharCode, ShiftState);

            Exit;
          end;
        end;
      end;
    end;
  end;

  inherited WndProc(Message);
end;

end.
