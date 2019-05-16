{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit EmrEdit;

interface

uses
  Windows, Classes, Controls, Vcl.Graphics, HCCommon, HCStyle, HCEdit, HCItem,
  HCCustomData, HCViewData, EmrElementItem, EmrGroupItem, HCTextItem, HCRectItem;

type
  TEmrEdit = class(THCEdit)
  private
    FDeDoneColor, FDeUnDoneColor: TColor;
    FDesignMode: Boolean;
    FTrace: Boolean;
    procedure DoDeItemPaintBKG(const Sender: TObject; const ACanvas: TCanvas;
      const ADrawRect: TRect; const APaintInfo: TPaintInfo);
  protected
    function DoDataCreateStyleItem(const AData: THCCustomData;
      const AStyleNo: Integer): THCCustomItem; override;
    procedure DoDataInsertItem(const AData: THCCustomData; const AItem: THCCustomItem); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property DesignMode: Boolean read FDesignMode write FDesignMode;

    /// <summary> ��ǰ�ĵ���ʽ�� </summary>
    property Style;
  published
    { Published declarations }

    /// <summary> ��갴��ʱ���� </summary>
    property OnMouseDown;

    /// <summary> ��굯��ʱ���� </summary>
    property OnMouseUp;

    /// <summary> �ĵ����ݱ仯ʱ���� </summary>
    property OnChange;

    property PopupMenu;

    property Align;
  end;

/// <summary> ע��HCEmrView�ؼ����ؼ���� </summary>
procedure Register;

implementation

uses
  SysUtils, Forms, HCPrinters, HCTextStyle;

procedure Register;
begin
  RegisterComponents('HCEmrViewVCL', [TEmrEdit]);
end;

{ TEmrEdit }

constructor TEmrEdit.Create(AOwner: TComponent);
begin
  HCDefaultTextItemClass := TDeItem;
  HCDefaultDomainItemClass := TDeGroup;
  inherited Create(AOwner);
  Self.Width := 100;
  Self.Height := 100;
  FDeDoneColor := clBtnFace;  // Ԫ����д�󱳾�ɫ
  FDeUnDoneColor := $0080DDFF;  // Ԫ��δ��дʱ����ɫ
end;

destructor TEmrEdit.Destroy;
begin
  inherited Destroy;
end;

procedure TEmrEdit.DoDeItemPaintBKG(const Sender: TObject; const ACanvas: TCanvas;
  const ADrawRect: TRect; const APaintInfo: TPaintInfo);
var
  vDeItem: TDeItem;
begin
  if not APaintInfo.Print then
  begin
    vDeItem := Sender as TDeItem;
    if vDeItem.IsElement then  // ������Ԫ
    begin
      if vDeItem.MouseIn or vDeItem.Active then  // �������͹��������
      begin
        if vDeItem.IsSelectPart or vDeItem.IsSelectComplate then
        begin

        end
        else
        begin
          if vDeItem[TDeProp.Name] <> vDeItem.Text then  // �Ѿ���д����
            ACanvas.Brush.Color := FDeDoneColor
          else  // û��д��
            ACanvas.Brush.Color := FDeUnDoneColor;

          ACanvas.FillRect(ADrawRect);
        end;
      end;
    end
    else  // ��������Ԫ
    if FDesignMode and vDeItem.EditProtect then
    begin
      ACanvas.Brush.Color := clBtnFace;
      ACanvas.FillRect(ADrawRect);
    end;
  end;
end;

function TEmrEdit.DoDataCreateStyleItem(const AData: THCCustomData;
  const AStyleNo: Integer): THCCustomItem;
begin
  case AStyleNo of
    THCStyle.Table:
      Result := TDeTable.Create(AData, 1, 1, 1);

    THCStyle.CheckBox:
      Result := TDeCheckBox.Create(AData, '��ѡ��', False);

    THCStyle.Edit:
      Result := TDeEdit.Create(AData, '');

    THCStyle.Combobox:
      Result := TDeCombobox.Create(AData, '');

    THCStyle.DateTimePicker:
      Result := TDeDateTimePicker.Create(AData, Now);

    THCStyle.RadioGroup:
      Result := TDeRadioGroup.Create(AData);
  else
    Result := nil;
  end;
end;

procedure TEmrEdit.DoDataInsertItem(const AData: THCCustomData; const AItem: THCCustomItem);
var
  vDeItem: TDeItem;
begin
  if AItem is TDeItem then
  begin
    vDeItem := AItem as TDeItem;
    vDeItem.OnPaintBKG := DoDeItemPaintBKG;
  end;

  inherited DoDataInsertItem(AData, AItem);
end;

end.
