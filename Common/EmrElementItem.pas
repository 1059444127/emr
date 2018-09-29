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
  Windows, Classes, Controls, Graphics, SysUtils, System.JSON, HCStyle, HCItem,
  HCTextItem, HCEditItem, HCComboboxItem, HCDateTimePicker, HCRadioGroup, HCTableItem,
  HCTableCell, HCCheckBoxItem, HCFractionItem, HCCommon, HCCustomData;

type
  TStyleExtra = (cseNone, cseDel, cseAdd);  // �ۼ���ʽ

  TDeProp = class(TObject)
  public
    const
      Index = 'Index';
      Code = 'Code';
      &Name = 'Name';
      //Text = 'Text';
      Frmtp = 'Frmtp';  // ��� ��ѡ����ѡ����ֵ������ʱ���
      &Unit = 'Unit';
      CMV = 'CMV';  // �ܿشʻ��(ֵ�����)
      CMVVCode = 'CMVVCode';  // �ܿشʻ����(ֵ����)
      Trace = 'Trace';  // �ۼ���Ϣ
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
  TEmrTextItem = class(THCTextItem);

  /// <summary> ���Ӳ�������Ԫ���� </summary>
  TDeItem = class sealed(TEmrTextItem)  // ���ɼ̳�
  private
    FMouseIn, FDeleteProtect: Boolean;
    FStyleEx: TStyleExtra;
    FPropertys: TStringList;
  protected
    procedure SetText(const Value: string); override;
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawTop, ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    //
    function GetValue(const Key: string): string;
    procedure SetValue(const Key, Value: string);
    function GetIsElement: Boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure SetActive(const Value: Boolean); override;
    procedure Assign(Source: THCCustomItem); override;
    function CanConcatItems(const AItem: THCCustomItem): Boolean; override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
    function GetHint: string; override;
    function CanAccept(const AOffset: Integer): Boolean; override;

    procedure ToJson(const AJsonObj: TJSONObject);
    procedure ParseJson(const AJsonObj: TJSONObject);

    property IsElement: Boolean read GetIsElement;
    property StyleEx: TStyleExtra read FStyleEx write FStyleEx;
    property Propertys: TStringList read FPropertys;
    property DeleteProtect: Boolean read FDeleteProtect write FDeleteProtect;
    property Values[const Key: string]: string read GetValue write SetValue; default;
  end;

  TDeTable = class(THCTableItem)
  private
    FPropertys: TStringList;
  public
    constructor Create(const AOwnerData: TCustomData; const ARowCount, AColCount,
      AWidth: Integer); override;
    destructor Destroy; override;

    procedure ToJson(const AJsonObj: TJSONObject);
    procedure ParseJson(const AJsonObj: TJSONObject);
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;

    property Propertys: TStringList read FPropertys;
  end;

  TDeCheckBox = class(THCCheckBoxItem)
  private
    FPropertys: TStringList;
  public
    constructor Create(const AOwnerData: THCCustomData; const AText: string; const AChecked: Boolean); override;
    destructor Destroy; override;

    procedure ToJson(const AJsonObj: TJSONObject);
    procedure ParseJson(const AJsonObj: TJSONObject);
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;

    property Propertys: TStringList read FPropertys;
  end;

  TDeEdit = class(THCEditItem)
  private
    FPropertys: TStringList;
  public
    constructor Create(const AOwnerData: THCCustomData; const AText: string); override;
    destructor Destroy; override;

    procedure ToJson(const AJsonObj: TJSONObject);
    procedure ParseJson(const AJsonObj: TJSONObject);
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;

    property Propertys: TStringList read FPropertys;
  end;

  TDeCombobox = class(THCComboboxItem)
  private
    FPropertys: TStringList;
  public
    constructor Create(const AOwnerData: THCCustomData; const AText: string); override;
    destructor Destroy; override;

    procedure ToJson(const AJsonObj: TJSONObject);
    procedure ParseJson(const AJsonObj: TJSONObject);
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;

    property Propertys: TStringList read FPropertys;
  end;

  TDeDateTimePicker = class(THCDateTimePicker)
  private
    FPropertys: TStringList;
  public
    constructor Create(const AOwnerData: THCCustomData; const ADateTime: TDateTime); override;
    destructor Destroy; override;

    procedure ToJson(const AJsonObj: TJSONObject);
    procedure ParseJson(const AJsonObj: TJSONObject);
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;

    property Propertys: TStringList read FPropertys;
  end;

  TDeRadioGroup = class(THCRadioGroup)
  private
    FPropertys: TStringList;
  public
    constructor Create(const AOwnerData: THCCustomData); override;
    destructor Destroy; override;

    procedure ToJson(const AJsonObj: TJSONObject);
    procedure ParseJson(const AJsonObj: TJSONObject);
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
    property Propertys: TStringList read FPropertys;
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

function TDeItem.CanAccept(const AOffset: Integer): Boolean;
begin
  Result := not Self.IsElement;
  if not Result then
    Beep;
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

  FDeleteProtect := False;
  FMouseIn := False;
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
        //InflateRect(vRect, 0, AStyle.ParaStyles[Self.ParaNo].LineSpaceHalf);

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

procedure TDeItem.ParseJson(const AJsonObj: TJSONObject);
var
  i: Integer;
  vS: string;
  vDeInfo, vDeProp: TJSONObject;
begin
  Self.Propertys.Clear;

  vS := AJsonObj.GetValue('DeType').Value;
  if vS = 'DeItem' then
  begin
    vDeInfo := AJsonObj.GetValue('DeInfo') as TJSONObject;
    Self.Text := vDeInfo.GetValue('Text').Value;

    i := StrToInt(vDeInfo.GetValue('StyleNo').Value);
    if i >= 0 then
      Self.StyleNo := i;

    vDeProp := vDeInfo.GetValue('Property') as TJSONObject;

    for i := 0 to vDeProp.Count - 1 do
    begin
      vS := vDeProp.Pairs[i].JsonString.Value;
      Self.Propertys.Add(vS + '=' + vDeProp.Pairs[i].JsonValue.Value);
    end;
  end;
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
  if not Value then
    FMouseIn := False;
  inherited SetActive(Value);
end;

procedure TDeItem.SetText(const Value: string);
begin
  if Value <> '' then
    inherited SetText(Value)
  else
  begin
    if IsElement and FDeleteProtect then  // ����ԪֵΪ��ʱĬ��ʹ������
      Text := FPropertys.Values[TDeProp.Name]
    else
      inherited SetText('');
  end;
end;

procedure TDeItem.SetValue(const Key, Value: string);
begin
  FPropertys.Values[Key] := Value;
end;

procedure TDeItem.ToJson(const AJsonObj: TJSONObject);
var
  i: Integer;
  vDeInfo, vDeProp: TJSONObject;
  vS: string;
begin
  AJsonObj.AddPair('DeType', 'DeItem');

  vDeInfo := TJSONObject.Create;

  vDeInfo.AddPair('StyleNo', Self.StyleNo.ToString);
  vDeInfo.AddPair('Text', Self.Text);

  vDeProp := TJSONObject.Create;
  for i := 0 to Self.Propertys.Count - 1 do
  begin
    vS := Self.Propertys.Names[i];
    vDeProp.AddPair(vS, Self.Propertys.ValueFromIndex[i]);
  end;

  vDeInfo.AddPair('Property', vDeProp);
  AJsonObj.AddPair('DeInfo', vDeInfo);
end;

{ TDeEdit }

constructor TDeEdit.Create(const AOwnerData: THCCustomData;
  const AText: string);
begin
  FPropertys := TStringList.Create;
  inherited Create(AOwnerData, AText);
end;

destructor TDeEdit.Destroy;
begin
  FreeAndNil(FPropertys);
  inherited Destroy;
end;

procedure TDeEdit.LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
  const AFileVersion: Word);
var
  vSize: Word;
  vBuffer: TBytes;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
  begin
    SetLength(vBuffer, vSize);
    AStream.Read(vBuffer[0], vSize);
    Propertys.Text := StringOf(vBuffer);
  end;
end;

procedure TDeEdit.ParseJson(const AJsonObj: TJSONObject);
var
  i: Integer;
  vDeInfo, vPropertys: TJSONObject;
begin
  Self.Propertys.Clear;

  vDeInfo := AJsonObj.GetValue('DeInfo') as TJSONObject;
  Self.Text := vDeInfo.GetValue('Text').Value;

  vPropertys := vDeInfo.GetValue('Property') as TJSONObject;
  for i := 0 to vPropertys.Count - 1 do
    Self.Propertys.Add(vPropertys.Pairs[i].JsonString.Value + '=' + vPropertys.Pairs[i].JsonValue.Value);
end;

procedure TDeEdit.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
var
  vBuffer: TBytes;
  vSize: Word;
begin
  inherited SaveToStream(AStream, AStart, AEnd);

  vBuffer := BytesOf(FPropertys.Text);
  vSize := System.Length(vBuffer);

  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);
end;

procedure TDeEdit.ToJson(const AJsonObj: TJSONObject);
var
  i: Integer;
  vDeInfo, vPropertys: TJSONObject;
begin
  AJsonObj.AddPair('DeType', 'Edit');

  vPropertys := TJSONObject.Create;
  for i := 0 to FPropertys.Count - 1 do
    vPropertys.AddPair(FPropertys.Names[i], FPropertys.ValueFromIndex[i]);

  vDeInfo := TJSONObject.Create;
  vDeInfo.AddPair('Text', Self.Text);
  vDeInfo.AddPair('Property',vPropertys);

  AJsonObj.AddPair('DeInfo', vDeInfo);
end;

{ TDeCombobox }

constructor TDeCombobox.Create(const AOwnerData: THCCustomData;
  const AText: string);
begin
  FPropertys := TStringList.Create;
  inherited Create(AOwnerData, AText);
end;

destructor TDeCombobox.Destroy;
begin
  FreeAndNil(FPropertys);
  inherited Destroy;
end;

procedure TDeCombobox.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vSize: Word;
  vBuffer: TBytes;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
  begin
    SetLength(vBuffer, vSize);
    AStream.Read(vBuffer[0], vSize);
    Propertys.Text := StringOf(vBuffer);
  end;
end;

procedure TDeCombobox.ParseJson(const AJsonObj: TJSONObject);
var
  i: Integer;
  vDeInfo, vItems, vPropertys: TJSONObject;
begin
  Self.Items.Clear;
  Self.Propertys.Clear;

  vDeInfo := AJsonObj.GetValue('DeInfo') as TJSONObject;
  Self.Text := vDeInfo.GetValue('Text').Value;
  vItems := vDeInfo.GetValue('Items') as TJSONObject;
  for i := 0 to vItems.Count - 1 do
    Self.Items.Add(vItems.Pairs[i].JsonValue.Value);

  vPropertys := vDeInfo.GetValue('Property') as TJSONObject;
  for i := 0 to vPropertys.Count - 1 do
    Self.Propertys.Add(vPropertys.Pairs[i].JsonString.Value + '=' + vPropertys.Pairs[i].JsonValue.Value);
end;

procedure TDeCombobox.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
var
  vBuffer: TBytes;
  vSize: Word;
begin
  inherited SaveToStream(AStream, AStart, AEnd);

  vBuffer := BytesOf(FPropertys.Text);
  vSize := System.Length(vBuffer);

  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);
end;

procedure TDeCombobox.ToJson(const AJsonObj: TJSONObject);
var
  i: Integer;
  vDeInfo, vItems, vPropertys: TJSONObject;
begin
  AJsonObj.AddPair('DeType', 'Combobox');

  vPropertys := TJSONObject.Create;
  for i := 0 to FPropertys.Count - 1 do
    vPropertys.AddPair(FPropertys.Names[i], FPropertys.ValueFromIndex[i]);

  vItems := TJSONObject.Create;
  for i := 0 to Self.Items.Count - 1 do
    vItems.AddPair(i.ToString, Self.Items[i]);

  vDeInfo := TJSONObject.Create;
  vDeInfo.AddPair('Text', Self.Text);
  vDeInfo.AddPair('Items', vItems);
  vDeInfo.AddPair('Property',vPropertys);

  AJsonObj.AddPair('DeInfo', vDeInfo);
end;

{ TDeDateTimePicker }

constructor TDeDateTimePicker.Create(const AOwnerData: THCCustomData;
  const ADateTime: TDateTime);
begin
  FPropertys := TStringList.Create;
  inherited Create(AOwnerData, ADateTime);
end;

destructor TDeDateTimePicker.Destroy;
begin
  FreeAndNil(FPropertys);
  inherited Destroy;
end;

procedure TDeDateTimePicker.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vSize: Word;
  vBuffer: TBytes;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
  begin
    SetLength(vBuffer, vSize);
    AStream.Read(vBuffer[0], vSize);
    Propertys.Text := StringOf(vBuffer);
  end;
end;

procedure TDeDateTimePicker.ParseJson(const AJsonObj: TJSONObject);
begin

end;

procedure TDeDateTimePicker.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
var
  vBuffer: TBytes;
  vSize: Word;
begin
  inherited SaveToStream(AStream, AStart, AEnd);

  vBuffer := BytesOf(FPropertys.Text);
  vSize := System.Length(vBuffer);

  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);
end;

procedure TDeDateTimePicker.ToJson(const AJsonObj: TJSONObject);
begin

end;

{ TDeRadioGroup }

constructor TDeRadioGroup.Create(const AOwnerData: THCCustomData);
begin
  FPropertys := TStringList.Create;
  inherited Create(AOwnerData);
end;

destructor TDeRadioGroup.Destroy;
begin
  FreeAndNil(FPropertys);
  inherited Destroy;
end;

procedure TDeRadioGroup.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vSize: Word;
  vBuffer: TBytes;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
  begin
    SetLength(vBuffer, vSize);
    AStream.Read(vBuffer[0], vSize);
    Propertys.Text := StringOf(vBuffer);
  end;
end;

procedure TDeRadioGroup.ParseJson(const AJsonObj: TJSONObject);
begin

end;

procedure TDeRadioGroup.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
var
  vBuffer: TBytes;
  vSize: Word;
begin
  inherited SaveToStream(AStream, AStart, AEnd);

  vBuffer := BytesOf(FPropertys.Text);
  vSize := System.Length(vBuffer);

  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);
end;

procedure TDeRadioGroup.ToJson(const AJsonObj: TJSONObject);
begin

end;

{ TDeTable }

constructor TDeTable.Create(const AOwnerData: TCustomData; const ARowCount,
  AColCount, AWidth: Integer);
begin
  FPropertys := TStringList.Create;
  inherited Create(AOwnerData, ARowCount, AColCount, AWidth);
end;

destructor TDeTable.Destroy;
begin
  FreeAndNil(FPropertys);
  inherited Destroy;
end;

procedure TDeTable.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vSize: Word;
  vBuffer: TBytes;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
  begin
    SetLength(vBuffer, vSize);
    AStream.Read(vBuffer[0], vSize);
    Propertys.Text := StringOf(vBuffer);
  end;
end;

procedure TDeTable.ParseJson(const AJsonObj: TJSONObject);
var
  i, j, vR, vC: Integer;
  r, g, b: Byte;
  vS: string;
  vCells, vCellInfo, vItems, vDeInfo, vJson: TJSONObject;
  vDeItem: TDeItem;
  vArrayString: TArray<string>;
begin
  vCells := AJsonObj.GetValue('Cells') as TJSONObject;

  for i := 0 to vCells.Count - 1 do
  begin
    vS := vCells.Pairs[i].JsonString.Value;
    vR := StrToInt(System.Copy(vS, 1, Pos(',', vS) - 1));
    vC := StrToInt(System.Copy(vS, Pos(',', vS) + 1, vS.Length));

    vCellInfo := vCells.Pairs[i].JsonValue as TJSONObject;

    Self.Cells[vR, vC].RowSpan := StrToInt(vCellInfo.GetValue('RowSpan').Value);
    Self.Cells[vR, vC].ColSpan := StrToInt(vCellInfo.GetValue('ColSpan').Value);

    if (Self.Cells[vR, vC].RowSpan < 0) or (Self.Cells[vR, vC].ColSpan < 0) then
    begin
      Self.Cells[vR, vC].CellData.Free;
      Self.Cells[vR, vC].CellData := nil;
    end
    else
    begin
      if vCellInfo.GetValue('BorderSides-Left').Value = 'False' then
        Self.Cells[vR, vC].BorderSides := Self.Cells[vR, vC].BorderSides - [cbsLeft];
      if vCellInfo.GetValue('BorderSides-Top').Value = 'False' then
        Self.Cells[vR, vC].BorderSides := Self.Cells[vR, vC].BorderSides - [cbsTop];
      if vCellInfo.GetValue('BorderSides-Right').Value = 'False' then
        Self.Cells[vR, vC].BorderSides := Self.Cells[vR, vC].BorderSides - [cbsRight];
      if vCellInfo.GetValue('BorderSides-Bottom').Value = 'False' then
        Self.Cells[vR, vC].BorderSides := Self.Cells[vR, vC].BorderSides - [cbsBottom];

      vS := vCellInfo.GetValue('BackgroundColor').Value;

      vArrayString := vS.Split([',']);
      r := StrToInt(vArrayString[0]);
      g := StrToInt(vArrayString[1]);
      b := StrToInt(vArrayString[2]);
      Self.Cells[vR, vC].BackgroundColor := RGB(r, g, b);

      vItems := vCellInfo.GetValue('Items') as TJSONObject;
      for j := 0 to vItems.Count - 1 do
      begin
        vJson := vItems.Pairs[j].JsonValue as TJSONObject;
        vS := vJson.GetValue('DeType').Value;
        if vS = 'DeItem' then
        begin
          vDeInfo := vJson.GetValue('DeInfo') as TJSONObject;
          vS := vDeInfo.GetValue('Text').Value;
          if vS <> '' then
          begin
            vDeItem := TDeItem.Create;  // Text
            vDeItem.ParseJson(vJson);

            Self.Cells[vR, vC].CellData.InsertItem(vDeItem);
          end;
        end
        else
        if vS = 'DeText' then
        begin
          vDeInfo := vJson.GetValue('DeInfo') as TJSONObject;
          vS := vDeInfo.GetValue('Text').Value;
          if vS <> '' then
            Self.Cells[vR, vC].CellData.InsertText(vS);
        end;
      end;

      Self.Cells[vR, vC].CellData.ReadOnly := vCellInfo.GetValue('ReadOnly').Value = 'True';
    end;
  end;
end;

procedure TDeTable.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
var
  vBuffer: TBytes;
  vSize: Word;
begin
  inherited SaveToStream(AStream, AStart, AEnd);

  vBuffer := BytesOf(FPropertys.Text);
  vSize := System.Length(vBuffer);

  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);
end;

procedure TDeTable.ToJson(const AJsonObj: TJSONObject);

  procedure TColor2RGB(const Color: LongInt; var R, G, B: Byte);
  begin
    R := Color and $FF;
    G := (Color shr 8) and $FF;
    B := (Color shr 16) and $FF;
  end;

var
  vDeInfo, vCells, vCellInfo, vCellItems, vItemInfo: TJSONObject;
  i, vR, vC: Integer;
  r, g, b: Byte;
  vTableCell: THCTableCell;
begin
  AJsonObj.AddPair('DeType', 'Table');

  vDeInfo := TJSONObject.Create;
  vDeInfo.AddPair('RowCount', Self.RowCount.ToString);
  vDeInfo.AddPair('ColCount', Self.ColCount.ToString);

  vCells := TJSONObject.Create;
  for vR := 0 to Self.RowCount - 1 do
  begin
    for vC := 0 to Self.ColCount - 1 do
    begin
      vTableCell := Self.Cells[vR, vC];

      vCellInfo := TJSONObject.Create;
      vCellInfo.AddPair('RowSpan', vTableCell.RowSpan.ToString);
      vCellInfo.AddPair('ColSpan', vTableCell.ColSpan.ToString);

      if (vTableCell.RowSpan >= 0) and (vTableCell.ColSpan >= 0) then
      begin
        if vTableCell.CellData.ReadOnly then
          vCellInfo.AddPair('ReadOnly', 'True')
        else
          vCellInfo.AddPair('ReadOnly', 'False');

        if cbsLeft in vTableCell.BorderSides then
          vCellInfo.AddPair('BorderSides-Left', 'True')
        else
          vCellInfo.AddPair('BorderSides-Left', 'False');
        if cbsTop in vTableCell.BorderSides then
          vCellInfo.AddPair('BorderSides-Top', 'True')
        else
          vCellInfo.AddPair('BorderSides-Top', 'False');
        if cbsRight in vTableCell.BorderSides then
          vCellInfo.AddPair('BorderSides-Right', 'True')
        else
          vCellInfo.AddPair('BorderSides-Right', 'False');
        if cbsBottom in vTableCell.BorderSides then
          vCellInfo.AddPair('BorderSides-Bottom', 'True')
        else
          vCellInfo.AddPair('BorderSides-Bottom', 'False');

        TColor2RGB(ColorToRGB(vTableCell.BackgroundColor), r, g, b);
        vCellInfo.AddPair('BackgroundColor', r.ToString + ',' + g.ToString + ',' + b.ToString);

        vCellItems := TJSONObject.Create;
        for i := 0 to vTableCell.CellData.Items.Count - 1 do
        begin
          if vTableCell.CellData.Items[i] is TDeItem then
          begin
            vItemInfo := TJSONObject.Create;
            (vTableCell.CellData.Items[i] as TDeItem).ToJson(vItemInfo);
            vCellItems.AddPair(i.ToString, vItemInfo);
          end;
        end;

        vCellInfo.AddPair('Items', vCellItems);
      end;

      vCells.AddPair(vR.ToString + ',' + vC.ToString, vCellInfo);
    end;
  end;

  vDeInfo.AddPair('Cells', vCells);
  AJsonObj.AddPair('DeInfo', vDeInfo);
end;

{ TDeCheckBox }

constructor TDeCheckBox.Create(const AOwnerData: THCCustomData;
  const AText: string; const AChecked: Boolean);
begin
  FPropertys := TStringList.Create;
  inherited Create(AOwnerData, AText, AChecked);
end;

destructor TDeCheckBox.Destroy;
begin
  FreeAndNil(FPropertys);
  inherited;
end;

procedure TDeCheckBox.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vSize: Word;
  vBuffer: TBytes;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
  begin
    SetLength(vBuffer, vSize);
    AStream.Read(vBuffer[0], vSize);
    Propertys.Text := StringOf(vBuffer);
  end;
end;

procedure TDeCheckBox.ParseJson(const AJsonObj: TJSONObject);
begin

end;

procedure TDeCheckBox.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
var
  vBuffer: TBytes;
  vSize: Word;
begin
  inherited SaveToStream(AStream, AStart, AEnd);

  vBuffer := BytesOf(FPropertys.Text);
  vSize := System.Length(vBuffer);

  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);
end;

procedure TDeCheckBox.ToJson(const AJsonObj: TJSONObject);
begin

end;

end.
