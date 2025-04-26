object fm_Main: Tfm_Main
  Left = 0
  Top = 0
  Caption = 'XML Flat parser'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object pnlBody: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 368
    Align = alClient
    BevelEdges = []
    BevelOuter = bvNone
    TabOrder = 0
    object redParserOutput: TRichEdit
      Left = 0
      Top = 0
      Width = 624
      Height = 368
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      Lines.Strings = (
        'redParserOutput')
      ParentFont = False
      TabOrder = 0
    end
  end
  object pnlFoot: TPanel
    Left = 0
    Top = 368
    Width = 624
    Height = 73
    Align = alBottom
    BevelEdges = []
    BevelOuter = bvNone
    TabOrder = 1
    object btnTryFlatParse: TButton
      Left = 256
      Top = 32
      Width = 97
      Height = 25
      Caption = 'Try flat parse'
      TabOrder = 0
      OnClick = btnTryFlatParseClick
    end
  end
end
