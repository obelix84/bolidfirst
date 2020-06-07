unit First;


interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, RTTI, IniFiles, TypInfo,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.ValEdit, Generics.Collections, System.Generics.Collections;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    RadioGroup1: TRadioGroup;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


   // Класс от коротого наследуемся, родитель
   {
    Наследуемся от этого класса, все объекты от него имеют 2 основных метода:
    procedure RestorePublishedProps(name: string
    function GetPublishedPropsToStrings(): TStrings;
    Т.е. каждый объект наследуемый от данного класса будет иметь возможность
    сохранять и восстанавливать свои published параметры.
    Сохранение было сделано в INI Файлы.
    Тут необходимо заметить, что можно было сделать некую "Обертку" на
    сохранение, чтобы в дальнейшем было легко заменить на храние в другом месте,
    в БД или реестре.
   }
   TParent = class(TObject)
    var
      //Словарь для хранения названия параметров и их значений
      PropsDict: TDictionary <string, TValue>;
    public
      procedure SavePublishedProps(); //Сохраняет в INI файлы публичные параметры
      //Восстанавливает параметры из INI файла, название передается в name
      procedure RestorePublishedProps(name: string);
      //Для работы с TMemo, для наглядности
      function GetPublishedPropsToStrings(): TStrings;
    private
      //Устанавливает значение параметра у по имени и значению НЕ ИСПОЛЬЗУЕТСЯ
      //Планироваловась для взаимодействия с объектами формы
      procedure SetPublishedPropByName(name: string; value: TValue); virtual;
      //Процедура заргужает в Словарь определенный выше (PropsDict) все
      //паблишед параметры
      procedure GetAllPublishedProps(); virtual;
      //Проверка параметра по имени на сущетвование, НЕ ИСПОЛЬЗУЕТСЯ
      //Планироваловась для взаимодействия с объектами формы
      function IsPropExist(name: string): boolean; virtual;
      //Выдает значение параметра по имени, НЕ ИСПОЛЬЗУЕТСЯ
      //Планироваловась для взаимодействия с объектами формы
      function GetPublishedPropByName(name: string): TValue; virtual;
      constructor Create();
      destructor Destroy();
    end;


  TChild1 = class(TParent)
    private
      FPriNumber : Integer;
    public
      Int : Integer;
      Ch : Char;
      I64: Int64;
      Fl: Double;
      Str : String;
      constructor Create();
      destructor Destroy();
    published
     property FPubNumber: Integer read Int write Int;
     property FSome: String read Str write Str;
     property FBigInt64: Int64 read I64 write I64;
     property FChar: Char read Ch write Ch;
     property FFloat: Double read Fl write Fl;
  end;

  TChild2 = class(TParent)
    private
    public
      Int : Integer;
      Ch : Char;
      I64: Int64;
      Fl: Double;
      Str : String;
      constructor Create();
      destructor Destroy();
    published
      property SPubNumber: Integer read Int write Int;
      property SSome: String read Str write Str;
      property SBigInt64: Int64 read I64 write I64;
      property SChar: Char read Ch write Ch;
      property SFloat: Double read Fl write Fl;
  end;

var
  Form1: TForm1;
  Child1: TChild1;
  Child2: TChild2;

implementation

{$R *.dfm}


{ TChild2 }

constructor TChild2.Create;
begin
      inherited;
      Int := 222200;
      Ch  := 'S';
      I64 := 123999999999999321;
      Fl  := 2.654321;
      Str := 'Объекст два';
end;

destructor TChild2.Destroy;
begin
  inherited;
end;

{ TChild1 }

constructor TChild1.Create;
begin
      inherited;
      Int := 1000000;
      Ch  := 'М';
      I64 := 99999999999999;
      Fl  := 0.123456;
      Str := 'Объекст Один';
end;


destructor TChild1.Destroy;
begin
  inherited;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  case Form1.RadioGroup1.ItemIndex of
    0:
      begin
        try
          Child1.SavePublishedProps();
        except
          on E: Exception do MessageDlg(E.Message + ' ' + IntToStr(E.HelpContext) ,mtError, mbOKCancel, 0);
        end;
      end;
    1:
      begin
        try
          Child2.SavePublishedProps();
        except
          on E: Exception do MessageDlg(E.Message + ' ' + IntToStr(E.HelpContext) ,mtError, mbOKCancel, 0);
        end;
      end;
  end;
end;

{ TParent }

procedure TParent.SavePublishedProps;
var
  SettingsFile : TCustomIniFile;
  Pair: TPair<string, TValue>;
begin
  Self.GetAllPublishedProps();
  SettingsFile := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.INI'), TEncoding.UTF8);
  SettingsFile.EraseSection(self.ClassName);
  try
    for Pair in PropsDict do
    begin
      case Pair.Value.Kind of
          tkInteger:
          begin
            SettingsFile.WriteInteger(self.ClassName, Pair.Key, Pair.Value.AsInteger);
            SettingsFile.UpdateFile;
          end;
          tkInt64:
          begin
            SettingsFile.WriteString(self.ClassName, Pair.Key, IntToStr(Pair.Value.AsInt64));
            SettingsFile.UpdateFile;
          end;
          tkstring, tkUString, tkLString, tkWString, tkChar, tkWChar:
          begin
            SettingsFile.WriteString(self.ClassName, Pair.Key, Pair.Value.AsString);
            SettingsFile.UpdateFile;
          end;
          tkFloat:
          begin
            SettingsFile.WriteFloat(self.ClassName, Pair.Key, Pair.Value.AsExtended);
            SettingsFile.UpdateFile;
          end;
      end;

    end;
  finally
    SettingsFile.Free;
  end;
end;

procedure TParent.SetPublishedPropByName(name: string; value: TValue);
var
  FRtti: TRttiContext;
  FTyp: TRttiType;
  FProp: TRttiProperty;
begin
  FRtti := TRttiContext.Create;
  FTyp := FRtti.GetType(self.ClassType);
  FProp := FTyp.GetProperty(name);
  FProp.SetValue(self, value);
  FRtti.Free;
end;

constructor TParent.Create;
begin
  PropsDict := TDictionary <string, TValue>.Create();
end;

destructor TParent.Destroy;
begin
  PropsDict.Destroy;
end;

procedure TParent.GetAllPublishedProps;
var
  FRtti: TRttiContext;
  FTyp: TRttiType;
  FProp: TRttiProperty;
  Value: TValue;
begin
  FRtti := TRttiContext.Create;
  FTyp := FRtti.GetType(self.ClassType);
  PropsDict.Clear();
  for FProp in FTyp.GetProperties do
  begin
    Value := FProp.GetValue(self);
    PropsDict.Add(Fprop.Name, Value);
  end;
FRtti.Free;
end;

function TParent.GetPublishedPropByName(name: string): TValue;
var
  FRtti: TRttiContext;
  FTyp: TRttiType;
  FProp: TRttiProperty;
  FValue: TValue;
begin
  FRtti := TRttiContext.Create;
  FTyp := FRtti.GetType(self.ClassType);
  FProp := FTyp.GetProperty(name);
  if FProp <> nil then
  begin
    FValue := FProp.GetValue(self);
  end;
  FRtti.Free;
  Result := FValue;
end;

function TParent.GetPublishedPropsToStrings: TStrings;
var
  FRtti: TRttiContext;
  FTyp: TRttiType;
  FProp: TRttiProperty;
  Value: TValue;
  PropsLines: TStrings;
  L: string;
begin
  FRtti := TRttiContext.Create;
  FTyp := FRtti.GetType(self.ClassType);
  PropsLines := TStringList.Create;
  for FProp in FTyp.GetProperties do
  begin
    Value := FProp.GetValue(self);
    case Value.Kind of
      tkInteger, tkInt64:
      begin
        L := FProp.Name + ': ' + IntToStr(Value.AsInt64);
      end;
      tkstring, tkUString, tkLString, tkWString, tkChar, tkWChar:
      begin
        L := FProp.Name + ': ' + Value.AsString;
      end;
      tkFloat:
      begin
        L := FProp.Name + ': ' + FloatToStr(Value.AsExtended);
      end;
    end;
    PropsLines.Add(L);
  end;
  Result := PropsLines;
  FRtti.Free;
end;

function TParent.IsPropExist(name: string): boolean;
var
  FRtti: TRttiContext;
  FTyp: TRttiType;
  FProp: TRttiProperty;
begin
  FRtti := TRttiContext.Create;
  FTyp := FRtti.GetType(self.ClassType);
  FProp := FTyp.GetProperty(name);
  if FProp <> nil then
  begin
    Result := True;
  end
  else
  begin
    Result := False;
  end;
  FRtti.Free;
end;

procedure TParent.RestorePublishedProps(name: string);
var
  SettingsFile : TCustomIniFile;
  FRtti: TRttiContext;
  FTyp: TRttiType;
  FProp: TRttiProperty;
  Value: TValue;
  V: TValue;
begin
  FRtti := TRttiContext.Create;
  FTyp := FRtti.GetType(self.ClassType);

  if FileExists(name) then
  begin
    SettingsFile := TMemIniFile.Create(name, TEncoding.UTF8);
    if SettingsFile.SectionExists(self.ClassName) then
    begin
      for FProp in FTyp.GetProperties do
      begin
        Value := FProp.GetValue(self);
        if SettingsFile.ValueExists(self.ClassName, FProp.Name) then
        begin
          case Value.Kind of
            tkInteger:
            begin
              V := SettingsFile.ReadInteger(self.ClassName, FProp.Name, 0);
              FProp.SetValue(self, V);
            end;
            tkInt64:
            begin
              V := SettingsFile.ReadString(self.ClassName, FProp.Name, '');
              FProp.SetValue(self, StrToInt64(V.AsString));
            end;
            tkstring, tkUString, tkLString, tkWString, tkChar, tkWChar:
            begin
              V := SettingsFile.ReadString(self.ClassName, FProp.Name, '');
              FProp.SetValue(self, V);
            end;
            tkFloat:
            begin
              V := SettingsFile.ReadFloat(self.ClassName, FProp.Name, 0);
              FProp.SetValue(self, V);
            end;
          end;
        end
        else
        begin
          ShowMessage('В файле нет данных для параметра ' + FProp.Name + '!');
        end;
      end;
    end
    else
    begin
      ShowMessage('Нет параметров для текущего объекта в Файле!');
    end;
  end
  else
  begin
    ShowMessage('Файла с параметрами не существует!');
  end;
  FRtti.Free;
  SettingsFile.Free;
end;

procedure TForm1.Button2Click(Sender: TObject);
var OpenDlg : TOpenDialog;
begin

  OpenDlg := TOpenDialog.Create(Self);
  OpenDlg.Filter :='*.INI';
  OpenDlg.InitialDir := ExtractFilePath(Application.ExeName);

  if OpenDlg.Execute then begin
    case Form1.RadioGroup1.ItemIndex of
    0:
      begin
        Child1.RestorePublishedProps(OpenDlg.FileName);
        Form1.Memo1.Clear;
        Form1.Memo1.Lines := Child1.GetPublishedPropsToStrings();
      end;
    1:
      begin
        Child2.RestorePublishedProps(OpenDlg.FileName);
        Form1.Memo1.Clear;
        Form1.Memo1.Lines := Child2.GetPublishedPropsToStrings();
      end;
    end;
  end;
  OpenDlg.Free;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Child1 := TChild1.Create;
  Child2 := TChild2.Create;

  case Form1.RadioGroup1.ItemIndex of
    0:
      Form1.Memo1.Lines := Child1.GetPublishedPropsToStrings();
    1:
      Form1.Memo1.Lines := Child2.GetPublishedPropsToStrings();
  end;
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin

  Memo1.Clear;
  case Form1.RadioGroup1.ItemIndex of
  0:
    Form1.Memo1.Lines := Child1.GetPublishedPropsToStrings();
  1:
    Form1.Memo1.Lines := Child2.GetPublishedPropsToStrings();
  end;
end;

end.
