{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit TemplateCommon;

interface

uses
  emr_Common, emr_BLLServerProxy, FireDAC.Comp.Client;

  function CommonLastError: string;

  // ɾ��ֵ��ѡ�����������
  function DeleteDomainItemContent(const ADItemID: Integer): Boolean;

  // ɾ��ֵ��ĳ��ѡ��
  function DeleteDomainItem(const ADItemID: Integer): Boolean;

  // ɾ��ֵ������ѡ��
  function DeleteDomainAllItem(const ADomainID: Integer): Boolean;

implementation

var
  FLastError: string;

function CommonLastError: string;
begin
  Result := FLastError;
end;

function DeleteDomainAllItem(const ADomainID: Integer): Boolean;
var
  vDeleteOk: Boolean;
begin
  Result := False;

  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_DELETEDOMAINALLITEM;  // ɾ��ֵ���Ӧ������ѡ��
      ABLLServerReady.ExecParam.I['DomainID'] := ADomainID;
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      vDeleteOk := ABLLServer.MethodRunOk;
      if not vDeleteOk then
        FLastError := ABLLServer.MethodError;
    end);

  Result := vDeleteOk;
end;

function DeleteDomainItem(const ADItemID: Integer): Boolean;
var
  vDeleteOk: Boolean;
begin
  Result := False;  // ɾ��ѡ��

  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_DELETEDOMAINITEM;  // ɾ��ֵ��ѡ��
      ABLLServerReady.ExecParam.I['ID'] := ADItemID;
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      vDeleteOk := ABLLServer.MethodRunOk;
      if not vDeleteOk then
        FLastError := ABLLServer.MethodError;
    end);

  Result := vDeleteOk;
end;

function DeleteDomainItemContent(const ADItemID: Integer): Boolean;
var
  vDeleteOk: Boolean;
begin
  Result := False;

  BLLServerExec(procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_DELETEDOMAINITEMCONTENT;  // ɾ��ֵ��ѡ���������
      ABLLServerReady.ExecParam.I['DItemID'] := ADItemID;
    end,
    procedure(const ABLLServer: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      vDeleteOk := ABLLServer.MethodRunOk;
      if not vDeleteOk then
        FLastError := ABLLServer.MethodError;
    end);

  Result := vDeleteOk;
end;

end.
