unit PluginIntf;

interface

uses
  Classes, FunctionIntf;

const
  PLUGIN_INFO = '{09A9DC5B-97FC-43D1-ACFD-B1E86D878238}';

type
  IPlugin = interface(IInterface)  // �����Ϣ
    [PLUGIN_INFO]
    /// <summary> ���ز����cpi�ļ���(��·��) </summary>
    /// <returns></returns>
    function GetFileName: string;
    procedure SetFileName(const AFileName: string);

    /// <summary> ���ز�� </summary>
    /// <param name="AFileName">����ļ���</param>
    /// <returns>True:���سɹ�,False����ʧ��</returns>
    procedure LoadPlugin;

    /// <summary> ж�ز�� </summary>
    /// <returns></returns>
    procedure UnLoadPlugin;

    procedure GetPluginInfo;

    /// <summary> ���ע��һ�������ⲿ�ṩ�Ĺ��� </summary>
    /// <param name="AID">����ΨһID</param>
    /// <param name="AName">��������</param>
    /// <returns>����ע��õĹ���</returns>
    function RegFunction(const AID, AName: ShortString): IPluginFunction;

    /// <summary> ���ִ��һ������ </summary>
    /// <param name="AIFun">����</param>
    procedure ExecFunction(const AIFun: ICustomFunction);

    /// <summary> ���ز���ṩ�Ĺ������� </summary>
    /// <returns>��������</returns>
    function GetFunctionCount: Integer;

    /// <summary> ���ز��ָ������ </summary>
    /// <param name="AIndex"></param>
    /// <returns></returns>
    function GetFunction(const AIndex: Integer): IPluginFunction; overload;
    function GetFunction(const AID: ShortString): IPluginFunction; overload;

    /// <summary> ���ز�������� </summary>
    /// <returns>����</returns>
    function GetAuthor: ShortString;

    /// <summary> ָ����������� </summary>
    /// <param name="Value">����</param>
    procedure SetAuthor(const Value: ShortString);

    /// <summary> ���ز����˵�� </summary>
    /// <returns>˵����Ϣ</returns>
    function GetComment: ShortString;

    /// <summary> ���ò����˵�� </summary>
    /// <param name="Value">˵����Ϣ</param>
    procedure SetComment(const Value: ShortString);

    /// <summary> ���ز����ΨһID </summary>
    /// <returns>ID</returns>
    function GetID: ShortString;

    /// <summary> ���ò����ΨһID(GUID) </summary>
    /// <param name="Value">GUID</param>
    procedure SetID(const Value: ShortString);

    /// <summary> ���ز���Ĺ��ܻ�ҵ������ </summary>
    /// <returns>���ܻ�ҵ������</returns>
    function GetName: ShortString;

    /// <summary> ���ò���Ĺ��ܻ�ҵ������ </summary>
    /// <param name="Value">���ܻ�ҵ������</param>
    procedure SetName(const Value: ShortString);

    /// <summary> ���ز���İ汾�� </summary>
    /// <returns>�汾��</returns>
    function GetVersion: ShortString;

    /// <summary> ���ò���İ汾�� </summary>
    /// <param name="Value">�汾��</param>
    procedure SetVersion(const Value: ShortString);

    // �ӿ�����
    property ID: ShortString read GetID write SetID;
    property Author: ShortString read GetAuthor write SetAuthor;
    property Comment: ShortString read GetComment write SetComment;
    property Name: ShortString read GetName write SetName;
    property Version: ShortString read GetVersion write SetVersion;
    property FunctionCount: Integer read GetFunctionCount;
    property FileName: string read GetFileName write SetFileName;
  end;

  TPluginList = class(TList);

  IPluginManager = interface(IInterface)
    ['{3B27642C-376E-4140-B5E0-B25AD258B7FC}']

    /// <summary> ����ָ��Ŀ¼��ָ����׺�������в�� </summary>
    /// <param name="APath">·��</param>
    /// <param name="AExt">��׺��</param>
    /// <returns></returns>
    function LoadPlugins(const APath, AExt: ShortString): Boolean;

    /// <summary> ����ָ���Ĳ�� </summary>
    /// <param name="AFileName">����ļ���</param>
    /// <returns>True�����سɹ���False������ʧ��</returns>
    function LoadPlugin(const AFileName: ShortString): Boolean;

    function UnLoadPlugin(const APluginID: ShortString): Boolean;

    /// <summary> ���ݲ��ID��ȡ��� </summary>
    /// <param name="APluginID">���ID</param>
    /// <returns></returns>
    function GetPlugin(const APluginID: ShortString): IPlugin;

    /// <summary> ���ز���б� </summary>
    /// <returns>����б�</returns>
    function PluginList: TPluginList;

    /// <summary> ������� </summary>
    /// <returns>�������</returns>
    function Count: Integer;

    /// <summary> �����в���㲥һ������ </summary>
    procedure FunBroadcast(const AFun: ICustomFunction);

    /// <summary> ж�����в�� </summary>
    /// <returns></returns>
    function UnLoadAllPlugin: Boolean;
  end;

implementation

end.
