{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit EmrYueJingItem;

interface

uses
  Windows, Classes, Controls, Graphics, HCCustomData, HCExpressItem, HCXml, emr_Common;

type
  TToothArea = (ctaNone, ctaLeftTop, ctaLeftBottom, ctaRightTop, ctaRightBottom);

  TEmrYueJingItem = class(THCExpressItem)  // �¾���ʽ(�ϡ��¡������ı�����ʮ����)
  public
    constructor Create(const AOwnerData: THCCustomData;
      const ALeftText, ATopText, ARightText, ABottomText: string); override;
    procedure ToXmlEmr(const ANode: IHCXMLNode);
    procedure ParseXmlEmr(const ANode: IHCXMLNode);
  end;

implementation

uses
  System.SysUtils;

{ TEmrYueJingItem }

constructor TEmrYueJingItem.Create(const AOwnerData: THCCustomData;
  const ALeftText, ATopText, ARightText, ABottomText: string);
begin
  inherited Create(AOwnerData, ALeftText, ATopText, ARightText, ABottomText);
  Self.StyleNo := EMRSTYLE_YUEJING;
end;

procedure TEmrYueJingItem.ParseXmlEmr(const ANode: IHCXMLNode);
begin
  if ANode.Attributes['DeCode'] = IntToStr(EMRSTYLE_YUEJING) then
  begin
    TopText := ANode.Attributes['toptext'];
    BottomText := ANode.Attributes['bottomtext'];
    LeftText := ANode.Attributes['lefttext'];
    RightText := ANode.Attributes['righttext'];
  end;
end;

procedure TEmrYueJingItem.ToXmlEmr(const ANode: IHCXMLNode);
begin
  ANode.Attributes['DeCode'] := IntToStr(EMRSTYLE_YUEJING);
  ANode.Attributes['toptext'] := TopText;
  ANode.Attributes['bottomtext'] := BottomText;
  ANode.Attributes['lefttext'] := LeftText;
  ANode.Attributes['righttext'] := RightText
end;

end.
