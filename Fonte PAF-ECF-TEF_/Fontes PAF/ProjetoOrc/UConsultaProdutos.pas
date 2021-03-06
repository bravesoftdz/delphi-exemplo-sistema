unit UConsultaProdutos;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, DBGrids, DB, RXCtrls, Mask, ComCtrls,
  ExtCtrls, DBCtrls, ToolWin;

type
  TFPesquisaProdutos = class(TForm)
    DBGrid: TDBGrid;
    dsPesqProdutos: TDataSource;
    SB: TStatusBar;
    ToolBar1: TToolBar;
    GroupBox1: TGroupBox;
    BtConsulta: TSpeedButton;
    CPesquisa: TComboBox;
    EPesquisa: TMaskEdit;
    Panel1: TPanel;
    RxLabel1: TRxLabel;
    Label5: TLabel;
    DBText5: TDBText;
    Label6: TLabel;
    DBText6: TDBText;
    Label4: TLabel;
    DBText4: TDBText;
    Label7: TLabel;
    DBText8: TDBText;
    Label10: TLabel;
    DBText1: TDBText;
    Bevel1: TBevel;
    procedure FormShow(Sender: TObject);
    procedure EPesquisaKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGridKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EPesquisaEnter(Sender: TObject);
    procedure EPesquisaExit(Sender: TObject);
    procedure EPesquisaKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure DBGridKeyPress(Sender: TObject; var Key: Char);
    procedure CPesquisaKeyPress(Sender: TObject; var Key: Char);
    procedure BtConsultaClick(Sender: TObject);
    procedure EPesquisaChange(Sender: TObject);
    procedure DBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
    vConsultando : Boolean;
    procedure SelecionaColuna(Sender: TObject);
  end;

var
  FPesquisaProdutos: TFPesquisaProdutos;

implementation

uses USelecionaPreco, UDM, UOrcamento, UBarsa;

{$R *.dfm}

procedure TFPesquisaProdutos.SelecionaColuna(Sender: TObject);
var
   I, vColunaSelecionada : Integer;
begin
    if vConsultando
    then begin
           if sPrecoTabela='V'
           then vColunaSelecionada:=4
           else vColunaSelecionada:=5;

           For i := 0 to DBGrid.Columns.count-1
           do begin
              DBGrid.Columns[i].Color := clWhite;
              DBGrid.Columns[i].Font.Color := clBlack;
              //DBGrid.Columns[i].Font.Style := [FSBold];
              DBGrid.Columns[i].Font.Style := [];
              end;
              DBGrid.Columns[vColunaSelecionada].Color := clYellow;
              DBGrid.Columns[vColunaSelecionada].Font.Color := clBlack;
              //DBGrid.Columns[vColunaSelecionada].Font.Style := [FSBold];
              DBGrid.Columns[vColunaSelecionada].Font.Style := [];

         FPesquisaProdutos.Refresh;
         end;
end;         

procedure TFPesquisaProdutos.FormShow(Sender: TObject);
begin
     if Status_Serv='ON'
     then begin
           dsPesqProdutos.DataSet:=DM.TPesqProduto;
           if PackedRecords_Produtos='-1'
           then begin
                DM.TPesqProduto.FetchOnDemand:=True;
                DM.TPesqProduto.PacketRecords:=-1;
                end
           else begin
                DM.TPesqProduto.FetchOnDemand:=False;
                DM.TPesqProduto.PacketRecords:=StrToInt(PackedRecords_Produtos)
                end;

           if not vConsultando
           then begin
                EPesquisa.Text:='';
                if DM.TEmpresaPADRAOBUSCA.Value='B'//C�digo de Barras
                then CPesquisa.ItemIndex:=2
                else CPesquisa.ItemIndex:=0;
                EPesquisa.Clear;
                EPesquisa.SetFocus;
                end
           else begin
                if DM.TEmpresaPADRAOBUSCA.Value='R'//Refer�ncia
                then CPesquisa.ItemIndex:=1
                else CPesquisa.ItemIndex:=0;

                EPesquisa.SetFocus;
                EPesquisa.Selstart:= Length(EPesquisa.text);
                end;
           end
      else begin//Servidor Off
           CarregaEstoqueOff;
           dsPesqProdutos.DataSet:=DM.TPesqProdutoTemp;

           BtConsulta.Enabled:=False;

           EPesquisa.SetFocus;
           EPesquisa.Selstart:= Length(EPesquisa.text);
           end;

    SelecionaColuna(Nil);

end;

procedure TFPesquisaProdutos.EPesquisaKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
     if key=40  // seta para baixo
     then DBGrid.SetFocus;
end;

procedure TFPesquisaProdutos.DBGridKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
      if (key >= 49) and (key <= 105)
      then begin
           EPesquisa.Text:='';
           EPesquisa.text := EPesquisa.Text+Chr(key);
           EPesquisa.SetFocus;
           EPesquisa.Selstart:= Length(EPesquisa.Text);
           end;
end;

procedure TFPesquisaProdutos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if key = VK_ESCAPE
     then FPesquisaProdutos.Close;

     if (Shift = [ssAlt])
     then begin
           if Key=80//P
           then begin
                 if vConsultando
                 then begin
                     Try
                        if FClassificaPreco=Nil
                        then Application.CreateForm(TFClassificaPreco,FClassificaPreco);
                        FClassificaPreco.ShowModal;
                     Finally
                        FClassificaPreco.Release;
                        FClassificaPreco:=nil;
                        end;
                     end;
                end;
           end;

     if Key=VK_F6
     then begin
          EPesquisa.Clear;
          CPesquisa.ItemIndex:=0;
          EPesquisa.SetFocus;
          end
     else if Key=VK_F7
     then begin
          EPesquisa.Clear;
          CPesquisa.ItemIndex:=1;
          EPesquisa.SetFocus;
          end
     else if Key=VK_F8
     then begin
          EPesquisa.Clear;
          CPesquisa.ItemIndex:=2;
          EPesquisa.SetFocus;
          end
     else if Key=VK_F9
     then begin
          EPesquisa.Clear;
          CPesquisa.ItemIndex:=3;
          EPesquisa.SetFocus;
          end;
end;

procedure TFPesquisaProdutos.EPesquisaEnter(Sender: TObject);
begin
     if (Sender is TMaskEdit) then
     TMaskEdit(Sender).Color:=$0080FFFF;
end;

procedure TFPesquisaProdutos.EPesquisaExit(Sender: TObject);
begin
     if (Sender is TMaskEdit) then
     TMaskEdit(Sender).Color:=clWindow;
end;

procedure TFPesquisaProdutos.EPesquisaKeyPress(Sender: TObject;
  var Key: Char);
begin
     if Key=#13
     then begin
          if Status_Serv='ON'
          then begin
               if Auto_Pesq_Produtos='S'
               then DBGrid.SetFocus
               else BtConsultaClick(Sender);
               end
          else DBGrid.SetFocus;
          end;
end;

procedure TFPesquisaProdutos.FormKeyPress(Sender: TObject; var Key: Char);
begin
     TabEnter(FPesquisaProdutos,Key);
end;

procedure TFPesquisaProdutos.DBGridKeyPress(Sender: TObject;
  var Key: Char);
begin
     if Key=#13
     then ModalResult:=MrOk;
end;

procedure TFPesquisaProdutos.CPesquisaKeyPress(Sender: TObject;
  var Key: Char);
begin
     if Key=#13
     then Key:=#0;
end;

procedure TFPesquisaProdutos.BtConsultaClick(Sender: TObject);
begin
     if Trim(EPesquisa.text)<>''
     then begin
          AC;
          DM.TPesqProduto.Close;
          if CPesquisa.ItemIndex=0//Descricao
          then begin
               if Busca_Contenha_Prod='S'
               then DM.TPesqProduto.Params[0].Value:='%'+EPesquisa.Text+'%'
               else DM.TPesqProduto.Params[0].Value:=EPesquisa.Text+'%';
               DM.TPesqProduto.Params[1].AsString:='-1';
               DM.TPesqProduto.Params[2].AsString:='-1';
               DM.TPesqProduto.Params[3].AsInteger:=-1;
               end
          else if CPesquisa.ItemIndex=1//Refer�ncia
          then begin
               DM.TPesqProduto.Params[0].AsString:='-1';
               if Busca_Contenha_Prod='S'
               then DM.TPesqProduto.Params[1].Value:=EPesquisa.Text+'%'
               else DM.TPesqProduto.Params[1].Value:='%'+EPesquisa.Text+'%';
               DM.TPesqProduto.Params[2].AsString:='-1';
               DM.TPesqProduto.Params[3].AsInteger:=-1;
               end
          else if CPesquisa.ItemIndex=2//C�digo de Barras
          then begin
               DM.TPesqProduto.Params[0].AsString:='-1';
               DM.TPesqProduto.Params[1].AsString:='-1';
               DM.TPesqProduto.Params[2].AsString:=EPesquisa.Text;
               DM.TPesqProduto.Params[3].AsInteger:=-1;
               end
          else if CPesquisa.ItemIndex=3//C�digo Interno
          then begin
               DM.TPesqProduto.Params[0].AsString:='-1';
               DM.TPesqProduto.Params[1].AsString:='-1';
               DM.TPesqProduto.Params[2].AsString:='-1';
               DM.TPesqProduto.Params[3].AsInteger:=StrToInt(EPesquisa.Text);
               end;
          DM.TPesqProduto.Params[4].Value:='N';
          DM.TPesqProduto.IndexFieldNames:='DESCRICAO';
          DM.TPesqProduto.Open;

          if Auto_Pesq_Produtos='N'
          then begin
               if DM.TPesqProduto.RecordCount = 0
               then EPesquisa.SetFocus;
               end;

     SB.Panels[0].Text:='Ocorr�ncias encontradas: '+StrZero(DM.TPesqProduto.RecordCount,6);

     DC;
     end;
end;

procedure TFPesquisaProdutos.EPesquisaChange(Sender: TObject);
begin
     if Status_Serv='ON'
     then begin
          if Auto_Pesq_Produtos='S'
          then BtConsultaClick(Sender);
          end
     else begin
          if DM.TPesqProdutoTemp.Active
          then begin
               if CPesquisa.ItemIndex=0
               then DM.TPesqProdutoTemp.IndexFieldNames:='DESCRICAO'
               else if CPesquisa.ItemIndex=1
               then DM.TPesqProdutoTemp.IndexFieldNames:='REFERENCIA'
               else if CPesquisa.ItemIndex=2
               then DM.TPesqProdutoTemp.IndexFieldNames:='CODBARRA'
               else if CPesquisa.ItemIndex=3
               then DM.TPesqProdutoTemp.IndexFieldNames:='CODIGO';

               DM.TPesqProdutoTemp.FindNearest([EPesquisa.Text]);
               end;
          end;
end;

procedure TFPesquisaProdutos.DBGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
    if not odd(dsPesqProdutos.DataSet.RecNo)
    then begin
         if not (gdselected in state)
         then begin
              DBGrid.Canvas.Brush.Color := $00F0F0F0;
              DBGrid.Canvas.FillRect(Rect);
              DBGrid.DefaultDrawDataCell(rect, Column.Field, State);
              end;
         end;
end;

end.

