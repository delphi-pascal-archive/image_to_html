object MainForm: TMainForm
  Left = 220
  Top = 131
  Width = 817
  Height = 629
  Caption = 'Image to HTML'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 13
  object Splitter: TSplitter
    Left = 226
    Top = 0
    Height = 601
    Beveled = True
    MinSize = 226
    OnCanResize = SplitterCanResize
  end
  object InputPanel: TPanel
    Left = 0
    Top = 0
    Width = 226
    Height = 601
    Align = alLeft
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    object InputHeader: THeaderControl
      Left = 0
      Top = 0
      Width = 226
      Height = 20
      FullDrag = False
      Enabled = False
      Sections = <
        item
          AllowClick = False
          ImageIndex = -1
          MaxWidth = 228
          MinWidth = 228
          Text = 'Input Parameters'
          Width = 228
        end>
    end
    object InputClientPanel: TPanel
      Left = 0
      Top = 20
      Width = 226
      Height = 581
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 10
      Constraints.MinHeight = 575
      ParentColor = True
      TabOrder = 1
      DesignSize = (
        226
        581)
      object Spacer2: TBevel
        Left = 10
        Top = 323
        Width = 206
        Height = 51
        Align = alBottom
        Shape = bsSpacer
      end
      object Spacer1: TBevel
        Left = 10
        Top = 10
        Width = 206
        Height = 35
        Align = alTop
        Shape = bsSpacer
      end
      object ImagePanel: TPanel
        Left = 10
        Top = 45
        Width = 206
        Height = 278
        Align = alClient
        BevelInner = bvLowered
        BorderWidth = 1
        ParentColor = True
        TabOrder = 1
        object ImageHash: TShape
          Left = 3
          Top = 3
          Width = 200
          Height = 272
          Align = alClient
          Brush.Color = clBtnShadow
          Brush.Style = bsBDiagonal
          Pen.Style = psClear
        end
        object Image: TImage
          Left = 3
          Top = 3
          Width = 200
          Height = 272
          Align = alClient
          Center = True
          Proportional = True
        end
      end
      object btnSelectImage: TButton
        Left = 10
        Top = 10
        Width = 206
        Height = 27
        Caption = 'Select &Image...'
        TabOrder = 0
        OnClick = btnSelectImageClick
      end
      object btnConvert: TButton
        Left = 10
        Top = 329
        Width = 206
        Height = 27
        Anchors = [akLeft, akBottom]
        Caption = 'Con&vert Image'
        Enabled = False
        TabOrder = 2
        OnClick = btnConvertClick
      end
      object ParamsPanel: TPanel
        Left = 10
        Top = 374
        Width = 206
        Height = 197
        Align = alBottom
        ParentColor = True
        TabOrder = 3
        object lblCharacters: TLabel
          Left = 122
          Top = 32
          Width = 53
          Height = 13
          Caption = 'Characters'
          ShowAccelChar = False
          Transparent = True
        end
        object btnSelectFont: TButton
          Left = 118
          Top = 158
          Width = 73
          Height = 27
          Caption = '&Font...'
          TabOrder = 6
          OnClick = btnSelectFontClick
        end
        object stMaxLineWIdth: TStaticText
          Left = 16
          Top = 13
          Width = 92
          Height = 17
          Caption = '&Max. Line Width:'
          FocusControl = edMaxLineWidth
          TabOrder = 0
        end
        object edMaxLineWidth: TEdit
          Tag = 120
          Left = 16
          Top = 28
          Width = 98
          Height = 21
          TabOrder = 1
          Text = '120'
          OnExit = edMaxLineWidthExit
          OnKeyPress = edMaxLineWidthKeyPress
        end
        object stSequence: TStaticText
          Left = 16
          Top = 61
          Width = 149
          Height = 17
          Caption = 'S&equence (Color/Grayscale):'
          FocusControl = edSequence
          TabOrder = 2
        end
        object edSequence: TEdit
          Tag = 120
          Left = 16
          Top = 76
          Width = 175
          Height = 21
          TabOrder = 3
          Text = '01'
        end
        object stColorMap: TStaticText
          Left = 16
          Top = 109
          Width = 100
          Height = 17
          Caption = 'C&olor Map (Mono):'
          FocusControl = edColorMap
          TabOrder = 4
        end
        object edColorMap: TEdit
          Tag = 120
          Left = 16
          Top = 124
          Width = 175
          Height = 21
          TabOrder = 5
          Text = '#NVo!r/. '
        end
      end
    end
  end
  object OutputPanel: TPanel
    Left = 229
    Top = 0
    Width = 580
    Height = 601
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    object OutputHeader: THeaderControl
      Left = 0
      Top = 0
      Width = 580
      Height = 20
      FullDrag = False
      Enabled = False
      Sections = <
        item
          AutoSize = True
          ImageIndex = -1
          Text = 'Output HTML'
          Width = 580
        end>
    end
    object OutputClientPanel: TPanel
      Left = 0
      Top = 20
      Width = 580
      Height = 581
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 10
      ParentColor = True
      TabOrder = 1
      object HTMLPages: TPageControl
        Left = 10
        Top = 10
        Width = 560
        Height = 526
        ActivePage = tsColor
        Align = alClient
        TabOrder = 0
        object tsColor: TTabSheet
          Caption = 'Color'
          object wbColor: TWebBrowser
            Left = 0
            Top = 0
            Width = 552
            Height = 498
            Align = alClient
            TabOrder = 0
            ControlData = {
              4C000000A42D00002D2900000000000000000000000000000000000000000000
              000000004C000000000000000000000001000000E0D057007335CF11AE690800
              2B2E126208000000000000004C0000000114020000000000C000000000000046
              8000000000000000000000000000000000000000000000000000000000000000
              00000000000000000100000000000000000000000000000000000000}
          end
        end
        object tsGrayscale: TTabSheet
          Caption = 'Grayscale'
          ImageIndex = 1
          object wbGrayscale: TWebBrowser
            Left = 0
            Top = 0
            Width = 344
            Height = 492
            Align = alClient
            TabOrder = 0
            ControlData = {
              4C000000DB2C0000112A00000000000000000000000000000000000000000000
              000000004C000000000000000000000001000000E0D057007335CF11AE690800
              2B2E126208000000000000004C0000000114020000000000C000000000000046
              8000000000000000000000000000000000000000000000000000000000000000
              00000000000000000100000000000000000000000000000000000000}
          end
        end
        object tsMono: TTabSheet
          Caption = 'Mono'
          ImageIndex = 2
          object wbMono: TWebBrowser
            Left = 0
            Top = 0
            Width = 344
            Height = 492
            Align = alClient
            TabOrder = 0
            ControlData = {
              4C000000DB2C0000112A00000000000000000000000000000000000000000000
              000000004C000000000000000000000001000000E0D057007335CF11AE690800
              2B2E126208000000000000004C0000000114020000000000C000000000000046
              8000000000000000000000000000000000000000000000000000000000000000
              00000000000000000100000000000000000000000000000000000000}
          end
        end
      end
      object CmdsPanel: TPanel
        Left = 10
        Top = 536
        Width = 560
        Height = 35
        Align = alBottom
        BevelOuter = bvNone
        Constraints.MinWidth = 352
        ParentColor = True
        TabOrder = 1
        DesignSize = (
          560
          35)
        object btnSaveToFile: TButton
          Left = 327
          Top = 8
          Width = 113
          Height = 27
          Anchors = [akTop, akRight]
          Caption = '&Save To File...'
          Enabled = False
          TabOrder = 1
          OnClick = btnSaveToFileClick
        end
        object btnCopyToClipboard: TButton
          Left = 208
          Top = 8
          Width = 113
          Height = 27
          Anchors = [akTop, akRight]
          Caption = '&Copy To Clipboard'
          Enabled = False
          TabOrder = 0
          OnClick = btnCopyToClipboardClick
        end
        object btnPrint: TButton
          Left = 447
          Top = 8
          Width = 113
          Height = 27
          Anchors = [akTop, akRight]
          Caption = '&Print...'
          Enabled = False
          TabOrder = 2
          OnClick = btnPrintClick
        end
      end
    end
  end
  object OpenPictureDialog: TOpenPictureDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofNoTestFileCreate, ofEnableSizing]
    Title = 'Select Image'
    Left = 56
    Top = 80
  end
  object ApplicationEvents: TApplicationEvents
    OnMessage = ApplicationEventsMessage
    Left = 23
    Top = 79
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Options = [fdEffects, fdScalableOnly]
    Left = 88
    Top = 80
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'html'
    Filter = 'HTML Files (*.html)|*.html'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Save HTML As'
    Left = 120
    Top = 80
  end
end
