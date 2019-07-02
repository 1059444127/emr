{*******************************************************}
{                                                       }
{         ����HCView�ĵ��Ӳ�������  ���ߣ���ͨ          }
{                                                       }
{ �˴������ѧϰ����ʹ�ã�����������ҵĿ�ģ��ɴ�������  }
{ �����ʹ���߳е�������QQȺ 649023932 ����ȡ����ļ��� }
{ ������                                                }
{                                                       }
{*******************************************************}

unit frm_Paragraph;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, HCEmrView;

type
  TfrmParagraph = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    lbl9: TLabel;
    lbl10: TLabel;
    btnOk: TButton;
    clrbxBG: TColorBox;
    cbbAlignHorz: TComboBox;
    cbbAlignVert: TComboBox;
    cbbSpaceMode: TComboBox;
    edtFirstIndent: TEdit;
    edtLeftIndent: TEdit;
    edtRightIndent: TEdit;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetView(const AHCView: THCEmrView);
    procedure SetGridView(const AGridView: THCEmrView);
  end;

var
  frmParagraph: TfrmParagraph;

implementation

uses
  HCParaStyle;

{$R *.dfm}

procedure TfrmParagraph.btnOkClick(Sender: TObject);
begin
  Self.ModalResult := mrOk;
end;

procedure TfrmParagraph.SetGridView(const AGridView: THCEmrView);
begin

end;

procedure TfrmParagraph.SetView(const AHCView: THCEmrView);
begin
  cbbSpaceMode.ItemIndex := Ord(AHCView.Style.ParaStyles[AHCView.CurParaNo].LineSpaceMode);
  cbbAlignHorz.ItemIndex := Ord(AHCView.Style.ParaStyles[AHCView.CurParaNo].AlignHorz);
  cbbAlignVert.ItemIndex := Ord(AHCView.Style.ParaStyles[AHCView.CurParaNo].AlignVert);
  clrbxBG.Color := AHCView.Style.ParaStyles[AHCView.CurParaNo].BackColor;

  Self.ShowModal;
  if Self.ModalResult = mrOk then
  begin
    AHCView.BeginUpdate;
    try
      AHCView.ApplyParaLineSpace(TParaLineSpaceMode(cbbSpaceMode.ItemIndex));
      AHCView.ApplyParaAlignHorz(TParaAlignHorz(cbbAlignHorz.ItemIndex));
      AHCView.ApplyParaAlignVert(TParaAlignVert(cbbAlignVert.ItemIndex));
      AHCView.ApplyParaBackColor(clrbxBG.Color);
    finally
      AHCView.EndUpdate;
    end;
  end;
end;

end.
