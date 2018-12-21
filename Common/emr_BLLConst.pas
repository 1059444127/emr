{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit emr_BLLConst;

interface

uses
  SysUtils;

const
  BLLVERSION = 1;  // ҵ��汾

  BLL_CMD = 'b.cmd';
  //BACKDATA = 'p.data';  // ���ڷ��ص��÷������ص����ݼ�
  BLL_PROXYTYPE = 'b.type';  // �����������
  BLL_VER = 'b.ver';  // ҵ��汾
  BLL_METHODRESULT = 'b.ret';  // ����˷������ظ��ͻ��˵ķ���ִ���Ƿ�ɹ�
  BLL_RECORDCOUNT = 'b.rcount';  // ��ŷ���˷���ִ��ʱ���ݼ��ĸ���
  BLL_METHODMSG = 'b.msg';  // ����˷�����ִ��ʱ�ش������ͻ��˵���Ϣ(��ʧ��ԭ���)
  BLL_EXECPARAM = 'b.exp';  // ��ſͻ��˵���ҵ��ʱ���ݵģ�Sql�ֶβ�������
  BLL_REPLACEPARAM = 'b.rep';  // ��ſͻ��˵���ҵ��ʱ���ݵģ�Sql�滻��������

  BLL_BATCH = 'b.bat';  // ��ſͻ��˵���ҵ��ʱ�Ƿ�����������
  BLL_BATCHDATA = 'b.batdata';  // ��ſͻ��˵���ҵ��ʱ�������ݵ����ݼ�

  BLL_BACKDATASET = 'b.bkds';  // ��ſͻ��˵���ҵ��ʱ���ݵģ�֪ͨ�������Ҫ�������ݼ�(���ȼ�����BLLBACKPARAM)
  BLL_DATASET = 'b.ds';   // ��ſͻ��˵���ҵ��ʱ���ݵģ�����˷��ص����ݼ�
  BLL_BACKFIELD = 'b.field';  // ��ſͻ��˵���ҵ��ʱ���ݵģ�֪ͨ��Ҫ���ص������ֶ�(���ȼ�����BLLBACKDATA)
  BLL_DEVICE = 'b.dc';      // ���ӷ���˵��豸����
  BLL_DEVICEINFO = 'b.dcf'; // ���ӷ���˵��豸��Ϣ
  BLL_ERROR = 'b.err';  // ������Ϣ��������ҵ��ʧ��ʱ������ô���ʾ

  /// <summary> ��ȡ��������ǰʱ�� </summary>
  BLL_SRVDT = 1;

  /// <summary> ִ��Sql��� </summary>
  BLL_EXECSQL = 2;

  /// <summary> ��ȡ���б�ͱ�˵�� </summary>
  BLL_GETAllTABLE = 3;

  BLL_BASE = 1000;  // ҵ������ʼֵ

  { ҵ����(��1000��ʼ) }
  /// <summary> ȫ���û� </summary>
  BLL_COMM_ALLUSER = BLL_BASE;

  /// <summary> �˶Ե�¼��Ϣ </summary>
  BLL_LOGIN = BLL_BASE + 1;

  /// <summary> ��ȡָ���û���Ϣ </summary>
  BLL_GETUSERINFO = BLL_BASE + 2;

  /// <summary> ��ȡ�û��Ĺ����� </summary>
  BLL_GETUSERGROUPS = BLL_BASE + 3;

  /// <summary> ��ȡ�û��Ľ�ɫ </summary>
  BLL_GETUSERROLES = BLL_BASE + 4;

  /// <summary> ��ȡָ���û����õ����й��� </summary>
  BLL_GETUSERFUNS = BLL_BASE + 5;

  /// <summary> ��ȡָ���û����й������Ӧ�Ŀ��� </summary>
  BLL_GETUSERGROUPDEPTS = BLL_BASE + 6;

  /// <summary> ��ȡ���� </summary>
  BLL_COMM_GETPARAM = BLL_BASE + 7;

  /// <summary> ��ȡ����˻�������� </summary>
  BLL_GETCLIENTCACHE = BLL_BASE + 8;

  /// <summary> ��ȡָ��������������Ȩ�޿��ƵĿؼ� </summary>
  BLL_GETCONTROLSAUTH = BLL_BASE + 9;

  /// <summary> ��ȡҪ���������°汾�� </summary>
  BLL_GETLASTVERSION = BLL_BASE + 10;

  /// <summary> ��ȡҪ�������ļ� </summary>
  BLL_GETUPDATEINFO = BLL_BASE + 11;

  /// <summary> �ϴ�������Ϣ </summary>
  BLL_UPLOADUPDATEINFO = BLL_BASE + 12;

  /// <summary> ��ȡ��Ժ���� </summary>
  BLL_HIS_GETINPATIENT = BLL_BASE + 13;

  /// <summary> ��ȡ���ݼ�(��Ŀ¼)��Ϣ </summary>
  BLL_GETDATAELEMENTSETROOT = BLL_BASE + 14;

  /// <summary> ��ȡ���ݼ�(ȫĿ¼)��Ϣ </summary>
  BLL_GETDATAELEMENTSETALL = BLL_BASE + 15;

  /// <summary> ��ȡָ�����ݼ���Ӧ��ģ�� </summary>
  BLL_GETTEMPLATELIST = BLL_BASE + 16;

  /// <summary> �½�ģ�� </summary>
  BLL_NEWTEMPLATE = BLL_BASE + 17;

  /// <summary> ��ȡģ������ </summary>
  BLL_GETTEMPLATECONTENT = BLL_BASE + 18;

  /// <summary> ����ģ������ </summary>
  BLL_SAVETEMPLATECONTENT = BLL_BASE + 19;

  /// <summary> ɾ��ģ�弰���� </summary>
  BLL_DELETETEMPLATE = BLL_BASE + 20;

  /// <summary> ��ȡ����Ԫ </summary>
  BLL_GETDATAELEMENT = BLL_BASE + 21;

  /// <summary> ��ȡ����Ԫֵ��ѡ�� </summary>
  BLL_GETDOMAINITEM = BLL_BASE + 22;

  /// <summary> ��������Ԫѡ��ֵ���Ӧ������ </summary>
  BLL_SAVEDOMAINITEMCONTENT = BLL_BASE + 23;

  /// <summary> ��ȡ����Ԫѡ��ֵ���Ӧ������ </summary>
  BLL_GETDOMAINITEMCONTENT = BLL_BASE + 24;

  /// <summary> ɾ������Ԫѡ��ֵ���Ӧ������ </summary>
  BLL_DELETEDOMAINITEMCONTENT = BLL_BASE + 25;

  /// <summary> ��ȡָ����סԺ���߲����б� </summary>
  BLL_GETINCHRECORDLIST = BLL_BASE + 26;

  /// <summary> �½�סԺ���� </summary>
  BLL_NEWINCHRECORD = BLL_BASE + 27;

  /// <summary> ��ȡָ��סԺ�������� </summary>
  BLL_GETINCHRECORDCONTENT = BLL_BASE + 28;

  /// <summary> ����ָ��סԺ�������� </summary>
  BLL_SAVERECORDCONTENT = BLL_BASE + 29;

  /// <summary> ��ȡָ���������ݼ�(��Ŀ¼)��Ӧ�Ĳ������� </summary>
  BLL_GETDESETRECORDCONTENT = BLL_BASE + 30;

  /// <summary> ɾ��ָ����סԺ���� </summary>
  BLL_DELETEINCHRECORD = BLL_BASE + 31;

  /// <summary> ��ȡָ������Ԫ��������Ϣ </summary>
  BLL_GETDEPROPERTY = BLL_BASE + 32;

  /// <summary> סԺ����ǩ�� </summary>
  BLL_INCHRECORDSIGNATURE = BLL_BASE + 33;

  /// <summary> ��ȡסԺ����ǩ����Ϣ </summary>
  BLL_GETINCHRECORDSIGNATURE = BLL_BASE + 34;

  /// <summary> ��ȡģ����Ϣ </summary>
  BLL_GETTEMPLATEINFO = BLL_BASE + 35;

  /// <summary> �޸�ģ����Ϣ </summary>
  BLL_SETTEMPLATEINFO = BLL_BASE + 36;

  /// <summary> ��ȡָ������Ԫ��Ϣ </summary>
  BLL_GETDEINFO = BLL_BASE + 37;

  /// <summary> �޸�ָ������Ԫ��Ϣ </summary>
  BLL_SETDEINFO = BLL_BASE + 38;

  /// <summary> �½�����Ԫ </summary>
  BLL_NEWDE = BLL_BASE + 39;

  /// <summary> ɾ������Ԫ </summary>
  BLL_DELETEDE = BLL_BASE + 40;

  /// <summary> ��ȡָ����Ԫֵ��ѡ�� </summary>
  BLL_GETDOMAINITEMINFO = BLL_BASE + 41;

  /// <summary> �޸�����Ԫֵ��ѡ�� </summary>
  BLL_SETDOMAINITEMINFO = BLL_BASE + 42;

  /// <summary> �½�����Ԫֵ��ѡ�� </summary>
  BLL_NEWDOMAINITEM = BLL_BASE + 43;

  /// <summary> ɾ������Ԫֵ��ѡ�� </summary>
  BLL_DELETEDOMAINITEM = BLL_BASE + 44;

  /// <summary> ��ȡ����ֵ�� </summary>
  BLL_GETDOMAIN = BLL_BASE + 45;

  /// <summary> �½�ֵ�� </summary>
  BLL_NEWDOMAIN = BLL_BASE + 46;

  /// <summary> �޸�ֵ�� </summary>
  BLL_SETDOMAIN = BLL_BASE + 47;

  /// <summary> ɾ��ֵ�� </summary>
  BLL_DELETEDOMAIN = BLL_BASE + 48;

  /// <summary> ɾ��ֵ���Ӧ������ѡ�� </summary>
  BLL_DELETEDOMAINALLITEM = BLL_BASE + 49;

  /// <summary> ��ȡ���ݼ���������������Ԫ </summary>
  BLL_GETDATASETELEMENT = BLL_BASE + 50;

//  function GetBLLMethodName(const AMethodID: Integer): string;

implementation

//function GetBLLMethodName(const AMethodID: Integer): string;
//begin
//  case AMethodID of
//    BLL_SRVDT: Result := 'BLL_SRVDT(1 ��ȡ���ݿ�ʱ��)';
//    BLL_EXECSQL: Result := 'BLL_EXECSQL(2 ִ��Sql���)';
//    BLL_GETAllTABLE: Result := 'BLL_GETAllTABLE(3 ��ȡ���б�ͱ�˵��)';
//    BLL_LOGIN: Result := 'BLL_LOGIN(1001 �˶Ե�¼��Ϣ)';
//    BLL_GETUSERINFO: Result := 'BLL_GETUSERINFO(1002 ��ȡָ���û�����Ϣ)';
//    BLL_GETUSERGROUPS: Result := 'BLL_GETUSERGROUPS(1003 ��ȡ�û��Ĺ�����)';
//    BLL_GETUSERROLES: Result := 'BLL_GETUSERROLES(1004 ��ȡ�û��Ľ�ɫ)';
//    BLL_GETUSERFUNS: Result := 'BLL_GETUSERFUNS(1005 ��ȡָ���û����õ����й���)';
//    BLL_GETUSERGROUPDEPTS: Result := 'BLL_GETUSERGROUPDEPTS(1006 ��ȡָ���û����й������Ӧ�Ŀ���)';
//    BLL_COMM_GETPARAM: Result := 'BLL_COMM_GETPARAM(1007 ��ȡ����)';
//    BLL_GETCLIENTCACHE: Result := 'BLL_GETCLIENTCACHE(1008 ��ȡ����˻��������)';
//    BLL_GETCONTROLSAUTH: Result := 'BLL_GETCONTROLSAUTH(1009 ��ȡָ��������������Ȩ�޿��ƵĿؼ�)';
//    BLL_GETLASTVERSION: Result := 'BLL_GETLASTVERSION(1010 ��ȡҪ���������°汾��)';
//    BLL_GETUPDATEINFO: Result := 'BLL_GETUPDATEINFO(1011 ��ȡҪ�������ļ�)';
//    BLL_UPLOADUPDATEINFO: Result := 'BLL_UPLOADUPDATEINFO(1012 �ϴ�������Ϣ)';
//    BLL_HIS_GETINPATIENT: Result := 'BLL_HIS_GETPATIENT(1013 ��ȡ��Ժ����)';
//    BLL_GETDATAELEMENTSET: Result := 'BLL_GETDATAELEMENTSET(1014 ��ȡ���ݼ�Ŀ¼)';
//    BLL_GETTEMPLATELIST: Result := 'BLL_GETTEMPLATELIST(1015 ��ȡģ�����������ӷ����ģ��)';
//    BLL_NEWTEMPLATE: Result := 'BLL_NEWTEMPLATE(1016 �½�ģ��)';
//    BLL_GETTEMPLATECONTENT: Result := 'BLL_GETTEMPLATECONTENT(1017 ��ȡģ������)';
//    BLL_SAVETEMPLATECONTENT: Result := 'BLL_SAVETEMPLATECONTENT(1018 ����ģ������)';
//    BLL_DELETETEMPLATE: Result := 'BLL_DELETETEMPLATE(1019 ɾ��ģ�弰����)';
//    BLL_GETDATAELEMENT: Result := 'BLL_GETDATAELEMENT(1020 ��ȡ����Ԫ�б�)';
//    BLL_GETDATAELEMENTDOMAIN: Result := 'BLL_GETDATAELEMENTDOMAIN(1021 ��ȡ����Ԫֵ��ѡ��)';
//    BLL_SAVEDOMAINCONTENT: Result := 'BLL_SAVEDOMAINCONTENT(1022 ��������Ԫѡ��ֵ���Ӧ������)';
//    BLL_GETDOMAINCONTENT: Result := 'BLL_GETDOMAINCONTENT(1023 ��ȡ����Ԫѡ��ֵ���Ӧ������)';
//    BLL_GETINCHRECORDLIST: Result := 'BLL_GETINCHRECORDLIST(1024 ��ȡָ����סԺ���߲����б�)';
//    BLL_NEWINCHRECORD: Result := 'BLL_NEWINCHRECORD(1025 �½�סԺ����)';
//    BLL_GETINCHRECORDCONTENT: Result := 'BLL_GETINCHRECORDCONTENT(1026 ��ȡָ��סԺ��������)';
//    BLL_SAVERECORDCONTENT: Result := 'BLL_SAVERECORDCONTENT(1027 ����ָ��סԺ��������)';
//  else
//    Result := 'δ����[' + IntToStr(AMethodID) + ']';
//  end;
//end;

end.
