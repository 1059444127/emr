unit HCEmrViewLite;

interface

uses
  Classes, SysUtils, HCView, HCStyle, HCCustomData, HCCustomFloatItem,
  HCItem, HCTextItem, HCRectItem, HCSectionData;

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
  end;

implementation

uses
  HCEmrElementItem, HCEmrGroupItem, HCEmrYueJingItem, HCEmrFangJiaoItem, HCEmrToothItem;

{ THCEmrViewLite }

constructor THCEmrViewLite.Create(AOwner: TComponent);
begin
  HCDefaultTextItemClass := TDeItem;
  HCDefaultDomainItemClass := TDeGroup;
  inherited Create(AOwner);
end;

function THCEmrViewLite.DoSectionCreateStyleItem(const AData: THCCustomData;
  const AStyleNo: Integer): THCCustomItem;
begin
  Result := CreateEmrStyleItem(aData, aStyleNo);
end;

end.
