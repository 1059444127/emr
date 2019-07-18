{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit frm_Record;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.XPMan,
  System.ImageList, Vcl.ImgList, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ToolWin,
  System.Generics.Collections, HCEmrView, HCView, HCRichData, HCItem, HCCustomData,
  HCEmrGroupItem, HCEmrElementItem, HCDrawItem, HCSection, frm_RecordPop, System.Actions,
  frm_DataElement, Vcl.ActnList, Vcl.Buttons, HCCommon;

type
  TTravTag = class(TObject)
    public
      class function Contains(const ATags, ATag: Integer): Boolean;
    const
      WriteTraceInfo = 1;  // �������ݣ�Ϊ�ºۼ����Ӻۼ���Ϣ
      HideTrace = 1 shl 1;  // ���غۼ�����
      //DataSetElement = 1 shl 2;  // ������ݼ���Ҫ������Ԫ
  end;

  //TTraverseTags = set of TTraverseTag;
  TDeItemInsertEvent = procedure(const AEmrView: THCEmrView; const ASection: THCSection;
    const AData: THCCustomData; const AItem: THCCustomItem) of object;

  TDeItemSetTextEvent = procedure(Sender: TObject; const ADeItem: TDeItem;
    var AText: string; var ACancel: Boolean) of object;

  TfrmRecord = class(TForm)
    tlbTool: TToolBar;
    btnFile: TToolButton;
    btnprint: TToolButton;
    btn3: TToolButton;
    cbbZoom: TComboBox;
    btnSymmetryMargin: TToolButton;
    btn4: TToolButton;
    cbbFont: TComboBox;
    btn1: TToolButton;
    cbbFontSize: TComboBox;
    cbBackColor: TColorBox;
    cbFontColor: TColorBox;
    btnBold: TToolButton;
    btnItalic: TToolButton;
    btnUnderLine: TToolButton;
    btnStrikeOut: TToolButton;
    btnSuperScript: TToolButton;
    btnSubScript: TToolButton;
    btnAlignLeft: TToolButton;
    btnAlignCenter: TToolButton;
    btnAlignRight: TToolButton;
    btnAlignJustify: TToolButton;
    btnAlignScatter: TToolButton;
    btnLineSpace: TToolButton;
    btn9: TToolButton;
    sbStatus: TStatusBar;
    il1: TImageList;
    pmView: TPopupMenu;
    mniCut: TMenuItem;
    mniCopy: TMenuItem;
    mniPaste: TMenuItem;
    mniTable: TMenuItem;
    mniInsertRowTop: TMenuItem;
    mniInsertRowBottom: TMenuItem;
    mniInsertColLeft: TMenuItem;
    mniInsertColRight: TMenuItem;
    mniDeleteCurRow: TMenuItem;
    mniDeleteCurCol: TMenuItem;
    mniN25: TMenuItem;
    mniDisBorder: TMenuItem;
    mniPara: TMenuItem;
    pmLineSpace: TPopupMenu;
    mniLineSpace100: TMenuItem;
    mniLineSpace150: TMenuItem;
    mniLineSpace200: TMenuItem;
    pmFile: TPopupMenu;
    mniOpen: TMenuItem;
    mniSave: TMenuItem;
    mniSaveAs: TMenuItem;
    mniPageSet: TMenuItem;
    mniPrint: TMenuItem;
    mniMerge: TMenuItem;
    mniClear: TMenuItem;
    pmInsert: TPopupMenu;
    mniInsertTable: TMenuItem;
    mniN4: TMenuItem;
    mniCheckbox: TMenuItem;
    mniInsertImage: TMenuItem;
    mniN7: TMenuItem;
    mniYueJing: TMenuItem;
    mniInsertLine: TMenuItem;
    mniPageBreak: TMenuItem;
    mniSection: TMenuItem;
    mniInsertGif: TMenuItem;
    actlst: TActionList;
    actSave: TAction;
    mniDeItem: TMenuItem;
    mniDeGroup: TMenuItem;
    mniDeItemProp: TMenuItem;
    mniDeleteDeItem: TMenuItem;
    mniDeleteGroup: TMenuItem;
    mniN13: TMenuItem;
    mniN14: TMenuItem;
    mniN15: TMenuItem;
    mniTooth: TMenuItem;
    mniEditItem: TMenuItem;
    mniReSync: TMenuItem;
    mniLineSpace115: TMenuItem;
    mniControlItem: TMenuItem;
    actCut: TAction;
    actCopy: TAction;
    actPaste: TAction;
    mniSplitRow: TMenuItem;
    mniSplitCol: TMenuItem;
    mniN21: TMenuItem;
    mniCombobox: TMenuItem;
    mniTableProperty: TMenuItem;
    mniFangJiao: TMenuItem;
    mniN5: TMenuItem;
    btnRightIndent: TToolButton;
    btnLeftIndent: TToolButton;
    btnUndo: TToolButton;
    btnRedo: TToolButton;
    actUndo: TAction;
    actRedo: TAction;
    btnSave: TSpeedButton;
    btnInsert: TSpeedButton;
    mniSplit: TMenuItem;
    mniDeleteProtect: TMenuItem;
    mniSaveStructure: TMenuItem;
    mniFastPrint: TMenuItem;
    mniPirntPreview: TMenuItem;
    mniPrintCurLine: TMenuItem;
    mniPrintSelect: TMenuItem;
    mniN20: TMenuItem;
    mniInsertDeItem: TMenuItem;
    mniHideTrace: TMenuItem;
    mniN1: TMenuItem;
    mniN2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBoldClick(Sender: TObject);
    procedure btnprintClick(Sender: TObject);
    procedure cbbZoomChange(Sender: TObject);
    procedure btnSymmetryMarginClick(Sender: TObject);
    procedure cbbFontChange(Sender: TObject);
    procedure cbbFontSizeChange(Sender: TObject);
    procedure cbBackColorChange(Sender: TObject);
    procedure cbFontColorChange(Sender: TObject);
    procedure btnAlignLeftClick(Sender: TObject);
    procedure mniLineSpace100Click(Sender: TObject);
    procedure mniOpenClick(Sender: TObject);
    procedure mniMergeClick(Sender: TObject);
    procedure mniInsertRowTopClick(Sender: TObject);
    procedure mniInsertRowBottomClick(Sender: TObject);
    procedure mniInsertColLeftClick(Sender: TObject);
    procedure mniInsertColRightClick(Sender: TObject);
    procedure mniDeleteCurRowClick(Sender: TObject);
    procedure mniDeleteCurColClick(Sender: TObject);
    procedure mniDisBorderClick(Sender: TObject);
    procedure mniParaClick(Sender: TObject);
    procedure mniSaveAsClick(Sender: TObject);
    procedure pmViewPopup(Sender: TObject);
    procedure mniClearClick(Sender: TObject);
    procedure mniInsertTableClick(Sender: TObject);
    procedure mniCheckboxClick(Sender: TObject);
    procedure mniInsertImageClick(Sender: TObject);
    procedure mniYueJingClick(Sender: TObject);
    procedure mniInsertLineClick(Sender: TObject);
    procedure mniPageBreakClick(Sender: TObject);
    procedure mniSectionClick(Sender: TObject);
    procedure mniInsertGifClick(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mniDeleteGroupClick(Sender: TObject);
    procedure mniDeleteDeItemClick(Sender: TObject);
    procedure mniPageSetClick(Sender: TObject);
    procedure mniToothClick(Sender: TObject);
    procedure mniEditItemClick(Sender: TObject);
    procedure mniReSyncClick(Sender: TObject);
    procedure mniSplitRowClick(Sender: TObject);
    procedure mniSplitColClick(Sender: TObject);
    procedure mniComboboxClick(Sender: TObject);
    procedure mniControlItemClick(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure mniTablePropertyClick(Sender: TObject);
    procedure mniFangJiaoClick(Sender: TObject);
    procedure mniN5Click(Sender: TObject);
    procedure actUndoExecute(Sender: TObject);
    procedure actRedoExecute(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure mniDeItemPropClick(Sender: TObject);
    procedure mniDeleteProtectClick(Sender: TObject);
    procedure mniSaveStructureClick(Sender: TObject);
    procedure mniPrintCurLineClick(Sender: TObject);
    procedure mniFastPrintClick(Sender: TObject);
    procedure mniPirntPreviewClick(Sender: TObject);
    procedure mniPrintSelectClick(Sender: TObject);
    procedure mniInsertDeItemClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mniHideTraceClick(Sender: TObject);
    procedure pmFilePopup(Sender: TObject);
  private
    { Private declarations }
    FMouseDownTick: Cardinal;
    FfrmRecordPop: TfrmRecordPop;
    FEmrView: THCEmrView;

    FOnSave, FOnSaveStructure, FOnChangedSwitch, FOnReadOnlySwitch: TNotifyEvent;
    FOnInsertDeItem: TDeItemInsertEvent;
    FOnSetDeItemText: TDeItemSetTextEvent;

    /// <summary> ��������ۼ����ػ���ʾ </summary>
    procedure DoHideTraceTraverse(const AData: THCCustomData;
      const AItemNo, ATags: Integer; var AStop: Boolean);

    /// <summary> ���õ�ǰ�Ƿ����غۼ� </summary>
    procedure SetHideTrace(const Value: Boolean);

    /// <summary> ��ȡ�ĵ���ǰ��괦����Ϣ </summary>
    procedure GetPagesAndActive;

    /// <summary> �ĵ����λ�÷����仯ʱ���� </summary>
    procedure DoCaretChange(Sender: TObject);

    /// <summary> �ĵ��䶯״̬�����仯ʱ���� </summary>
    procedure DoChangedSwitch(Sender: TObject);

    /// <summary> �ĵ��༭ʱֻ����ǰλ�ò��ɱ༭ʱ���� </summary>
    procedure DoCanNotEdit(Sender: TObject);

    /// <summary> �ĵ�ֻ��״̬�����仯ʱ���� </summary>
    procedure DoReadOnlySwitch(Sender: TObject);

    /// <summary> �ĵ���ֱ����������ʱ���� </summary>
    procedure DoVerScroll(Sender: TObject);

    /// <summary> ����ҳ����ǰ�¼� </summary>
    procedure DoPaintPaperBefor(const Sender: TObject; const APageIndex: Integer;
      const ARect: TRect; const ACanvas: TCanvas; const APaintInfo: TSectionPaintInfo);

    /// <summary> ���õ�ǰ����Ԫ���ı����� </summary>
    procedure DoSetActiveDeItemText(const ADeItem: TDeItem; const AText: string; var ACancel: Boolean);

    /// <summary> ���õ�ǰ����Ԫ������Ϊ��չ���� </summary>
    procedure DoSetActiveDeItemExtra(const ADeItem: TDeItem; const AStream: TStream);

    /// <summary> ��ǰλ���ı���ʽ����һλ�ò�һ��ʱ�¼� </summary>
    procedure CurTextStyleChange(const ANewStyleNo: Integer);

    /// <summary> ��ǰλ�ö���ʽ����һλ�ò�һ��ʱ�¼� </summary>
    procedure CurParaStyleChange(const ANewStyleNo: Integer);

    /// <summary> ��ȡ����Ԫֵ������ </summary>
    function PopupForm: TfrmRecordPop;

    /// <summary> ��Ԫֵ������ر��¼� </summary>
    procedure PopupFormClose;
  protected
    procedure DoEmrViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoEmrViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    /// <summary> �������µ�Item����ʱ���� </summary>
    procedure DoInsertItem(const Sender: TObject; const AData: THCCustomData;
      const AItem: THCCustomItem);

    /// <summary> ���ñ��没������ </summary>
    procedure DoSave;

    /// <summary> ���ñ��没���ṹ���� </summary>
    procedure DoSaveStructure;
  public
    { Public declarations }
    ObjectData: Pointer;
    FfrmDataElement: TfrmDataElement;

    /// <summary> ���ع����� </summary>
    procedure HideToolbar;

    /// <summary> ����һ������Ԫ </summary>
    /// <param name="AIndex">����ԪΨһ��ʶ</param>
    /// <param name="AName">����Ԫ����</param>
    procedure InsertDeItem(const AIndex, AName: string);

    /// <summary> �����ĵ�ָ��Data��Item </summary>
    /// <param name="ATravEvent">ÿ������һ��Itemʱ�������¼�</param>
    /// <param name="AAreas">Ҫ������Data</param>
    /// <param name="ATag">������ʶ</param>
    procedure TraverseElement(const ATravEvent: TTraverseItemEvent;
      const AAreas: TSectionAreas = [saHeader, saPage, saFooter]; const ATag: Integer = 0);

    /// <summary> �����༭�� </summary>
    property EmrView: THCEmrView read FEmrView;

    /// <summary> ���没��ʱ���õķ��� </summary>
    property OnSave: TNotifyEvent read FOnSave write FOnSave;

    /// <summary> ���没���ṹʱ���õķ��� </summary>
    property OnSaveStructure: TNotifyEvent read FOnSaveStructure write FOnSaveStructure;

    /// <summary> �ĵ�Change״̬�л�ʱ���õķ��� </summary>
    property OnChangedSwitch: TNotifyEvent read FOnChangedSwitch write FOnChangedSwitch;

    /// <summary> ��ֻ�������б仯ʱ���õķ��� </summary>
    property OnReadOnlySwitch: TNotifyEvent read FOnReadOnlySwitch write FOnReadOnlySwitch;

    /// <summary> �����µ�Item����ʱ���õķ��� </summary>
    property OnInsertDeItem: TDeItemInsertEvent read FOnInsertDeItem write FOnInsertDeItem;

    /// <summary> ����DeItemֵʱ�����ķ��� </summary>
    property OnSetDeItemText: TDeItemSetTextEvent read FOnSetDeItemText write FOnSetDeItemText;
  end;

implementation

uses
  Vcl.Clipbrd, HCStyle, HCTextStyle, HCParaStyle, System.DateUtils, HCPrinters,
  frm_InsertTable, frm_Paragraph, HCRectItem, HCImageItem, HCGifItem, HCEmrYueJingItem,
  HCViewData, HCEmrToothItem, HCEmrFangJiaoItem, frm_PageSet, frm_DeControlProperty,
  frm_DeTableProperty, frm_TableBorderBackColor, frm_DeProperty, frm_PrintView,
  emr_Common;

{$R *.dfm}

procedure TfrmRecord.actCopyExecute(Sender: TObject);
begin
  FEmrView.Copy;
end;

procedure TfrmRecord.actCutExecute(Sender: TObject);
begin
  FEmrView.Cut;
end;

procedure TfrmRecord.actPasteExecute(Sender: TObject);
begin
  FEmrView.Paste;
end;

procedure TfrmRecord.actRedoExecute(Sender: TObject);
begin
  FEmrView.Redo;
end;

procedure TfrmRecord.actSaveExecute(Sender: TObject);
begin
  DoSave;
end;

procedure TfrmRecord.actUndoExecute(Sender: TObject);
begin
  FEmrView.Undo;
end;

procedure TfrmRecord.btnInsertClick(Sender: TObject);
var
  vPt: TPoint;
begin
  vPt := btnInsert.ClientToScreen(Point(0, btnInsert.Height));
  pmInsert.Popup(vPt.X, vPt.Y);
end;

procedure TfrmRecord.btnAlignLeftClick(Sender: TObject);
begin
  case (Sender as TToolButton).Tag of
    0: FEmrView.ApplyParaAlignHorz(TParaAlignHorz.pahLeft);
    1: FEmrView.ApplyParaAlignHorz(TParaAlignHorz.pahCenter);
    2: FEmrView.ApplyParaAlignHorz(TParaAlignHorz.pahRight);
    3: FEmrView.ApplyParaAlignHorz(TParaAlignHorz.pahJustify);  // ����
    4: FEmrView.ApplyParaAlignHorz(TParaAlignHorz.pahScatter);  // ��ɢ
    5: FEmrView.ApplyParaLeftIndent;
    6: FEmrView.ApplyParaLeftIndent(False);
  end;
end;

procedure TfrmRecord.btnBoldClick(Sender: TObject);
begin
  case (Sender as TToolButton).Tag of
    0: FEmrView.ApplyTextStyle(THCFontStyle.tsBold);
    1: FEmrView.ApplyTextStyle(THCFontStyle.tsItalic);
    2: FEmrView.ApplyTextStyle(THCFontStyle.tsUnderline);
    3: FEmrView.ApplyTextStyle(THCFontStyle.tsStrikeOut);
    4: FEmrView.ApplyTextStyle(THCFontStyle.tsSuperscript);
    5: FEmrView.ApplyTextStyle(THCFontStyle.tsSubscript);
  end;
end;

procedure TfrmRecord.btnprintClick(Sender: TObject);
var
  vPrintDlg: TPrintDialog;
begin
  vPrintDlg := TPrintDialog.Create(nil);
  try
    vPrintDlg.MaxPage := FEmrView.PageCount;
    if vPrintDlg.Execute then
      FEmrView.Print(HCPrinter.Printers[HCPrinter.PrinterIndex]);
  finally
    FreeAndNil(vPrintDlg);
  end;
end;

procedure TfrmRecord.btnSymmetryMarginClick(Sender: TObject);
begin
  FEmrView.SymmetryMargin := not FEmrView.SymmetryMargin;
end;

procedure TfrmRecord.cbbFontChange(Sender: TObject);
begin
  FEmrView.ApplyTextFontName(cbbFont.Text);
  if not FEmrView.Focused then
    FEmrView.SetFocus;
end;

procedure TfrmRecord.cbbFontSizeChange(Sender: TObject);
begin
  FEmrView.ApplyTextFontSize(GetFontSize(cbbFontSize.Text));
  if not FEmrView.Focused then
    FEmrView.SetFocus;
end;

procedure TfrmRecord.cbbZoomChange(Sender: TObject);
begin
  FEmrView.Zoom := (StrToInt(cbbZoom.Text) / 100);
end;

procedure TfrmRecord.cbBackColorChange(Sender: TObject);
begin
  FEmrView.ApplyTextBackColor(cbBackColor.Selected);
  if not FEmrView.Focused then
    FEmrView.SetFocus;
end;

procedure TfrmRecord.cbFontColorChange(Sender: TObject);
begin
  FEmrView.ApplyTextColor(cbFontColor.Selected);
  if not FEmrView.Focused then
    FEmrView.SetFocus;
end;

procedure TfrmRecord.CurParaStyleChange(const ANewStyleNo: Integer);
var
  vAlignHorz: TParaAlignHorz;
begin
  if ANewStyleNo >= 0 then
  begin
    vAlignHorz := FEmrView.Style.ParaStyles[ANewStyleNo].AlignHorz;

    btnAlignLeft.Down := vAlignHorz = TParaAlignHorz.pahLeft;
    btnAlignRight.Down := vAlignHorz = TParaAlignHorz.pahRight;
    btnAlignCenter.Down := vAlignHorz = TParaAlignHorz.pahCenter;
    btnAlignJustify.Down := vAlignHorz = TParaAlignHorz.pahJustify;
    btnAlignScatter.Down := vAlignHorz = TParaAlignHorz.pahScatter;

    case FEmrView.Style.ParaStyles[ANewStyleNo].LineSpaceMode of
      TParaLineSpaceMode.pls100: mniLineSpace100.Checked := True;
      TParaLineSpaceMode.pls115: mniLineSpace115.Checked := True;
      TParaLineSpaceMode.pls150: mniLineSpace150.Checked := True;
      TParaLineSpaceMode.pls200: mniLineSpace200.Checked := True;
    end;
  end;
end;

procedure TfrmRecord.CurTextStyleChange(const ANewStyleNo: Integer);
begin
  if ANewStyleNo >= 0 then
  begin
    cbbFont.ItemIndex := cbbFont.Items.IndexOf(FEmrView.Style.TextStyles[ANewStyleNo].Family);
    cbbFontSize.ItemIndex := cbbFontSize.Items.IndexOf(GetFontSizeStr(FEmrView.Style.TextStyles[ANewStyleNo].Size));
    btnBold.Down := tsBold in FEmrView.Style.TextStyles[ANewStyleNo].FontStyles;
    btnItalic.Down := tsItalic in FEmrView.Style.TextStyles[ANewStyleNo].FontStyles;
    btnUnderline.Down := tsUnderline in FEmrView.Style.TextStyles[ANewStyleNo].FontStyles;
    btnStrikeOut.Down := tsStrikeOut in FEmrView.Style.TextStyles[ANewStyleNo].FontStyles;
    btnSuperscript.Down := tsSuperscript in FEmrView.Style.TextStyles[ANewStyleNo].FontStyles;
    btnSubscript.Down := tsSubscript in FEmrView.Style.TextStyles[ANewStyleNo].FontStyles;
  end
  else
  begin
    btnBold.Down := False;
    btnItalic.Down := False;
    btnUnderline.Down := False;
    btnStrikeOut.Down := False;
    btnSuperscript.Down := False;
    btnSubscript.Down := False;
  end;
end;

procedure TfrmRecord.DoSetActiveDeItemExtra(const ADeItem: TDeItem; const AStream: TStream);
begin
  FEmrView.SetActiveItemExtra(AStream);
end;

procedure TfrmRecord.DoSetActiveDeItemText(const ADeItem: TDeItem; const AText: string; var ACancel: Boolean);
var
  vText: string;
begin
  if Assigned(FOnSetDeItemText) then
  begin
    vText := AText;
    FOnSetDeItemText(Self, ADeItem, vText, ACancel);
    if not ACancel then
      FEmrView.SetActiveItemText(vText);
  end
  else
    FEmrView.SetActiveItemText(AText);
  //FEmrView.ActiveSection.ReFormatActiveItem;
end;

procedure TfrmRecord.DoHideTraceTraverse(const AData: THCCustomData; const AItemNo,
  ATags: Integer; var AStop: Boolean);
var
  vDeItem: TDeItem;
begin
  if (not (AData.Items[AItemNo] is TDeItem))
    //or (not (AData.Items[AItemNo] is TDeGroup))
  then
    Exit;  // ֻ��Ԫ����Ч

  vDeItem := AData.Items[AItemNo] as TDeItem;
  if vDeItem.StyleEx = TStyleExtra.cseDel then
    vDeItem.Visible := not (ATags = TTravTag.HideTrace);  // ����/��ʾ�ۼ�
end;

procedure TfrmRecord.DoCanNotEdit(Sender: TObject);
begin
  ShowMessage('��ǰλ��ֻ�������ɱ༭��');
end;

procedure TfrmRecord.DoCaretChange(Sender: TObject);
begin
  GetPagesAndActive;

  CurTextStyleChange(FEmrView.CurStyleNo);
  CurParaStyleChange(FEmrView.CurParaNo);
end;

procedure TfrmRecord.DoChangedSwitch(Sender: TObject);
begin
  if Assigned(FOnChangedSwitch) then
    FOnChangedSwitch(Self);
end;

procedure TfrmRecord.DoInsertItem(const Sender: TObject;
  const AData: THCCustomData; const AItem: THCCustomItem);
begin
  if Assigned(FOnInsertDeItem) then
    FOnInsertDeItem(FEmrView, Sender as THCSection, AData, AItem);
end;

procedure TfrmRecord.DoEmrViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  PopupFormClose;
  FMouseDownTick := GetTickCount;
end;

function CalcTickCount(const AStart, AEnd: Cardinal): Cardinal;
begin
  if AEnd >= AStart then
    Result := AEnd - AStart
  else
    Result := High(Cardinal) - AStart + AEnd;
end;

procedure TfrmRecord.DoEmrViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  vActiveItem: THCCustomItem;
  vDeItem: TDeItem;
  vDeGroup: TDeGroup;
  vDeEdit: TDeEdit;
  vDeCombobox: TDeCombobox;
  vDeDateTimePicker: TDeDateTimePicker;
  vDeRadioGroup: TDeRadioGroup;
  vActiveDrawItem: THCCustomDrawItem;
  vPt: TPoint;
  vDrawItemRect: TRect;
  vInfo: string;
  vTopData: THCRichData;
begin
  vInfo := '';

  vActiveItem := FEmrView.GetTopLevelItem;
  if vActiveItem <> nil then
  begin
    if FEmrView.ActiveSection.ActiveData.ActiveDomain.BeginNo >= 0 then
    begin
      vDeGroup := FEmrView.ActiveSection.ActiveData.Items[
        FEmrView.ActiveSection.ActiveData.ActiveDomain.BeginNo] as TDeGroup;

      vInfo := vDeGroup[TDeProp.Name];
    end;

    if vActiveItem is TDeItem then
    begin
      vDeItem := vActiveItem as TDeItem;
      if vDeItem.StyleEx <> cseNone  then
        vInfo := vInfo + '-' + vDeItem.GetHint
      else
      if vDeItem.Active
        and (vDeItem[TDeProp.Index] <> '')
        and (not vDeItem.IsSelectComplate)
        and (not vDeItem.IsSelectPart)
        and (CalcTickCount(FMouseDownTick, GetTickCount) < 500)  // ����ѡ��Ի���
      then
      begin
        if ClientCache.FindDataElementByIndex(vDeItem[TDeProp.Index]) then
          vInfo := vInfo + '-' + ClientCache.DataElementDT.FieldByName('dename').AsString + '(' + vDeItem[TDeProp.Index] + ')'
        else
          vInfo := vInfo + '-[ȱ��Index]';

        if FEmrView.ActiveSection.ActiveData.ReadOnly then
        begin
          sbStatus.Panels[1].Text := vInfo;
          Exit;
        end;

        vPt := FEmrView.GetActiveDrawItemClientCoord;  // �õ����EmrView������
        vActiveDrawItem := FEmrView.GetTopLevelDrawItem;
        vDrawItemRect := vActiveDrawItem.Rect;
        vDrawItemRect := Bounds(vPt.X, vPt.Y, vDrawItemRect.Width, vDrawItemRect.Height);

        if PtInRect(vDrawItemRect, Point(X, Y)) then
        begin
          vPt.Y := vPt.Y + FEmrView.ZoomIn(vActiveDrawItem.Height);
          vPt.Offset(FEmrView.Left, FEmrView.Top);
          //PopupForm.Left := vPt.X + FEmrView.Left;
          //PopupForm.Top := vPt.Y + FEmrView.Top;
          vPt := ClientToScreen(vPt);

          PopupForm.PopupDeItem(vDeItem, vPt);
        end;
      end;
    end
    else
    if vActiveItem is TDeEdit then
    begin
      vDeEdit := vActiveItem as TDeEdit;
      if ClientCache.FindDataElementByIndex(vDeEdit[TDeProp.Index]) then
        vInfo := vInfo + '-' + vDeEdit[TDeProp.Name] + '(' + vDeEdit[TDeProp.Index] + ')'
      else
        vInfo := vInfo + '-[ȱ��Index]';
    end
    else
    if vActiveItem is TDeCombobox then
    begin
      vDeCombobox := vActiveItem as TDeCombobox;
      if ClientCache.FindDataElementByIndex(vDeCombobox[TDeProp.Index]) then
        vInfo := vInfo + '-' + vDeCombobox[TDeProp.Name] + '(' + vDeCombobox[TDeProp.Index] + ')'
      else
        vInfo := vInfo + '-[ȱ��Index]';
    end
    else
    if vActiveItem is TDeDateTimePicker then
    begin
      vDeDateTimePicker := vActiveItem as TDeDateTimePicker;
      if ClientCache.FindDataElementByIndex(vDeDateTimePicker[TDeProp.Index]) then
        vInfo := vInfo + '-' + vDeDateTimePicker[TDeProp.Name] + '(' + vDeDateTimePicker[TDeProp.Index] + ')'
      else
        vInfo := vInfo + '-[ȱ��Index]';
    end;
  end;

  sbStatus.Panels[1].Text := vInfo;
end;

procedure TfrmRecord.DoPaintPaperBefor(const Sender: TObject;
  const APageIndex: Integer; const ARect: TRect; const ACanvas: TCanvas;
  const APaintInfo: TSectionPaintInfo);
begin
  if (not APaintInfo.Print) and THCSection(Sender).ReadOnly then
  begin
    ACanvas.Font.Size := 48;
    ACanvas.Font.Color := clMedGray;
    ACanvas.Font.Name := '����';
    ACanvas.TextOut(ARect.Left + 10, ARect.Top + 10, 'ֻ��');
  end;
end;

procedure TfrmRecord.DoReadOnlySwitch(Sender: TObject);
begin
  if Assigned(FOnReadOnlySwitch) then
    FOnReadOnlySwitch(Self);
end;

procedure TfrmRecord.DoSave;
begin
  if Assigned(FOnSave) then
    FOnSave(Self);
end;

procedure TfrmRecord.DoSaveStructure;
begin
  if Assigned(FOnSaveStructure) then
    FOnSaveStructure(Self);
end;

procedure TfrmRecord.DoVerScroll(Sender: TObject);
begin
  GetPagesAndActive;
  PopupFormClose;
end;

procedure TfrmRecord.FormCreate(Sender: TObject);
begin
  cbbFont.Items := Screen.Fonts;
  cbbFont.ItemIndex := cbbFont.Items.IndexOf('����');

  FEmrView := THCEmrView.Create(Self);
  FEmrView.OnSectionItemInsert := DoInsertItem;
  FEmrView.OnMouseDown := DoEmrViewMouseDown;
  FEmrView.OnMouseUp := DoEmrViewMouseUp;
  FEmrView.OnCaretChange := DoCaretChange;
  FEmrView.OnVerScroll := DoVerScroll;
  FEmrView.OnChangedSwitch := DoChangedSwitch;
  FEmrView.OnSectionReadOnlySwitch := DoReadOnlySwitch;
  FEmrView.OnCanNotEdit := DoCanNotEdit;
  FEmrView.OnSectionPaintPaperBefor := DoPaintPaperBefor;
  FEmrView.PopupMenu := pmView;
  FEmrView.Parent := Self;
  FEmrView.Align := alClient;
  //FEmrView.ShowHint := True; ��������Ԫ�ص����������ʾHint�Զ���ʧ
end;

procedure TfrmRecord.FormDestroy(Sender: TObject);
begin
  if Assigned(FfrmRecordPop) then
    FreeAndNil(FfrmRecordPop);

  if Assigned(FfrmDataElement) then
    FreeAndNil(FfrmDataElement);

  FEmrView.Free;
end;

procedure TfrmRecord.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = Ord('S')) then
    actSaveExecute(Sender);
end;

procedure TfrmRecord.FormShow(Sender: TObject);
begin
  cbbFont.Items := Screen.Fonts;
  cbbFont.ItemIndex := cbbFont.Items.IndexOf('����');
  SendMessage(cbbFont.Handle, CB_SETDROPPEDWIDTH, 200, 0);
  FEmrView.SetFocus;
end;

procedure TfrmRecord.GetPagesAndActive;
begin
  sbStatus.Panels[0].Text := 'Ԥ��' + IntToStr(FEmrView.PagePreviewFirst + 1)
    + 'ҳ ���' + IntToStr(FEmrView.ActivePageIndex + 1)
    + 'ҳ ��' + IntToStr(FEmrView.PageCount) + 'ҳ';
end;

procedure TfrmRecord.HideToolbar;
begin
  tlbTool.Visible := False;
end;

procedure TfrmRecord.InsertDeItem(const AIndex, AName: string);
var
  vDeItem: TDeItem;
begin
  if (AIndex = '') or (AName = '') then
  begin
    ShowMessage('Ҫ���������Ԫ���������Ʋ���Ϊ�գ�');
    Exit;
  end;

  vDeItem := FEmrView.NewDeItem(AName);
  vDeItem[TDeProp.Index] := AIndex;
  vDeItem[TDeProp.Name] := AName;
  FEmrView.InsertDeItem(vDeItem);
end;

procedure TfrmRecord.mniOpenClick(Sender: TObject);
var
  vOpenDlg: TOpenDialog;
begin
  if FEmrView.ReadOnly then
  begin
    ShowMessage('��ǰ�ĵ�ֻ����');
    Exit;
  end;

  vOpenDlg := TOpenDialog.Create(Self);
  try
    vOpenDlg.Filter := '�ļ�|*' + HC_EXT;
    if vOpenDlg.Execute then
    begin
      if vOpenDlg.FileName <> '' then
        FEmrView.LoadFromFile(vOpenDlg.FileName);
    end;
  finally
    FreeAndNil(vOpenDlg);
  end;
end;

procedure TfrmRecord.mniSaveAsClick(Sender: TObject);
var
  vSaveDlg: TSaveDialog;
  vExt: string;
begin
  vSaveDlg := TSaveDialog.Create(nil);
  try
    vSaveDlg.Filter := '�ļ�|*' + HC_EXT + '|HCView xml|*.xml|Word 2007 Document (*.docx)|*.docx';
    if vSaveDlg.Execute then
    begin
      if vSaveDlg.FileName <> '' then
      begin
        vExt := '';
        case vSaveDlg.FilterIndex of
          1: vExt := HC_EXT;
          2: vExt := '.xml';
          3: vExt := '.docx';
        else
          Exit;
        end;

        if ExtractFileExt(vSaveDlg.FileName) <> vExt then  // �����ظ���׺
          vSaveDlg.FileName := vSaveDlg.FileName + vExt;

        case vSaveDlg.FilterIndex of
          1: FEmrView.SaveToFile(vSaveDlg.FileName);  // .hcf

          2: FEmrView.SaveToXML(vSaveDlg.FileName, TEncoding.UTF8);  // xml

          3: FEmrView.SaveToDocumentFile(vSaveDlg.FileName, vExt)
        end;
      end;
    end;
  finally
    FreeAndNil(vSaveDlg);
  end;
end;

procedure TfrmRecord.mniSplitColClick(Sender: TObject);
begin
  FEmrView.ActiveTableSplitCurCol;
end;

procedure TfrmRecord.mniSplitRowClick(Sender: TObject);
begin
  FEmrView.ActiveTableSplitCurRow;
end;

procedure TfrmRecord.mniTablePropertyClick(Sender: TObject);
var
  vFrmDeTableProperty: TFrmDeTableProperty;
begin
  vFrmDeTableProperty := TFrmDeTableProperty.Create(Self);
  try
    vFrmDeTableProperty.SetHCView(FEmrView);
  finally
    FreeAndNil(vFrmDeTableProperty);
  end;
end;

procedure TfrmRecord.mniHideTraceClick(Sender: TObject);
begin
  if FEmrView.HideTrace then
    SetHideTrace(False)
  else
    SetHideTrace(True);
end;

procedure TfrmRecord.mniSectionClick(Sender: TObject);
begin
  FEmrView.InsertSectionBreak;
end;

procedure TfrmRecord.pmFilePopup(Sender: TObject);
begin
  mniHideTrace.Visible := FEmrView.TraceCount > 0;

  if mniHideTrace.Visible then
  begin
    if FEmrView.HideTrace then
      mniHideTrace.Caption := '��ʾ�ۼ�'
    else
      mniHideTrace.Caption := '����ʾ�ۼ�';
  end;
end;

procedure TfrmRecord.pmViewPopup(Sender: TObject);
var
  vActiveItem, vTopItem: THCCustomItem;
  vTable: TDeTable;
  vActiveData, vTopData: THCCustomData;
begin
  vActiveData := FEmrView.ActiveSection.ActiveData;
  vActiveItem := vActiveData.GetActiveItem;

  vTopData := nil;
  vTopItem := vActiveItem;

  while vTopItem is THCCustomRectItem do
  begin
    if (vTopItem as THCCustomRectItem).GetActiveData <> nil then
    begin
      if vTopData <> nil then
      begin
        vActiveData := vTopData;
        vActiveItem := vTopItem;
      end;

      vTopData := (vTopItem as THCCustomRectItem).GetActiveData;
      vTopItem := vTopData.GetActiveItem;
    end
    else
      Break;
  end;

  if vTopData = nil then
    vTopData := vActiveData;

  mniTable.Enabled := vActiveItem.StyleNo = THCStyle.Table;
  if mniTable.Enabled then
  begin
    vTable := vActiveItem as TDeTable;
    mniInsertRowTop.Enabled := vTable.GetEditCell <> nil;
    mniInsertRowBottom.Enabled := mniInsertRowTop.Enabled;
    mniInsertColLeft.Enabled := mniInsertRowTop.Enabled;
    mniInsertColRight.Enabled := mniInsertRowTop.Enabled;
    mniSplitRow.Enabled := mniInsertRowTop.Enabled;
    mniSplitCol.Enabled := mniInsertRowTop.Enabled;

    mniDeleteCurRow.Enabled := vTable.CurRowCanDelete;
    mniDeleteCurCol.Enabled := vTable.CurColCanDelete;
    mniMerge.Enabled := vTable.SelectedCellCanMerge;
  end;

  actCut.Enabled := (not FEmrView.ActiveSection.ReadOnly) and vTopData.SelectExists;
  actCopy.Enabled := actCut.Enabled;
  actPaste.Enabled := (not (vTopData as THCRichData).ReadOnly)  // ��ֻ��
    and (Clipboard.HasFormat(HC_FILEFORMAT)
         or Clipboard.HasFormat(CF_TEXT)
         or Clipboard.HasFormat(CF_BITMAP));
  mniControlItem.Visible := (not (vTopData as THCRichData).ReadOnly) and (not vTopData.SelectExists)
    and (vTopItem is THCControlItem) and vTopItem.Active;
  if mniControlItem.Visible then
    mniControlItem.Caption := '����(' + (vTopItem as THCControlItem).ClassName + ')';

  mniDeItem.Visible := False;
  mniDeleteProtect.Visible := False;

  if vTopItem is TDeItem then
  begin
    if (vTopItem as TDeItem).IsElement then
    begin
      mniDeItem.Visible := True;
      mniDeItem.Caption := (vTopItem as TDeItem)[TDeProp.Name];
    end;

    if FEmrView.DesignMode then  // ���ģʽ
    begin
      if vTopData.SelectExists then
      begin
        mniDeleteProtect.Caption := 'ֻ��';
        mniDeleteProtect.Visible := True;
      end
      else
      if (vTopItem as TDeItem).EditProtect then
      begin
        mniDeleteProtect.Caption := 'ȡ��ֻ��';
        mniDeleteProtect.Visible := True;
      end;
    end;
  end;

  if (vTopData as THCViewData).ActiveDomain.BeginNo >= 0 then
  begin
    mniDeGroup.Visible := True;
    mniDeGroup.Caption := (vTopData.Items[(vTopData as THCViewData).ActiveDomain.BeginNo] as TDeGroup)[TDeProp.Name];
  end
  else
    mniDeGroup.Visible := False;

  mniSplit.Visible := mniControlItem.Visible or mniDeItem.Visible or mniDeGroup.Visible;
end;

function TfrmRecord.PopupForm: TfrmRecordPop;
begin
  if not Assigned(FfrmRecordPop) then
  begin
    FfrmRecordPop := TfrmRecordPop.Create(nil);
    FfrmRecordPop.OnSetActiveItemText := DoSetActiveDeItemText;
    FfrmRecordPop.OnSetActiveItemExtra := DoSetActiveDeItemExtra;
    //FfrmRecordPop.Parent := Self;
  end;

  Result := FfrmRecordPop;
end;

procedure TfrmRecord.PopupFormClose;
begin
  if Assigned(FfrmRecordPop) and FfrmRecordPop.Visible then  // ʹ��PopupForm�ᵼ��û��FfrmRecordPopʱ����һ���ٹرգ�������
    FfrmRecordPop.Close;
end;

procedure TfrmRecord.SetHideTrace(const Value: Boolean);
begin
  if FEmrView.HideTrace <> Value then
  begin
    FEmrView.HideTrace := Value;

    if Value then  // ���غۼ�
    begin
      FEmrView.AnnotatePre.Visible := False;
      TraverseElement(DoHideTraceTraverse, [saPage], TTravTag.HideTrace);
    end
    else  // ��ʾ�ۼ�
    begin
      if (FEmrView.TraceCount > 0) and (not FEmrView.AnnotatePre.Visible) then
        FEmrView.AnnotatePre.Visible := True;

      TraverseElement(DoHideTraceTraverse, [saPage], 0);
    end;

    if Value and (not FEmrView.ReadOnly) then
      FEmrView.ReadOnly := True;
  end;
end;

procedure TfrmRecord.TraverseElement(const ATravEvent: TTraverseItemEvent;
   const AAreas: TSectionAreas = [saHeader, saPage, saFooter]; const ATag: Integer = 0);
var
  vItemTraverse: THCItemTraverse;
begin
  if not Assigned(ATravEvent) then Exit;

  if AAreas = [] then Exit;

  vItemTraverse := THCItemTraverse.Create;
  try
    vItemTraverse.Tag := ATag;
    vItemTraverse.Areas := [saHeader, saPage, saFooter];
    vItemTraverse.Process := ATravEvent;
    FEmrView.TraverseItem(vItemTraverse);

    FEmrView.FormatData;
  finally
    vItemTraverse.Free;
  end;
end;

procedure TfrmRecord.mniComboboxClick(Sender: TObject);
var
  vDeCombobox: TDeCombobox;
  vS: string;
begin
  vS := 'Ĭ��ֵ';
  if InputQuery('������', '�ı�����', vS) then
  begin
    vDeCombobox := TDeCombobox.Create(FEmrView.ActiveSectionTopLevelData, vS);
    vDeCombobox.SaveItem := False;  // ����ѡ��洢���ĵ���
    vDeCombobox[TDeProp.Index] := '1002';  // �ؼ�������Ԫ����
    {vCombobox.Items.Add('ѡ��1');
    vCombobox.Items.Add('ѡ��2');
    vCombobox.Items.Add('ѡ��3');}
    //vCombobox.ItemIndex := 0;
    FEmrView.InsertItem(vDeCombobox);
  end;
end;

procedure TfrmRecord.mniControlItemClick(Sender: TObject);
var
  vFrmDeControlProperty: TfrmDeControlProperty;
begin
  vFrmDeControlProperty := TfrmDeControlProperty.Create(nil);
  try
    vFrmDeControlProperty.SetHCView(FEmrView);
  finally
    FreeAndNil(vFrmDeControlProperty);
  end;
end;

procedure TfrmRecord.mniDeleteCurColClick(Sender: TObject);
begin
  FEmrView.ActiveTableDeleteCurCol;
end;

procedure TfrmRecord.mniDeleteGroupClick(Sender: TObject);
begin
  FEmrView.DeleteActiveDomain;
end;

procedure TfrmRecord.mniDeleteCurRowClick(Sender: TObject);
begin
  FEmrView.ActiveTableDeleteCurRow;
end;

procedure TfrmRecord.mniDisBorderClick(Sender: TObject);
var
  vTable: TDeTable;
begin
  if FEmrView.ActiveSection.ActiveData.GetActiveItem is TDeTable then
  begin
    vTable := FEmrView.ActiveSection.ActiveData.GetActiveItem as TDeTable;
    vTable.BorderVisible := not vTable.BorderVisible;
    FEmrView.UpdateView;
  end;
end;

procedure TfrmRecord.mniInsertGifClick(Sender: TObject);
var
  vOpenDlg: TOpenDialog;
  vGifItem: THCGifItem;
begin
  vOpenDlg := TOpenDialog.Create(Self);
  try
    vOpenDlg.Filter := 'GIF�����ļ�|*.gif';
    if vOpenDlg.Execute then
    begin
      if vOpenDlg.FileName <> '' then
      begin
        vGifItem := THCGifItem.Create(FEmrView.ActiveSectionTopLevelData);
        vGifItem.LoadFromFile(vOpenDlg.FileName);
        Application.ProcessMessages;  // ���˫�����ļ��󣬴����²�ؼ���Mousemove��Mouseup�¼�
        FEmrView.InsertItem(vGifItem);
      end;
    end;
  finally
    FreeAndNil(vOpenDlg);
  end;
end;

procedure TfrmRecord.mniInsertColLeftClick(Sender: TObject);
begin
  FEmrView.ActiveTableInsertColBefor(1);
end;

procedure TfrmRecord.mniInsertColRightClick(Sender: TObject);
begin
  FEmrView.ActiveTableInsertColAfter(1);
end;

procedure TfrmRecord.mniInsertRowBottomClick(Sender: TObject);
begin
  FEmrView.ActiveTableInsertRowAfter(1);
end;

procedure TfrmRecord.mniInsertRowTopClick(Sender: TObject);
begin
  FEmrView.ActiveTableInsertRowBefor(1);
end;

procedure TfrmRecord.mniLineSpace100Click(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    case (Sender as TMenuItem).Tag of
      0: FEmrView.ApplyParaLineSpace(TParaLineSpaceMode.pls100);
      1: FEmrView.ApplyParaLineSpace(TParaLineSpaceMode.pls115);
      2: FEmrView.ApplyParaLineSpace(TParaLineSpaceMode.pls150);
      3: FEmrView.ApplyParaLineSpace(TParaLineSpaceMode.pls200);
    end;
  end;
end;

procedure TfrmRecord.mniPageBreakClick(Sender: TObject);
begin
  FEmrView.InsertPageBreak;
end;

procedure TfrmRecord.mniDeItemPropClick(Sender: TObject);
var
  vFrmDeProperty: TfrmDeProperty;
begin
  vFrmDeProperty := TfrmDeProperty.Create(nil);
  try
    vFrmDeProperty.SetHCView(FEmrView);
  finally
    FreeAndNil(vFrmDeProperty);
  end;
end;

procedure TfrmRecord.mniDeleteDeItemClick(Sender: TObject);
var
  vTopData: THCRichData;
begin
  vTopData := FEmrView.ActiveSectionTopLevelData as THCRichData;
  FEmrView.DeleteActiveDataItems(vTopData.SelectInfo.StartItemNo);
end;

procedure TfrmRecord.mniToothClick(Sender: TObject);
var
  vToothItem: TEmrToothItem;
begin
  vToothItem := TEmrToothItem.Create(FEmrView.ActiveSectionTopLevelData,
    'XX', 'XX', 'XX', 'XX');
  FEmrView.InsertItem(vToothItem);
end;

procedure TfrmRecord.mniPrintCurLineClick(Sender: TObject);
begin
  FEmrView.PrintCurPageByActiveLine(False, False);
end;

procedure TfrmRecord.mniEditItemClick(Sender: TObject);
var
  vDeEdit: TDeEdit;
  vS: string;
begin
  vS := InputBox('�ı���', '�ı�', '');
  vDeEdit := TDeEdit.Create(FEmrView.ActiveSectionTopLevelData, vS);
  FEmrView.InsertItem(vDeEdit);
end;

procedure TfrmRecord.mniReSyncClick(Sender: TObject);
var
  vTopData, vPage: THCViewData;
  vDomain: THCDomainInfo;
  vText: string;
begin
  vTopData := FEmrView.ActiveSectionTopLevelData as THCViewData;
  vDomain := vTopData.ActiveDomain;
  vPage := FEmrView.ActiveSection.Page;

  if vTopData = vPage then
    vText := FEmrView.GetDataForwardDeGroupText(vPage, vDomain.BeginNo)
  else  {to do: ȡ����е�������}
    vText := '';

  if vText <> '' then
  begin
    FEmrView.BeginUpdate;
    try
      FEmrView.SetDeGroupText(vTopData, vDomain.BeginNo, vText);
      FEmrView.FormatSection(FEmrView.ActiveSectionIndex);
    finally
      FEmrView.EndUpdate;
    end;
  end;
end;

procedure TfrmRecord.mniPrintSelectClick(Sender: TObject);
begin
  FEmrView.PrintCurPageSelected(False, False);
end;

procedure TfrmRecord.mniMergeClick(Sender: TObject);
begin
  FEmrView.MergeTableSelectCells;
end;

procedure TfrmRecord.mniInsertDeItemClick(Sender: TObject);
begin
  if not Assigned(FfrmDataElement) then
  begin
    FfrmDataElement := TfrmDataElement.Create(Self);
    FfrmDataElement.OnInsertAsDE := InsertDeItem;
  end;

  FfrmDataElement.Show;
end;

procedure TfrmRecord.mniClearClick(Sender: TObject);
begin
  FEmrView.Clear;
end;

procedure TfrmRecord.mniFangJiaoClick(Sender: TObject);
var
  vFangJiaoItem: TEmrFangJiaoItem;
begin
  vFangJiaoItem := TEmrFangJiaoItem.Create(FEmrView.ActiveSectionTopLevelData, '', '', '', '');
  FEmrView.InsertItem(vFangJiaoItem);
end;

procedure TfrmRecord.mniN5Click(Sender: TObject);
var
  vFrmBorderBackColor: TfrmBorderBackColor;
begin
  vFrmBorderBackColor := TfrmBorderBackColor.Create(Self);
  try
    vFrmBorderBackColor.SetView(FEmrView);
  finally
    FreeAndNil(vFrmBorderBackColor);
  end;
end;

procedure TfrmRecord.mniFastPrintClick(Sender: TObject);
begin
  btnprintClick(Sender);
end;

procedure TfrmRecord.mniSaveStructureClick(Sender: TObject);
begin
  DoSaveStructure;
end;

procedure TfrmRecord.mniDeleteProtectClick(Sender: TObject);
var
  vTopData: THCCustomData;
  vDeItem: TDeItem;
  vS: string;
begin
  vTopData := FEmrView.ActiveSectionTopLevelData;

  if vTopData.SelectExists then
  begin
    vS := vTopData.GetSelectText;
    vS := StringReplace(vS, #13#10, '', [rfReplaceAll, rfIgnoreCase]);
    vDeItem := FEmrView.NewDeItem(vS);
    vDeItem.EditProtect := True;
    FEmrView.InsertDeItem(vDeItem);
  end
  else
  begin
    vDeItem := vTopData.GetActiveItem as TDeItem;
    if vDeItem.EditProtect then
    begin
      vDeItem.EditProtect := False;
      FEmrView.ReAdaptActiveItem;
    end;
  end;
end;

procedure TfrmRecord.mniInsertTableClick(Sender: TObject);
var
  vFrmInsertTable: TfrmInsertTable;
  vTable: TDeTable;
  vTopData: THCRichData;
begin
  vFrmInsertTable := TfrmInsertTable.Create(Self);
  try
    vFrmInsertTable.ShowModal;
    if vFrmInsertTable.ModalResult = mrOk then
    begin
      vTopData := FEmrView.ActiveSectionTopLevelData as THCRichData;
      vTable := TDeTable.Create(vTopData, StrToInt(vFrmInsertTable.edtRows.Text),
        StrToInt(vFrmInsertTable.edtCols.Text), vTopData.Width);
      FEmrView.InsertItem(vTable);
    end;
  finally
    FreeAndNil(vFrmInsertTable);
  end;
end;

procedure TfrmRecord.mniCheckboxClick(Sender: TObject);
var
  vCheckBox: TDeCheckBox;
  vS: string;
begin
  vS := InputBox('��ѡ��', '�ı�', '');
  vCheckBox := TDeCheckBox.Create(FEmrView.ActiveSectionTopLevelData, vS, False);
  FEmrView.InsertItem(vCheckBox);
end;

procedure TfrmRecord.mniInsertImageClick(Sender: TObject);
var
  vOpenDlg: TOpenDialog;
  vImageItem: THCImageItem;
begin
  vOpenDlg := TOpenDialog.Create(Self);
  try
    vOpenDlg.Filter := 'bmp�ļ�|*.bmp';
    if vOpenDlg.Execute then
    begin
      if vOpenDlg.FileName <> '' then
      begin
        vImageItem := THCImageItem.Create(FEmrView.ActiveSectionTopLevelData);
        vImageItem.LoadFromBmpFile(vOpenDlg.FileName);
        Application.ProcessMessages;  // ���˫�����ļ��󣬴����²�ؼ���Mousemove��Mouseup�¼�
        FEmrView.InsertItem(vImageItem);
      end;
    end;
  finally
    FreeAndNil(vOpenDlg);
  end;
end;

procedure TfrmRecord.mniYueJingClick(Sender: TObject);
var
  vYueJingItem: TEmrYueJingItem;
begin
  vYueJingItem := TEmrYueJingItem.Create(FEmrView.ActiveSectionTopLevelData,
    '12', '5-6', FormatDateTime('YYYY-MM-DD', Now), '28-30');
  FEmrView.InsertItem(vYueJingItem);
end;

procedure TfrmRecord.mniPirntPreviewClick(Sender: TObject);
var
  vFrmPrintView: TfrmPrintView;
begin
  vFrmPrintView := TfrmPrintView.Create(Self);
  try
    vFrmPrintView.SetView(FEmrView);
  finally
    FreeAndNil(vFrmPrintView);
  end;
end;

procedure TfrmRecord.mniInsertLineClick(Sender: TObject);
begin
  FEmrView.InsertLine(1);
end;

procedure TfrmRecord.mniPageSetClick(Sender: TObject);
var
  vFrmPageSet: TFrmPageSet;
begin
  vFrmPageSet := TFrmPageSet.Create(Self);
  try
    vFrmPageSet.SetHCView(FEmrView);
  finally
    FreeAndNil(vFrmPageSet);
  end;
end;

procedure TfrmRecord.mniParaClick(Sender: TObject);
var
  vFrmParagraph: TfrmParagraph;
begin
  vFrmParagraph := TfrmParagraph.Create(Self);
  try
    vFrmParagraph.SetView(FEmrView);
  finally
    FreeAndNil(vFrmParagraph);
  end;
end;

{ TTravTag }

class function TTravTag.Contains(const ATags, ATag: Integer): Boolean;
begin
  Result := (ATags and ATag) = ATag;
end;

end.
