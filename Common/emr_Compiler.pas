unit emr_Compiler;

interface

uses
  System.Classes, HCCompiler, PaxRegister, HCEmrElementItem, emr_Common,
  IMPORT_Classes, IMPORT_SysUtils, IMPORT_Dialogs, IMPORT_Variants;

type
  TSetDeItemTextCpl = class(TObject)
  public
    class procedure RegImportClass;
    /// <summary> ע�� SetDeItemText ��Ҫ�����Ҫ���õ��ַ��� </summary>
    class procedure RegClassVariable(const ACompiler: THCCompiler; const ADeItem,
      APatientInfo, ARecordInfo, AText: Pointer);

    /// <summary> ���� SetDeItemText ��صĴ�����ʾ </summary>
    class procedure Proposal(const AWord: string; const AInsertList, AItemList: TStrings);
  end;

  procedure SetClassProposal(const AWord: string; const AInsertList,
    AItemList: TStrings);

implementation

var
  DeItemClassType: Integer;

function TDeItem_GetValue(Self: TDeItem; const Key: String): String;
begin
  Result := Self[Key];
end;

procedure TDeItem_SetValue(Self: TDeItem; const Key: string; const Value: string);
begin
  Self[Key] := Value;
end;

procedure SetClassProposal(const AWord: string; const AInsertList, AItemList: TStrings);
begin
  if AWord = 'PATIENTINFO' then
    TPatientInfo.SetProposal(AInsertList, AItemList)
  else
  if AWord = 'RECORDINFO' then
    TRecordInfo.SetProposal(AInsertList, AItemList)
  else
  if AWord = 'DEITEM' then
    TDeItem.SetProposal(AInsertList, AItemList)
  else
  if AWord = 'TDEPROP' then
    TDeProp.SetProposal(AInsertList, AItemList);
end;

{ TSetDeItemTextCpl }

class procedure TSetDeItemTextCpl.Proposal(const AWord: string; const AInsertList,
  AItemList: TStrings);
begin
  if AWord = '.' then
  begin
    AInsertList.Add('TDeProp');
    AItemList.Add('var \column{}\style{+B}TDeProp\style{-B}: class(TObject);  // ����Ԫ���Գ���');
    AInsertList.Add('DeItem');
    AItemList.Add('var \column{}\style{+B}DeItem\style{-B}: TDeItem;  // ��ǰ����Ԫ');
    AInsertList.Add('PatientInfo');
    AItemList.Add('var \column{}\style{+B}PatientInfo\style{-B}: TPatientInfo;  // ��ǰ������Ϣ');
    AInsertList.Add('RecordInfo');
    AItemList.Add('var \column{}\style{+B}RecordInfo\style{-B}: TRecordInfo;  // ��ǰ������Ϣ');
    AInsertList.Add('Text');
    AItemList.Add('var \column{}\style{+B}Text\style{-B}: string;  // ����ԪҪ���õ�ֵ');
  end
  else
    SetClassProposal(AWord, AInsertList, AItemList);
end;

class procedure TSetDeItemTextCpl.RegClassVariable(const ACompiler: THCCompiler;
  const ADeItem, APatientInfo, ARecordInfo, AText: Pointer);
var
  vClassType: Integer;
begin
  // ע������Ԫ
  ACompiler.RegisterVariable(0, 'DeItem', DeItemClassType, ADeItem);

  // ע������Ԫ���Գ���
  vClassType := ACompiler.RegisterClassType(0, TDeProp);

  // ע�Ỽ��
  vClassType := ACompiler.RegisterClassType(0, TPatientInfo);
  ACompiler.RegisterVariable(0, 'PatientInfo', vClassType, APatientInfo);

  // ע�ᵱǰ������Ϣ
  vClassType := ACompiler.RegisterClassType(0, TRecordInfo);
  ACompiler.RegisterVariable(0, 'RecordInfo', vClassType, ARecordInfo);

  // ע��Ҫ���õ��ı�����
  ACompiler.RegisterVariable(0, 'Text', _typeSTRING, AText);
end;

class procedure TSetDeItemTextCpl.RegImportClass;
var
  vH, vClassType: Integer;
begin
  vH := RegisterNamespace(0, 'HCEmrElementItem');
  vClassType := RegisterClassType(vH, TDeProp);
  RegisterConstant(vClassType, 'Index', TDeProp.Index);
  RegisterConstant(vClassType, 'Unit', TDeProp.&Unit);
  RegisterConstant(vClassType, 'CMV', TDeProp.CMV);
  RegisterConstant(vClassType, 'CMVVCode', TDeProp.CMVVCode);

  // ע������Ԫ
  DeItemClassType := RegisterClassType(vH, TDeItem);
  RegisterFakeHeader(DeItemClassType, 'function _TDeItem_GetValue(const Key: string): string;', @TDeItem_GetValue);
  RegisterFakeHeader(DeItemClassType, 'procedure _TDeItem_SetValue(const Key: string; const Value: string);', @TDeItem_SetValue);
  RegisterProperty(DeItemClassType, 'property Values[const Key: string]: string read _TDeItem_GetValue write _TDeItem_SetValue; default;');
end;

procedure RegisterImportClass;
begin
  IMPORT_Classes.Register_Classes;
  IMPORT_SysUtils.Register_SysUtils;
  IMPORT_Dialogs.Register_Dialogs;
  IMPORT_Variants.Register_Variants;

  TSetDeItemTextCpl.RegImportClass;
end;

initialization
  RegisterImportClass;

end.
