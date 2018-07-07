{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit EmrElementItem;

interface

uses
  Windows, Classes, Controls, Graphics, SysUtils, HCStyle, HCItem, HCTextItem,
  HCCommon;

type
  TStyleExtra = (cseNone, cseDel, cseAdd);  // �ۼ���ʽ

  TDeProp = class(TObject)
  public
    const
      Index = '0';
      Code = '1';
      &Name = '2';
      Frmtp = '3';  // ��� ��ѡ����ѡ����ֵ������ʱ���
      &Unit = '4';
      CMV = '5';  // �ܿشʻ��(ֵ�����)
      CMVVCode = '6';  // �ܿشʻ����(ֵ����)
      Trace = '7';  // �ۼ���Ϣ
  end;

  TDeFrmtp = class(TObject)
  public
    const
      Radio = 'RS';  // ��ѡ
      Multiselect = 'MS';  // ��ѡ
      Number = 'N';  // ��ֵ
      &String = 'S';  // �ı�
      Date = 'D';  // ����
      Time = 'T';  // ʱ��
      DateTime = 'DT';  // ����ʱ��
  end;

  /// <summary> ���Ӳ����ı����� </summary>
  TEmrTextItem = class(THCTextItem)

  end;

  /// <summary> ���Ӳ�������Ԫ���� </summary>
  TDeItem = class sealed(TEmrTextItem)  // ���ɼ̳�
  private
    FMouseIn: Boolean;
    FStyleEx: TStyleExtra;
    FPropertys: TStrings;
  protected
    procedure SetText(const Value: string); override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure SetActive(const Value: Boolean); override;
    procedure Assign(Source: THCCustomItem); override;
    function CanConcatItems(const AItem: THCCustomItem): Boolean; override;
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
    function GetHint: string; override;
    //
    function GetValue(const Key: string): string;
    procedure SetValue(const Key, Value: string);
    function GetIsElement: Boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
    function CanAccept: Boolean; override;
    property IsElement: Boolean read GetIsElement;
    property StyleEx: TStyleExtra read FStyleEx write FStyleEx;
    property Propertys: TStrings read FPropertys;
    property Values[const Key: string]: string read GetValue write SetValue; default;
  end;

implementation

uses
  HCParaStyle;

const
  DE_CHECKCOLOR = clBtnFace;
  DE_NOCHECKCOLOR = $0080DDFF;

{ TDeItem }

procedure TDeItem.Assign(Source: THCCustomItem);
begin
  inherited Assign(Source);
  Self.FStyleEx := (Source as TDeItem).StyleEx;
  Self.FPropertys.Assign((Source as TDeItem).Propertys);
end;

function TDeItem.CanAccept: Boolean;
begin
  Result := not Self.IsElement;
end;

function TDeItem.CanConcatItems(const AItem: THCCustomItem): Boolean;
var
  vDeItem: TDeItem;
begin
  Result := inherited CanConcatItems(AItem);
  if Result then
  begin
    vDeItem := AItem as TDeItem;
    Result := (Self[TDeProp.Index] = vDeItem[TDeProp.Index])
      and (Self.FStyleEx = vDeItem.FStyleEx)
      and (Self[TDeProp.Trace] = vDeItem[TDeProp.Trace]);
  end;
end;

constructor TDeItem.Create;
begin
  inherited Create;
  FPropertys := TStringList.Create;
end;

destructor TDeItem.Destroy;
begin
  FreeAndNil(FPropertys);
  inherited;
end;

procedure TDeItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vTop: Integer;
  vRect: TRect;
  vAlignVert, vTextHeight: Integer;
begin
  inherited DoPaint(AStyle, ADrawRect, ADataDrawTop, ADataDrawBottom, ADataScreenTop,
    ADataScreenBottom, ACanvas, APaintInfo);

  ACanvas.Refresh;
  if (not APaintInfo.Print) and IsElement then  // ������Ԫ
  begin
    if FMouseIn or Active then  // �������͹��������
    begin
      if IsSelectPart or IsSelectComplate then
      begin

      end
      else
      begin
        if Self[TDeProp.Name] <> Self.Text then  // �Ѿ���д����
          ACanvas.Brush.Color := DE_CHECKCOLOR
        else  // û��д��
          ACanvas.Brush.Color := DE_NOCHECKCOLOR;

        vRect := ADrawRect;
        InflateRect(vRect, 0, AStyle.ParaStyles[Self.ParaNo].LineSpaceHalf);

        ACanvas.FillRect(vRect);
      end;
    end;
  end;

  case FStyleEx of  // �ۼ�
    //cseNone: ;
    cseDel:
      begin
        // ��ֱ����
        vTextHeight := ACanvas.TextHeight('��');
        case AStyle.ParaStyles[Self.ParaNo].AlignVert of
          pavCenter: vAlignVert := DT_CENTER;
          pavTop: vAlignVert := DT_TOP;
        else
          vAlignVert := DT_BOTTOM;
        end;
        case vAlignVert of
          DT_TOP: vTop := ADrawRect.Top;
          DT_CENTER: vTop := ADrawRect.Top + (ADrawRect.Bottom - ADrawRect.Top - vTextHeight) div 2;
        else
          vTop := ADrawRect.Bottom - vTextHeight;
        end;
        // ����ɾ����
        ACanvas.Pen.Style := psSolid;
        ACanvas.Pen.Color := clRed;
        vTop := vTop + (ADrawRect.Bottom - vTop) div 2;
        ACanvas.MoveTo(ADrawRect.Left, vTop - 1);
        ACanvas.LineTo(ADrawRect.Right, vTop - 1);
        ACanvas.MoveTo(ADrawRect.Left, vTop + 2);
        ACanvas.LineTo(ADrawRect.Right, vTop + 2);
      end;

    cseAdd:
      begin
        ACanvas.Pen.Style := psSolid;
        ACanvas.Pen.Color := clBlue;
        ACanvas.MoveTo(ADrawRect.Left, ADrawRect.Bottom);
        ACanvas.LineTo(ADrawRect.Right, ADrawRect.Bottom);
      end;
  end;
end;

function TDeItem.GetHint: string;
begin
  case FStyleEx of
    cseNone: Result := Self.Values[TDeProp.Name];
  else
    Result := Self.Values[TDeProp.Trace];
  end;
end;

function TDeItem.GetIsElement: Boolean;
begin
  Result := FPropertys.IndexOfName(TDeProp.Index) >= 0;
end;

function TDeItem.GetValue(const Key: string): string;
begin
  Result := FPropertys.Values[Key];
end;

procedure TDeItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vSize: Word;
  vBuffer: TBytes;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(FStyleEx, SizeOf(TStyleExtra));
  AStream.ReadBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
  begin
    SetLength(vBuffer, vSize);
    AStream.Read(vBuffer[0], vSize);
    Propertys.Text := StringOf(vBuffer);
  end;
end;

procedure TDeItem.MouseEnter;
begin
  inherited;
  FMouseIn := True;
  //GUpdateInfo.RePaint := True;
end;

procedure TDeItem.MouseLeave;
begin
  inherited;
  FMouseIn := False;
  //GUpdateInfo.RePaint := True;
end;

procedure TDeItem.SaveToStream(const AStream: TStream; const AStart, AEnd: Integer);
var
  vBuffer: TBytes;
  vSize: Word;
begin
  inherited SaveToStream(AStream, AStart, AEnd);
  AStream.WriteBuffer(FStyleEx, SizeOf(TStyleExtra));

  vBuffer := BytesOf(FPropertys.Text);
  vSize := System.Length(vBuffer);

  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);
end;

procedure TDeItem.SetActive(const Value: Boolean);
begin
  //if Active <> Value then
  //  GUpdateInfo.RePaint := True;
  if not Value then
    FMouseIn := False;
  inherited;
end;

procedure TDeItem.SetText(const Value: string);
begin
  if Value <> '' then
    inherited SetText(Value)
  else
  begin
    if IsElement then  // ����ԪֵΪ��ʱĬ��ʹ������
      Text := FPropertys.Values[TDeProp.Name]
    else
      inherited SetText('');
  end;
end;

procedure TDeItem.SetValue(const Key, Value: string);
begin
  FPropertys.Values[Key] := Value;
end;

end.
