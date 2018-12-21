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

  IPlugInUserInfo = interface(IPluginObject)
    ['{60512600-C4C7-477D-A9A3-D56F667303BD}']
    function GetUserID: string;
    procedure SetUserID(const Value: string);
    property UserID: string read GetUserID write SetUserID;
  end;

  TPlugInObjectInfo = class(TInterfacedObject, IPlugInObjectInfo)
  private
    FObject: TObject;
    function GetObject: TObject;
    procedure SetObject(const Value: TObject);
  end;

  TPlugInUserInfo = class(TInterfacedObject, IPlugInUserInfo)
  private
    FUserID: string;
    function GetUserID: string;
    procedure SetUserID(const Value: string);
  end;

implementation

{ TPlugInUserInfo }

function TPlugInUserInfo.GetUserID: string;
begin
  Result := FUserID;
end;

procedure TPlugInUserInfo.SetUserID(const Value: string);
begin
  FUserID := Value;
end;

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


