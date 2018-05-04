{*******************************************************}
{                                                       }
{                       HCView V1.0                     }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{*******************************************************}

unit EmrView;

interface

uses
  Windows, Classes, Graphics, HCView, HCStyle, HCItem, HCTextItem, HCDrawItem,
  HCCustomData, HCCustomRichData, EmrElementItem, HCCommon, EmrGroupItem, HCDataCommon;

type
  TEmrState = (cesLoading, cesTrace);
  TEmrStates = set of TEmrState;

  TEmrView = class(THCView)
  private
    FDataSetName,  // ���ݼ�����
    FDataSetCode   // ���ݼ�����
      : string;
    FStates: TEmrStates;
    procedure DoCreateItem(Sender: TObject);  // SenderΪTEmrTextItem
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure DoSaveBefor(const AStream: TStream); override;
    procedure DoSaveAfter(const AStream: TStream); override;
    procedure DoLoadBefor(const AStream: TStream; const AFileVersion: Word); override;
    procedure DoLoadAfter(const AStream: TStream; const AFileVersion: Word); override;
    procedure DoSectionItemPaintAfter(const AData: THCCustomData;
      const ADrawItemIndex: Integer; const ADrawRect: TRect;
      const ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure LoadFromStream(const AStream: TStream); override;
    //
    function GetTrace: Boolean;
    procedure SetTrace(const Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    function GetActiveDrawItemCoord: TPoint;

    /// <summary>
    /// �ӵ�ǰ�д�ӡ��ǰҳ
    /// </summary>
    /// <param name="APrintHeader"></param>
    /// <param name="APrintFooter"></param>
    procedure PrintCurPageByActiveLine(const APrintHeader, APrintFooter: Boolean);
    procedure TraverseItem(const ATraverse: TItemTraverse);
    function InsertDeGroup(const AItem: TDeGroup): Boolean;
    function InsertDeItem(const AItem: TEmrTextItem): Boolean;
    property Trace: Boolean read GetTrace write SetTrace;
  end;

implementation

uses
  SysUtils, Forms, Printers, HCTextStyle, HCRectItem, HCSection, HCRichData;

{ TEmrView }

constructor TEmrView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Self.OnCreateItem := DoCreateItem;
end;

procedure TEmrView.DoCreateItem(Sender: TObject);
begin
  if (not (cesLoading in FStates)) and (cesTrace in FStates) then
    (Sender as TEmrTextItem).StyleEx := TStyleExtra.cseAdd;
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

procedure TEmrView.DoSectionItemPaintAfter(const AData: THCCustomData;
  const ADrawItemIndex: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vItem: THCCustomItem;
  vEmrTextItem: TEmrTextItem;
begin
  if Self.ShowAnnotation then  // ��ʾ��ע
  begin
    vItem := AData.Items[AData.DrawItems[ADrawItemIndex].ItemNo];
    if vItem.StyleNo > THCStyle.RsNull then
    begin
      vEmrTextItem := vItem as TEmrTextItem;
      if (vEmrTextItem.StyleEx <> TStyleExtra.cseNone)
        and (vEmrTextItem.FirstDItemNo = ADrawItemIndex)
      then  // �����ע
      begin
        if vEmrTextItem.StyleEx = TStyleExtra.cseDel then
          Self.Annotations.AddAnnotation(ADrawRect, vEmrTextItem.Text + sLineBreak + vEmrTextItem[TDeProp.Trace])
        else
          Self.Annotations.AddAnnotation(ADrawRect, vEmrTextItem.Text + sLineBreak + vEmrTextItem[TDeProp.Trace]);
      end;
    end;
  end;

  inherited DoSectionItemPaintAfter(AData, ADrawItemIndex, ADrawRect, ADataDrawLeft,
    ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
end;

function TEmrView.GetActiveDrawItemCoord: TPoint;
var
  vPageIndex: Integer;
begin
  Result := ActiveSection.GetActiveDrawItemCoord;
  vPageIndex := ActiveSection.ActivePageIndex;

  // ӳ�䵽��ҳ��(��ɫ����)
  Result.X := GetSectionDrawLeft(Self.ActiveSectionIndex)
    + ZoomIn(ActiveSection.GetPageMarginLeft(vPageIndex) + Result.X) - Self.HScrollValue;

  if ActiveSection.ActiveData = ActiveSection.Header then
    Result.Y := ZoomIn(
      GetSectionTopFilm(Self.ActiveSectionIndex)
      + ActiveSection.GetPageTopFilm(vPageIndex)  // 20
      + ActiveSection.GetHeaderPageDrawTop
      + Result.Y
      - ActiveSection.GetPageDataFmtTop(vPageIndex))  // 0
      - Self.VScrollValue
  else
    Result.Y := ZoomIn(
      GetSectionTopFilm(Self.ActiveSectionIndex)
      + ActiveSection.GetPageTopFilm(vPageIndex)  // 20
      + ActiveSection.GetHeaderAreaHeight // 94
      + Result.Y
      - ActiveSection.GetPageDataFmtTop(vPageIndex))  // 0
      - Self.VScrollValue;
end;

function TEmrView.GetTrace: Boolean;
begin
  Result := cesTrace in FStates;
end;

function TEmrView.InsertDeGroup(const AItem: TDeGroup): Boolean;
var
  //vDeName: string;
  vGroupItem: TDeGroup;
  //vTextItem: TEmrTextItem;
  //vInsertIndex: Integer;
  vTopData: THCRichData;
  vDomainLevel: Byte;
begin
  vTopData := ActiveSection.ActiveData.GetTopLevelData as THCRichData;
  if vTopData <> nil then
  begin
    Self.BeginUpdate;
    try
      if vTopData.ActiveDomain <> nil then
        vDomainLevel := (vTopData.Items[vTopData.ActiveDomain.BeginNo] as TDeGroup).Level + 1
      else
        vDomainLevel := 0;

      // ͷ
      vGroupItem := TDeGroup.Create;
      vGroupItem.Level := vDomainLevel;
      vGroupItem.Assign(AItem);
      vGroupItem.MarkType := cmtBeg;
      vTopData.InsertItem(vGroupItem);  // [

      // β
      vGroupItem := TDeGroup.Create;
      vGroupItem.Level := vDomainLevel;
      vGroupItem.Assign(AItem);
      vGroupItem.MarkType := cmtEnd;
      vTopData.InsertItem(vGroupItem);  // ]

      // �ı����� �Ȳ���[]���������м����item����ֹitem�ͺ�������ݺϲ�
      {vInsertIndex := vTopData.SelectInfo.StartItemNo;
      vTextItem := TEmrTextItem.CreateByText(vGroupItem[DEName]);
      vTextItem.StyleNo := Style.CurStyleNo;
      vTextItem.ParaNo := Style.CurParaNo;
      vTopData.InsertItem(vInsertIndex, vTextItem);}
    finally
      Self.EndUpdate;
    end;
  end;
end;

function TEmrView.InsertDeItem(const AItem: TEmrTextItem): Boolean;
begin
  Result := Self.InsertItem(AItem);
end;

procedure TEmrView.KeyDown(var Key: Word; Shift: TShiftState);
var
  vData: THCCustomRichData;
  vText, vCurTrace: string;
  vStyleNo, vParaNo: Integer;
  vEmrTextItem: TEmrTextItem;
  vCurItem: THCCustomItem;
  vCurStyleEx: TStyleExtra;
begin
  if cesTrace in FStates then
  begin
    vText := '';
    vCurTrace := '';
    vStyleNo := THCStyle.RsNull;
    vParaNo := THCStyle.RsNull;
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

    if vData.Items[vData.SelectInfo.StartItemNo].StyleNo < THCStyle.RsNull then
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
        if Items[SelectInfo.StartItemNo] is TEmrTextItem then  // �ı�
        begin
          vEmrTextItem := Items[SelectInfo.StartItemNo] as TEmrTextItem;
          vText := vEmrTextItem.GetTextPart(SelectInfo.StartItemOffset, 1);
          vStyleNo := vEmrTextItem.StyleNo;
          vParaNo := vEmrTextItem.ParaNo;
          vCurStyleEx := vEmrTextItem.StyleEx;
          vCurTrace := vEmrTextItem[TDeProp.Trace];
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
        if Items[SelectInfo.StartItemNo] is TEmrTextItem then  // �ı�
        begin
          vEmrTextItem := Items[SelectInfo.StartItemNo] as TEmrTextItem;
          vText := vEmrTextItem.GetTextPart(SelectInfo.StartItemOffset + 1, 1);
          vStyleNo := vEmrTextItem.StyleNo;
          vParaNo := vEmrTextItem.ParaNo;
          vCurStyleEx := vEmrTextItem.StyleEx;
          vCurTrace := vEmrTextItem[TDeProp.Trace];
        end;
      end;
    end;

    // ɾ�����������Ժۼ�����ʽ����
    Self.BeginUpdate;
    try
      inherited KeyDown(Key, Shift);

      if (cesTrace in FStates) and (vText <> '') then  // ��ɾ��������
      begin
        if (vCurStyleEx = TStyleExtra.cseAdd) and (vCurTrace = '') then Exit;  // �����δ��Ч�ۼ�����ֱ��ɾ��

        // ����ɾ���ַ���Ӧ��Item
        vEmrTextItem := TEmrTextItem.CreateByText(vText);
        vEmrTextItem.StyleNo := vStyleNo;  // Style.CurStyleNo;
        vEmrTextItem.ParaNo := vParaNo;  // Style.CurParaNo;

        if (vCurStyleEx = TStyleExtra.cseDel) and (vCurTrace = '') then  // ԭ����ɾ��δ��Ч�ۼ�
          vEmrTextItem.StyleEx := TStyleExtra.cseNone  // ȡ��ɾ���ۼ�
        else  // ����ɾ���ۼ�
          vEmrTextItem.StyleEx := TStyleExtra.cseDel;

        // ����ɾ���ۼ�Item
        vCurItem := vData.Items[vData.SelectInfo.StartItemNo];
        if (vData.SelectInfo.StartItemOffset = 0) then  // ��Item��ǰ��
        begin
          if vEmrTextItem.CanConcatItems(vCurItem) then // ���Ժϲ�
          begin
            vCurItem.Text := vEmrTextItem.Text + vCurItem.Text;

            if Key = VK_DELETE then  // ��ɾ
              vData.SelectInfo.StartItemOffset := vData.SelectInfo.StartItemOffset + 1;

            Self.ActiveSection.ReFormatActiveItem;
          end
          else  // ���ܺϲ�
          begin
            vEmrTextItem.ParaFirst := vCurItem.ParaFirst;
            vCurItem.ParaFirst := False;
            vData.InsertItem(vEmrTextItem);
            if Key = VK_BACK then  // ��ɾ
              vData.SelectInfo.StartItemOffset := vData.SelectInfo.StartItemOffset - 1;
          end;
        end
        else
        if vData.SelectInfo.StartItemOffset = vCurItem.Length then  // ��Item�����
        begin
          if vCurItem.CanConcatItems(vEmrTextItem) then // ���Ժϲ�
          begin
            vCurItem.Text := vCurItem.Text + vEmrTextItem.Text;

            if Key = VK_DELETE then  // ��ɾ
              vData.SelectInfo.StartItemOffset := vData.SelectInfo.StartItemOffset + 1;

            Self.ActiveSection.ReFormatActiveItem;
          end
          else  // �����Ժϲ�
          begin
            vData.InsertItem(vEmrTextItem);
            if Key = VK_BACK then  // ��ɾ
              vData.SelectInfo.StartItemOffset := vData.SelectInfo.StartItemOffset - 1;
          end;
        end
        else  // ��Item�м�
        begin
          vData.InsertItem(vEmrTextItem);
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
  vData: THCCustomRichData;
  vEmrTraceItem: TEmrTextItem;
begin
  if cesTrace in FStates then
  begin
    if IsKeyPressWant(Key) then
    begin
      vData := Self.ActiveSection.ActiveData.GetTopLevelData;

      if vData.SelectInfo.StartItemNo < 0 then Exit;

      if vData.SelectExists then
        Self.DisSelect
      else
      begin
        // ������Ӻۼ�Ԫ��
        vEmrTraceItem := TEmrTextItem.CreateByText(Key);
        vEmrTraceItem.StyleNo := Style.CurStyleNo;
        vEmrTraceItem.ParaNo := Style.CurParaNo;
        vEmrTraceItem.StyleEx := TStyleExtra.cseAdd;

        Self.InsertItem(vEmrTraceItem);
      end;

      Exit;
    end;
  end;
  inherited KeyPress(Key);
end;

procedure TEmrView.LoadFromStream(const AStream: TStream);
begin
  Include(FStates, cesLoading);
  try
    inherited LoadFromStream(AStream);
  finally
    Exclude(FStates, cesLoading);
  end;
end;

procedure TEmrView.PrintCurPageByActiveLine(const APrintHeader, APrintFooter: Boolean);
var
  vScaleX, vScaleY: Single;

  {$REGION 'SetPrintBySectionInfo'}
  procedure SetPrintBySectionInfo(const ASectionIndex: Integer);
  var
    vDevice: Array[0..(cchDeviceName - 1)] of Char;
    vDriver: Array[0..(MAX_PATH - 1)] of Char;
    vPort: Array[0..32] of Char;
    vHDMode: THandle;
    vPDMode: PDevMode;
  begin
    Printer.GetPrinter(vDevice, vDriver, vPort, vHDMode);
    if vHDMode <> 0 then
    begin
      // ��ȡָ��DeviceMode��ָ��
      vPDMode := GlobalLock(vHDMode);
      if vPDMode <> nil then
      begin
        {vOlddmPaperSize := vPDMode^.dmPaperSize;
        vOlddmPaperLength := vPDMode^.dmPaperLength;
        vOlddmPaperWidth := vPDMode^.dmPaperWidth;}
        // ���ֳ��óߴ��ֱ�����ö�Ӧ�������B5Ϊ�� ��� 0.4cm ���ȹ���
        vPDMode^.dmPaperSize := Self.Sections[ASectionIndex].PaperSize;
        if vPDMode^.dmPaperSize = DMPAPER_USER then
        begin
          vPDMode^.dmPaperSize := DMPAPER_USER;  // �Զ���ֽ��
          vPDMode^.dmPaperLength := Round(Self.Sections[ASectionIndex].PaperHeight * 10); //ֽ������ñ������ֽ�ŵĳ�����
          vPDMode^.dmPaperWidth := Round(Self.Sections[ASectionIndex].PaperWidth * 10);   //ֽ��
          vPDMode^.dmFields := vPDMode^.dmFields or DM_PAPERSIZE or DM_PAPERLENGTH or DM_PAPERWIDTH;
        end
      end;

      ResetDC(Printer.Handle, vPDMode^);
      GlobalUnlock(vHDMode);
      //Printer.SetPrinter(vDevice, vDriver, vPort, vHDMode);
    end;
  end;
  {$ENDREGION}

  procedure ZoomRect(var ARect: TRect);
  begin
    ARect.Left := Round(ARect.Left * vScaleX);
    ARect.Top := Round(ARect.Top * vScaleY);
    ARect.Right := Round(ARect.Right * vScaleX);
    ARect.Bottom := Round(ARect.Bottom * vScaleY);
  end;

var
  vPt: TPoint;
  vPageCanvas: TCanvas;
  vPrintWidth, vPrintHeight, vPrintOffsetX, vPrintOffsetY: Integer;
  vMarginLeft, vMarginRight: Integer;
  vRect: TRect;
  vPaintInfo: TSectionPaintInfo;
begin
  vPrintOffsetX := GetDeviceCaps(Printer.Handle, PHYSICALOFFSETX);  // 90
  vPrintOffsetY := GetDeviceCaps(Printer.Handle, PHYSICALOFFSETY);  // 99
  vPrintWidth := GetDeviceCaps(Printer.Handle, PHYSICALWIDTH);
  vPrintHeight := GetDeviceCaps(Printer.Handle, PHYSICALHEIGHT);
  vScaleX := vPrintWidth / Self.ActiveSection.PageWidthPix;
  vScaleY := vPrintHeight / Self.ActiveSection.PageHeightPix;
  SetPrintBySectionInfo(Self.ActiveSectionIndex);

  Printer.BeginDoc;
  try
    vPaintInfo := TSectionPaintInfo.Create;
    vPaintInfo.Print := True;
    vPaintInfo.SectionIndex := Self.ActiveSectionIndex;
    vPaintInfo.PageIndex := Self.ActiveSection.ActivePageIndex;

    vPageCanvas := TCanvas.Create;
    try
      vPageCanvas.Handle := Printer.Canvas.Handle;  // Ϊʲô����vPageCanvas�н��ӡ�Ͳ����أ�

      Self.ActiveSection.PaintPage(Self.ActiveSection.ActivePageIndex, vPrintOffsetX, vPrintOffsetY,
        Self.ActiveSection.PageWidthPix, Self.ActiveSection.PageHeightPix,
        vScaleX, vScaleY, vPageCanvas, vPaintInfo);

      if Self.ActiveSection.ActiveData = Self.ActiveSection.PageData then
      begin
        vPt := Self.ActiveSection.GetActiveDrawItemCoord;
        vPt.Y := vPt.Y - ActiveSection.GetPageDataFmtTop(Self.ActiveSection.ActivePageIndex);
      end;
      vPageCanvas.Brush.Color := clRed;
      Self.ActiveSection.GetPageMarginLeftAndRight(Self.ActiveSection.ActivePageIndex, vMarginLeft, vMarginRight);
      if APrintHeader then  // ��ӡҳü
        vRect := Bounds(vPrintOffsetX + vMarginLeft,
          vPrintOffsetY + Self.ActiveSection.GetHeaderAreaHeight,
          Self.ActiveSection.PageWidthPix - vMarginLeft - vMarginRight, vPt.Y)
      else
        vRect := Bounds(vPrintOffsetX + vMarginLeft, vPrintOffsetY,
          Self.ActiveSection.PageWidthPix - vMarginLeft - vMarginRight,
          Self.ActiveSection.GetHeaderAreaHeight + vPt.Y);

      ZoomRect(vRect);
      vPageCanvas.FillRect(vRect);

      if not APrintFooter then
      begin
        vRect := Bounds(vPrintOffsetX + vMarginLeft,
          vPrintOffsetY + Self.ActiveSection.PageHeightPix - Self.ActiveSection.PageMarginBottomPix,
          Self.ActiveSection.PageWidthPix - vMarginLeft - vMarginRight,
          Self.ActiveSection.PageMarginBottomPix);
        ZoomRect(vRect);
        vPageCanvas.FillRect(vRect);
      end;
    finally
      vPageCanvas.Handle := 0;
      vPageCanvas.Free;
      vPaintInfo.Free;
    end;
  finally
    Printer.EndDoc;
  end;
end;

procedure TEmrView.SetTrace(const Value: Boolean);
begin
  if Value then
    Include(FStates, cesTrace)
  else
    Exclude(FStates, cesTrace);
end;

procedure TEmrView.TraverseItem(const ATraverse: TItemTraverse);
var
  i: Integer;
begin
  for i := 0 to Self.Sections.Count - 1 do
  begin
    with Self.Sections[i] do
    begin
      Header.TraverseItem(ATraverse);
      Footer.TraverseItem(ATraverse);
      PageData.TraverseItem(ATraverse);
    end;
  end;
end;

end.
