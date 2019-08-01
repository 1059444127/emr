unit CFGrid;

interface

uses
  Windows, Classes, Controls, Graphics, Generics.Collections,
  CFControl, CFScrollBar;

type
  TColStates = set of (ccsSelected, ccsFocused);

  TRow = class;

  TCol = class(TPersistent)
  private
    FRow: TRow;
    FText: string;
    FWidth: Integer;
    FStates: TColStates;
  public
    constructor Create(const ARow: TRow);
    procedure Draw(const ACanvas: TCanvas; const ALeft, ATop, AHeight: Integer);
    //
    property Text: string read FText write FText;
    property Width: Integer read FWidth write FWidth;
    property States: TColStates read FStates write FStates default [];
  end;

  TTitleRow = class;

  TTitleCol = class(TPersistent)
  private
    FText: string;
    FWidth: Integer;
  public
    constructor Create(const ATitleRow: TTitleRow);
    procedure Draw(const ACanvas: TCanvas; const ALeft, ATop, AHeight: Integer);
    //
    property Text: string read FText write FText;
    property Width: Integer read FWidth write FWidth;
  end;

  TCFGrid = class;

  TRow = class(TList)
  private
    FGrid: TCFGrid;
    /// <summary> ��ȡ���е��е����� </summary>
    function Get(Index: Integer): TCol;

    /// <summary> ���ø��е��е����� </summary>
    procedure Put(Index: Integer; const Value: TCol);
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create(const AGrid: TCFGrid; const AColCount: Cardinal);

    /// <summary> ������ </summary>
    procedure Draw(const ACanvas: TCanvas; const ALeft, ATop, AStartCol, AEndCol: Integer);
    property Items[Index: Integer]: TCol read Get write Put; default;
  end;

  TTitleRow = class(TList)
  private
    FGrid: TCFGrid;
    /// <summary> ��ȡ���е��е����� </summary>
    function Get(Index: Integer): TTitleCol;

    /// <summary> ���ø��е��е����� </summary>
    procedure Put(Index: Integer; const Value: TTitleCol);
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create(const AGrid: TCFGrid; const AColCount: Cardinal);

    /// <summary> ������ </summary>
    procedure Draw(const ACanvas: TCanvas; const ALeft, ATop, AStartCol, AEndCol: Integer);
    property Items[Index: Integer]: TTitleCol read Get write Put; default;
  end;

  TCGridOption = (cgoRowSizing, cgoColSizing, cgoIndicator, cgoRowSelect);
  TCGridOptions = set of TCGridOption;
  TEditControlType = (ectEdit, ectCombobox, ectButtonEdit, ectGridEdit);

  TOnSelectCell = procedure(Sender: TObject; ARow, ACol: Integer{; var CanSelect: Boolean}) of object;
  TOnTitleClick = procedure(Sender: TObject; ATitleRow, ATitleCol: Integer) of object;
  TOnCellDraw = procedure(Sender: TObject; const ARow, ACol: Cardinal;
    const ACanvas: TCanvas; const ALeft, ATop: Integer) of object;
  TOnCellBeforeEdit = procedure(Sender: TObject; const ARow, ACol: Cardinal; var ACancel: Boolean; var AEditControlType: TEditControlType) of object;
  TOnCellAfterEdit = procedure(Sender: TObject; const ARow, ACol: Cardinal; const ANewValue: string; var ACancel: Boolean) of object;

  TCFGrid = class(TCFTextControl)
  private
    FRows: TObjectList<TRow>;
    FTitleRow: TTitleRow;
    FVScrollBar, FHScrollBar: TCFScrollBar;
    FEditControl: TCFTextControl;
    FMouseDownCtronl: TCFCustomControl;

    FDefaultColWidth,
    FRowHeight: Integer;
    /// <summary> ֻ�� </summary>
    FReadOnly: Boolean;

    // �϶��ı��п�
    FResizeCol,  // �϶��ı��п�ʱ��Ӧ����
    FResizeX     // ��¼�϶�ʱXλ��
      : Integer;
    FMovePt: TPoint;  // ����м�����ƽ��ʱ��ʼ����
    FIndicatorWidth: Integer;
    FColResizing: Boolean;
    FOptions: TCGridOptions;
    FRowIndex, FColIndex: Integer;

    FOnSelectCell: TOnSelectCell;
    FOnTitleClick: TOnTitleClick;
    FOnCellDraw: TOnCellDraw;
    FOnCellBeforeEdit: TOnCellBeforeEdit;
    FOnCellAfterEdit: TOnCellAfterEdit;
    /// <summary>
    /// ��ȡ���ݵ��ܿ��
    /// </summary>
    /// <returns>���ݵ��ܿ��</returns>
    function GetDataWidth: Integer;

    /// <summary>
    /// ��ȡչʾ���ݵĿ��
    /// </summary>
    /// <returns>��չʾ���ݵ��ܿ��</returns>
    function GetDataDisplayWidth: Integer;

    /// <summary>
    /// ��ȡչʾ���ݵĸ߶�
    /// </summary>
    /// <returns>չʾ���ݸ߶�</returns>
    function GetDataDisplayHeight: Integer;

    /// <summary>
    /// ��ȡչʾ���ݵ��ұ�
    /// </summary>
    /// <returns>���ݵ��ұ�</returns>
    function GetDataDisplayRight: Integer;

    /// <summary>
    /// ��ȡչʾ���ݵĵײ�
    /// </summary>
    /// <returns>���ݵĵײ�</returns>
    function GetDataDisplayBottom: Integer;

    /// <summary>
    /// ��ȡ��Ԫ�������
    /// </summary>
    /// <param name="ARow">��</param>
    /// <param name="ACol">��</param>
    /// <returns>��Ԫ�������</returns>
    function GetCells(ARow, ACol: Integer): string;

    /// <summary>
    /// ��ȡ�еı���
    /// </summary>
    /// <param name="ACol">��</param>
    /// <returns>�еı���</returns>
    function GetTitleText(ACol: Integer): string;

    /// <summary> ��ֱ�������¼� </summary>
    procedure OnVScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);

    /// <summary> ˮƽ�������¼� </summary>
    procedure OnHScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);

    /// <summary>
    /// ��ȡչʾ���ݵ���ʼ�кͽ�����
    /// </summary>
    /// <param name="AStartRow">��ʼ��</param>
    /// <param name="AEndRow">������</param>
    /// <param name="ATopOffset">ƫ����</param>
    procedure GetFirstRowDisplay(var AStartRow, AEndRow, ATopOffset: Integer);

    /// <summary>
    /// ��ȡչʾ���ݵ���ʼ�кͽ�����
    /// </summary>
    /// <param name="AStartCol">��ʼ��</param>
    /// <param name="AEndCol">������</param>
    /// <param name="ALeftOffset">����ƫ����</param>
    procedure GetFirstColDisplay(var AStartCol, AEndCol, ALeftOffset: Integer);

    /// <summary>
    /// ��ȡ����ĸ߶�
    /// </summary>
    /// <returns>����߶�</returns>
    function GetTitleHeight: Integer;

    /// <summary>
    /// ����Ԫ��ֵ
    /// </summary>
    /// <param name="ARow">��Ԫ����</param>
    /// <param name="ACol">��Ԫ����</param>
    /// <param name="Value">��Ӧֵ</param>
    procedure SetCells(ARow, ACol: Integer; const Value: string);

    /// <summary>
    /// �����⸳ֵ
    /// </summary>
    /// <param name="ACol">��</param>
    /// <param name="Value">�����и�ֵ</param>
    procedure SetTitleText(ATitleCol: Integer; const Value: string);

    procedure SetOptions(Value: TCGridOptions);

    /// <summary> �����ǹ�������λ�� </summary>
    procedure CalcScrollBarPosition;

    /// <summary> �����Ƿ�Ҫ��ʾ������ </summary>
    procedure CheckScrollBarVisible;

    procedure ShowEditControl(const ARow, ACol: Cardinal; const AEditControlType: TEditControlType);
    procedure DoOnCellBeforeEdit(const ARow, ACol: Cardinal);
    procedure DoOnCellAfterEdit(const ARow, ACol: Cardinal);
    procedure DoOnEditControlKeyPress(Sender: TObject; var Key: Char);
  protected
    /// <summary> ���� </summary>
    procedure DrawControl(ACanvas: TCanvas); override;
    /// <summary>
    /// ����ֻ������
    /// </summary>
    /// <param name="Value">True��ֻ��</param>
    procedure SetReadOnly(Value: Boolean);

    procedure AdjustBounds; override;
    //
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
        MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateEx(AOwner: TComponent; const ARowCount, AColCount: Cardinal);
    destructor Destroy; override;
    function GetRowCount: Cardinal;
    procedure SetRowCount(Value: Cardinal);
    function GetColCount: Cardinal;
    procedure SetColCount(Value: Cardinal);

    /// <summary>
    /// ������ָ����
    /// </summary>
    /// <param name="ARowIndex">�к�</param>
    procedure ScrollToRow(const ARowIndex: Cardinal);

    /// <summary>
    /// ��ȡָ��������к���
    /// </summary>
    /// <param name="DataX">��������X</param>
    /// <param name="DataY">��������Y</param>
    /// <param name="ARow">����������</param>
    /// <param name="ACol">����������</param>
    procedure GetDataCellAt(const ADataX, ADataY: Integer; var ARow, ACol: Integer);

    procedure GetTitleCellAt(const ATitleX, ATitleY: Integer; var ATitleRow, ATitleCol: Integer);

    /// <summary>
    /// ��ȡ��Ԫ�������(��Ӧ������)
    /// </summary>
    /// <param name="ARow">��Ԫ����</param>
    /// <param name="ACol">��Ԫ����</param>
    /// <returns>��Ԫ������</returns>
    function GetCellClientRect(const ARow, ACol: Integer): TRect;

    /// <summary>
    /// ��ȡָ�����е����򣨴ӱ�����ָ����
    /// </summary>
    /// <param name="ACol">������</param>
    /// <returns>������</returns>
    function GetTitleColClientRect(const ATitleCol: Integer): TRect;

    /// <summary>
    /// ��ȡ��Ԫ���������ݵ���������
    /// </summary>
    /// <param name="ARow">��Ԫ����</param>
    /// <param name="ACol">��Ԫ����</param>
    /// <returns>��������</returns>
    function GetCellDataBoundRect(const ARow, ACol: Integer): TRect;

    /// <summary>
    /// �����еĿ��
    /// </summary>
    /// <param name="ACol">ָ����</param>
    /// <param name="AWidth">�п��</param>
    procedure SetColWidth(const ACol, AWidth: Integer);

    /// <summary>
    /// ʹ�õ�Ԫ��Ĭ�ϵĻ��Ʒ�ʽ����ָ����Ԫ�����ݵ�ָ���Ļ�����
    /// </summary>
    /// <param name="ARow">��</param>
    /// <param name="ACol">��</param>
    /// <param name="ACanvas">����</param>
    procedure DefaultCellDraw(const ARow, ACol: Cardinal; const ACanvas: TCanvas;
      const ALeft, ATop: Integer);

    property Cells[ARow, ACol: Integer]: string read GetCells write SetCells;
    property TitleText[ACol: Integer]: string read GetTitleText write SetTitleText;
    //property Objects[ACol, ARow: Integer]: TObject read GetObjects write SetObjects;
    property RowIndex: Integer read FRowIndex;
    property ColIndex: Integer read FColIndex;
  published
    property DefaultColWidth: Integer read FDefaultColWidth write FDefaultColWidth;
    property RowHeight: Integer read FRowHeight write FRowHeight;
    property RowCount: Cardinal read GetRowCount write SetRowCount;
    property ColCount: Cardinal read GetColCount write SetColCount;
    property Options: TCGridOptions read FOptions write SetOptions;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
    property PopupMenu;

    property OnSelectCell: TOnSelectCell read FOnSelectCell write FOnSelectCell;
    property OnTitleClick: TOnTitleClick read FOnTitleClick write FOnTitleClick;
    property OnCellDraw: TOnCellDraw read FOnCellDraw write FOnCellDraw;
    property OnCellBeforeEdit: TOnCellBeforeEdit read FOnCellBeforeEdit write FOnCellBeforeEdit;
    property OnCellAfterEdit: TOnCellAfterEdit read FOnCellAfterEdit write FOnCellAfterEdit;
  end;

implementation

uses
  SysUtils, Math, CFEdit, CFButtonEdit, CFCombobox, CFGridEdit;

{ TCFGrid }

function TCFGrid.GetDataWidth: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to ColCount - 1 do
    Result := Result + FTitleRow[i].Width;
end;

procedure TCFGrid.AdjustBounds;
var
  vDC: HDC;
  vNewHeight, vNewWidth: Integer;
begin
  vDC := GetDC(0);
  try
    Canvas.Handle := vDC;
    Canvas.Font := Font;
    vNewHeight := FRowHeight + GetSystemMetrics(SM_CYBORDER) * 4;
    vNewWidth := FDefaultColWidth + GetSystemMetrics(SM_CYBORDER) * 4;
    if vNewWidth < Width then
      vNewWidth := Width;

    if vNewHeight < Height then
      vNewHeight := Height;

    Canvas.Handle := 0;
  finally
    ReleaseDC(0, vDC);
  end;

  SetBounds(Left, Top, vNewWidth, vNewHeight);
end;

procedure TCFGrid.CalcScrollBarPosition;
begin
  if (not Assigned(FVScrollBar)) or (not Assigned(FHScrollBar)) then Exit;  // �����

  // ����λ��
  if BorderVisible then  // ��ʾ�߿�
  begin
    FVScrollBar.Left := Width - FVScrollBar.Width - GBorderWidth;
    FVScrollBar.Top := GBorderWidth;
    FVScrollBar.Height := Height - 2 * GBorderWidth;
    if FHScrollBar.Visible then  // ˮƽ�������
      FVScrollBar.Height := FVScrollBar.Height - FHScrollBar.Height;

    FHScrollBar.Left := GBorderWidth;
    FHScrollBar.Top := Height - FHScrollBar.Height - GBorderWidth;
    FHScrollBar.Width := Width - 2 * GBorderWidth;
    if FVScrollBar.Visible then  // ��ֱ�������
      FHScrollBar.Width := FHScrollBar.Width - FVScrollBar.Width;
  end
  else  // ����ʾ�߿�
  begin
    FVScrollBar.Left := Width - FVScrollBar.Width;
    FVScrollBar.Top := 0;
    FVScrollBar.Height := Height;
    if FHScrollBar.Visible then  // ˮƽ�������
      FVScrollBar.Height := FVScrollBar.Height - FHScrollBar.Height;

    FHScrollBar.Left := 0;
    FHScrollBar.Top := Height - FHScrollBar.Height;
    FHScrollBar.Width := Width;
    if FVScrollBar.Visible then  // ��ֱ�������
      FHScrollBar.Width := FHScrollBar.Width - FVScrollBar.Width;
  end;
end;

procedure TCFGrid.CheckScrollBarVisible;
var
  vWidth, vHeight, vHMax, vVMax: Integer;
  vVVisible, vHVisible: Boolean;
begin
  if (not Assigned(FVScrollBar)) or (not Assigned(FHScrollBar)) then Exit;  // �����

  vHMax := GetDataWidth;
  vVMax := FRows.Count * RowHeight;  // ���ݸ�
  // ��ֱ�������ݿ���ʾ�ĸ߶�
  vHeight := Height - GetTitleHeight;  // ��ȥ������
  // ˮƽ�������ݿ���ʾ�Ŀ��
  vWidth := Width;
  if cgoIndicator in FOptions then
    vWidth := vWidth - FIndicatorWidth;

  if BorderVisible then  // �߿����
  begin
    vHeight := vHeight - 2 * GBorderWidth;  // �߶ȼ�ȥ�߿�
    vWidth := vWidth - 2 * GBorderWidth;
  end;
  // �жϹ������Ƿ���ʾ
  vVVisible := False;
  vHVisible := False;
  if vVMax > vHeight then  // ��ֱ���ڸ߶�
  begin
    vVVisible := True;
    vWidth := vWidth - FVScrollBar.Width;
  end;

  if vHMax > vWidth then  // ˮƽ���ڿ��
  begin
    vHVisible := True;
    vHeight := vHeight - FHScrollBar.Height;
  end;

  // �ٴ��ж���ʾ״̬���Ծ�����2�������������κ�һ������ʾ���ƫ��
  if (not vVVisible) and (vVMax > vHeight) then  // ��ֱ���ڸ߶�
  begin
    vVVisible := True;
    vWidth := vWidth - FVScrollBar.Width;
  end;

  if (not vHVisible) and (vHMax > vWidth) then  // ˮƽ���ڿ��
  begin
    vHVisible := True;
    vHeight := vHeight - FHScrollBar.Height;
  end;

  // ���ù�������Max��Position
  FVScrollBar.Max := vVMax;
  FHScrollBar.Max := vHMax;
  if vHeight > 0 then
    FVScrollBar.PageSize := vHeight
  else
    FVScrollBar.PageSize := 0;

  if vWidth > 0 then
    FHScrollBar.PageSize := vWidth
  else
    FHScrollBar.PageSize := 0;

  // ���ù������Ŀɼ���
  FVScrollBar.Visible := vVVisible;
  FHScrollBar.Visible := vHVisible;
end;

constructor TCFGrid.Create(AOwner: TComponent);
begin
  CreateEx(AOwner, 0, 0);
end;

constructor TCFGrid.CreateEx(AOwner: TComponent; const ARowCount, AColCount: Cardinal);
begin
  inherited Create(AOwner);  // ���� CGrid
  FDefaultColWidth := 70;
  FRowHeight := 20;
  FIndicatorWidth := 20;
  FResizeCol := -1;
  FRowIndex := -1;
  FColIndex := -1;
  FColResizing := False;
  FOptions := [cgoRowSizing, cgoColSizing, cgoIndicator, cgoRowSelect];

  FVScrollBar := TCFScrollBar.Create(Self);  // ������ֱ������
  FVScrollBar.Orientation := coVertical;  // ���ù�����Ϊ��ֱ����
  FVScrollBar.OnScroll := OnVScroll;  // �󶨹����¼�
  FVScrollBar.Width := 10;
  FVScrollBar.Parent := Self;

  FHScrollBar := TCFScrollBar.Create(Self);  // ����ˮƽ������
  FHScrollBar.Orientation := coHorizontal;  // ���ù���������Ϊˮƽ����������
  FHScrollBar.OnScroll := OnHScroll;  // �󶨹����¼�
  FHScrollBar.Height := 10;
  FHScrollBar.Parent := Self;

  FTitleRow := TTitleRow.Create(Self, AColCount);  // ����������
  // �����к���
  FRows := TObjectList<TRow>.Create;

  if (ARowCount = 0) and (AColCount <> 0) then
    raise Exception.Create('�쳣������Ϊ0ʱ����������Ϊ����0����ֵ��');
  if ARowCount <> 0 then
  begin
    RowCount := ARowCount;
    if AColCount <> 0 then
      ColCount := AColCount;
  end;

  // ���ô��崴��ʱ�ĳ�ʼֵ
  Width := 200;
  Height := 250;
end;

procedure TCFGrid.DefaultCellDraw(const ARow, ACol: Cardinal;
  const ACanvas: TCanvas; const ALeft, ATop: Integer);
begin
  FRows[ARow][ACol].Draw(ACanvas, ALeft, ATop, FRowHeight);
end;

destructor TCFGrid.Destroy;
begin
  FRows.Free;
  FTitleRow.Free;
  FVScrollBar.Free;
  FHScrollBar.Free;
  inherited;
end;

function TCFGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  inherited;
  if WheelDelta < 0 then
  begin
    if FVScrollBar.Visible then  // ���ڹ���������
    begin
      if FVScrollBar.Position < FVScrollBar.Max - FVScrollBar.PageSize then
      begin
        FVScrollBar.Position := FVScrollBar.Position + WHEEL_DELTA;
        UpdateDirectUI;
        Result := True;
      end;
    end;
  end
  else
  begin
    if FVScrollBar.Visible then
    begin
      if FVScrollBar.Position > FVScrollBar.Min then
      begin
        FVScrollBar.Position := FVScrollBar.Position - WHEEL_DELTA;
        UpdateDirectUI;
        Result := True;
      end;
    end;
  end;
end;

procedure TCFGrid.DoOnCellAfterEdit(const ARow, ACol: Cardinal);
begin
  if FEditControl <> nil then
  begin
    Cells[ARow, ACol] := FEditControl.Text;
    SendMessage(Self.Parent.Handle, WM_CF_REMOVECONTROL, Integer(FEditControl), 0);
    FEditControl.Free;
    FEditControl := nil;
  end;
end;

procedure TCFGrid.DoOnCellBeforeEdit(const ARow, ACol: Cardinal);
var
  vCancel: Boolean;
  vEditControlType: TEditControlType;
begin
  vCancel := False;
  vEditControlType := ectEdit;
  if Assigned(FOnCellBeforeEdit) then
    FOnCellBeforeEdit(Self, ARow, ACol, vCancel, vEditControlType);
  if not vCancel then
    ShowEditControl(ARow, ACol, vEditControlType);
end;

procedure TCFGrid.DoOnEditControlKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    DoOnCellAfterEdit(FRowIndex, FColIndex);
end;

procedure TCFGrid.DrawControl(ACanvas: TCanvas);

  procedure DrawTitle(const ADrawLeft, AStartCol, AEndCol: Integer);  // ���Ʊ����б���
  var
    vRight, i: Integer;
  begin
    ACanvas.Brush.Color := GTitleBackColor;
    vRight := Math.Min(GetDataDisplayRight, GetDataWidth);
    if cgoIndicator in FOptions then
      vRight := vRight + FIndicatorWidth;

    ACanvas.FillRect(Bounds(0, 0, vRight, GetTitleHeight));

    // ���Ʊ���������
    vRight := ADrawLeft;
    for i := AStartCol to AEndCol do
    begin
      FTitleRow[i].Draw(ACanvas, vRight, 0, FRowHeight);
      vRight := vRight + FTitleRow[i].Width;
    end;
  end;

  procedure DrawBorder;  // ���Ʊ߿�
  begin
    if BorderVisible then
    begin
      with ACanvas do
      begin
        Pen.Color := GBorderColor;
        MoveTo(0, 0);
        LineTo(Width - 1, 0);
        LineTo(Width - 1, Height - 1);
        LineTo(0, Height - 1);
        LineTo(0, 0);
      end;
    end;
  end;

var
  i, j, vDrawTop, vDrawLeft, vTop, vLeft, vDisplayRight: Integer;
  vStartRow, vEndRow, vStartCol, vEndCol: Integer;
begin
  inherited DrawControl(ACanvas);

  // ����ؼ���������
  vDisplayRight := Width;
  if FVScrollBar.Visible then  // ��ֱ����������
    vDisplayRight := vDisplayRight - FVScrollBar.Width;  // ��ȥ��ֱ�������Ŀ��

  if BorderVisible then  // �߿����
    vDisplayRight := vDisplayRight - GBorderWidth;  // ��ȥ�߿�

  ACanvas.FillRect(Rect(0, 0, vDisplayRight, GetDataDisplayBottom));

  // ��ȡ����ʾ����
  GetFirstColDisplay(vStartCol, vEndCol, vDrawLeft);  // ���㵱ǰ��ʾ����ʼ�С������к���ʼ����Կؼ�����ƫ����

  if (FRows.Count = 0) or (ColCount = 0) then
  begin
    DrawTitle(vDrawLeft, vStartCol, vEndCol);
    DrawBorder;
    Exit;
  end;

  // ��ȡ����ʾ����
  GetFirstRowDisplay(vStartRow, vEndRow, vDrawTop);  // ���㵱ǰ��ʾ����ʼ�С���������ź���ʼ����Կؼ�������ƫ����

  if ColCount <> 0 then  // ���ƿ���ʾ������������
  begin
    vTop := vDrawTop;
    //vDisplayRight := GetDataDisplayRight;
    for i := vStartRow to vEndRow  do
    begin
      vLeft := vDrawLeft;
      for j := vStartCol to vEndCol do
      begin
        if Assigned(FOnCellDraw) then
          FOnCellDraw(Self, i, j, ACanvas, vLeft, vTop)
        else
          DefaultCellDraw(i, j, ACanvas, vLeft, vTop);
        vLeft := vLeft + FRows[i][j].Width;
      end;

      {if i = FRowIndex then
      begin
        ACanvas.Brush.Color := GHightLightColor;
        ACanvas.FillRect(Rect(vLeft, vTop, vDisplayRight, vTop + FRowHeight));
      end
      else
        ACanvas.Brush.Color := GThemeColor;
      FRows[i].Draw(ACanvas, vLeft, vTop, vStartCol, vEndCol);}

      vTop := vTop + FRowHeight;
    end;
  end;

  DrawTitle(vDrawLeft, vStartCol, vEndCol);  // ���Ʊ����б���

  // ����ָʾ��
  if cgoIndicator in FOptions then
  begin
    i := Math.Min(GetDataDisplayBottom, FRows.Count * FRowHeight) + GetTitleHeight;
    ACanvas.FillRect(Rect(0, 0, FIndicatorWidth, i));
    vTop := vDrawTop;
    for i := vStartRow to vEndRow + 1 do  // +1�������ݸ߶�С�ڿؼ��߶�ʱ���һ��ָʾ��û���±���
    begin
      if vTop >= GetTitleHeight then
      begin
        ACanvas.MoveTo(0, vTop);
        ACanvas.LineTo(FIndicatorWidth, vTop);
      end;
      vTop := vTop + FRowHeight;
    end;
  end;

  // ��������
  if FVScrollBar.Visible then  // ��ֱ����������
  begin
    ACanvas.Refresh;
    i := SaveDC(ACanvas.Handle);  // ����(�豸�����Ļ���)�ֳ�
    try
      MoveWindowOrg(ACanvas.Handle, FVScrollBar.Left, FVScrollBar.Top);
      FVScrollBar.DrawTo(ACanvas);
    finally
      RestoreDC(ACanvas.Handle, i);  // �ָ�(�豸�����Ļ���)�ֳ�
    end;
  end;

  if FHScrollBar.Visible then  // ˮƽ����������
  begin
    ACanvas.Refresh;
    i := SaveDC(ACanvas.Handle);  // ����(�豸�����Ļ���)�ֳ�
    try
      MoveWindowOrg(ACanvas.Handle, FHScrollBar.Left, FHScrollBar.Top);
      FHScrollBar.DrawTo(ACanvas);
    finally
      RestoreDC(ACanvas.Handle, i);  // �ָ�(�豸�����Ļ���)�ֳ�
    end;
  end;

  // �������������ཻ�Ľ�
  if (FVScrollBar.Visible) and (FHScrollBar.Visible) then
  begin
    ACanvas.Brush.Color := GTitleBackColor;
    if BorderVisible then  // �߿����
      ACanvas.FillRect(Rect(Width - FVScrollBar.Width - GBorderWidth, Height - FHScrollBar.Height - GBorderWidth, Width - GBorderWidth, Height - GBorderWidth))
    else  // �߿����
      ACanvas.FillRect(Rect(Width - FVScrollBar.Width, Height - FHScrollBar.Height, Width, Height));
  end;

  DrawBorder;
end;

procedure TCFGrid.GetDataCellAt(const ADataX, ADataY: Integer; var ARow, ACol: Integer);
var
  vRang, vRight: Integer;
  vGridPos, vRowSingle: Single;
begin
  ARow := -1;
  ACol := -1;

  if (ADataX < 0) or (ADataY < 0) then Exit;
  if ADataX > GetDataWidth then Exit;
  if ADataY > FRows.Count * FRowHeight then Exit;

  // �ڼ���
  vRang := FVScrollBar.Rang;  // ��Χ
  vGridPos := ADataY
    * (vRang - (GetDataDisplayHeight - FVScrollBar.PageSize))  // ��������
    / vRang;
  vRowSingle := vGridPos / FRowHeight;
  ARow := Trunc(vRowSingle);

  //�ڼ���
  if BorderVisible then
    vRight := GBorderWidth
  else
    vRight := 0;
  if cgoIndicator in FOptions then
    vRight := vRight + FIndicatorWidth;

  for vRang := 0 to ColCount - 1 do  // �����vRang�൱�� i �ã�ʡ������
  begin
    vRight := vRight + FTitleRow[vRang].Width;
    if vRight > ADataX then
    begin
      ACol := vRang;
      Break;
    end;
  end;
end;

function TCFGrid.GetCellDataBoundRect(const ARow, ACol: Integer): TRect;
var
  i, vCellTop, vCellLeft: Integer;
begin
  vCellLeft := 0;
  vCellTop := ARow * FRowHeight + GetTitleHeight;
  for i := 0 to ACol - 1 do
    vCellLeft := vCellLeft + FTitleRow[i].Width;
  Result := Bounds(vCellLeft, vCellTop, FTitleRow[ACol].Width, FRowHeight);
end;

function TCFGrid.GetCellClientRect(const ARow, ACol: Integer): TRect;
begin
  Result := GetCellDataBoundRect(ARow, ACol);
  OffsetRect(Result, -FHScrollBar.Position, -FVScrollBar.Position);
  if cgoIndicator in FOptions then  // ָʾ������
    OffsetRect(Result, FIndicatorWidth, 0);  // ����ָʾ���Ŀ��
end;

function TCFGrid.GetCells(ARow, ACol: Integer): string;
begin
  if (ARow < 0) or (ARow > RowCount - 1) then
    raise Exception.Create('�쳣��GetCells�������� ARow ����������Χ��');
  if (ACol < 0) or (ACol > ColCount - 1) then
    raise Exception.Create('�쳣��GetCells�������� ACol ����������Χ��');
    
  Result := FRows[ARow].Items[ACol].Text;
end;

function TCFGrid.GetColCount: Cardinal;
begin
  {if FRows.Count > 0 then  // ������Ϊ0
    Result := FRows[0].Count
  else}
  if Assigned(FTitleRow) then
    Result := FTitleRow.Count
  else
    Result := 0;
end;

function TCFGrid.GetDataDisplayBottom: Integer;
begin
  Result := Height;
  if FHScrollBar.Visible then  // ˮƽ������
    Result := Result - FHScrollBar.Height;

  if BorderVisible then  // �߿����
    Result := Result - GBorderWidth;
end;

function TCFGrid.GetDataDisplayHeight: Integer;
begin
  Result := Height - GetTitleHeight;
  if BorderVisible then  // �߿����
    Result := Result - 2 * GBorderWidth;  // ��ȥ�߿�
  if FHScrollBar.Visible then  // ˮƽ����������
    Result := Result - FHScrollBar.Height;  // ˮƽ�������ĸ߶�
end;

function TCFGrid.GetDataDisplayRight: Integer;
begin
  // ���ݿ��
  Result := GetDataWidth;
  if cgoIndicator in FOptions then  // ָʾ������
    Result := Result + FIndicatorWidth;  // ����ָʾ���Ŀ��

  if Result < Width then Exit;

  Result := Width;
  if FVScrollBar.Visible then  // ��ֱ����������
    Result := Result - FVScrollBar.Width;  // ��ȥ��ֱ�������Ŀ��
  if BorderVisible then  // �߿����
    Result := Result - GBorderWidth;  // ��ȥ�߿�
end;

function TCFGrid.GetDataDisplayWidth: Integer;
begin
  Result := Width;
  if FVScrollBar.Visible then  // ��ֱ����������
    Result := Result - FVScrollBar.Width;  // ��ȥ��ֱ�������Ŀ��
  if BorderVisible then  // �߿����
    Result := Result - 2 * GBorderWidth;  // ��ȥ���ߵı߿�

  if cgoIndicator in FOptions then  // ָʾ������
    Result := Result - FIndicatorWidth;  // ��ȥָʾ���Ŀ��
end;

procedure TCFGrid.GetFirstColDisplay(var AStartCol, AEndCol, ALeftOffset: Integer);
var
  vRight, vDspWidth: Integer;
  vGridHPos: Single;
  i: Integer;
begin
  //if RowCount = 0 then Exit;
  // ���ó�ֵ����֤���˳�����ִ�������ѭ��
  AStartCol := -1;
  AEndCol := -2;
  vGridHPos := 0;

  vDspWidth := GetDataDisplayWidth;  // չʾ���ݵĿ��
  if FHScrollBar.Rang > 0 then
    vGridHPos := (FHScrollBar.Position - FHScrollBar.Min)
      * (FHScrollBar.Rang - (vDspWidth - FHScrollBar.PageSize))  // ���ݷ�Χ����Ҫ����������ʾ�Ĵ�С(������ʾ�����Ĳ���)
      / FHScrollBar.Rang;

  vRight := 0;
  for i := 0 to ColCount - 1 do  // ������
  begin
    vRight := vRight + FTitleRow[i].Width;  // �ۼ��п�
    if vRight > vGridHPos then  // ��������п��ҵ�
    begin
      AStartCol := i;  // ��ʼ�и�ֵ
      Break;
    end;
  end;

  if AStartCol < 0 then Exit;  // ���õĳ�ʼֵ�ܱ�֤�˳�����ȥ�ҽ�����

  ALeftOffset := -Round(FTitleRow[AStartCol].Width - (vRight - vGridHpos));  // ��ƫ����
  if cgoIndicator in FOptions then  // ָʾ������
    ALeftOffset := ALeftOffset + FIndicatorWidth;  // ��ƫ����Ҫ��ָʾ���Ŀ��

  if FHScrollBar.Rang > vDspWidth then  // ���ݿ�ȴ��ڽ������ʾ���ݿ��
  begin
    for i := AStartCol + 1 to ColCount - 1 do  // ��������
    begin
      vRight := vRight + FTitleRow[i].Width;  // �ۼ��п�
      if vRight - vGridHPos >= vDspWidth then  // �ҵ�����Ľ�����
      begin
        AEndCol := i;  // ������
        Break;
      end;
    end;
  end
  else  // ���ݿ��С�ڵ��ڽ������ʾ���ݿ��
  begin
    AEndCol := ColCount - 1;
    if AEndCol < 0 then  // ������Ϊ 0 ʱ�����ƽ�����С����ʼ�У����������ݱ�������
      AEndCol := -2;
  end;
end;

procedure TCFGrid.GetFirstRowDisplay(var AStartRow, AEndRow, ATopOffset: Integer);
var
  vGridVPos, vfIndex: Single;
begin
  if RowCount = 0 then Exit;
  // ���ó�ʼ�У���֤���ʼֵ���������˳�����
  AStartRow := -1;
  AEndRow := -2;
  vGridVPos := 0;
  ATopOffset := 0;

  if FVScrollBar.Rang > 0 then
    vGridVPos := FVScrollBar.Position
      * (FVScrollBar.Rang - (GetDataDisplayHeight - FVScrollBar.PageSize))  // ���ݷ�Χ����Ҫ����������ʾ�Ĵ�С(������ʾ�����Ĳ���)
      / FVScrollBar.Rang;

  vfIndex := vGridVPos / FRowHeight;  // ��ʼ�У�ʵ����
  AStartRow := Trunc(vfIndex);  // ��ʼ�У�������
  ATopOffset := GetTitleHeight - Round(Frac(vfIndex) * FRowHeight);  // ��������ƫ�Ʊ����и�

  vfIndex := (vGridVPos + GetDataDisplayHeight) / FRowHeight;  // �����У�ʵ����
  AEndRow := Trunc(vfIndex);  // �����У�������
  {if Frac(vfIndex) > 0 then  // �����������������һ�д���
    Inc(vEndRow);}
  if AEndRow > RowCount - 1 then  // AEndRow��ֵΪ-2ʱ��������
    AEndRow := RowCount - 1;
end;

function TCFGrid.GetRowCount: Cardinal;
begin
  Result := FRows.Count;  // ��ȡ����
end;

procedure TCFGrid.GetTitleCellAt(const ATitleX, ATitleY: Integer; var ATitleRow,
  ATitleCol: Integer);
var
  i, vRight: Integer;
begin
  ATitleRow := -1;
  ATitleCol := -1;
  if (ATitleX > 0) and (ATitleX < FHScrollBar.Max)
    and (ATitleY > 0) and (ATitleY < GetTitleHeight)
  then  // �ڱ�����
  begin
    // �ڼ���
    ATitleRow := 0;

    //�ڼ���
    vRight := 0;
    for i := 0 to ColCount - 1 do  // �����vRang�൱�� i �ã�ʡ������
    begin
      vRight := vRight + FTitleRow[i].Width;
      if vRight > ATitleX then
      begin
        ATitleCol := i;
        Break;
      end;
    end;
  end;
end;

function TCFGrid.GetTitleColClientRect(const ATitleCol: Integer): TRect;
var
  i, vLeft: Integer;
begin
  vLeft := 0;
  for i := 0 to ATitleCol - 1 do  // ������
    vLeft := vLeft + FTitleRow[i].Width;  // �õ��е����
  Result := Bounds(vLeft, 0, FTitleRow[ATitleCol].Width, FRowHeight);  // ��ȡ��Ԫ��������
end;

function TCFGrid.GetTitleHeight: Integer;
begin
  Result := FRowHeight;  // ����߶�
end;

function TCFGrid.GetTitleText(ACol: Integer): string;
begin
  if (ACol < 0) or (ACol > ColCount - 1) then
    raise Exception.Create('�쳣��GetTitleText�������� ACol ����������Χ��');
  Result := FTitleRow[ACol].Text;
end;

procedure TCFGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  i, vDateX, vDateY, vOldRowIndex, vOldColIndex, vRight, vBottom: Integer;
begin
  inherited;
  if Button = mbMiddle then  // ����м�����ƽ�ƿ�ʼ
  begin
    FMovePt := Point(X, Y);
    Windows.SetCursor(LoadCursor(0, IDC_HAND));
    Exit;
  end;

  vRight := GetDataDisplayRight;
  vBottom := GetDataDisplayBottom;
  if cgoColSizing in FOptions then  // ָʾ������
  begin
    if PtInRect(Bounds(0, 0, vRight, GetTitleHeight), Point(X, Y)) then  // ����ڱ�����
    begin
      if FResizeCol >= 0 then  // Ҫ�ı���д���
      begin
        FResizeX := X;  // �ı�ֵ
        FColResizing := True;  // �������ڸı�
      end;
      Exit;
    end;
  end;

  if FVScrollBar.Visible and (X > vRight) and (Y < vBottom) then  // ������ڴ�ֱ��������
  begin
    FMouseDownCtronl := FVScrollBar;  // ��ֵ������������
    FVScrollBar.MouseDown(Button, Shift, X - vRight, Y);  // ����
  end
  else
  if FHScrollBar.Visible and (Y > vBottom) and (X < vRight) then  // �������ˮƽ��������
  begin
    FMouseDownCtronl := FHScrollBar;
    FHScrollBar.MouseDown(Button, Shift, X, Y - vBottom);
  end
  else
  if FRows.Count > 0 then  // �����������
  begin
    // ����ֵ
    vOldRowIndex := FRowIndex;
    vOldColIndex := FColIndex;
    FRowIndex := -1;
    FColIndex := -1;
    vDateX := FHScrollBar.Position + X;  // ʵ������ˮƽ����
    vDateY := FVScrollBar.Position + Y - GetTitleHeight;  // ʵ�����ݵĴ�ֱ���꣨��ȥ��������У�
    GetDataCellAt(vDateX, vDateY, FRowIndex, FColIndex);
    if (FRowIndex <> vOldRowIndex) or (FColIndex <> vOldColIndex) then  // ѡ�����з����仯
    begin
      if (vOldRowIndex >= 0) and (not FReadOnly) then  // ԭѡ�е�Ԫ��
        DoOnCellAfterEdit(vOldRowIndex, vOldColIndex);  // �༭���
      if cgoRowSelect in FOptions then  // ��ѡ
      begin
        if vOldRowIndex >= 0 then  // ԭѡ���д���
        begin
          for i := 0 to ColCount - 1 do  // ���ԭѡ���еĸ���Ԫ���ѡ��״̬
            Exclude(FRows[vOldRowIndex][i].FStates, ccsSelected);
        end;

        if FRowIndex >= 0 then  // ��ѡ���д���
        begin
          for i := 0 to ColCount - 1 do  // ��ѡ���и���Ԫ���ѡ��״̬
            Include(FRows[FRowIndex][i].FStates, ccsSelected);
        end;
      end
      else  // ����ѡ
      begin
        if vOldRowIndex >= 0 then  // ԭѡ�е�Ԫ�����
          Exclude(FRows[vOldRowIndex][vOldColIndex].FStates, ccsSelected);

        if FRowIndex >= 0 then  // ��ѡ�е�Ԫ��
          Include(FRows[FRowIndex][FColIndex].FStates, ccsSelected);
      end;

      UpdateDirectUI;  // �Ż�Ϊֻ���Ʊ䶯����
      if Assigned(FOnSelectCell) then
        FOnSelectCell(Self, FRowIndex, FColIndex);
    end;

    if (FRowIndex >= 0) and (not FReadOnly) then  // ��ѡ�е�Ԫ��
      DoOnCellBeforeEdit(FRowIndex, FColIndex);
  end;
end;

procedure TCFGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  vStartCol, vEndCol, vLeftOffset: Integer;
  i, vRight: Integer;
begin
  inherited;

  if Shift = [ssMiddle] then  // ����м�����
  begin
    FHScrollBar.Position := FHScrollBar.Position + (FMovePt.X - X);
    FVScrollBar.Position := FVScrollBar.Position + (FMovePt.Y - Y);
    FMovePt.X := X;
    FMovePt.Y := Y;
    Windows.SetCursor(LoadCursor(0, IDC_HAND));
    UpdateDirectUI;
    Exit;
  end;
  if cgoColSizing in FOptions then  // ָʾ������
  begin
    if FColResizing then  // ����ڱ�������������֮��������ϣ�����ƶ��п�ʵʱ�ı�
    begin
      // �п�ʵʱ�ı�
      SetColWidth(FResizeCol, FTitleRow[FResizeCol].Width + X - FResizeX);
      FResizeX := X;
      Exit;
    end;
    Cursor := crDefault;  // ������ʽΪ��ͨ
    FResizeCol := -1;

    if PtInRect(Bounds(0, 0, Width - FVScrollBar.Width, GetTitleHeight), Point(X, Y)) then  // ���û�е����ڱ������ƶ������ʽ��ʾ���Ըı��п�
    begin
      GetFirstColDisplay(vStartCol, vEndCol, vLeftOffset);  // �ͻ������ݵ���ʼ�кͽ������Լ����ݵ�ƫ����
      if vStartCol >= 0 then
      begin
        vRight := vLeftOffset;
        for i := vStartCol to vEndCol do  // �ӿ�ʼ�е�������������
        begin
          vRight := vRight + FTitleRow[i].Width;  // �ͻ������ұ߽��λ��
          if (X > vRight - 4) and (X < vRight + 5) then  // ����֮����λ������ƫ�Ƽ�������
          begin
            FResizeCol := i;  // Ҫ�ı��е��п�
            Cursor := crHSplit;  // �ı�������ʽ
            Break;
          end;
        end;
      end;
      Exit;
    end;
  end;

  if FMouseDownCtronl = FVScrollBar then  // �ڴ�ֱ���������ƶ�
    FVScrollBar.MouseMove(Shift, X + FVScrollBar.Width - Width, Y)
  else
  if FMouseDownCtronl = FHScrollBar then  // ��ˮƽ���������ƶ�
    FHScrollBar.MouseMove(Shift, X, Y + FHScrollBar.Height - Height)
  else
  if FRows.Count > 0 then
  begin
    if ssLeft in Shift then  // ��ѡ
    begin

    end;
  end;
end;

procedure TCFGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  vTitleRow, vTitleCol: Integer;
begin
  inherited;
  if Button = mbMiddle then
  begin
    Windows.SetCursor(LoadCursor(0, IDC_ARROW));
    Exit;
  end;
  FColResizing := False;
  if FResizeCol >= 0 then  // ���иı�ѡ���е��п�
  begin
    //SetColWidth(FResizeCol, FTitleRow[FResizeCol].Width + X - FResizeX);
    FResizeCol := -1;  // �ı��п�֮����Ϊû��Ҫ�ı���е��п�
    Cursor := crDefault;  // �ָ������ʽ
    Exit;
  end;

  if FMouseDownCtronl = FVScrollBar then  // �ڴ�ֱ��������
    FVScrollBar.MouseUp(Button, Shift, X - GetDataDisplayRight, Y)
  else
  if FMouseDownCtronl = FHScrollBar then  // ��ˮƽ��������
    FHScrollBar.MouseUp(Button, Shift, X, Y - GetDataDisplayBottom);
  if FMouseDownCtronl <> nil then  // �����¼�������
    FMouseDownCtronl := nil
  else  // �ڷǹ�����������
  begin
    GetTitleCellAt(FHScrollBar.Position + X, Y, vTitleRow, vTitleCol);
    if (vTitleRow >= 0) and (vTitleCol >= 0) then
    begin
      if Assigned(FOnTitleClick) then
        FOnTitleClick(Self, vTitleRow, vTitleCol);
    end;
  end;
end;


procedure TCFGrid.OnHScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  UpdateDirectUI;  // �ػ�����
end;

procedure TCFGrid.OnVScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  UpdateDirectUI;  // ��������
end;

procedure TCFGrid.ScrollToRow(const ARowIndex: Cardinal);
begin
  FVScrollBar.Position := 50;
  UpdateDirectUI;
end;

procedure TCFGrid.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  CheckScrollBarVisible;
  CalcScrollBarPosition;
end;

procedure TCFGrid.SetCells(ARow, ACol: Integer; const Value: string);
var
  vCellRect: TRect;
begin 
  if (ARow < 0) or (ARow > RowCount - 1) then
    raise Exception.Create('�쳣��SetCells�������� ARow ����������Χ��');
  if (ACol < 0) or (ACol > ColCount - 1) then
    raise Exception.Create('�쳣��SetCells�������� ACol ����������Χ��');
    
  if Value <> FRows[ARow].Items[ACol].Text then
  begin
    FRows[ARow].Items[ACol].Text := Value;
    vCellRect := GetCellClientRect(ARow, ACol);
    OffsetRect(vCellRect, Left, Top);

    IntersectRect(vCellRect, vCellRect, ClientRect);  // ���ص�2��3��������ľ��ν���

    if not IsRectEmpty(vCellRect) then  // ��Ԫ������Ϳͻ��������н���
      UpdateDirectUI(vCellRect);
  end;
end;

procedure TCFGrid.SetColCount(Value: Cardinal);
var
  i, j, vColCount: Integer;
  vCol: TCol;
  vTitleCol: TTitleCol;
begin
  if ColCount <> Value then  // ��������иı�
  begin
    vColCount := ColCount;
    if Value > vColCount then  // ������
    begin
      // ���ı����е�����
      for i := vColCount to Value - 1 do
      begin
        vTitleCol := TTitleCol.Create(FTitleRow);  // ���ӱ�����
        //vCol.Text := IntToStr(i) + '-����';
        FTitleRow.Add(vTitleCol);  // ���ӱ�����
      end;
      // ���������е�����
      if RowCount > 0 then
      begin
        for i := 0 to FRows.Count - 1 do  // ������
        begin
          for j := vColCount to Value - 1 do  // �����н��и�������
          begin
            vCol := TCol.Create(FRows[i]);  // ������
            //vCol.Text := IntToStr(i) + '-' + IntToStr(j);
            FRows[i].Add(vCol);  // ������
          end;
        end;
      end;
    end
    else  // ������
    begin
      // ���ı����е�����
      for i := vColCount - 1 downto Value do  // ���±�����ʵ�ּ���
        FTitleRow.Delete(i);  // ɾ��������
      // ���������е�����
      if RowCount > 0 then
      begin
        for i := 0 to FRows.Count - 1 do  // ������
        begin
          for j := vColCount - 1 downto Value do  // ���±�������������ʵ�ּ���
            FRows[i].Delete(j);  // ����
        end;
      end;
    end;
    CheckScrollBarVisible;
    UpdateDirectUI;
  end;
end;

procedure TCFGrid.SetColWidth(const ACol, AWidth: Integer);
var
  i, vW: Integer;
begin
  if AWidth < DefaultColWidth then  // �п�С��Ĭ�ϵ��п�
    vW := DefaultColWidth  // �����п�ΪĬ��ֵ
  else
    vW := AWidth;  // �п�ΪҪ���õ��п�ֵ
  FTitleRow[ACol].Width := vW;  // �ı�����п�
  for i := 0 to RowCount - 1 do  // ����������
    FRows[i][ACol].Width := vW;  // �������п���иı�
  CheckScrollBarVisible;
  UpdateDirectUI;  // ���¿ͻ�������
end;

procedure TCFGrid.SetOptions(Value: TCGridOptions);
begin
  if FOptions <> Value then
  begin
    FOptions := Value;
    UpdateDirectUI;
  end;
end;

procedure TCFGrid.SetReadOnly(Value: Boolean);
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    {to do: ����༭������ʾ������Ϊֻ��ʱȡ���༭}
  end;
end;

procedure TCFGrid.SetRowCount(Value: Cardinal);
var
  vRow: TRow;
  i, vRowCount: Integer; 
begin
  if FRows.Count <> Value then  // �и��иı�
  begin
    vRowCount := RowCount;  // ����ԭ��������
    if Value > vRowCount then  // Ҫ���õ������ͺ�ԭ�����������бȽϣ�Ҫ������
    begin
      for i := vRowCount to Value - 1 do  // ����������
      begin
        vRow := TRow.Create(Self, ColCount);  // ������
        FRows.Add(vRow);  // ������
      end;
    end
    else  // Ҫʵ�ּ�����
    begin
      for i := vRowCount - 1 downto Value do  // ���±�����ʵ�ּ���
        FRows.Delete(i);  // ����
    end;                                              
    CheckScrollBarVisible;
    UpdateDirectUI;
  end;
end;

procedure TCFGrid.SetTitleText(ATitleCol: Integer; const Value: string);
var
  vColRect: TRect;
begin
  if (ATitleCol < 0) or (ATitleCol > ColCount - 1) then
    raise Exception.Create('�쳣��SetTitleText�������� ACol ����������Χ��');
  if Value <> FTitleRow[ATitleCol].Text then
  begin
    FTitleRow[ATitleCol].Text := Value;
    vColRect := GetTitleColClientRect(ATitleCol);
    OffsetRect(vColRect, Left, Top);

    IntersectRect(vColRect, vColRect, ClientRect);  // ���ص�2��3��������ľ��ν���

    if not IsRectEmpty(vColRect) then  // ��Ԫ������Ϳͻ��������н���
      UpdateDirectUI(vColRect);
  end;
end;

procedure TCFGrid.ShowEditControl(const ARow, ACol: Cardinal;
  const AEditControlType: TEditControlType);
var
  vRect: TRect;
begin
  case AEditControlType of
    ectEdit:
      begin
        FEditControl := TCFEdit.Create(Self);
        with (FEditControl as TCFEdit) do
        begin
          Font := Self.Font;
          Text := Cells[ARow, ACol];
          OnKeyPress := DoOnEditControlKeyPress;
        end;
      end;

    ectCombobox: FEditControl := TCFCombobox.Create(Self);
    ectButtonEdit: FEditControl := TCFButtonEdit.Create(Self);
    ectGridEdit: FEditControl := TCFGridEdit.Create(Self);
  end;

  vRect := GetCellClientRect(ARow, ACol);
  FEditControl.Left := Left + vRect.Left;
  FEditControl.Top := Top + vRect.Top;
  FEditControl.Width := vRect.Right - vRect.Left + 1;
  FEditControl.Height := vRect.Bottom - vRect.Top + 1;

  FEditControl.Parent := Self.Parent;
  FEditControl.BringToFront;
end;

{ TCol }

constructor TCol.Create(const ARow: TRow);
begin
  inherited Create;
  FRow := ARow;
  FWidth := 70;
end;

procedure TCol.Draw(const ACanvas: TCanvas; const ALeft, ATop, AHeight: Integer);
var
  vRect: TRect;
begin
  if ccsSelected in FStates then  // ��Ԫ��ѡ��
    ACanvas.Brush.Color := GHightLightColor  // ������ʾ
  else
    ACanvas.Brush.Color := GBackColor;

  vRect := Rect(ALeft + 1, ATop + 1, ALeft + FWidth, ATop + AHeight);
  ACanvas.FillRect(vRect);  // �ػ�Ҫ������ʾ������
  // �����Ԫ�������
  InflateRect(vRect, -2, -1);
  {Windows.ExtTextOut(ACanvas.Handle, ALeft + 3, ATop + 4, 0, nil, FText,
    Length(FText), nil);}
  ACanvas.TextRect(vRect, FText);  // ʵ�ֲ�������Ԫ��Χ������ʾ�ı�
  // �߿�
  ACanvas.Pen.Color := GLineColor;  // ������
  //ACanvas.Rectangle(Rect(ALeft, ATop, ALeft + FWidth, ATop + AHeight));
  // ����Ԫ��ı߿���
  ACanvas.MoveTo(ALeft, ATop + AHeight);  // ���½�
  ACanvas.LineTo(ALeft + FWidth, ATop + AHeight);  // ���½�
  ACanvas.LineTo(ALeft + FWidth, ATop);  // ���Ͻ�

//  TextOut(ACanvas.Handle, ALeft + 4, ATop + 4, PChar(FText), Length(FText));
//  ACanvas.TextOut(ALeft + 4, ATop + 4, FText);
//  TextHeight(FText);
//  vWCent := 4;
//  vWCent := ACanvas.TextWidth(FText);
//  vWCent := (FWidth - vWCent) div 2;
//  //InflateRect(vRect, -2, 0);
//  Windows.DrawTextEx(ACanvas.Handle, PChar(FText), -1, vRect, DT_LEFT or DT_VCENTER or DT_SINGLELINE, nil);
end;

{ TRow }

constructor TRow.Create(const AGrid: TCFGrid; const AColCount: Cardinal);
var
  vCol: TCol;
  i: Integer;
begin
  inherited Create;
  FGrid := AGrid;
  for i := 0 to AColCount - 1 do  // ������
  begin
    vCol := TCol.Create(Self);  // ������
    Add(vCol);  // ������
  end;
end;

procedure TRow.Draw(const ACanvas: TCanvas; const ALeft, ATop, AStartCol, AEndCol: Integer);
var
  i, vLeft: Integer;
begin
  vLeft := ALeft;
  for i := AStartCol to AEndCol do  // ������չʾ����
  begin
    Items[i].Draw(ACanvas, vLeft, ATop, FGrid.RowHeight);  // ����Ԫ�������
    vLeft := vLeft + Items[i].Width;  // ��һ����Ԫ������Ҫ���п�
  end;
end;

function TRow.Get(Index: Integer): TCol;
begin
  Result := TCol(inherited Get(Index));
end;

procedure TRow.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if Action = TListNotification.lnDeleted then  // ����֪ͨ�ͷ�
    TCol(Ptr).Free;
end;

procedure TRow.Put(Index: Integer; const Value: TCol);
begin
  inherited Put(Index, Value);
end;

{ TTitleRow }

constructor TTitleRow.Create(const AGrid: TCFGrid; const AColCount: Cardinal);
var
  vTitleCol: TTitleCol;
  i: Integer;
begin
  inherited Create;
  FGrid := AGrid;
  for i := 0 to AColCount - 1 do  // ������
  begin
    vTitleCol := TTitleCol.Create(Self);  // ������
    Add(vTitleCol);  // ������
  end;
end;

procedure TTitleRow.Draw(const ACanvas: TCanvas; const ALeft, ATop, AStartCol,
  AEndCol: Integer);
var
  i, vLeft: Integer;
begin
  vLeft := ALeft;
  for i := AStartCol to AEndCol do  // ������չʾ����
  begin
    Items[i].Draw(ACanvas, vLeft, ATop, FGrid.RowHeight);  // ����Ԫ�������
    vLeft := vLeft + Items[i].Width;  // ��һ����Ԫ������Ҫ���п�
  end;
end;

function TTitleRow.Get(Index: Integer): TTitleCol;
begin
  Result := TTitleCol(inherited Get(Index));
end;

procedure TTitleRow.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if Action = TListNotification.lnDeleted then  // ����֪ͨ�ͷ�
    TTitleCol(Ptr).Free;
end;

procedure TTitleRow.Put(Index: Integer; const Value: TTitleCol);
begin
  inherited Put(Index, Value);
end;

{ TTitleCol }

constructor TTitleCol.Create(const ATitleRow: TTitleRow);
begin
  inherited Create;
  //FRow := ARow;
  FWidth := 70;
end;

procedure TTitleCol.Draw(const ACanvas: TCanvas; const ALeft, ATop,
  AHeight: Integer);
begin
  ACanvas.FillRect(Rect(ALeft + 1, ATop + 1, ALeft + FWidth, ATop + AHeight));  // �ػ�Ҫ������ʾ������
  ACanvas.Pen.Color := GLineColor;  // ������
  // ����Ԫ��ı߿���
  ACanvas.MoveTo(ALeft, ATop + AHeight);  // ���½�
  ACanvas.LineTo(ALeft + FWidth, ATop + AHeight);  // ���½�
  ACanvas.LineTo(ALeft + FWidth, ATop);  // ���Ͻ�
  // �����Ԫ�������
  Windows.ExtTextOut(ACanvas.Handle, ALeft + 3, ATop + 4, 0, nil, FText,
    Length(FText), nil);
end;

end.
