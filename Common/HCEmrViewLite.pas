unit HCEmrViewLite;

interface

uses
  System.Classes, System.SysUtils, HCView, HCStyle, HCCustomData, HCItem, HCTextItem, HCRectItem;

type
  THCImportAsTextEvent = procedure (const AText: string) of object;

  THCEmrViewLite = class(THCView)
  protected
    /// <summary> ������Item����ʱ���� </summary>
    /// <param name="AData">����Item��Data</param>
    /// <param name="AStyleNo">Ҫ������Item��ʽ</param>
    /// <returns>�����õ�Item</returns>
    function DoSectionCreateStyleItem(const AData: THCCustomData;
      const AStyleNo: Integer): THCCustomItem; override;
  public
    constructor Create(AOwner: TComponent); override;
    /// <summary> ����ָ����ʽ��Item </summary>
    /// <param name="AData">Ҫ����Item��Data</param>
    /// <param name="AStyleNo">Ҫ������Item��ʽ</param>
    /// <returns>�����õ�Item</returns>
    class function CreateEmrStyleItem(const AData: THCCustomData;
      const AStyleNo: Integer): THCCustomItem;
  end;

implementation

uses
  emr_Common, HCEmrElementItem, HCEmrGroupItem, HCEmrYueJingItem,
  HCEmrFangJiaoItem, HCEmrToothItem;

{ THCEmrViewLite }

constructor THCEmrViewLite.Create(AOwner: TComponent);
begin
  HCDefaultTextItemClass := TDeItem;
  HCDefaultDomainItemClass := TDeGroup;
  inherited Create(AOwner);
end;

class function THCEmrViewLite.CreateEmrStyleItem(const AData: THCCustomData;
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

    THCStyle.Express, EMRSTYLE_YUEJING:
      Result := TEmrYueJingItem.Create(AData, '', '', '', '');

    EMRSTYLE_TOOTH:
      Result := TEmrToothItem.Create(AData, '', '', '', '');

    EMRSTYLE_FANGJIAO:
      Result := TEMRFangJiaoItem.Create(AData, '', '', '', '');
  else
    Result := nil;
  end;
end;

function THCEmrViewLite.DoSectionCreateStyleItem(const AData: THCCustomData;
  const AStyleNo: Integer): THCCustomItem;
begin
  Result := CreateEmrStyleItem(aData, aStyleNo);
end;

end.
