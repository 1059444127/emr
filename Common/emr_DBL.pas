unit emr_DBL;

interface

uses
  Classes, emr_DataBase, emr_BLLDataBase, emr_MsgPack;

Type
  TExecutelog = procedure(const ALog: string) of object;

  TDBL = class(TObject)  // DataBase Logic
  private
    FDB: TDataBase;
    FBLLDB: TBLLDataBase;
    FOnExecuteLog: TExecuteLog;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ExecuteMsgPack(const AMsgPack: TMsgPack);
    property DB: TDataBase read FDB;
    property OnExecuteLog: TExecutelog read FOnExecuteLog write FOnExecuteLog;
  end;

implementation

uses
  emr_BLLServerProxy, SysUtils, DB, Provider,
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.StorageBin, emr_MsgConst;

{ TBLLServerMethod }

constructor TDBL.Create;
begin
  FDB := TDataBase.Create(nil);
  FBLLDB := TBLLDataBase.Create;
end;

destructor TDBL.Destroy;
begin
  FreeAndNil(FDB);
  FreeAndNil(FBLLDB);
  inherited Destroy;
end;

procedure TDBL.ExecuteMsgPack(const AMsgPack: TMsgPack);

  function IsSelectSql(const ASql: string): Boolean;
  var
    i: Integer;
    vKey: string;
  begin
    Result := False;
    vKey := '';
    for i := 1 to Length(ASql) do
    begin
      if ASql[i] <> '' then
        vKey := vKey + UpperCase(ASql[i]);
      if Length(vKey) = 6 then
      begin
        Result := vKey = 'SELECT';
        Break;
      end;
    end;
  end;

  procedure DoBackErrorMsg(const AMsg: string);
  begin
    AMsgPack.Clear;  // ���ͻ��˵���ʱ�����Ĳ���ֵ����������ٲ���Ҫ�Ļش�������
    AMsgPack.S[BLL_METHODMSG] := AMsg;
    if Assigned(FOnExecuteLog) then
      FOnExecuteLog(AMsg);
  end;

var
  vQuery: TFDQuery;
  vBLLDataBase: TDataBase;
  vBLLDataBaseID: Integer;
  vFrameSql: string;

  function CheckBllDataBase: Boolean;
  begin
    Result := False;
    try
      if vBLLDataBaseID > 0 then
      begin
        vFrameSql := Format('SELECT dbtype, server, port, dbname, username, paw FROM frame_blldbconn WHERE id=%d',
          [vBLLDataBaseID]);
        vQuery.Close;
        vQuery.SQL.Text := vFrameSql;
        vQuery.Open;
        vBLLDataBase := FBLLDB.GetBLLDataBase(vBLLDataBaseID,
          vQuery.FieldByName('dbtype').AsInteger,
          vQuery.FieldByName('server').AsString,
          vQuery.FieldByName('port').AsInteger,
          vQuery.FieldByName('dbname').AsString,
          vQuery.FieldByName('username').AsString,
          vQuery.FieldByName('paw').AsString);
        vQuery.Connection := vBLLDataBase.Connection;
      end
      else
        vBLLDataBase := FDB;
      Result := True;
    except
      on E: Exception do
        DoBackErrorMsg(Format('�쳣(�����)��û���ҵ�ConnIDΪ %d ��ҵ������������Ϣ', [vBLLDataBaseID])
          + sLineBreak + '��䣺' + vFrameSql + sLineBreak + '������Ϣ��' + E.Message);
    end;
  end;

var
  //vData: OleVariant;
  vDeviceType: TDeviceType;
  i, j, vCMD, vVer, vRecordCount: Integer;
  vProvider: TDataSetProvider;
  vExecParams, vReplaceParams, vBatchData, vBackParam: TMsgPack;
  vBLLSql, vBLLInfo: string;
  vMemStream: TMemoryStream;
  vMemTable: TFDMemTable;
begin
  AMsgPack.Result := False;

  vCMD := AMsgPack.ForcePathObject(BLL_CMD).AsInteger;
  vDeviceType := TDeviceType(AMsgPack.I[BLL_DEVICE]);
  vVer := AMsgPack.I[BLL_VER];
  vBLLInfo := '[' + vCMD.ToString + ']';
  vQuery := FDB.GetQuery;
  try
    // ȡҵ����䲢��ѯ
    vFrameSql := Format('SELECT dbconnid, sqltext, name FROM frame_bllsql WHERE bllid = %d AND ver = %d',
      [vCMD, vVer]);
    {���Ĭ��֧�ֵĲ������־
    if Assigned(FOnExecuteLog) then
      FOnExecuteLog(vFrameSql);}
    vQuery.Close;
    vQuery.SQL.Text := vFrameSql;
    vQuery.Open;
    if vQuery.RecordCount = 1 then  // ��ѯ��Ψһ
    begin
      try
        vBLLInfo := vBLLInfo + vQuery.FieldByName('name').AsString;  // ҵ������
        // ȡ�����ҵ������ݿ����Ӷ���
        vBLLDataBaseID := vQuery.FieldByName('dbconnid').AsInteger;
        vBLLSql := vQuery.FieldByName('sqltext').AsString;
        if CheckBllDataBase then
        begin
          vFrameSql := '';
          vQuery.Close;
          vQuery.Connection := vBLLDataBase.Connection;

          vRecordCount := 0;

          if AMsgPack.B[BLL_BATCH] then  // ��������
          begin
            vBatchData := AMsgPack.ForcePathObject(BLL_BATCHDATA);
            vMemStream := TMemoryStream.Create;
            try
              vMemTable := TFDMemTable.Create(nil);
              try
                vBatchData.SaveBinaryToStream(vMemStream);
                vMemStream.Position := 0;
                vMemTable.LoadFromStream(vMemStream, TFDStorageFormat.sfBinary);
                if vMemTable.RecordCount > 0 then  // ����ִ��
                begin
                  vQuery.SQL.Text := vBLLSql;
                  vQuery.Params.ArraySize := vMemTable.RecordCount;
                  for i := 0 to vMemTable.RecordCount - 1 do
                  begin
                    for j := 0 to vQuery.Params.Count - 1 do
                    begin
                      vQuery.Params[j].Values[i] :=
                        vMemTable.SourceView.Rows[i].GetData(vQuery.Params[j].Name);
                    end;
                  end;

                  vQuery.Execute(vQuery.Params.ArraySize);

                  if Assigned(FOnExecuteLog) then
                  begin
                    FOnExecuteLog(vBLLInfo + sLineBreak + '��䣺' + vBLLSql + sLineBreak + '��������'
                      + vQuery.RowsAffected.ToString + '������');
                  end;
                end;
              finally
                FreeAndNil(vMemTable);
              end;
            finally
              FreeAndNil(vMemStream);
            end;
          end
          else  // ��������
          begin
            // ����Sql����е��滻����
            vReplaceParams := AMsgPack.ForcePathObject(BLL_REPLACEPARAM);
            for i := 0 to vReplaceParams.Count - 1 do
              vBLLSql := StringReplace(vBLLSql, '{' + vReplaceParams[i].NameEx + '}', vReplaceParams[i].AsString, [rfIgnoreCase]);

            // ����Sql����е��ֶβ���
            vQuery.SQL.Text := vBLLSql;
            if vQuery.Params.Count > 0 then  // ���ֶβ���
            begin
              vExecParams := AMsgPack.ForcePathObject(BLL_EXECPARAM);
              for i := 0 to vQuery.Params.Count - 1 do
              begin
                case vExecParams.ForcePathObject(vQuery.Params[i].Name).DataType of
                  mptString, mptInteger, mptBoolean, mptDouble, mptSingle:
                    vFrameSql := vFrameSql + sLineBreak + vQuery.Params[i].Name
                      + ' = ' + vExecParams.ForcePathObject(vQuery.Params[i].Name).AsString;

                  mptDateTime:
                    vFrameSql := vFrameSql + sLineBreak + vQuery.Params[i].Name + ' = '
                      + FormatDateTime('YYYY-MM-DD HH:mm:ss', vExecParams.ForcePathObject(vQuery.Params[i].Name).AsDateTime);
                else
                  vFrameSql := vFrameSql + sLineBreak + vQuery.Params[i].Name + ' =�ա�δ֪���������';
                end;

                vQuery.Params[i].Value := vExecParams.ForcePathObject(vQuery.Params[i].Name).AsVariant;
              end;
            end;

            if Assigned(FOnExecuteLog) then
            begin
              if vFrameSql <> '' then
                FOnExecuteLog(vBLLInfo + sLineBreak + '��䣺' + vBLLSql + sLineBreak + '������' + vFrameSql)
              else
                FOnExecuteLog(vBLLInfo + sLineBreak + '��䣺' + vBLLSql);
            end;

            if IsSelectSql(vBLLSql)
              or AMsgPack.B[BLL_BACKDATASET]
              or (AMsgPack.O[BLL_BACKFIELD] <> nil)
            then  // ��ѯ��
            begin
              vQuery.Open;
              vRecordCount := vQuery.RecordCount;
            end
            else
            begin
              vQuery.ExecSQL;
              vRecordCount := vQuery.RowsAffected;
            end;
          end;
        end;

        // ����ͻ�����Ҫ���ص����ݼ���ָ���ֶ�
        if AMsgPack.B[BLL_BACKDATASET] then  // �ͻ�����Ҫ�������ݼ�
        begin
          vMemStream := TMemoryStream.Create;
          try
            vQuery.SaveToStream(vMemStream, TFDStorageFormat.sfBinary);
            AMsgPack.ForcePathObject(BLL_DATASET).LoadBinaryFromStream(vMemStream);
          finally
            FreeAndNil(vMemStream);
          end;
        end
        else
        if (AMsgPack.O[BLL_BACKFIELD] <> nil) and (vRecordCount > 0) then  // �ͻ�����Ҫ����ָ���ֶ�
        begin
          vBackParam := AMsgPack.ForcePathObject(BLL_BACKFIELD);
          for i := 0 to vBackParam.Count - 1 do
            vBackParam.Items[i].AsVariant := vQuery.FieldByName(vBackParam.Items[i].NameLower).AsVariant;
        end;

        { �������ִ�н�������� }
        // �ȷ���Э�鶨��õ�
        AMsgPack.ForcePathObject(BLL_EXECPARAM).Clear;  // ���ͻ��˵���ʱ�����Ĳ���ֵ����������ٲ���Ҫ�Ļش�������
        AMsgPack.ForcePathObject(BLL_METHODRESULT).AsBoolean := True;  // �ͻ��˵��óɹ�
        AMsgPack.ForcePathObject(BLL_RECORDCOUNT).AsInteger := vRecordCount;
      except
        on E: Exception do
          DoBackErrorMsg('�쳣(�����)��ִ�з��� ' + vBLLInfo
            + sLineBreak + '��䣺' + vBLLSql + sLineBreak + '������' + vFrameSql + sLineBreak + '������Ϣ��' + E.Message);
      end;
    end
    else  // û�ҵ�ҵ���Ӧ�����
      DoBackErrorMsg('(�����)δ�ҵ�ȷ����ҵ��' + vBLLInfo + '��Ӧִ�����'
        + sLineBreak + '�汾��' + vVer.ToString);
  finally
    vQuery.Free;
  end;

  AMsgPack.Result := True;
end;

end.
