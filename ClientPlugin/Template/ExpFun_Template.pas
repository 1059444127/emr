unit ExpFun_Template;

{******************************************************************************}
{                                                                              }
{                    ����ģ��������ʵ�ֵ�Ԫ hc 2018-1-18                     }
{                                                                              }
{                 ����������Ԫ��Ϊ������Ͳ�������ṩ���º�����               }
{                      1.GetPluginInfo��ȡ�����Ϣ                             }
{                      2.ExecFunction���ò��ĳ����                            }
{******************************************************************************}

interface

uses
  PluginIntf, FunctionIntf;

/// <summary>
/// ���ز����Ϣ��ע�����ṩ�Ĺ���
/// </summary>
/// <param name="AIPlugin">�����Ϣ</param>
procedure GetPluginInfo(const AIPlugin: IPlugin); stdcall;

/// <summary>
/// ж�ز��
/// </summary>
/// <param name="AIPlugin">�����Ϣ</param>
procedure UnLoadPlugin(const AIPlugin: IPlugin); stdcall;

/// <summary>
/// ִ�й���
/// </summary>
/// <param name="AIService">��������</param>
procedure ExecFunction(const AIFun: ICustomFunction); stdcall;

exports
   GetPluginInfo,
   ExecFunction,
   UnLoadPlugin;

implementation

uses
  FunctionImp, PluginConst, FunctionConst, Vcl.Forms, frm_Template;

// �����Ϣ��ע�Ṧ��
procedure GetPluginInfo(const AIPlugin: IPlugin); stdcall;
begin
  AIPlugin.Author := 'HC';  // ���ģ������
  AIPlugin.Comment := '���ģ������ҵ��';  // ���˵��
  AIPlugin.ID := PLUGIN_TEMPLATE; // ���GUID����Ψһ��ʶ
  AIPlugin.Name := '����ģ��ά��';  // ������ܻ�ҵ������
  AIPlugin.Version := '1.0.0';  // ����汾��
  //
  with AIPlugin.RegFunction(FUN_BLLFORMSHOW, '����ģ��ά��') do
    ShowEntrance := True;  // �ڽ�����ʾ�������
end;

procedure ExecFunction(const AIFun: ICustomFunction); stdcall;
var
  vID: string;
  vIFun: IFunBLLFormShow;
begin
  vID := AIFun.ID;
  if vID = FUN_BLLFORMSHOW then  // ��ʾҵ����
  begin
    vIFun := TFunBLLFormShow.Create;
    vIFun.AppHandle := (AIFun as IFunBLLFormShow).AppHandle;
    //Application.Handle := vIFun.AppHandle;
    vIFun.ShowEntrance := (AIFun as IFunBLLFormShow).ShowEntrance;  // ��ʾ��ڵ�
    vIFun.OnNotifyEvent := (AIFun as IFunBLLFormShow).OnNotifyEvent;  // ����¼�

    PluginShowTemplateForm(vIFun);
  end
  else
  if vID = FUN_BLLFORMDESTROY then  // ҵ����ر�
    PluginCloseTemplateForm;
end;

procedure UnLoadPlugin(const AIPlugin: IPlugin); stdcall;
begin
  PluginCloseTemplateForm;
end;

end.
