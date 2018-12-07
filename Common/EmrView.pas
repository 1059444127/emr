{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit EmrView;

interface

uses
  Windows, Classes, Controls, Vcl.Graphics, HCView, HCStyle, HCItem, HCTextItem,
  HCDrawItem, HCCustomData, HCCustomRichData, HCViewData, HCSectionData, EmrElementItem,
  HCCommon, HCRectItem, EmrGroupItem, Generics.Collections, Winapi.Messages;

type
  TEmrView = class(THCView)
  private
    FLoading,
    FTrace: Boolean;
    procedure DoSectionCreateItem(Sender: TObject);  // SenderΪTDeItem
    procedure InsertEmrTraceItem(const AText: string);
    function DoCreateStyleItem(const AData: THCCustomData; const AStyleNo: Integer): THCCustomItem;
    function DoCanEdit(const Sender: TObject): Boolean;
  protected
    /// <summary> ��갴�� </summary>
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

    /// <summary> ��갴ѹ </summary>
    procedure KeyPress(var Key: Char); override;

    /// <summary> �����ı� </summary>
    /// <param name="AText">Ҫ������ַ���(֧�ִ�#13#10�Ļس�����)</param>
    /// <returns>True������ɹ�</returns>
    function DoInsertText(const AText: string): Boolean; override;

    /// <summary> ��ʼ�����ĵ� </summary>
    /// <param name="AStream"></param>
    procedure DoSaveBefor(const AStream: TStream); override;

    /// <summary> �ĵ�������� </summary>
    /// <param name="AStream"></param>
    procedure DoSaveAfter(const AStream: TStream); override;

    /// <summary> ��ʼ�����ĵ� </summary>
    /// <param name="AStream"></param>
    /// <param name="AFileVersion">�ļ��汾��</param>
    procedure DoLoadBefor(const AStream: TStream; const AFileVersion: Word); override;

    /// <summary> �ĵ�������� </summary>
    /// <param name="AStream"></param>
    /// <param name="AFileVersion">�ļ��汾��</param>
    procedure DoLoadAfter(const AStream: TStream; const AFileVersion: Word); override;

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
      const AData: THCCustomData; const ADrawItemIndex: Integer; const ADrawRect: TRect;
      const ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;

    /// <summary> �ؼ������ĵ����ݿ�ʼ </summary>
    /// <param name="ACanvas">����</param>
    procedure DoUpdateViewBefor(const ACanvas: TCanvas);

    /// <summary> �ؼ������ĵ����ݽ��� </summary>
    /// <param name="ACanvas">����</param>
    procedure DoUpdateViewAfter(const ACanvas: TCanvas);
//    procedure DoSectionDrawItemPaintAfter(const AData: THCCustomData;
//      const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
//      ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
//      const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary> �ĵ����浽�� </summary>
    procedure SaveToStream(const AStream: TStream;
      const ASaveParts: TSaveParts = [saHeader, saPage, saFooter]); override;

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

    /// <summary> ˮƽ��������ֵ </summary>
    property HScrollValue;

    /// <summary> ��ֱ��������ֵ </summary>
    property VScrollValue;

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
    property OnUpdateViewBefor;

    /// <summary> �����ػ�����󴥷� </summary>
    property OnUpdateViewAfter;

    property PopupMenu;

    property Align;
  end;

/// <summary> ע��HCEmrView�ؼ����ؼ���� </summary>
procedure Register;

implementation

uses
  SysUtils, Forms, Printers, HCTextStyle, HCSection;

procedure Register;
begin
  RegisterComponents('HCEmrViewVCL', [TEmrView]);
end;

{ TEmrView }

constructor TEmrView.Create(AOwner: TComponent);
begin
  FLoading := False;
  FTrace := False;
  HCDefaultTextItemClass := TDeItem;
  HCDefaultDomainItemClass := TDeGroup;
  inherited Create(AOwner);
  Self.Width := 100;
  Self.Height := 100;
  Self.OnSectionCreateItem := DoSectionCreateItem;
  Self.OnUpdateViewBefor := DoUpdateViewBefor;
  Self.OnUpdateViewAfter := DoUpdateViewAfter;
  Self.OnSectionCreateStyleItem := DoCreateStyleItem;
  Self.OnSectionCanEdit := DoCanEdit;
end;

destructor TEmrView.Destroy;
begin
  inherited Destroy;
end;

procedure TEmrView.DoSectionCreateItem(Sender: TObject);
begin
  if (not FLoading) and FTrace then
    (Sender as TDeItem).StyleEx := TStyleExtra.cseAdd;
end;

function TEmrView.DoCanEdit(const Sender: TObject): Boolean;
var
  vViewData: THCViewData;
begin
  vViewData := Sender as THCViewData;
  if vViewData.ActiveDomain.BeginNo >= 0 then
    Result := not (vViewData.Items[vViewData.ActiveDomain.BeginNo] as TDeGroup).ReadOnly
  else
    Result := True;
end;

function TEmrView.DoCreateStyleItem(const AData: THCCustomData; const AStyleNo: Integer): THCCustomItem;
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

function TEmrView.DoInsertText(const AText: string): Boolean;
begin
  Result := False;
  if FTrace then
  begin
    InsertEmrTraceItem(AText);
    Result := True;
  end
  else
    Result := inherited DoInsertText(AText);
end;

procedure TEmrView.DoLoadAfter(const AStream: TStream; const AFileVersion: Word);
begin
  inherited DoLoadAfter(AStream, AFileVersion);;
end;

procedure TEmrView.DoLoadBefor(const AStream: TStream; const AFileVersion: Word);
begin
  inherited DoLoadBefor(AStream, AFileVersion);
end;

procedure TEmrView.DoSaveAfter(const AStream: TStream);
begin
  inherited DoSaveAfter(AStream);
end;

procedure TEmrView.DoSaveBefor(const AStream: TStream);
begin
  inherited DoSaveBefor(AStream);
end;

procedure TEmrView.DoSectionDrawItemPaintAfter(const Sender: TObject;
  const AData: THCCustomData; const ADrawItemIndex: Integer; const ADrawRect: TRect;
  const ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vItem: THCCustomItem;
  vDeItem: TDeItem;
begin
//  if Self.ShowAnnotation then  // ��ʾ��ע
//  begin
//    vItem := AData.Items[AData.DrawItems[ADrawItemIndex].ItemNo];
//    if vItem.StyleNo > THCStyle.Null then
//    begin
//      vDeItem := vItem as TDeItem;
//      if (vDeItem.StyleEx <> TStyleExtra.cseNone)
//        and (vDeItem.FirstDItemNo = ADrawItemIndex)
//      then  // �����ע
//      begin
//        if vDeItem.StyleEx = TStyleExtra.cseDel then
//          Self.Annotates.AddAnnotation(ADrawRect, vDeItem.Text + sLineBreak + vDeItem[TDeProp.Trace])
//        else
//          Self.Annotates.AddAnnotation(ADrawRect, vDeItem.Text + sLineBreak + vDeItem[TDeProp.Trace]);
//      end;
//    end;
//  end;

  inherited DoSectionDrawItemPaintAfter(Sender, AData, ADrawItemIndex, ADrawRect,
    ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
end;

procedure TEmrView.DoUpdateViewAfter(const ACanvas: TCanvas);
{var
  i: Integer;
  vRect: TRect;
  vS: string;}
begin
  {ACanvas.Brush.Color := clInfoBk;
  for i := 0 to FAreas.Count - 1 do
  begin
    vRect := FAreas[i].Rect;
    ACanvas.FillRect(vRect);
    ACanvas.Pen.Color := clBlack;
    ACanvas.Rectangle(vRect);

    ACanvas.Pen.Color := clMedGray;
    ACanvas.MoveTo(vRect.Left + 2, vRect.Bottom + 1);
    ACanvas.LineTo(vRect.Right, vRect.Bottom + 1);
    ACanvas.LineTo(vRect.Right, vRect.Top + 2);

    vS := '����';
    ACanvas.TextRect(vRect, vS, [tfSingleLine, tfCenter, tfVerticalCenter]);
  end;}
end;

procedure TEmrView.DoUpdateViewBefor(const ACanvas: TCanvas);
begin
  //FAreas.Clear;
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
  vEmrTraceItem.StyleNo := Style.CurStyleNo;
  vEmrTraceItem.ParaNo := Style.CurParaNo;
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
  if FTrace then
  begin
    vText := '';
    vCurTrace := '';
    vStyleNo := THCStyle.Null;
    vParaNo := THCStyle.Null;
    vCurStyleEx := TStyleExtra.cseNone;

    vData := Self.ActiveSection.ActiveData;
    if vData <> nil then
      vData := vData.GetTopLevelData;

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
          vText := vDeItem.GetTextPart(SelectInfo.StartItemOffset, 1);
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
          vText := vDeItem.GetTextPart(SelectInfo.StartItemOffset + 1, 1);
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
        if (vData.SelectInfo.StartItemOffset = 0) then  // ��Item��ǰ��
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
end;

procedure TEmrView.KeyPress(var Key: Char);
var
  vData: THCRichData;
begin
  if FTrace then
  begin
    if IsKeyPressWant(Key) then
    begin
      vData := Self.ActiveSectionTopLevelData;

      if vData.SelectInfo.StartItemNo < 0 then Exit;

      if vData.SelectExists then
        Self.DisSelect
      else
        InsertEmrTraceItem(Key);

      Exit;
    end;
  end;
  inherited KeyPress(Key);
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
  if Self.Style.CurStyleNo > THCStyle.Null then
    Result.StyleNo := Self.Style.CurStyleNo
  else
    Result.StyleNo := 0;

  Result.ParaNo := Self.Style.CurParaNo;
end;

procedure TEmrView.SaveToStream(const AStream: TStream;
  const ASaveParts: TSaveParts);
begin
  inherited SaveToStream(AStream, ASaveParts);
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
  for i := 0 to Self.Sections.Count - 1 do
  begin
    with Self.Sections[i] do
    begin
      case ATraverse.Area of
        saHeader: Header.TraverseItem(ATraverse);
        saPage: PageData.TraverseItem(ATraverse);
        saFooter: Footer.TraverseItem(ATraverse);
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
