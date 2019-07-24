unit HCViewIH;

interface

uses
  Windows, Classes, SysUtils, Messages, Imm, HCView, HCInputHelper, HCCustomData;

type
  THCViewIH = class(THCView)
  private
    FInputHelper: THCInputHelper;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    /// <summary> �Ƿ��������뷨����Ĵ���������ID�ʹ��� </summary>
    function DoProcessIMECandi(const ACandi: string): Boolean; virtual;
    procedure WMImeNotify(var Message: TMessage); message WM_IME_NOTIFY;
    procedure UpdateImeComposition(const ALParam: Integer); override;
    procedure UpdateImePosition; override;  // IME ֪ͨ���뷨����λ��
    /// <summary> ʵ�ֲ����ı� </summary>
    function DoInsertText(const AText: string): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{ THCViewIH }

constructor THCViewIH.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInputHelper := THCInputHelper.Create;
end;

destructor THCViewIH.Destroy;
begin
  FreeAndNil(FInputHelper);
  inherited;
end;

function THCViewIH.DoInsertText(const AText: string): Boolean;
var
  vTopData: THCCustomData;
begin
  Result := inherited DoInsertText(AText);
  vTopData := Self.ActiveSectionTopLevelData;
end;

function THCViewIH.DoProcessIMECandi(const ACandi: string): Boolean;
begin
  Result := True;
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

    vCF.dwStyle := CFS_FORCE_POSITION;  // ǿ�ư��ҵ�λ��  CFS_RECT
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

  inherited;
end;

end.
