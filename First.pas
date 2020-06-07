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


   TParent = class(TObject)
    // Класс от коротого наследуемся, родитель
    var
      PropsDict: TDictionary <string, TValue>;
    public
      procedure SavePublishedProps();
      procedure RestorePublishedProps(name: string);
      function GetPublishedPropsToStrings(): TStrings;
    private
      procedure SetPublishedPropByName(name: string; value: TValue); virtual;
      procedure GetAllPublishedProps(); virtual;
      function IsPropExist(name: string): boolean; virtual;
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
      function Test():string;
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

function TChild1.Test: string;
var
  Ch1: TChild1;
  Ch2: TChild2;
  FRtti: TRttiContext;
  FTyp: TRttiType;
  FProp: TRttiProperty;
  Value: TValue;
begin
ShowMessage('1');
  self.GetAllPublishedProps();
  {Value := self.GetPublishedPropByName('FPubNumber');
  ShowMessage('Exit');
  ShowMessage(IntToStr(Value.AsInteger));
  self.SetPublishedPropByName('FPubNumber', 22);
  //ShowMessage(FProp.Name);
  Value := self.GetPublishedPropByName('FPubNumber');
  ShowMessage('--------------');
  ShowMessage(IntToStr(self.FPubNumber));
  Result := 'Привет' }
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Ch1: TChild1;
  Ch2: TChild2;
  Ctx: TRttiContext;
  Typ: TRttiType;
  Prop: TRttiProperty;
  Val: TValue;
  var i:integer;
begin
    Ch1 := TChild1.Create();
    Ch2 := TChild2.Create();
    Ch1.SavePublishedProps();
    ShowMessage(Val.ToString);
    Val := Ch1.GetPublishedPropByName('niaaome');
    ShowMessage(Val.ToString);
    if not Val.IsEmpty then
    begin
      ShowMessage(Val.ToString);
    end
    else
    begin
      ShowMessage('nil');
    end;
    if Ch1.IsPropExist('Sex') then
    begin
      ShowMessage('FSome');
    end ;
    //Ch1.RestorePublishedProps(ChangeFileExt(Application.ExeName, '.INI'));
    //Ch1.SavePublishedProps();
    Ch1.GetPublishedPropsToStrings();
        //Ch1.Test();
end;

{ TParent }

procedure TParent.SavePublishedProps;
var
  SettingsFile : TCustomIniFile;
  Pair: TPair<string, TValue>;
begin
  Self.GetAllPublishedProps();
  ShowMessage(self.ClassName);
  SettingsFile := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.INI'), TEncoding.UTF8);
  ShowMessage(SettingsFile.FileName);
  ShowMessage(SettingsFile.ToString);
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
  Line: string;
begin
  ShowMessage('____GetPublishedPropsToStrings');
  FRtti := TRttiContext.Create;
  FTyp := FRtti.GetType(self.ClassType);
  PropsLines := TStrings.Create;
  for FProp in FTyp.GetProperties do
  begin
    Value := FProp.GetValue(self);
    case Value.Kind of
      tkInteger:
        Line := FProp.Name + ': ' + IntToStr(Value.AsInt64);
      tkInt64:
      begin
        Line := FProp.Name + ': ' + IntToStr(Value.AsInt64);
        ShowMessage(Line);
      end;
      tkstring, tkUString, tkLString, tkWString, tkChar, tkWChar:
      begin
        Line := FProp.Name + ': ' + Value.AsString;
        ShowMessage(Line);
      end;
      tkFloat:
      begin
        Line := FProp.Name + ': ' + FloatToStr(Value.AsExtended);
        ShowMessage(Line);
      end;
    end;
    PropsLines.Add(Line);
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
      ShowMessage(Child1.ToString);
    1:
      ShowMessage(Child2.ToString);
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
      Memo1.Lines.Add(Child1.ToString);
    1:
      Memo1.Lines.Add(Child2.ToString);
  end;
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin

  Memo1.Clear;
  case Form1.RadioGroup1.ItemIndex of
  0:
    Memo1.Lines.Add(Child1.ToString);
  1:
    Memo1.Lines.Add(Child2.ToString);
  end;
end;

end.
