object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'FormTestOne'
  ClientHeight = 193
  ClientWidth = 530
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Button1: TButton
    Left = 4
    Top = 157
    Width = 75
    Height = 25
    Caption = 'Save'
    Default = True
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 85
    Top = 157
    Width = 75
    Height = 25
    Caption = 'Restore'
    TabOrder = 1
    OnClick = Button2Click
  end
  object RadioGroup1: TRadioGroup
    Left = 8
    Top = 8
    Width = 152
    Height = 127
    Caption = 'Choose object'
    ItemIndex = 0
    Items.Strings = (
      'Object 1'
      'Object 2')
    TabOrder = 2
    OnClick = RadioGroup1Click
  end
  object Memo1: TMemo
    Left = 192
    Top = 18
    Width = 321
    Height = 164
    TabOrder = 3
  end
end
