object fm_ProgressPopUp: Tfm_ProgressPopUp
  Left = 0
  Top = 0
  Caption = 'Flat parse progress'
  ClientHeight = 310
  ClientWidth = 621
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  Visible = True
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 54
    Width = 34
    Height = 15
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 8
    Top = 158
    Width = 34
    Height = 15
    Caption = 'Label1'
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 72
    Width = 601
    Height = 17
    TabOrder = 0
  end
  object ProgressBar2: TProgressBar
    Left = 8
    Top = 176
    Width = 601
    Height = 17
    TabOrder = 1
  end
end
