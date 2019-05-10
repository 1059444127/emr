{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit EmrViewNatural;

interface

uses
  Windows, Classes, Controls, Vcl.Graphics, SysUtils, Generics.Collections,
  Xml.XMLDoc, Xml.XMLIntf, HCView, HCStyle, HCSection, HCCommon, HCCustomData,
  HCItem, HCViewData, HCTextItem, HCRectItem, EmrView, EmrElementItem, EmrGroupItem,
  emr_Common, FireDAC.Comp.Client, FireDAC.Stan.Intf, Data.DB;

type
  TXmlStruct = class(TObject)
  private
    FXmlDoc: IXMLDocument;
    FDeGroupNodes: TList;
    FDETable: TFDMemTable;
    FHasData: Boolean;  // �Ƿ��л�ȡ������һ������Ԫ�������飬����ʶ���ɵ�xml�Ƿ�������
    FOnlyDeItem: Boolean;  // �Ƿ�ֻ������Ԫ��������ͨ�ı�
  public
    constructor Create;
    destructor Destroy; override;
    procedure TraverseItem(const AData: THCCustomData;
      const AItemNo, ATag: Integer; var AStop: Boolean);
    property XmlDoc: IXMLDocument read FXmlDoc;
    property HasData: Boolean read FHasData;
  end;

  TStructDoc = class(TObject)
  strict private
    FPatID: string;
    FDesID: Integer;
    FXmlDoc: IXMLDocument;
  public
    constructor Create(const APatID: string; const ADesID: Integer);
    destructor Destroy; override;
    class function GetDeItemNode(const ADeIndex: string; const AXmlDoc: IXMLDocument): IXmlNode;
    property PatID: string read FPatID write FPatID;
    property DesID: Integer read FDesID write FDesID;
    property XmlDoc: IXMLDocument read FXmlDoc;
  end;

  TEmrViewNatural = class(TObject)
  private
    FStyle: THCStyle;
    FSections: TObjectList<THCSection>;
    //FOnSectionCreateStyleItem: TStyleItemEvent;
    //
    function NewDefaultSection: THCSection;
    procedure DoLoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const ALoadSectionProc: TLoadSectionProc);

    function GetUserInfo: TUserInfo;
    procedure SetUserInfo(const Value: TUserInfo);
    function GetPatientInfo: TPatientInfo;
    procedure SetPatientInfo(const Value: TPatientInfo);
    function GetRecordInfo: TRecordInfo;
    procedure SetRecordInfo(const Value: TRecordInfo);
    //
    procedure PrepareSyncData;
  protected
    function DoSectionCreateStyleItem(const AData: THCCustomData; const AStyleNo: Integer): THCCustomItem;
    procedure DoInsertItem(const Sender: TObject; const AData: THCCustomData; const AItem: THCCustomItem);
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary> ȫ�����(�������ҳü��ҳ�š�ҳ���Item��DrawItem) </summary>
    procedure Clear;

    // �����ĵ�
    /// <summary> �ĵ����浽�� </summary>
    procedure SaveToStream(const AStream: TStream; const AQuick: Boolean = False;
      const AAreas: TSectionAreas = [saHeader, saPage, saFooter]); virtual;

    /// <summary> ��ȡ�ļ��� </summary>
    procedure LoadFromStream(const AStream: TStream); virtual;

    property UserInfo: TUserInfo read GetUserInfo write SetUserInfo;
    property PatientInfo: TPatientInfo read GetPatientInfo write SetPatientInfo;
    property RecordInfo: TRecordInfo read GetRecordInfo write SetRecordInfo;
  end;

  /// <summary> �滻�ĵ��е�����Ԫ���� </summary>
  procedure SyncDeItem(const Sender: TObject; const AData: THCCustomData; const AItem: THCCustomItem);
  procedure SyncDeGroupByStruct(const Sender: TObject; const AData: THCCustomData);
  /// <summary> �滻ָ������������� </summary>
  /// <param name="AData">ָ�����ĸ�Data���ȡ</param>
  /// <param name="ADeGroupNo">���滻����������ʼ�������ItemNo</param>
  /// <param name="AText">Ҫ�滻������</param>
  procedure SetDeGroupText(const AData: THCViewData;
    const ADeGroupNo: Integer; const AText: string);

implementation

uses
  emr_BLLServerProxy, System.Rtti, HCSectionData, HCRichData, EmrYueJingItem,
  EmrToothItem, EmrFangJiaoItem;

var
  FUserInfo: TUserInfo;
  FPatientInfo: TPatientInfo;
  FRecordInfo: TRecordInfo;
  FServerInfo: TServerInfo;
  FDataElementSetMacro: TFDMemTable;
  FStructDocs: TObjectList<TStructDoc>;

procedure SetDeGroupText(const AData: THCViewData; const ADeGroupNo: Integer; const AText: string);
var
  vGroupBeg, vGroupEnd: Integer;
begin
  vGroupEnd := (AData as THCViewData).GetDomainAnother(ADeGroupNo);

  if vGroupEnd > ADeGroupNo then
    vGroupBeg := ADeGroupNo
  else
  begin
    vGroupBeg := vGroupEnd;
    vGroupEnd := ADeGroupNo;
  end;

  // ѡ�У�ʹ�ò���ʱɾ����ǰ�������е�����
  AData.SetSelectBound(vGroupBeg, OffsetAfter, vGroupEnd, OffsetBefor);
  AData.InsertText(AText);
end;

function GetMarcoSqlResult(const AObjID, AMacro: string): string;
var
  vSqlResult: string;
  vQuery: TFDQuery;
  i: Integer;
begin
  Result := '';
  vSqlResult := AMacro;

  vQuery := TFDQuery.Create(nil);
  try
    vQuery.SQL.Text := AMacro;
    //if (vQuery.FieldList.Count > 0) or (vQuery.FieldDefs.Count > 0) or (vQuery.FieldDefList.Count > 0) or (vQuery.Fields.Count > 0) then
    if vQuery.Params.Count > 0 then  // ���ֶβ���
    begin
      for i := 0 to vQuery.Params.Count - 1 do
      begin
        if Pos('patientinfo', LowerCase(vQuery.Params[i].Name)) > 0 then
        begin
          vSqlResult := StringReplace(vSqlResult, ':' + vQuery.Params[i].Name,
            GetValueAsString(FPatientInfo.FieldByName(
              Copy(vQuery.Params[i].Name, Pos('.', vQuery.Params[i].Name) + 1, 20) ) ), [rfReplaceAll, rfIgnoreCase]);
        end
        else
        if Pos('userinfo', LowerCase(vQuery.Params[i].Name)) > 0 then
        begin
          vSqlResult := StringReplace(vSqlResult, ':' + vQuery.Params[i].Name,
            GetValueAsString(FUserInfo.FieldByName(
              Copy(vQuery.Params[i].Name, Pos('.', vQuery.Params[i].Name) + 1, 20) ) ), [rfReplaceAll, rfIgnoreCase]);
        end
        else
        if Pos('serverinfo', LowerCase(vQuery.Params[i].Name)) > 0 then
        begin
          vSqlResult := StringReplace(vSqlResult, ':' + vQuery.Params[i].Name,
            GetValueAsString(FServerInfo.FieldByName(
              Copy(vQuery.Params[i].Name, Pos('.', vQuery.Params[i].Name) + 1, 20) ) ), [rfReplaceAll, rfIgnoreCase]);
        end;
      end;
    end;
  finally
    FreeAndNil(vQuery);
  end;

  BLLServerExec(procedure(const ABLLServerReady: TBLLServerProxy)
  begin
    ABLLServerReady.Cmd := BLL_EXECSQL;  // ��ȡָ���û�����Ϣ
    ABLLServerReady.ReplaceParam.S['Sql'] := vSqlResult;
    ABLLServerReady.AddBackField('value');
  end,
  procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
  begin
    if not ABLLServerRun.MethodRunOk then
      raise Exception.Create(ABLLServerRun.MethodError);

    vSqlResult := ABLLServerRun.BackField('value').AsString;
  end);

  if vSqlResult <> '' then
    Result := vSqlResult;
end;

function GetDeItemNodeFromStructDoc(const APatID: string; const ADesID: Integer;
  ADeIndex: string): IXMLNode;
var
  i: Integer;
  vStructDoc: TStructDoc;
  vXmlDoc: IXMLDocument;
  vStream: TMemoryStream;
begin
  Result := nil;
  vXmlDoc := nil;
  for i := 0 to FStructDocs.Count - 1 do
  begin
    if (FStructDocs[i].PatID = APatID) and (FStructDocs[i].DesID = ADesID) then
    begin
      vXmlDoc := FStructDocs[i].XmlDoc;
      Break;
    end;
  end;

  if not Assigned(vXmlDoc) then
  begin
    vStream := TMemoryStream.Create;
    try
      BLLServerExec(procedure(const ABLLServerReady: TBLLServerProxy)
      begin
        ABLLServerReady.Cmd := BLL_GetPatDesStructure;  // ��ȡָ������ָ�����ݼ��Ĳ����ṹ����
        ABLLServerReady.ExecParam.S['Patient_ID'] := APatID;
        ABLLServerReady.ExecParam.I['DesID'] := ADesID;  // ���ݼ�ID
        ABLLServerReady.AddBackField('structure');
      end,
      procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
      begin
        if not ABLLServerRun.MethodRunOk then  // ����˷�������ִ�в��ɹ�
          raise Exception.Create(ABLLServerRun.MethodError);

        ABLLServerRun.BackField('structure').SaveBinaryToStream(vStream);

        if vStream.Size > 0 then
        begin
          vStream.Position := 0;

          vStructDoc := TStructDoc.Create(APatID, ADesID);
          vStructDoc.XmlDoc.LoadFromStream(vStream);
          vXmlDoc := vStructDoc.XmlDoc;
          //vXmlDoc.SaveToFile('x.xml');
        end;
      end);
    finally
      FreeAndNil(vStream);
    end;
  end;

  if Assigned(vXmlDoc) then
    Result := TStructDoc.GetDeItemNode(ADeIndex, vXmlDoc);
end;

procedure AssignDeItemFromStruct(const APatID: string; ADesID: Integer; const ADeItem: TDeItem);
var
  vXmlNode: IXMLNode;
begin
  vXmlNode := GetDeItemNodeFromStructDoc(APatID, ADesID, ADeItem[TDeProp.Index]);

  if Assigned(vXmlNode) then
  begin
    if vXmlNode.Text <> '' then
      ADeItem.Text := vXmlNode.Text;
  end;
end;

procedure SyncDeItem(const Sender: TObject; const AData: THCCustomData; const AItem: THCCustomItem);
var
  vDeItem: TDeItem;
  vDeIndex, vSqlResult: string;
begin
  if AItem is TDeItem then
  begin
    vDeItem := AItem as TDeItem;
    if vDeItem.IsElement then
    begin
      if vDeItem.StyleNo > THCStyle.Null then  // ���ı�����
      begin
        vDeIndex := vDeItem[TDeProp.Index];
        if vDeIndex <> '' then  // ������Ԫ
        begin
          FDataElementSetMacro.Filtered := False;
          FDataElementSetMacro.Filter := 'ObjID = ' + vDeIndex;
          FDataElementSetMacro.Filtered := True;
          if FDataElementSetMacro.RecordCount = 1 then  // �д�����Ԫ���滻��Ϣ
          begin
            case FDataElementSetMacro.FieldByName('MacroType').AsInteger of
              1:  // ������Ϣ(�ͻ���)
                vDeItem.Text := GetValueAsString(FPatientInfo.FieldByName(FDataElementSetMacro.FieldByName('Macro').AsString));

              2:  // �û���Ϣ(�ͻ���)
                vDeItem.Text := GetValueAsString(FUserInfo.FieldByName(FDataElementSetMacro.FieldByName('Macro').AsString));

              3: // ������Ϣ(�����)
                AssignDeItemFromStruct(FPatientInfo.PatID, FDataElementSetMacro.FieldByName('Macro').AsInteger, vDeItem);

              4:  // ������Ϣ(����ˣ��統ǰʱ���)
                vDeItem.Text := GetValueAsString(FServerInfo.FieldByName(FDataElementSetMacro.FieldByName('Macro').AsString));

              5:  // SQL�ű�(�����)
                begin
                  vSqlResult := GetMarcoSqlResult(vDeIndex, FDataElementSetMacro.FieldByName('Macro').AsString);
                  if vSqlResult <> '' then
                    vDeItem.Text := vSqlResult;
                end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure SyncDeGroupByStruct(const Sender: TObject; const AData: THCCustomData);
var
  vDeGroupIndex, vText: string;
  i, vIndex: Integer;
  vXmlNode: IXMLNode;
begin
  vIndex := AData.Items.Count - 1;

  while vIndex >= 0 do
  begin
    if THCDomainItem.IsBeginMark(AData.Items[vIndex]) then
    begin
      vDeGroupIndex := (AData.Items[vIndex] as TDeGroup)[TDeProp.Index];

      FDataElementSetMacro.Filtered := False;
      FDataElementSetMacro.Filter := 'MacroType = 3 and ObjID = ' + vDeGroupIndex;
      FDataElementSetMacro.Filtered := True;
      //
      if FDataElementSetMacro.RecordCount > 0 then
      begin
        vXmlNode := GetDeItemNodeFromStructDoc(FPatientInfo.PatID,
          FDataElementSetMacro.FieldByName('Macro').AsInteger, vDeGroupIndex);

        if Assigned(vXmlNode) then
        begin
          vText := '';
          for i := 0 to vXmlNode.ChildNodes.Count - 1 do
            vText := vText + vXmlNode.ChildNodes[i].Text;

          if vText <> '' then
            SetDeGroupText(AData as THCViewData, vIndex, vText);
        end;
      end;
    end;

    Dec(vIndex);
  end;
end;

{ TEmrViewNatural }

procedure TEmrViewNatural.Clear;
begin
  FStyle.Initialize;  // ������ʽ����ֹData��ʼ��ΪEmptyDataʱ��Item��ʽ��ֵΪCurStyleNo
  FSections.DeleteRange(1, FSections.Count - 1);
  FSections[0].Clear;
end;

constructor TEmrViewNatural.Create;
begin
  inherited Create;
  FUserInfo := nil;
  FPatientInfo := nil;
  FRecordInfo := nil;
  FServerInfo := TServerInfo.Create;
  FDataElementSetMacro := TFDMemTable.Create(nil);

  HCDefaultTextItemClass := TDeItem;
  HCDefaultDomainItemClass := TDeGroup;
  FStyle := THCStyle.CreateEx(True, True);
  FSections := TObjectList<THCSection>.Create;
  FSections.Add(NewDefaultSection);
end;

destructor TEmrViewNatural.Destroy;
begin
  FreeAndNil(FSections);
  FreeAndNil(FStyle);
  FreeAndNil(FDataElementSetMacro);
  FreeAndNil(FServerInfo);
  FreeAndNil(FStructDocs);
  inherited Destroy;
end;

procedure TEmrViewNatural.DoInsertItem(const Sender: TObject;
  const AData: THCCustomData; const AItem: THCCustomItem);
begin
  SyncDeItem(Sender, AData, AItem);
end;

procedure TEmrViewNatural.DoLoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const ALoadSectionProc: TLoadSectionProc);
var
  vFileExt: string;
  vVersion: Word;
  vLang: Byte;
begin
  AStream.Position := 0;
  _LoadFileFormatAndVersion(AStream, vFileExt, vVersion, vLang);  // �ļ���ʽ�Ͱ汾
  if (vFileExt <> HC_EXT) and (vFileExt <> 'cff.') then
    raise Exception.Create('����ʧ�ܣ�����' + HC_EXT + '�ļ���');
  if vVersion > HC_FileVersionInt then
    raise Exception.Create('����ʧ�ܣ���ǰ�༭�����֧�ְ汾Ϊ'
      + IntToStr(HC_FileVersionInt) + '���ļ����޷��򿪰汾Ϊ'
      + IntToStr(vVersion) + '���ļ���');

  AStyle.LoadFromStream(AStream, vVersion);  // ������ʽ��
  ALoadSectionProc(vVersion);  // ���ؽ�������������
end;

function TEmrViewNatural.DoSectionCreateStyleItem(const AData: THCCustomData;
  const AStyleNo: Integer): THCCustomItem;
begin
  Result := TEmrView.CreateEmrStyleItem(AData, AStyleNo);
end;

function TEmrViewNatural.GetPatientInfo: TPatientInfo;
begin
  Result := FPatientInfo;
end;

function TEmrViewNatural.GetRecordInfo: TRecordInfo;
begin
  Result := FRecordInfo;
end;

function TEmrViewNatural.GetUserInfo: TUserInfo;
begin
  Result := FUserInfo;
end;

procedure TEmrViewNatural.LoadFromStream(const AStream: TStream);
var
  vByte: Byte;
begin
  PrepareSyncData;

  Self.Clear;
  if not Assigned(FStructDocs) then
    FStructDocs := TObjectList<TStructDoc>.Create
  else
    FStructDocs.Clear;

  AStream.Position := 0;
  DoLoadFromStream(AStream, FStyle, procedure(const AFileVersion: Word)
  var
    i: Integer;
    vSection: THCSection;
  begin
    AStream.ReadBuffer(vByte, 1);  // ������
    // ��������
    FSections[0].LoadFromStream(AStream, FStyle, AFileVersion);
    SyncDeGroupByStruct(nil, FSections[0].Page);

    for i := 1 to vByte - 1 do
    begin
      vSection := NewDefaultSection;
      vSection.LoadFromStream(AStream, FStyle, AFileVersion, True);
      FSections.Add(vSection);

      SyncDeGroupByStruct(nil, vSection.Page);
    end;
  end);
end;

function TEmrViewNatural.NewDefaultSection: THCSection;
begin
  Result := THCSection.Create(FStyle);
  Result.OnCreateItemByStyle := DoSectionCreateStyleItem;
  Result.OnInsertItem := DoInsertItem;
end;

procedure TEmrViewNatural.PrepareSyncData;
begin
  // ȡDataElementSetMacro;
  BLLServerExec(procedure(const ABLLServerReady: TBLLServerProxy)
  begin
    ABLLServerReady.Cmd := BLL_GetDataElementSetMacro;  // ��ȡָ���û�����Ϣ
    ABLLServerReady.ExecParam.I['DesID'] := FRecordInfo.DesID;  // ���ݼ�ID
    ABLLServerReady.BackDataSet := True;
  end,
  procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
  begin
    if not ABLLServerRun.MethodRunOk then
      raise Exception.Create(ABLLServerRun.MethodError);  //Exit;

    if AMemTable <> nil then
    begin
      FDataElementSetMacro.Close;
      FDataElementSetMacro.Data := AMemTable.Data;
    end;
  end);

  FServerInfo.DateTime := TBLLServer.GetServerDateTime;
end;

procedure TEmrViewNatural.SaveToStream(const AStream: TStream;
  const AQuick: Boolean; const AAreas: TSectionAreas);
var
  vByte: Byte;
  i: Integer;
begin
  _SaveFileFormatAndVersion(AStream);  // �ļ���ʽ�Ͱ汾

  if not AQuick then
    THCView.DeleteUnUsedStyle(FStyle, FSections, AAreas);  // ɾ����ʹ�õ���ʽ(�ɷ��Ϊ�����õĴ��ˣ�����ʱItem��StyleNoȡ����)

  FStyle.SaveToStream(AStream);
  // ������
  vByte := FSections.Count;
  AStream.WriteBuffer(vByte, 1);
  // ��������
  for i := 0 to FSections.Count - 1 do
    FSections[i].SaveToStream(AStream, AAreas);
end;

procedure TEmrViewNatural.SetPatientInfo(const Value: TPatientInfo);
begin
  FPatientInfo := Value;
end;

procedure TEmrViewNatural.SetRecordInfo(const Value: TRecordInfo);
begin
  FRecordInfo := Value;
end;

procedure TEmrViewNatural.SetUserInfo(const Value: TUserInfo);
begin
  FUserInfo := Value;
end;

{ TXmlStruct }

constructor TXmlStruct.Create;
begin
  FHasData := False;
  FOnlyDeItem := False;

  FDETable := TFDMemTable.Create(nil);
  FDETable.FilterOptions := [foCaseInsensitive{�����ִ�Сд, foNoPartialCompare��֧��ͨ���(*)����ʾ�Ĳ���ƥ��}];

  BLLServerExec(
    procedure(const ABLLServerReady: TBLLServerProxy)
    begin
      ABLLServerReady.Cmd := BLL_GETDATAELEMENT;  // ��ȡ����Ԫ�б�
      ABLLServerReady.BackDataSet := True;  // ���߷����Ҫ����ѯ���ݼ��������
    end,
    procedure(const ABLLServerRun: TBLLServerProxy; const AMemTable: TFDMemTable = nil)
    begin
      if not ABLLServerRun.MethodRunOk then  // ����˷�������ִ�в��ɹ�
        raise Exception.Create(ABLLServerRun.MethodError);

      if AMemTable <> nil then
        FDETable.CloneCursor(AMemTable);
    end);

  FDeGroupNodes := TList.Create;

  FXmlDoc := TXMLDocument.Create(nil);
  FXmlDoc.Active := True;
  FXmlDoc.DocumentElement := FXmlDoc.CreateNode('DocInfo', ntElement, '');
  FXmlDoc.DocumentElement.Attributes['SourceTool'] := 'HCView';
end;

destructor TXmlStruct.Destroy;
begin
  FreeAndNil(FDETable);
  FreeAndNil(FDeGroupNodes);
  FXmlDoc := nil;
  inherited Destroy;
end;

procedure TXmlStruct.TraverseItem(const AData: THCCustomData; const AItemNo,
  ATag: Integer; var AStop: Boolean);
var
  vDeItem: TDeItem;
  vDeGroup: TDeGroup;
  vXmlNode: IXMLNode;
begin
  if (AData is THCHeaderData) or (AData is THCFooterData) then Exit;

  if AData.Items[AItemNo] is TDeGroup then  // ������
  begin
    FHasData := True;

    vDeGroup := AData.Items[AItemNo] as TDeGroup;
    if vDeGroup.MarkType = TMarkType.cmtBeg then
    begin
      if FDeGroupNodes.Count > 0 then
        vXmlNode := IXMLNode(FDeGroupNodes[FDeGroupNodes.Count - 1]).AddChild('DeGroup', -1)
      else
        vXmlNode := FXmlDoc.DocumentElement.AddChild('DeGroup', -1);

      FDETable.Filtered := False;
      FDETable.Filter := 'DeID = ' + vDeGroup[TDeProp.Index];
      FDETable.Filtered := True;

      vXmlNode.Attributes['Index'] := vDeGroup[TDeProp.Index];
      vXmlNode.Attributes['Code'] := vDeGroup[TDeProp.Code];
      vXmlNode.Attributes['Name'] := vDeGroup[TDeProp.Name];

      FDeGroupNodes.Add(vXmlNode);
    end
    else
    begin
      if FDeGroupNodes.Count > 0 then
        FDeGroupNodes.Delete(FDeGroupNodes.Count - 1);
    end;
  end
  else
  if AData.Items[AItemNo].StyleNo > THCStyle.Null then  // �ı���
  begin
    if (AData.Items[AItemNo] as TDeItem).IsElement then  // ����Ԫ
    begin
      FHasData := True;

      vDeItem := AData.Items[AItemNo] as TDeItem;
      if vDeItem[TDeProp.Index] <> '' then
      begin
        if FDeGroupNodes.Count > 0 then
          vXmlNode := IXMLNode(FDeGroupNodes[FDeGroupNodes.Count - 1]).AddChild('DeItem', -1)
        else
          vXmlNode := FXmlDoc.DocumentElement.AddChild('DeItem', -1);

        FDETable.Filtered := False;
        FDETable.Filter := 'DeID = ' + vDeItem[TDeProp.Index];
        FDETable.Filtered := True;

        vXmlNode.Text := vDeItem.Text;
        vXmlNode.Attributes['Index'] := vDeItem[TDeProp.Index];
        vXmlNode.Attributes['Code'] := FDETable.FieldByName('DeCode').AsString;
        vXmlNode.Attributes['Name'] := FDETable.FieldByName('DeName').AsString;
      end;
    end
    else
    if not FOnlyDeItem then
    begin
      if FDeGroupNodes.Count > 0 then
        vXmlNode := IXMLNode(FDeGroupNodes[FDeGroupNodes.Count - 1]).AddChild('Text', -1)
      else
        vXmlNode := FXmlDoc.DocumentElement.AddChild('Text', -1);

      vXmlNode.Text := AData.Items[AItemNo].Text;
    end;
  end
  else  // ���ı���
  begin
    if AData.Items[AItemNo] is TEmrYueJingItem then
    begin
      if FDeGroupNodes.Count > 0 then
        vXmlNode := IXMLNode(FDeGroupNodes[FDeGroupNodes.Count - 1]).AddChild('DeItem', -1)
      else
        vXmlNode := FXmlDoc.DocumentElement.AddChild('DeItem', -1);

      (AData.Items[AItemNo] as TEmrYueJingItem).ToXmlEmr(vXmlNode);
    end
    else
    if AData.Items[AItemNo] is TEmrToothItem then
    begin
      if FDeGroupNodes.Count > 0 then
        vXmlNode := IXMLNode(FDeGroupNodes[FDeGroupNodes.Count - 1]).AddChild('DeItem', -1)
      else
        vXmlNode := FXmlDoc.DocumentElement.AddChild('DeItem', -1);

      (AData.Items[AItemNo] as TEmrToothItem).ToXmlEmr(vXmlNode);
    end
    else
    if AData.Items[AItemNo] is TEmrFangJiaoItem then
    begin
      if FDeGroupNodes.Count > 0 then
        vXmlNode := IXMLNode(FDeGroupNodes[FDeGroupNodes.Count - 1]).AddChild('DeItem', -1)
      else
        vXmlNode := FXmlDoc.DocumentElement.AddChild('DeItem', -1);

      (AData.Items[AItemNo] as TEmrFangJiaoItem).ToXmlEmr(vXmlNode);
    end;
  end;
end;

{ TStructDoc }

constructor TStructDoc.Create(const APatID: string; const ADesID: Integer);
begin
  FPatID := APatID;
  FDesID := ADesID;
  FXmlDoc := TXmlDocument.Create(nil);
end;

destructor TStructDoc.Destroy;
begin
  FXmlDoc := nil;
  inherited Destroy;
end;

class function TStructDoc.GetDeItemNode(const ADeIndex: string;
  const AXmlDoc: IXMLDocument): IXmlNode;
var
  i: Integer;
  vNodes: IXMLNodeList;
begin
  Result := nil;

  vNodes := AXmlDoc.DocumentElement.ChildNodes;
  for i := 0 to vNodes.Count - 1 do
  begin
    if vNodes[i].Attributes['Index'] = ADeIndex then
    begin
      Result := vNodes[i];
      Break;
    end;
  end;
end;

end.
