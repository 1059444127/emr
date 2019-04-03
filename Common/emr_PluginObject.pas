{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ �������˵�Ԫ������֮�����ݽ���ʹ�õĶ���          }
{                                                       }
{*******************************************************}

unit emr_PluginObject;

interface

uses
  FunctionIntf;

type
  IPlugInObjectInfo = interface(IPluginObject)
    ['{25AD862C-C1ED-46CC-ADB9-3A69F14BC00B}']
    function GetObject: TObject;
    procedure SetObject(const Value: TObject);
    property &Object: TObject read GetObject write SetObject;
  end;

  TPlugInObjectInfo = class(TInterfacedObject, IPlugInObjectInfo)
  private
    FObject: TObject;
    function GetObject: TObject;
    procedure SetObject(const Value: TObject);
  end;

implementation

{ TPlugInObjectInfo }

function TPlugInObjectInfo.GetObject: TObject;
begin
  Result := FObject;
end;

procedure TPlugInObjectInfo.SetObject(const Value: TObject);
begin
  FObject := Value;
end;

end.


