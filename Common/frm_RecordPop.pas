{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit frm_RecordPop;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, EmrElementItem, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids,
  FireDAC.Comp.Client, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf,
  FireDAC.Comp.UI;

type
  TfrmRecordPop = class(TForm)
    pgPop: TPageControl;
    tsDomain: TTabSheet;
    btnDomainOk: TButton;
    tsNumber: TTabSheet;
    tsMemo: TTabSheet;
    tsDateTime: TTabSheet;
    sgdDomain: TStringGrid;
    pnl1: TPanel;
    lbl2: TLabel;
    edtSpliter: TEdit;
    pnl2: TPanel;
    edtvalue: TButtonedEdit;
    chkhideunit: TCheckBox;
    cbbUnit: TComboBox;
    btn1: TButton;
    btn3: TButton;
    btn4: TButton;
    btn5: TButton;
    btn6: TButton;
    btn7: TButton;
    btn8: TButton;
    btn9: TButton;
    btn0: TButton;
    btnDiv: TButton;
    btn2: TButton;
    btnAdd: TButton;
    btnDec: TButton;
    btnMul: TButton;
    btnCE: TButton;
    btnC: TButton;
    btnResult: TButton;
    btn41: TButton;
    btnDot: TButton;
    btn39: TButton;
    btn40: TButton;
    btn35: TButton;
    btn36: TButton;
    btn37: TButton;
    btn38: TButton;
    btnNumberOk: TButton;
    btn42: TButton;
    pnl3: TPanel;
    pnl4: TPanel;
    btnMemoOk: TButton;
    btnDateTimeOk: TButton;
    mmoMemo: TMemo;
    fdgxwtcrsr: TFDGUIxWaitCursor;
    pnlDate: TPanel;
    pnlTime: TPanel;
    dtpdate: TDateTimePicker;
    cbbdate: TComboBox;
    dtptime: TDateTimePicker;
    cbbtime: TComboBox;
    bvl1: TBevel;
    btnNow: TButton;
    procedure btnDomainOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnDateTimeOkClick(Sender: TObject);
    procedure btnCEClick(Sender: TObject);
    procedure edtvalueKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbbUnitCloseUp(Sender: TObject);
    procedure cbbUnitSelect(Sender: TObject);
    procedure btnCClick(Sender: TObject);
    procedure btnNumberOkClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btnDotClick(Sender: TObject);
    procedure btnResultClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btn35Click(Sender: TObject);
    procedure btnMemoOkClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgdDomainDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnNowClick(Sender: TObject);
    procedure cbbdateChange(Sender: TObject);
    procedure cbbtimeChange(Sender: TObject);
  private
    { Private declarations }
    // ��������
    FSnum1, FSnum2, FSmark, FOldUnit: string;
    FNum1, FNum2{, FMark}: Real;
    FFlag, FSign, FTemp, FTemplate: Boolean;
    FConCalcValue: Boolean;  // True �����������ʱ��ԭ���ַ������� False���ԭ���������ַ�
    //
    FFrmtp: string;
    FDeItem: TDeItem;
    FDBDomain: TFDMemTable;
    FOnActiveItemChange: TNotifyEvent;
    procedure SetDeItemValue(const AValue: string);

    procedure SetValueFocus;  // ���������ʱ�����㷵�ص���ֵ��
    procedure SetConCalcValue;  // ������������ּ�ʱ �����Ƿ�ԭֵ���������ַ�
    procedure PutCalcNumber(const ANum: Integer);
  protected
    //FMMTimerID: Cardinal;
    FPopupWindow: THandle;
    procedure PopupWndProc(var Message: TMessage); virtual;
    procedure RegPopupClass;
    procedure CreatePopupHandle;
    procedure Popup(X, Y: Integer);
  public
    { Public declarations }
    procedure PopupDeItem(const ADeItem: TDeItem; const APopupPt: TPoint);
    property OnActiveItemChange: TNotifyEvent read FOnActiveItemChange write FOnActiveItemChange;
  end;

implementation

uses
  emr_Common, emr_BLLConst, emr_BLLServerProxy, Winapi.MMSystem;

const
  PopupClassName = 'EMR_PopupClassName';

{$R *.dfm}

function ConversionValueByUnit(const AValue, AOldUnit, ANewUnit: string): string;
var
  vOldUnit, vNewUnit: string;
  viValue{, vReValue}: Single;
begin
  Result := AValue;
  if not TryStrToFloat(AValue, viValue) then  // ֵ
    Exit;
  vOldUnit := LowerCase(AOldUnit);  // ԭʼ��λ
  vNewUnit := LowerCase(ANewUnit);  // �µ�λ
  if vOldUnit = 'mmhg' then  // �����mmHg  100mmHg=13.3kPa
  begin
    if vNewUnit = 'kpa' then
    begin
      viValue := viValue * 133.3 / 1000;
      Result := FormatFloat('#.#', viValue);
    end;
  end
  else
  if vOldUnit = 'kpa' then  // �����KPa
  begin
    if vNewUnit = 'mmhg' then
    begin
      viValue := viValue * 1000 / 133.3;
      Result := Format('%d', [Round(viValue)]);
    end;
  end
  else
  if vOldUnit = '��' then  // ������  37�� = 98.6�H
  begin
    if vNewUnit = '�H' then  // ת����
    begin
      viValue := (viValue * 9 / 5) + 32;
      Result := FormatFloat('#.#', viValue);
    end;
  end
  else
  if vOldUnit = '�H' then  // �ǻ���
  begin
    if vNewUnit = '��' then  // ת����
    begin
      viValue := (viValue - 32) * 5 / 9;
      Result := FormatFloat('#.#', viValue);
    end;
  end;
end;

function Equal(a: double; m: string; b: double): double;
var
  r: double;
begin
  if (m = '+')then
    r := a + b
  else
  if (m = '-')then
    r := a - b
  else
  if (m = '*')then
    r := a * b
  else
  if (m = '/')then
    r := a / b ;
  equal := r;
end;

procedure TfrmRecordPop.btn1Click(Sender: TObject);
begin
  PutCalcNumber((Sender as TButton).Tag);
end;

procedure TfrmRecordPop.btn35Click(Sender: TObject);
begin
  edtValue.Text := (Sender as TButton).Tag.ToString;
  FTemp := False;
  FTemplate := True;
  FConCalcValue := True;
  SetValueFocus;
end;

procedure TfrmRecordPop.btnAddClick(Sender: TObject);
begin
  if FSign then
  begin
    FSnum2 := edtValue.Text;
    if FSnum2 <> '' then
      FNum2 := StrToFloat(edtValue.Text) ;
    if(FSmark = '/') and (FNum2 = 0) then
    begin
      //lblPop.Caption := '��������Ϊ0';
      FNum1 := 0;
      FSmark := '';
      FNum2 := 0
    end
    else
    edtValue.Text := FloatToStr(equal(FNum1, FSmark, FNum2));
    FFlag := True;
  end;
  FSnum1 := edtValue.Text;
  if FSnum1 <> '' then
    FNum1 := StrToFloat(FSnum1)
  else
  begin
    FNum1 := 0;
  end;
  FSmark := (Sender as TButton).Caption;
  FFlag := False;
  FSign := True;
  FTemp := FSign;
  SetValueFocus;
end;

procedure TfrmRecordPop.btnCClick(Sender: TObject);
var
  vS: string;
begin
  vS := edtValue.Text;
  if FFlag then
    edtValue.Text := ''
  else
  begin
    vS := Copy(vS, 0, Length(vS) - 1);
    edtValue.Text := vS;
  end;
  SetValueFocus;
end;

procedure TfrmRecordPop.btnCEClick(Sender: TObject);
begin
  edtValue.Text := '';
  FNum1 := 0;
  FSmark := '';
  FNum2 := 0;
  FTemplate := False;
  SetValueFocus;
end;

procedure TfrmRecordPop.btnDateTimeOkClick(Sender: TObject);
var
  vText: string;
begin
  if FFrmtp = TDeFrmtp.Date then
  begin
    //FDeItem[TDeProp.PreFormat] := cbbdate.Text;
    //FDeItem[TDeProp.Raw] := DateToStr(dtpdate.Date);
    vText := FormatDateTime(cbbdate.Text, dtpdate.Date);
  end
  else
  if FFrmtp = TDeFrmtp.Time then
  begin
    //FDeItem[TDeProp.PreFormat] := cbbtime.Text;
    //FDeItem[TDeProp.Raw] := TimeToStr(dtptime.Time);
    vText := FormatDateTime(cbbtime.Text, dtptime.Time);
  end
  else
  if FFrmtp = TDeFrmtp.DateTime then
  begin
    dtpdate.Time := dtptime.Time;
    //FDeItem[TDeProp.PreFormat] := cbbdate.Text + ' ' + cbbtime.Text;
    //FDeItem[TDeProp.Raw] := DateTimeToStr(dtpdate.DateTime);
    vText := FormatDateTime(cbbdate.Text + ' ' + cbbtime.Text, dtpdate.DateTime);
  end;

  if vText <> '' then
  begin
    SetDeItemValue(vText);
    Close;
  end;
end;

procedure TfrmRecordPop.btnDomainOkClick(Sender: TObject);
begin
  if sgdDomain.Row > 0 then
  begin
    FDeItem[TDeProp.CMVVCode] := sgdDomain.Cells[1, sgdDomain.Row];
    SetDeItemValue(sgdDomain.Cells[0, sgdDomain.Row]);
    Close;
  end;
end;

procedure TfrmRecordPop.btnDotClick(Sender: TObject);
begin
  edtValue.Text := edtValue.Text + '.';
  SetValueFocus;
end;

procedure TfrmRecordPop.btnMemoOkClick(Sender: TObject);
begin
  if mmoMemo.Text <> '' then
  begin
    SetDeItemValue(mmoMemo.Text);
    Close;
  end;
end;

procedure TfrmRecordPop.btnNowClick(Sender: TObject);
begin
  dtpdate.DateTime := Now;
  dtptime.DateTime := Now;
end;

procedure TfrmRecordPop.btnNumberOkClick(Sender: TObject);
var
  vText: string;
begin
  if chkhideunit.Checked then
    vText := edtValue.Text
  else
    vText := edtValue.Text + cbbUnit.Text;

  FDeItem[TDeProp.&Unit] := cbbUnit.Text;

  SetDeItemValue(vText);
  Close;
end;

procedure TfrmRecordPop.btnResultClick(Sender: TObject);
begin
  if FFlag then
    edtValue.Text := FloatToStr(Equal(StrToFloat(edtValue.Text), FSmark, FNum2))
  else
  begin
    if (FSmark = '') then
      edtValue.text := edtValue.text
    else
    begin
      FSnum2 := edtValue.Text;
      if (FSnum2 <> '') then
        FNum2 := StrToFloat(edtValue.Text)
      else
        FNum2 := FNum1;
      if ((FSmark = '/') and (FNum2 = 0)) then
      begin
        //lblPop.Caption := '��������Ϊ0';
        FNum1 := 0;
        FSmark := '';
        FNum2 := 0
      end
      else
      edtValue.Text := FloatToStr(Equal(FNum1, FSmark, FNum2));
      FFlag := true;
      FSign := False;
      FTemp := true;
    end;
  end;
  SetValueFocus;
end;

procedure TfrmRecordPop.cbbdateChange(Sender: TObject);
begin
  dtpdate.Format := cbbdate.Text;
end;

procedure TfrmRecordPop.cbbtimeChange(Sender: TObject);
begin
  dtptime.Format := cbbtime.Text;
end;

procedure TfrmRecordPop.cbbUnitCloseUp(Sender: TObject);
begin
  FOldUnit := cbbUnit.Text;
end;

procedure TfrmRecordPop.cbbUnitSelect(Sender: TObject);
begin
  if Trim(edtvalue.Text) <> '' then
    edtvalue.Text := ConversionValueByUnit(edtvalue.Text, FOldUnit, cbbUnit.Text);
end;

procedure TfrmRecordPop.CreatePopupHandle;
begin
  if not IsWindow(FPopupWindow) then  // �����ʾ����û�д���
  begin
    FPopupWindow := CreateWindowEx(
        WS_EX_TOOLWINDOW {or WS_EX_TOPMOST},  // ���㴰��
        PopupClassName,
        nil,
        WS_POPUP,  // ����ʽ����,֧��˫��
        0, 0, 100, 100, 0, 0, HInstance, nil);
    SetWindowLong(FPopupWindow, GWL_WNDPROC, Longint(MakeObjectInstance(PopupWndProc)));  // ���ں����滻Ϊ�෽��
  end;
end;

procedure TfrmRecordPop.edtvalueKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    btnNumberOk.Click;
    Key := 0;
  end;
end;

procedure TfrmRecordPop.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {if FMMTimerID > 0 then
  begin
    timeKillEvent(FMMTimerID);
    FMMTimerID := 0;
  end;}
  ShowWindow(FPopupWindow, SW_HIDE);
end;

procedure TfrmRecordPop.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  //FMMTimerID := 0;
  FPopupWindow := 0;
  RegPopupClass;
  CreatePopupHandle;
  Windows.SetParent(Handle, FPopupWindow);

  FDBDomain := TFDMemTable.Create(Self);

  for i := 0 to pgPop.PageCount - 1 do
    pgPop.Pages[i].TabVisible := False;  // ���ر�ǩ

  sgdDomain.RowCount := 1;
  sgdDomain.ColWidths[0] := 120;
  sgdDomain.ColWidths[1] := 40;
  sgdDomain.ColWidths[2] := 25;
  sgdDomain.ColWidths[3] := 35;

  sgdDomain.Cells[0, 0] := 'ֵ';
  sgdDomain.Cells[1, 0] := '����';
  sgdDomain.Cells[2, 0] := 'ID';
  sgdDomain.Cells[3, 0] := 'ƴ��';
end;

procedure TfrmRecordPop.FormDeactivate(Sender: TObject);
begin
  Close;
end;

procedure TfrmRecordPop.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FDBDomain);
  if IsWindow(FPopupWindow) then
    DestroyWindow(FPopupWindow);
end;

procedure TfrmRecordPop.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

{
  ---------------ͨ���ؼ������ȡ�ؼ�ʵ��--------------------------------------------
  ---------------ԭ����� Classes.pas ��Ԫ��13045�� <Delphi7>------------------------
  ---------------ԭ����� Classes.pas ��Ԫ��11613�� <Delphi2007>---------------------
  ---------------ԭ����� Classes.pas ��Ԫ��13045�� <Delphi2010>---------------------
  ---------------ԭ����� Classes.pas ��Ԫ��13512�� <DelphiXE>-----------------------
}
{function GetInstanceFromhWnd(const hWnd: Cardinal): TWinControl;
type
  PObjectInstance = ^TObjectInstance;

  TObjectInstance = packed record
    Code: Byte;            // ����ת $E8
    Offset: Integer;       // CalcJmpOffset(Instance, @Block^.Code);
    Next: PObjectInstance; // MainWndProc ��ַ
    Self: Pointer;         // �ؼ������ַ
  end;
var
  wc: PObjectInstance;
begin
  Result := nil;
  wc := Pointer(GetWindowLong(hWnd, GWL_WNDPROC));
  if wc <> nil then
    Result := wc.Self;
end;

procedure MMTimerProc(uTimerID, uMessage: UINT; dwUser, dw1,
  dw2: DWORD); stdcall;
var
  vfrmRecordPop: TfrmRecordPop;
  vActiveWindow: THandle;
  vProcessId: Cardinal;
begin
  vActiveWindow := GetActiveWindow;
  GetWindowThreadProcessId(vActiveWindow, vProcessId);

  if vProcessId <> GetCurrentProcessId then
  begin
    vfrmRecordPop := TfrmRecordPop(GetInstanceFromhWnd(dwUser));
    if vfrmRecordPop <> nil then
      vfrmRecordPop.Close;
  end;
end;}

procedure TfrmRecordPop.Popup(X, Y: Integer);
var
  vMonitor: TMonitor;
  //vMsg: TMsg;
begin
  vMonitor := Screen.MonitorFromPoint(Point(X, Y));

  if vMonitor <> nil then
  begin
    if X + Width > vMonitor.WorkareaRect.Right then
      X := vMonitor.WorkareaRect.Right - Width;
    if Y + Height > vMonitor.WorkareaRect.Bottom then
      Y := vMonitor.WorkareaRect.Bottom - Height;

    if X < vMonitor.WorkareaRect.Left then
      X := vMonitor.WorkareaRect.Left;
    if Y < vMonitor.WorkareaRect.Top then
      Y := vMonitor.WorkareaRect.Top;
  end
  else // Monitor is nil, use Screen object instead
  begin
    if X + Width > Screen.WorkareaRect.Right then
      X := Screen.WorkareaRect.Right - Width;
    if Y + Height > Screen.WorkareaRect.Bottom then
      Y := Screen.WorkareaRect.Bottom - Height;

    if X < Screen.WorkareaRect.Left then
      X := Screen.WorkareaRect.Left;
    if Y < Screen.WorkareaRect.Top then
      Y := Screen.WorkareaRect.Top;
  end;

  MoveWindow(FPopupWindow, X, Y, Width, Height, False);
  MoveWindow(Handle, 0, 0, Width, Height, False);
  ShowWindow(FPopupWindow, SW_SHOW);  //  SW_SHOWNOACTIVATE
  // ������ʱ��
  {if FMMTimerID = 0 then
  begin
    FMMTimerID := timeSetEvent(
      100, // �Ժ���ָ���¼�������
      1, // �Ժ���ָ����ʱ�ľ��ȣ���ֵԽС��ʱ���¼��ֱ���Խ�ߡ�ȱʡֵΪ1ms��
      @MMTimerProc, // �ص�����
      Handle, // ����û��ṩ�Ļص�����
      //��ʱ���¼�����
      TIME_PERIODIC  // ÿ��uDelay���������Եز����¼�
      or TIME_CALLBACK_FUNCTION);
  end;}

  {repeat
    PeekMessage(vMsg,0,0,0,PM_REMOVE);

    if Visible and (vMsg.message <> WM_QUIT) then
    begin
      TranslateMessage(vMsg);
      DispatchMessage(vmsg);
    end
    else
      Break;
  until Application.Terminated;}
end;

procedure TfrmRecordPop.PopupDeItem(const ADeItem: TDeItem; const APopupPt: TPoint);

  {$REGION 'IniDomainUI ��ʾֵ��'}
  procedure IniDomainUI;
  var
    vRow: Integer;
  begin
    sgdDomain.RowCount := FDBDomain.RecordCount + 1;

    vRow := 0;
    FDBDomain.First;
    while not FDBDomain.Eof do
    begin
      Inc(vRow);

      sgdDomain.Cells[0, vRow] := FDBDomain.FieldByName('devalue').AsString;
      sgdDomain.Cells[1, vRow] := FDBDomain.FieldByName('code').AsString;
      sgdDomain.Cells[2, vRow] := FDBDomain.FieldByName('id').AsString;
      sgdDomain.Cells[3, vRow] := FDBDomain.FieldByName('py').AsString;

      FDBDomain.Next;
    end;

    if sgdDomain.RowCount > 1 then
      sgdDomain.FixedRows := 1;
  end;
  {$ENDREGION}

var
  vDeUnit: string;
  vCMV: Integer;
  vDT: TDateTime;
begin
  FFrmtp := '';
  FDeItem := ADeItem;

  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETDEPROPERTY;  // ��ȡָ������Ԫ��������Ϣ
      ABLLServerReady.ExecParam.I['deid'] := StrToInt(FDeItem[TDeProp.Index]);
      ABLLServerReady.AddBackField('frmtp');
      ABLLServerReady.AddBackField('deunit');
      ABLLServerReady.AddBackField('domainid');
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServer.MethodRunOk then  // ����˷�������ִ�гɹ�
      begin
        ShowMessage(ABLLServer.MethodError);
        Exit;
      end;

      FFrmtp := ABLLServer.BackField('frmtp').AsString;
      vDeUnit := ABLLServer.BackField('deunit').AsString;
      vCMV := ABLLServer.BackField('domainid').AsInteger;
    end);

    // �������չʾ����
    if FFrmtp = TDeFrmtp.Number then  // ��ֵ
    begin
      edtvalue.Clear;
      pgPop.ActivePageIndex := 1;
      Self.Width := 185;
      Self.Height := 285;
    end
    else
    if (FFrmtp = TDeFrmtp.Date)
      or (FFrmtp = TDeFrmtp.Time)
      or (FFrmtp = TDeFrmtp.DateTime)
    then  // ����ʱ��
    begin
      pgPop.ActivePageIndex := 3;
      Self.Width := 260;
      Self.Height := 170;

      pnlDate.Visible := FFrmtp <> TDeFrmtp.Time;
      pnlTime.Visible := FFrmtp <> TDeFrmtp.Date;

      {if FFrmtp = TDeFrmtp.Date then
      begin
        if FDeItem[TDeProp.CMVVCode] <> '' then
          cbbdate.ItemIndex := cbbdate.Items.IndexOf(FDeItem[TDeProp.CMVVCode]);
      end
      else
      if FFrmtp = TDeFrmtp.Time then
      begin
        if FDeItem[TDeProp.CMVVCode] <> '' then
          cbbtime.ItemIndex := cbbtime.Items.IndexOf(FDeItem[TDeProp.CMVVCode]);
      end
      else  // data and time
      begin
        if FDeItem[TDeProp.CMVVCode] <> '' then
        begin
          cbbdate.ItemIndex := cbbdate.Items.IndexOf(Copy(FDeItem[TDeProp.CMVVCode], 1,
            Pos(' ', FDeItem[TDeProp.CMVVCode]) - 1));
          cbbtime.ItemIndex := cbbtime.Items.IndexOf(Copy(FDeItem[TDeProp.CMVVCode],
            Pos(' ', FDeItem[TDeProp.CMVVCode]) - 1, 20));
        end;
      end;

      if TryStrToDateTime(FDeItem.Text, vDT) then  // ��ֵ
      begin
        dtpdate.DateTime := vDT;
        dtptime.DateTime := vDT;
      end
      else
      begin
        dtpdate.DateTime := Now;
        dtptime.DateTime := Now;
      end;}
    end
    else
    if (FFrmtp = TDeFrmtp.Radio) or (FFrmtp = TDeFrmtp.Multiselect) then  // ������ѡ
    begin
      edtSpliter.Clear;

      if FDBDomain.Active then
        FDBDomain.EmptyDataSet;

      sgdDomain.RowCount := 1;
      pgPop.ActivePageIndex := 0;
      Self.Width := 260;
      Self.Height := 300;

      if vCMV > 0 then  // ��ֵ��
      begin
        BLLServerExec(
          procedure(const ABLLServerReady: TBLLServerProxy)
          begin
            ABLLServerReady.Cmd := BLL_GETDOMAINITEM;  // ��ȡֵ��ѡ��
            ABLLServerReady.ExecParam.I['domainid'] := vCMV;
            ABLLServerReady.BackDataSet := True;
          end,
          procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
          begin
            if not ABLLServer.MethodRunOk then  // ����˷�������ִ�гɹ�
            begin
              ShowMessage(ABLLServer.MethodError);
              Exit;
            end;

            if AMemTable <> nil then
              FDBDomain.CloneCursor(AMemTable, True);
          end);
      end;

      if FDBDomain.Active then
        IniDomainUI;
    end
    else
    if FFrmtp = TDeFrmtp.String then
    begin
      mmoMemo.Clear;
      pgPop.ActivePageIndex := 2;
      Self.Width := 260;
      Self.Height := 200;
    end;

  if not Visible then
    Visible := True;;

  Popup(APopupPt.X, APopupPt.Y);
end;

procedure TfrmRecordPop.PopupWndProc(var Message: TMessage);
begin
  if Message.Msg = WM_ACTIVATEAPP then
  begin
    if Message.WParam = 0 then  // ��ʾ
      Close;
  end;
  Message.Result := DefWindowProc(FPopupWindow, Message.Msg, Message.WParam, Message.LParam);
end;

procedure TfrmRecordPop.PutCalcNumber(const ANum: Integer);
begin
  if FTemplate then
  begin
    if ANum <> 0 then
      edtvalue.Text := edtvalue.Text + '.' + ANum.ToString
  end
  else
  begin
    SetConCalcValue;
    if FTemp or FFlag then
    begin
      edtValue.Text := ANum.ToString;
      FTemp := False;
    end
    else
      edtValue.Text := edtValue.text + ANum.ToString;
  end;
  SetValueFocus;
end;

procedure TfrmRecordPop.RegPopupClass;
var
  vWndCls: TWndClassEx;
  vClassName: string;
begin
  vClassName := PopupClassName;
  if not GetClassInfoEx(HInstance, PChar(vClassName), vWndCls) then
  begin
    vWndCls.cbSize        := SizeOf(TWndClassEx);
    vWndCls.lpszClassName := PChar(vClassName);
    vWndCls.style         := CS_VREDRAW or CS_HREDRAW
      or CS_DROPSHADOW or CS_DBLCLKS;  // ͨ������ʽʵ�ִ��ڱ߿���ӰЧ����ֻ����ע�ᴰ����ʱʹ�ô����ԣ�ע����ͨ��SetClassLong(Handle, GCL_STYLE, GetClassLong(Handle, GCL_STYLE) or CS_DROPSHADOW);������

    vWndCls.hInstance     := HInstance;
    vWndCls.lpfnWndProc   := @DefWindowProc;
    vWndCls.cbClsExtra    := 0;
    vWndCls.cbWndExtra    := SizeOf(DWord) * 2;
    vWndCls.hIcon         := LoadIcon(hInstance,MakeIntResource('MAINICON'));
    vWndCls.hIconSm       := LoadIcon(hInstance,MakeIntResource('MAINICON'));
    vWndCls.hCursor       := LoadCursor(0, IDC_ARROW);
    vWndCls.hbrBackground := GetStockObject(white_Brush);
    vWndCls.lpszMenuName  := nil;

    if RegisterClassEx(vWndCls) = 0 then
    begin
      //MessageBox(0, 'ע��TCustomPopup����!', 'TCustomPopup', MB_OK);
      raise Exception.Create('�쳣��ע��TCustomPopup����!');
      Exit;
    end;
  end;
end;

procedure TfrmRecordPop.SetConCalcValue;
begin
  if not FConCalcValue then
  begin
    edtValue.Text := '';
    FConCalcValue := True;
  end;
end;

procedure TfrmRecordPop.SetDeItemValue(const AValue: string);
begin
  FDeItem.Text := AValue;
  if Assigned(FOnActiveItemChange) then
    FOnActiveItemChange(FDeItem);  // ��������,�������Ա仯���õ��ô˷���
end;

procedure TfrmRecordPop.SetValueFocus;
begin
  edtValue.SetFocus;
  edtvalue.SelStart := Length(edtvalue.Text);
  edtvalue.SelLength := 0;
end;

procedure TfrmRecordPop.sgdDomainDblClick(Sender: TObject);
begin
  if sgdDomain.Row >= 0 then
    btnDomainOkClick(Sender);
end;

end.
