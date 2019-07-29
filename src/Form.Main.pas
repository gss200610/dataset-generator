unit Form.Main;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.DBCtrls, Vcl.ComCtrls,
  Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait, FireDAC.DApt,

  Action.CreateMemTable;

type
  TForm1 = class(TForm)
    DataSource1: TDataSource;
    Timer1: TTimer;
    DBGrid1: TDBGrid;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDQuery1OrderID: TFDAutoIncField;
    FDQuery1CustomerID: TStringField;
    FDQuery1CompanyName: TStringField;
    FDQuery1EmployeeID: TIntegerField;
    FDQuery1EmployeeName: TWideStringField;
    FDQuery1OrderDate: TDateTimeField;
    FDQuery1RequiredDate: TDateTimeField;
    FDQuery1ShippedDate: TDateTimeField;
    FDQuery1ShipVia: TIntegerField;
    FDQuery1Freight: TCurrencyField;
    PageControl1: TPageControl;
    tshData: TTabSheet;
    tshCode: TTabSheet;
    Memo1: TMemo;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    actCreateMemTable: TCreateMemTableAction;
    function CreateSimpleMemTable: TFDMemTable;
    function CreateSqlQuery: TFDQuery;
    procedure GenerateDataAndCodeFromDataSet(ds: TDataSet);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function TForm1.CreateSimpleMemTable: TFDMemTable;
var
  ds: TFDMemTable;
begin
  ds := TFDMemTable.Create(Self);
  with ds do
  begin
    // FieldDefs.Add('bDelete', ftBoolean);
    FieldDefs.Add('id', ftInteger);
    FieldDefs.Add('text1', ftWideString, 30);
    FieldDefs.Add('date1', ftDate);
    FieldDefs.Add('float1', ftFloat);
    FieldDefs.Add('currency1', ftCurrency);
    CreateDataSet;
    AppendRecord([1, 'Ala ma kota', EncodeDate(2019, 09, 16), 1.2, 1200]);
    AppendRecord([2, 'Ala ma kota', System.Variants.Null, Null, 950]);
  end;
  ds.First;
  Result := ds;
end;

function TForm1.CreateSqlQuery: TFDQuery;
begin
  Result := TFDQuery.Create(Self);
  Result.Connection := FDConnection1;
  Result.Open('SELECT Orders.OrderID,  Orders.CustomerID,' +
    '   Customers.CompanyName, Orders.EmployeeID, ' +
    '   Employees.FirstName||'' ''||Employees.LastName EmployeeName,' +
    '   Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate,' +
    '   Orders.ShipVia, Orders.Freight' + ' FROM {id Orders} Orders ' +
    '   INNER JOIN {id Employees} Employees' +
    '     ON Orders.EmployeeID = Employees.EmployeeID ' +
    '   INNER JOIN {id Customers} Customers' +
    '     ON Orders.CustomerID = Customers.CustomerID ' +
    ' WHERE {year(OrderDate)} = 1997 ORDER BY Orders.OrderID ');
end;

procedure TForm1.GenerateDataAndCodeFromDataSet(ds: TDataSet);
begin
  DataSource1.DataSet := actCreateMemTable.CreateFDMemTable(ds);
  actCreateMemTable.GenerateCode(ds);
  Memo1.Lines := actCreateMemTable.Code;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  actCreateMemTable := TCreateMemTableAction.Create(Self);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  // GenerateDataAndCodeFromDataSet(CreateSimpleMemTable);
  GenerateDataAndCodeFromDataSet(CreateSqlQuery);
end;

end.