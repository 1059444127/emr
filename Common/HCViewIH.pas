unit HCViewIH;

interface

uses
  Windows, Classes, SysUtils, Messages, Imm, HCView, HCCallBackMethod, HCInputHelper,
  HCCustomData, HCItem, HCStyle, HCRectItem;

type
  THCViewIH = class(THCView)
  private
    FInputHelper: THCInputHelper;
    FPProc: Pointer;
    /// <summary> �ͼ����̹��ӵĻص������������������Ϣ </summary>
    /// <param name="nCode">Hook�ı�־</param>
    /// <param name="wParam">��ʾ��Ϣ������</param>
    /// <param name="lParam">ָ��KBDLLHOOKSTRUCT�ṹ��ָ��</param>
    /// <returns>�����Ϊ0��Windows���������Ϣ���򲻻����յ������Ϣ</returns>
    function KeyboardProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
    procedure SetIHKeyHook;  // ���õͼ����̹���
    procedure UnSetIHKeyHook;  // ж�صͼ����̹���
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    /// <summary> �Ƿ��������뷨����Ĵ���������ID�ʹ��� </summary>
    function DoProcessIMECandi(const ACandi: string): Boolean; virtual;
    procedure WMImeNotify(var Message: TMessage); message WM_IME_NOTIFY;
    procedure UpdateImeComposition(const ALParam: Integer); override;
    procedure UpdateImePosition; override;  // IME ֪ͨ���뷨����λ��
    /// <summary> ����ƶ���ȡ���ǰ���ı� </summary>
    procedure DoCaretChange; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function PreProcessMessage(var Msg: TMsg): Boolean; override;
  end;

implementation

const
  WH_KEYBOARD_LL = 13;  // //�ͼ����̹��ӵ�����ֵ
  LLKHF_ALTDOWN = $20;
  CARETSTOPCHAR = '��,��;����:';

type
  tagKBDLLHOOKSTRUCT = packed record  // ��Windows NT 4 sp3����ϵͳ�в���ʹ��
    vkCode: DWORD;//�����ֵ
    scanCode: DWORD;//ɨ����ֵ��û���ù�����Ҳ����^_^��
    {һЩ��չ��־�������־ֵ�ĵ���λ���������ƣ�Ϊ1ʱALT������Ϊ0�෴��}
    flags: DWORD;
    time: DWORD;//��Ϣʱ���
    dwExtraInfo: DWORD;//����Ϣ��ص���չ��Ϣ
  end;
  KBDLLHOOKSTRUCT = tagKBDLLHOOKSTRUCT;
  PKBDLLHOOKSTRUCT = ^KBDLLHOOKSTRUCT;

var
  HHKLowLevelKybd: HHOOK;

{ THCViewIH }

constructor THCViewIH.Create(AOwner: TComponent);
var
  vM: TMethod;
begin
  inherited Create(AOwner);

  vM.Code := @THCViewIH.KeyboardProc;
  vM.Data := Self;
  FPProc := HCMakeInstruction(vM);

  //SetIHKeyHook;  // ����ʱ�ɹص�����Ч��
  FInputHelper := THCInputHelper.Create;
end;

destructor THCViewIH.Destroy;
begin
  FreeAndNil(FInputHelper);
  //UnSetIHKeyHook;  // ����ʱ�ɹص�����Ч��
  HCFreeInstruction(FPProc);
  inherited;
end;

procedure THCViewIH.DoCaretChange;

  {$REGION 'ȡ���ǰ���ַ���'}
  function GetCharBefor(const AOffset: Integer; var AChars: string): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := AOffset downto 1 do
    begin
      if Pos(AChars[i], CARETSTOPCHAR) > 0 then
      begin
        AChars := System.Copy(AChars, i + 1, AOffset - i);
        Result := True;
        Break;
      end;
    end;
  end;

  procedure GetBeforString(const AData: THCCustomData; const AStartItemNo: Integer; var ABefor: string);
  var
    i: Integer;
    vText: string;
  begin
    for i := AStartItemNo - 1 downto 0 do  // ��ǰ
    begin
      vText := AData.Items[i].Text;
      if (vText <> '') and GetCharBefor(vText.Length, vText) then
      begin
        ABefor := vText + ABefor;
        Break;
      end
      else
        ABefor := vText + ABefor;
    end;
  end;

  function GetCharAfter(const AOffset: Integer; var AChars: string): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := AOffset to AChars.Length do
    begin
      if Pos(AChars[i], CARETSTOPCHAR) > 0 then
      begin
        AChars := System.Copy(AChars, AOffset, i - AOffset);
        Result := True;
        Break;
      end;
    end;
  end;

  procedure GetAfterString(const AData: THCCustomData; const AStartItemNo: Integer; var AAfter: string);
  var
    i: Integer;
    vText: string;
  begin
    for i := AStartItemNo + 1 to AData.Items.Count - 1 do  // ��ǰ
    begin
      vText := AData.Items[i].Text;
      if (vText <> '') and GetCharAfter(1, vText) then
      begin
        AAfter := AAfter + vText;
        Break;
      end
      else
        AAfter := AAfter + vText;
    end;
  end;
  {$ENDREGION}

var
  vTopData: THCCustomData;
  vCurItemNo, i: Integer;
  vCurItem: THCCustomItem;
  vText, vsBefor, vsAfter: string;
begin
  inherited DoCaretChange;
  if not FInputHelper.Enable then Exit;

  vsBefor := '';
  vsAfter := '';

  vTopData := Self.ActiveSectionTopLevelData;
  vCurItemNo := vTopData.SelectInfo.StartItemNo;
  vCurItem := vTopData.GetActiveItem;
  if vCurItem.StyleNo < THCStyle.Null then  // �����RectItem
  begin
    if vTopData.SelectInfo.StartItemOffset = OffsetBefor then  // �����ǰ
      GetBeforString(vTopData, vCurItemNo - 1, vsBefor)
    else  // ����ں�
      GetAfterString(vTopData, vCurItemNo + 1, vsAfter);
  end
  else  // �ı�
  begin
    // ȡ���ǰ
    vText := vCurItem.Text;
    if GetCharBefor(vTopData.SelectInfo.StartItemOffset, vText) then  // �ӵ�ǰλ����ǰ
      vsBefor := vText
    else  // ��ǰûȡ��
    begin
      vsBefor := System.Copy(vText, 1, vTopData.SelectInfo.StartItemOffset);
      GetBeforString(vTopData, vCurItemNo - 1, vsBefor);
    end;

    // ȡ����
    vText := vCurItem.Text;
    if GetCharAfter(vTopData.SelectInfo.StartItemOffset + 1, vText) then  // �ӵ�ǰλ������
      vsAfter := vText
    else  // ��ǰûȡ��
    begin
      vsAfter := System.Copy(vText, vTopData.SelectInfo.StartItemOffset + 1, vText.Length - vTopData.SelectInfo.StartItemOffset);
      GetAfterString(vTopData, vCurItemNo + 1, vsAfter);
    end;
  end;

  FInputHelper.SetCaretString(vsBefor, vsAfter);
end;

function THCViewIH.DoProcessIMECandi(const ACandi: string): Boolean;
begin
  Result := True;
end;

function THCViewIH.KeyboardProc(nCode: Integer; wParam: WPARAM;
  lParam: LPARAM): LRESULT;
var
  vEatKeystroke: Boolean;
  vPKB: PKBDLLHOOKSTRUCT;
begin
  Result := 0;
  vEatKeystroke := False;

  if nCode = HC_ACTION then  // ��ʾWParam��LParam���������˰�����Ϣ
  begin
    case WParam of
      WM_SYSKEYDOWN, WM_SYSKEYUP:
        begin
          vPKB := PKBDLLHOOKSTRUCT(LParam);
          if vPKB.flags = LLKHF_ALTDOWN then
          begin
            if vPKB.vkCode = VK_SPACE then
            begin
              FInputHelper.Show;
              vEatKeystroke := True;
            end;
          end;
        end;

      //WM_SYSKEYDOWN,
      //WM_KEYDOWN,
      //WM_KEYUP: ;
        //vEatKeystroke := ((vPKB.vkCode = VK_SPACE) and ((vPKB.flags and LLKHF_ALTDOWN) <> 0));
        //(p.vkCode = VK_RWIN) or (p.vkCode = VK_LWIN)
        //or ((p.vkCode = VK_TAB) and ((p.flags and LLKHF_ALTDOWN) <> 0))
        //or ((p.vkCode = VK_ESCAPE) and ((GetKeyState(VK_CONTROL) and $8000) <> 0));
    end;
  end;

  if vEatKeystroke then
    Result := 1
  else
  if nCode <> 0 then
    Result := CallNextHookEx(0, nCode, WPARAM, LParam);
end;

procedure THCViewIH.KeyDown(var Key: Word; Shift: TShiftState);

  function IsImeExtShow: Boolean;
  begin
    Result := (Shift = [ssCtrl, ssAlt]) and (Key = VK_SPACE);
  end;

  function IsImeExtClose: Boolean;
  begin
    Result := (Shift = []) and (Key = VK_ESCAPE);
  end;

begin
  if FInputHelper.Enable and IsImeExtShow then
    FInputHelper.Show
  else
  if FInputHelper.Enable and IsImeExtClose then
    FInputHelper.Close
  else
    inherited KeyDown(Key, Shift);
end;

function THCViewIH.PreProcessMessage(var Msg: TMsg): Boolean;
var
  vVirtualKey: Cardinal;
  vText: string;
begin
  if (Msg.message = WM_KEYDOWN) and (Msg.wParam = VK_PROCESSKEY) then // ���뷨ת���ļ�
  begin
    //Msg.WParam := ImmGetVirtualKey(Msg.hwnd);  // ԭ�����ذ�ɶ��ʾɶ
    vVirtualKey := ImmGetVirtualKey(Msg.hwnd);
    if vVirtualKey - 127 = 59 then  // ; ��Ҫ�������뷨;�ŵĹ��ܣ��������ѡ
    begin
      FInputHelper.Active := not FInputHelper.Active;
      Result := True;
      Exit;
    end
    else
    if FInputHelper.Active and (vVirtualKey in [32, 49..57]) then  // �ո�, 1..9
    begin
      keybd_event(VK_ESCAPE, 0, 0, 0);
      keybd_event(VK_ESCAPE, 0, KEYEVENTF_KEYUP, 0);
      if vVirtualKey = 32 then
        vVirtualKey := 49;

      vText := FInputHelper.GetCandiText(vVirtualKey - 49);
      Self.InsertText(vText);

      Result := True;
      Exit;
    end;
  end;

  Result := inherited PreProcessMessage(Msg);
end;

procedure THCViewIH.SetIHKeyHook;
begin
  if HHKLowLevelKybd = 0 then  // û���ù�
  begin
    HHKLowLevelKybd := SetWindowsHookExW(WH_KEYBOARD_LL, FPProc, Hinstance, 0);

    if HHKLowLevelKybd = 0 then
      MessageBox(Handle, 'HCView���������ݼ�����ʧ�ܣ�', '��ʾ', MB_OK);
  end;
end;

procedure THCViewIH.UnSetIHKeyHook;
begin
  if HHKLowLevelKybd <> 0 then
  begin
    if UnhookWindowsHookEx(HHKLowLevelKybd) then  // ж�سɹ�
      HHKLowLevelKybd := 0;
  end;
end;

procedure THCViewIH.UpdateImeComposition(const ALParam: Integer);

  function GetCompositionStr(const AhImc: HIMC; const AType: Cardinal): string;
  var
    vSize: Integer;
    vBuffer: TBytes;
  begin
    Result := '';
    if AhImc <> 0 then
    begin
      vSize := ImmGetCompositionString(AhImc, AType, nil, 0);  // ��ȡIME����ַ����Ĵ�С
      if vSize > 0 then  	// ���IME����ַ�����Ϊ�գ���û�д���
      begin
        // ȡ���ַ���
        SetLength(vBuffer, vSize);
        ImmGetCompositionString(AhImc, AType, vBuffer, vSize);
        Result := WideStringOf(vBuffer);
      end;
    end;
  end;

var
  vhIMC: HIMC;
  vS: string;
  vCF: TCompositionForm;
begin
  vhIMC := ImmGetContext(Handle);
  if vhIMC <> 0 then
  begin
    try
      if FInputHelper.Enable and ((ALParam and GCS_COMPSTR) <> 0) then  // ���������б仯
      begin
        vS := GetCompositionStr(vhIMC, GCS_COMPSTR);
        FInputHelper.SetCompositionString(vS);

        if FInputHelper.Resize then  // ֪ʶ���뷨�����С�б仯ʱ���´������뷨����λ��
        begin
          if ImmGetCompositionWindow(vhIMC, @vCF) then
          begin
            if FInputHelper.ResetImeCompRect(vCF.ptCurrentPos) then
              ImmSetCompositionWindow(vhIMC, @vCF);
          end;
        end;
      end;

      if (ALParam and GCS_RESULTSTR) <> 0 then  // ֪ͨ��������������ַ���
      begin
        // ���������ı�һ���Բ��룬����᲻ͣ�Ĵ���KeyPress�¼�
        vS := GetCompositionStr(vhIMC, GCS_RESULTSTR);
        if vS <> '' then
        begin
          if DoProcessIMECandi(vS) then
            InsertText(vS);
        end;
      end
    finally
      ImmReleaseContext(Handle, vhIMC);
    end;
  end;
end;

procedure THCViewIH.UpdateImePosition;
var
  vhIMC: HIMC;
  vCF: TCompositionForm;
begin
  vhIMC := ImmGetContext(Handle);
  try
    // �������뷨��ǰ���λ����Ϣ
    vCF.ptCurrentPos := Point(Caret.X, Caret.Y + Caret.Height + 4);  // ���뷨��������λ��

    if FInputHelper.Enable then
      FInputHelper.ResetImeCompRect(vCF.ptCurrentPos);

    vCF.dwStyle := CFS_FORCE_POSITION;  // ǿ�ư��ҵ�λ�� CFS_RECT
    vCF.rcArea := ClientRect;
    ImmSetCompositionWindow(vhIMC, @vCF);

    if FInputHelper.Enable then
    begin
      //ImmGetCompositionWindow() ���뷨������ܻ�����������������Ҫ���¼���λ��
      FInputHelper.CompWndMove(Self.Handle, Caret.X, Caret.Y + Caret.Height);
    end;
  finally
    ImmReleaseContext(Handle, vhIMC);
  end;
end;

procedure THCViewIH.WMImeNotify(var Message: TMessage);
begin
  inherited;
  if FInputHelper.Enable then
  begin
    case Message.WParam of
      {IMN_OPENSTATUSWINDOW:  // �����뷨
        FImeExt.ImeOpen := True;

      IMN_CLOSESTATUSWINDOW:  // �ر������뷨
        FImeExt.ImeOpen := False; }

      IMN_SETCOMPOSITIONWINDOW,  // ���뷨���봰��λ�ñ仯
      IMN_CLOSECANDIDATE:  // ���˱�ѡ
        FInputHelper.CompWndMove(Self.Handle, Caret.X, Caret.Y + Caret.Height);
    end;
  end;
end;

procedure THCViewIH.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  FInputHelper.Close;
end;

end.
