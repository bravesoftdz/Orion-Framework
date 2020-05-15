object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 612
  ClientWidth = 945
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    945
    612)
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 8
    Top = 128
    Width = 929
    Height = 476
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 121
    Height = 23
    Caption = 'Buscar'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 144
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 2
  end
  object edtIDExterno: TEdit
    Left = 144
    Top = 72
    Width = 121
    Height = 21
    TabOrder = 3
    TextHint = 'ID EXTERNO'
  end
  object edtRazaoSocial: TEdit
    Left = 280
    Top = 72
    Width = 121
    Height = 21
    TabOrder = 4
    TextHint = 'RAZ'#195'O SOCIAL'
  end
  object edtFantasia: TEdit
    Left = 416
    Top = 72
    Width = 121
    Height = 21
    TabOrder = 5
    TextHint = 'FANTASIA'
  end
  object Button2: TButton
    Left = 280
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Incluir'
    TabOrder = 6
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 361
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Alterar'
    TabOrder = 7
    OnClick = Button3Click
  end
  object edtID: TEdit
    Left = 8
    Top = 72
    Width = 121
    Height = 21
    TabOrder = 8
    TextHint = 'ID'
  end
  object Button4: TButton
    Left = 442
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Aterar Lista'
    TabOrder = 9
    OnClick = Button4Click
  end
  object DataSource1: TDataSource
    OnDataChange = DataSource1DataChange
    Left = 352
    Top = 208
  end
end
