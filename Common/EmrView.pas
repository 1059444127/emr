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
  Windows, Classes, Controls, Graphics, HCView, HCStyle, HCItem, HCTextItem,
  HCDrawItem, HCCustomData, HCCustomRichData, HCRichData, HCSectionData, EmrElementItem,
  HCCommon, HCRectItem, EmrGroupItem, System.Generics.Collections;

type
  TEmrState = (cesLoading, cesTrace);
  TEmrStates = set of TEmrState;

  TEmrView = class(THCView)
  private
    FStates: TEmrStates;
    procedure DoSectionCreateItem(Sender: TObject);  // SenderΪTDeItem
    procedure InsertEmrTraceItem(const AText: string);
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function DoInsertText(const AText: string): Boolean; override;
    procedure DoSaveBefor(const AStream: TStream); override;
    procedure DoSaveAfter(const AStream: TStream); override;
    procedure DoLoadBefor(const AStream: TStream; const AFileVersion: Word); override;
    procedure DoLoadAfter(const AStream: TStream; const AFileVersion: Word); override;
    procedure DoSectionItemPaintAfter(const AData: THCCustomData;
      const ADrawItemIndex: Integer; const ADrawRect: TRect;
      const ADataDrawLeft, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;

    procedure DoUpdateViewBefor(const ACanvas: TCanvas);
    procedure DoUpdateViewAfter(const ACanvas: TCanvas);
//    procedure DoSectionDrawItemPaintAfter(const AData: THCCustomData;
//      const ADrawItemNo: Integer; const ADrawRect: TRect; const ADataDrawLeft,
//      ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
//      const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
    procedure LoadFromStream(const AStream: TStream); override;
    //
    function GetTrace: Boolean;
    procedure SetTrace(const Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetActiveDrawItemCoord: TPoint;

    /// <summary> �ӵ�ǰ�д�ӡ��ǰҳ </summary>
    /// <param name="APrintHeader"></param>
    /// <param name="APrintFooter"></param>
    procedure PrintCurPageByActiveLine(const APrintHeader, APrintFooter: Boolean);

    procedure TraverseItem(const ATraverse: TItemTraverse);
    function InsertDeGroup(const ADeGroup: TDeGroup): Boolean;
    function InsertDeItem(const ADeItem: TDeItem): Boolean;
    function NewDeItem(const AText: string): TDeItem;

    /// <summary> ȡָ�����е��ı����� </summary>
    function GetDataDomainText(const AData: THCRichData;
      const ADomainStartNo, ADomainEndNo: Integer): string;

    /// <summary> �ӵ�ǰ����ʼλ����ǰ��ͬIndex������ </summary>
    function GetDataForwardDomainText(const AData: THCRichData;
      const ADomainStartNo: Integer): string;

    /// <summary> �滻ָ��������� </summary>
    procedure SetDataDomainText(const AData: THCRichData;
      const ADomainStartNo: Integer; const AText: string);

    property Trace: Boolean read GetTrace write SetTrace;
  published
    property Align;
  end;

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
  HCDefaultTextItemClass := TDeItem;
  HCDefaultDomainItemClass := TDeGroup;
  inherited Create(AOwner);
  Self.Width := 100;
  Self.Height := 100;
  Self.OnSectionCreateItem := DoSectionCreateItem;
  Self.OnUpdateViewBefor := DoUpdateViewBefor;
  Self.OnUpdateViewAfter := DoUpdateViewAfter;
end;

destructor TEmrView.Destroy;
begin
  inherited Destroy;
end;

procedure TEmrView.DoSectionCreateItem(Sender: TObject);
begin
  if (not (cesLoading in FStates)) and (cesTrace in FStates) then
    (Sender as TDeItem).StyleEx := TStyleExtra.cseAdd;
end;

function TEmrView.DoInsertText(const AText: string): Boolean;
begin
  Result := False;
  if cesTrace in FStates then
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

procedure TEmrView.DoSectionItemPaintAfter(const AData: THCCustomData;
  const ADrawItemIndex: Integer; const ADrawRect: TRect; const ADataDrawLeft,
  ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vItem: THCCustomItem;
  vDeItem: TDeItem;
begin
  if Self.ShowAnnotation then  // ��ʾ��ע
  begin
    vItem := AData.Items[AData.DrawItems[ADrawItemIndex].ItemNo];
    if vItem.StyleNo > THCStyle.RsNull then
    begin
      vDeItem := vItem as TDeItem;
      if (vDeItem.StyleEx <> TStyleExtra.cseNone)
        and (vDeItem.FirstDItemNo = ADrawItemIndex)
      then  // �����ע
      begin
        if vDeItem.StyleEx = TStyleExtra.cseDel then
          Self.Annotates.AddAnnotation(ADrawRect, vDeItem.Text + sLineBreak + vDeItem[TDeProp.Trace])
        else
          Self.Annotates.AddAnnotation(ADrawRect, vDeItem.Text + sLineBreak + vDeItem[TDeProp.Trace]);
      end;
    end;
  end;

  inherited DoSectionItemPaintAfter(AData, ADrawItemIndex, ADrawRect, ADataDrawLeft,
    ADataDrawBottom, ADataScreenTop, ADataScreenBottom, ACanvas, APaintInfo);
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

function TEmrView.GetDataForwardDomainText(const AData: THCRichData;
  const ADomainStartNo: Integer): string;
var
  i, vBeginNo, vEndNo: Integer;
  vDeGroup: TDeGroup;
  vDeIndex: string;
begin
  Result := '';

  vBeginNo := -1;
  vEndNo := -1;
  vDeIndex := (AData.Items[ADomainStartNo] as TDeGroup)[TDeProp.Index];

  for i := 0 to ADomainStartNo - 1 do  // ����ʼ
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
    for i := vBeginNo + 1 to ADomainStartNo - 1 do
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
      Result := GetDataDomainText(AData, vBeginNo, vEndNo);
  end;
end;

function TEmrView.GetDataDomainText(const AData: THCRichData;
  const ADomainStartNo, ADomainEndNo: Integer): string;
var
  i: Integer;
begin
  Result := '';
  for i := ADomainStartNo + 1 to ADomainEndNo - 1 do
    Result := Result + AData.Items[i].Text;
end;

function TEmrView.GetTrace: Boolean;
begin
  Result := cesTrace in FStates;
end;

function TEmrView.InsertDeGroup(const ADeGroup: TDeGroup): Boolean;
var
  vGroupItem: TDeGroup;
  vTopData: THCRichData;
  vDomainLevel: Byte;
begin
  Result := False;

  vTopData := Self.ActiveSectionTopData as THCRichData;
  if vTopData <> nil then
  begin
    if vTopData.ActiveDomain <> nil then
    begin
      if (vTopData.Items[vTopData.ActiveDomain.BeginNo] as TDeGroup)[TDeProp.Index] = ADeGroup[TDeProp.Index] then
        Exit;  // ��Index���в����ٲ�����ͬIndex����

      vDomainLevel := (vTopData.Items[vTopData.ActiveDomain.BeginNo] as TDeGroup).Level + 1;
    end
    else
      vDomainLevel := 0;


    Self.BeginUpdate;
    try
      // ͷ
      vGroupItem := TDeGroup.Create(vTopData);
      vGroupItem.Level := vDomainLevel;
      vGroupItem.Assign(ADeGroup);
      vGroupItem.MarkType := cmtBeg;
      InsertItem(vGroupItem);  // [ ����ʹ��vTopDataֱ�Ӳ��룬���䲻�ܴ������¼���ҳ��

      // β
      vGroupItem := TDeGroup.Create(vTopData);
      vGroupItem.Level := vDomainLevel;
      vGroupItem.Assign(ADeGroup);
      vGroupItem.MarkType := cmtEnd;
      InsertItem(vGroupItem);  // ]  ����ʹ��vTopDataֱ�Ӳ��룬���䲻�ܴ������¼���ҳ��

      // �ı����� �Ȳ���[]���������м����item����ֹitem�ͺ�������ݺϲ�
      {vInsertIndex := vTopData.SelectInfo.StartItemNo;
      vTextItem := TDeItem.CreateByText(vGroupItem[DEName]);
      vTextItem.StyleNo := Style.CurStyleNo;
      vTextItem.ParaNo := Style.CurParaNo;
      vTopData.InsertItem(vInsertIndex, vTextItem);}
    finally
      Self.EndUpdate;
    end;
  end;
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
  vData: THCCustomRichData;
  vText, vCurTrace: string;
  vStyleNo, vParaNo: Integer;
  vDeItem: TDeItem;
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

      if (cesTrace in FStates) and (vText <> '') then  // ��ɾ��������
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
  vData: THCCustomRichData;
begin
  if cesTrace in FStates then
  begin
    if IsKeyPressWant(Key) then
    begin
      vData := Self.ActiveSectionTopData;

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
  Include(FStates, cesLoading);
  try
    inherited LoadFromStream(AStream);
  finally
    Exclude(FStates, cesLoading);
  end;
end;

function TEmrView.NewDeItem(const AText: string): TDeItem;
begin
  Result := TDeItem.CreateByText(AText);
  if Self.Style.CurStyleNo > THCStyle.RsNull then
    Result.StyleNo := Self.Style.CurStyleNo
  else
    Result.StyleNo := 0;

  Result.ParaNo := Self.Style.CurParaNo;
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
    vPaintInfo.ScaleX := vPrintWidth / Self.ActiveSection.PageWidthPix;
    vPaintInfo.ScaleY := vPrintHeight / Self.ActiveSection.PageHeightPix;
    vPaintInfo.WindowWidth := vPrintWidth;  // FSections[vStartSection].PageWidthPix;
    vPaintInfo.WindowHeight := vPrintHeight;  // FSections[vStartSection].PageHeightPix;

    vPageCanvas := TCanvas.Create;
    try
      vPageCanvas.Handle := Printer.Canvas.Handle;  // Ϊʲô����vPageCanvas�н��ӡ�Ͳ����أ�

      Self.ActiveSection.PaintPage(Self.ActiveSection.ActivePageIndex,
        vPrintOffsetX, vPrintOffsetY, vPageCanvas, vPaintInfo);

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

procedure TEmrView.SetDataDomainText(const AData: THCRichData;
  const ADomainStartNo: Integer; const AText: string);
var
  i, vIgnore, vEndNo: Integer;
begin
  // ��ָ����������Item��Χ
  vEndNo := -1;
  vIgnore := 0;

  for i := ADomainStartNo + 1 to AData.Items.Count - 1 do
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
      AData.SetSelectBound(ADomainStartNo, OffsetAfter, vEndNo, OffsetBefor);
      AData.InsertText(AText);
    finally
      Self.EndUpdate
    end;
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
