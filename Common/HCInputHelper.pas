unit HCInputHelper;

interface

uses
  Windows, Classes, Messages, Graphics, SysUtils, Imm, HCCommon;

type
  THCInputHelper = class(TObject)
  private
    FHandle: THandle;
    FLeft, FTop, FWidth, FHeight: Integer;
    FBorderColor: TColor;
    FCompStr, FBeforText, FAfterText: string;  // FBeforText, FAfterTextĿǰ������ʾ��ʵ��Ӧ��ʱ��ֱ�����겻��Ҫ��¼
    FEnable, FResize, FActive: Boolean;
    function GetVisible: Boolean;
    procedure SetActive(const Value: Boolean);
    procedure Paint(const ADC: HDC; const ARect: TRect);
    procedure UpdateView;
    procedure WndProc(var Message: TMessage);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Show; overload;
    procedure Show(const ALeft, ATop: Integer); overload;
    procedure Show(const APoint: TPoint); overload;
    procedure Close;
    /// <summary> ���뷨�Ƿ���Ҫ���µ�����ʾλ�� </summary>
    function ResetImeCompRect(var AImePosition: TPoint): Boolean;
    function ClientRect: TRect;
    function GetCandiText(const AIndex: Byte): string;
    procedure SetCompositionString(const S: string);
    procedure SetCaretString(const ABeforText, AAfterText: string);
    procedure CompWndMove(const AHandle: THandle; const ACaretX, ACaretY: Integer);

    property Height: Integer read FHeight;
    property Resize: Boolean read FResize;
    property Enable: Boolean read FEnable write FEnable;
    property Visible: Boolean read GetVisible;
    property Active: Boolean read FActive write SetActive;
  end;

implementation

const
  ImeExtFormClassName = 'THCInputHelper';
  //IMMGWLP_PRIVATE = SizeOf(NativeUInt);

{ THCInputHelper }

function THCInputHelper.ClientRect: TRect;
begin
  Result := Rect(0, 0, FWidth, FHeight);
end;

procedure THCInputHelper.Close;
begin
  ShowWindow(FHandle, SW_HIDE);
end;

procedure THCInputHelper.CompWndMove(const AHandle: THandle; const ACaretX,
  ACaretY: Integer);
var
  //vhIMC: HIMC;
  //vUIPrivate: HGlobal;
  //vPrivate: PUIPriv;
  vPt: TPoint;
  //vCF: TCompositionForm;
  //vHWND: HWND;
begin
  vPt.X := ACaretX;
  vPt.Y := ACaretY;
  ClientToScreen(AHandle, vPt);
  FLeft := vPt.X + 2;
  FTop := vPt.Y + 4;
  if FCompStr <> '' then  // ��֪ʶ
    Show;

  //vHWND := GetWindowLongPtr(AHandle, GWLP_USERDATA);	//ͨ��USERDATA���UI���ھ��

  {vUIPrivate := GetWindowLong(AHandle, IMMGWLP_PRIVATE);
  if (vUIPrivate = 0) then Exit;

  try
    vPrivate := GlobalLock(vUIPrivate);
    if (vPrivate = nil) then Exit;  // can not draw candidate window

    vPt.X := 0;
    vPt.Y := 0;
    ClientToScreen(vPrivate.hCompWnd, vPt);
    Show(vPt.X + 2, vPt.Y - FHeight - 2);
  finally
    GlobalUnlock(vUIPrivate);
  end;}

  {vhIMC := ImmGetContext(AHandle);
  if vhIMC <> 0 then
  begin
    try
      if ImmGetCompositionWindow(vhIMC, @vCF) then
      begin
        vPt.X := vCF.ptCurrentPos.X;
        vPt.Y := vCF.ptCurrentPos.Y;
        ClientToScreen(AHandle, vPt);
        if FImeCompVisible then
          Show(vPt.X + 2, vPt.Y - FHeight - 2)
        else
          Show(vPt.X + 2, vPt.Y);
      end;
    finally
      ImmReleaseContext(AHandle, vhIMC);
    end;
  end;}
end;

constructor THCInputHelper.Create;
var
  vWndCls: TWndClassEx;
//  vMethod: TMethod;
begin
  if not GetClassInfoEx(HInstance, ImeExtFormClassName, vWndCls) then
  begin
    vWndCls.cbSize        := SizeOf(TWndClassEx);
    vWndCls.lpszClassName := ImeExtFormClassName;
    vWndCls.style         := CS_VREDRAW or CS_HREDRAW or CS_DROPSHADOW;
    vWndCls.hInstance     := HInstance;
    vWndCls.lpfnWndProc   := @DefWindowProc;
    vWndCls.cbClsExtra    := 0;
    vWndCls.cbWndExtra    := SizeOf(NativeUInt) * 2;
    vWndCls.hIcon         := LoadIcon(hInstance,MakeIntResource('MAINICON'));
    vWndCls.hIconSm       := LoadIcon(hInstance,MakeIntResource('MAINICON'));
    vWndCls.hCursor       := LoadCursor(0, IDC_ARROW);
    vWndCls.hbrBackground := GetStockObject(GRAY_BRUSH);
    vWndCls.lpszMenuName  := nil;

    if RegisterClassEx(vWndCls) = 0 then
    begin
      MessageBox(0, 'ע�����뷨��ʾ���ڴ���!', 'HCView', MB_OK);
      Exit;
    end;
  end;

  FLeft := 20;
  FTop := 20;
  FWidth := 400;
  FHeight := 24;
  FResize := False;
  FEnable := True;
  FActive := False;
  FBorderColor := $00D2C5B5;

  if not IsWindow(FHandle) then  // �����ʾ����û�д���
  begin
    FHandle := CreateWindowEx(WS_EX_TOPMOST or WS_EX_TOOLWINDOW,  // ���㴰��
      ImeExtFormClassName, 'HCInputHelper', WS_POPUP or WS_DISABLED, // ����ʽ����ʼ��ֹ
      0, 0, FWidth, FHeight, 0, 0, HInstance, nil);
  end;

  if not IsWindow(FHandle) then
    raise Exception.Create('HCInputHelper����ʧ�ܣ�' + IntToStr(GetLastError));

  // �ο� Classes function AllocateHWnd(AMethod: TWndMethod): HWND;
  SetWindowLong(FHandle, GWL_WNDPROC, Longint(MakeObjectInstance(WndProc)));
//  vMethod.Data := Self;
//  vMethod.Code := @WndProc;
//  TypInfo.SetMethodProp(Self, 'OnClick', vMethod);
end;

destructor THCInputHelper.Destroy;
var
  vWndCls: TWndClassEx;
begin
  if GetClassInfoEx(HInstance, ImeExtFormClassName, vWndCls) then
  begin
    if Windows.UnregisterClass(ImeExtFormClassName, HInstance) then
    begin
      DestroyIcon(vWndCls.hIcon);
      DestroyIcon(vWndCls.hIconSm);
    end;
  end;

  DeallocateHWND(FHandle);

  if FHandle <> 0 then
    DestroyWindow(FHandle);

  inherited Destroy;
end;

function THCInputHelper.GetCandiText(const AIndex: Byte): string;
begin
  Result := '��' + IntToStr(AIndex + 1) + '��';
end;

function THCInputHelper.GetVisible: Boolean;
begin
  Result := IsWindowVisible(FHandle);
end;

procedure THCInputHelper.Paint(const ADC: HDC; const ARect: TRect);
var
  vCanvas: TCanvas;
  vRect: TRect;
  vText: string;
begin
  vCanvas := TCanvas.Create;
  try
    vCanvas.Handle := ADC;
    vCanvas.Font.Name := '����';
    vCanvas.Font.Size := 10;
    vCanvas.Pen.Color := FBorderColor;
    if not FActive then
      vCanvas.Brush.Color := $00FFFEFE
    else
      vCanvas.Brush.Color := clGray;// clInfoBk;

    vCanvas.Rectangle(ARect);
    vRect := ARect;
    InflateRect(vRect, -5, -5);
    if FCompStr <> '' then
      //vText := FCompStr + '[' + FBeforText + '][' + FAfterText + ']'
      vText := '1.��1�� 2.��2�� 3.��3�� 4.��4�� 5.��5��'
    else
      vText := '�����ڻ�û�к�֪ʶ�����^_^';

    vCanvas.TextRect(vRect, vText, [tfVerticalCenter, tfSingleLine]);
  finally
    vCanvas.Free;
  end;
end;

function THCInputHelper.ResetImeCompRect(var AImePosition: TPoint): Boolean;
var
  vPt: TPoint;
begin
  Result := False;

  if True then  // ��֪ʶ
  begin
    AImePosition.Y := AImePosition.Y + FHeight + 2;  // ԭ���뷨����

    {CompWndMove(AHandle, ACaretX, ACaretY);
    vPt.X := ACaretX;
    vPt.Y := ACaretY;
    ClientToScreen(AHandle, vPt);
    Show(vPt.X + 2, vPt.Y + 4);}
    Result := True;
  end;
end;

procedure THCInputHelper.Show(const ALeft, ATop: Integer);
begin
  FLeft := ALeft;
  FTop := ATop;
  Show;
end;

procedure THCInputHelper.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    UpdateView;
  end;
end;

procedure THCInputHelper.SetCaretString(const ABeforText, AAfterText: string);
begin
  FBeforText := ABeforText;
  FAfterText := AAfterText;
  UpdateView;
end;

procedure THCInputHelper.SetCompositionString(const S: string);
begin
  FResize := False;

  if FCompStr <> S then
  begin
    FCompStr := S;
    { TODO : �µ����룬����ƥ��֪ʶ���� }

    if FCompStr <> '' then  // ��֪ʶ
    begin
      if not Visible then
        Show
      else
        UpdateView;
    end
    else  // ��֪ʶ
      Close;
  end;
end;

procedure THCInputHelper.Show(const APoint: TPoint);
begin
  Show(APoint.X, APoint.Y);
end;

procedure THCInputHelper.UpdateView;
begin
  InvalidateRect(FHandle, ClientRect, False)
end;

procedure THCInputHelper.WndProc(var Message: TMessage);
var
  vDC: hDC;
  vPS: TPaintStruct;
  vRect: TRect;
begin
  case (Message.Msg) of
    {WM_DESTROY:
      PostQuitMessage(0);  // �����ⲿ�������}

    WM_PAINT:
      begin
        vDC := BeginPaint(FHandle, vPS);
        GetClientRect(FHandle, vRect);
        Paint(vDC, vRect);
        EndPaint(FHandle, vPS);
      end;

    WM_ERASEBKGND:  // ֪ͨ�Ѿ��ػ�������
      begin
        Message.Result := 1;
      end;

    WM_MOUSEACTIVATE:
      Message.Result := MA_NOACTIVATE;
  else
    Message.Result := DefWindowProc(FHandle, Message.Msg, Message.WParam, Message.LParam);
  end;
end;

procedure THCInputHelper.Show;
begin
  FActive := False;

  if not Visible then
    ShowWindow(FHandle, SW_SHOWNOACTIVATE);

  MoveWindow(FHandle, FLeft, FTop, FWidth, FHeight, False);
end;

end.
