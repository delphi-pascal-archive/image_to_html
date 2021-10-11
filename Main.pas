//------------------------------------------------------------------------------
//
// ImageHTML -- Image to ASCII Convertor
// Copyright(C) 2003 Kambiz R. Khojasteh, all rights reserved.
//
//------------------------------------------------------------------------------

unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, OleCtrls, SHDocVw, StdCtrls, ExtDlgs, JPEG,
  AppEvnts, Spin;

type
  TMainForm = class(TForm)
    InputPanel: TPanel;
    OutputPanel: TPanel;
    Splitter: TSplitter;
    InputHeader: THeaderControl;
    OutputHeader: THeaderControl;
    InputClientPanel: TPanel;
    OutputClientPanel: TPanel;
    HTMLPages: TPageControl;
    tsColor: TTabSheet;
    tsGrayscale: TTabSheet;
    tsMono: TTabSheet;
    wbColor: TWebBrowser;
    wbGrayscale: TWebBrowser;
    wbMono: TWebBrowser;
    CmdsPanel: TPanel;
    btnSaveToFile: TButton;
    btnCopyToClipboard: TButton;
    btnPrint: TButton;
    OpenPictureDialog: TOpenPictureDialog;
    ApplicationEvents: TApplicationEvents;
    FontDialog: TFontDialog;
    Spacer1: TBevel;
    btnSelectImage: TButton;
    ImagePanel: TPanel;
    Image: TImage;
    Spacer2: TBevel;
    ParamsPanel: TPanel;
    stMaxLineWIdth: TStaticText;
    edMaxLineWidth: TEdit;
    lblCharacters: TLabel;
    stSequence: TStaticText;
    edSequence: TEdit;
    stColorMap: TStaticText;
    edColorMap: TEdit;
    btnSelectFont: TButton;
    btnConvert: TButton;
    ImageHash: TShape;
    SaveDialog: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ApplicationEventsMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure SplitterCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure btnCopyToClipboardClick(Sender: TObject);
    procedure btnSaveToFileClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnSelectImageClick(Sender: TObject);
    procedure btnSelectFontClick(Sender: TObject);
    procedure btnConvertClick(Sender: TObject);
    procedure edMaxLineWidthExit(Sender: TObject);
    procedure edMaxLineWidthKeyPress(Sender: TObject; var Key: Char);
  private
    AlreadyActivated: Boolean;
    ColorHTML, GrayHTML, MonoHTML: String;
    procedure InitWebBrowsers;
    procedure LoadImage(const FileName: String);
    procedure LoadSettingsFromRegistry;
    procedure SaveSettingsToRegistry;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  ShellAPI, ActiveX, Clipbrd, Registry, ImageAscii;

procedure SetHTML(WebBrowser: TWebBrowser; const HTML: String);
var
  Stream: IStream;
  Handle: HGLOBAL;
  Ptr: PChar;
begin
  if WebBrowser.Document <> nil then
  begin
    Handle := GlobalAlloc(GHND, Length(HTML)+1);
    try
      Ptr := GlobalLock(Handle);
      if Assigned(Ptr) then
      begin
        StrPCopy(Ptr, HTML);
        GlobalUnlock(Handle);
        if CreateStreamOnHGlobal(Handle, True, Stream) = S_OK then
        begin
          with (WebBrowser.Document as IPersistStreamInit) do
          begin
            InitNew;
            Load(Stream);
          end;
        end;
      end;
    finally
      GlobalFree(Handle);
    end;
  end;
end;

function GetWebColor(Color: TColor): String;
var
  RGB: Integer;
begin
  RGB := ColorToRGB(Color);
  Result := IntToHex(GetRValue(RGB), 2)
          + IntToHex(GetGValue(RGB), 2)
          + IntToHex(GetBValue(RGB), 2);
end;

procedure TMainForm.InitWebBrowsers;
const
  BlankDoc = 'about:blank';
begin
  if wbColor.Document = nil then
    wbColor.Navigate(BlankDoc);
  if wbGrayscale.Document = nil then
    wbGrayscale.Navigate(BlankDoc);
  if wbMono.Document = nil then
    wbMono.Navigate(BlankDoc);
end;

procedure TMainForm.LoadImage(const FileName: String);
begin
  Image.Picture.LoadFromFile(FileName);
  OpenPictureDialog.FileName := FileName;
  btnConvert.Enabled := True;
  Application.ProcessMessages;
  PostMessage(btnConvert.Handle, BM_CLICK, 0, 0);
end;

procedure TMainForm.LoadSettingsFromRegistry;
var
  R: TRegistry;
  WindowBounds: TRect;
begin
  R := TRegistry.Create;
  try
    if R.OpenKeyReadOnly('\Software\DELPHI AREA\ImageHTML') then
    begin
      if R.ValueExists('Window.Bounds') then
      begin
        R.ReadBinaryData('Window.Bounds', WindowBounds, SizeOf(WindowBounds));
        BoundsRect := WindowBounds;
        Realign;
      end;
      if R.ValueExists('Window.Maximized') and R.ReadBool('Window.Maximized') then
        WindowState := wsMaximized;
      if R.ValueExists('MaxLineWidth') then
      begin
        edMaxLineWidth.Tag := R.ReadInteger('MaxLineWidth');
        edMaxLineWidth.Text := IntToStr(edMaxLineWidth.Tag);
      end;
      if R.ValueExists('Map.Sequence') then
        edSequence.Text := R.ReadString('Map.Sequence');
      if R.ValueExists('Map.Table') then
        edColorMap.Text := R.ReadString('Map.Table');
      if R.ValueExists('Font.Name') then
        FontDialog.Font.Name := R.ReadString('Font.Name');
      if R.ValueExists('Font.Size') then
        FontDialog.Font.Size := R.ReadInteger('Font.Size');
      if R.ValueExists('Font.Bold') and R.ReadBool('Font.Bold') then
        FontDialog.Font.Style := Font.Style + [fsBold];
      if R.ValueExists('Font.Italic') and R.ReadBool('Font.Italic') then
        FontDialog.Font.Style := Font.Style + [fsItalic];
      if R.ValueExists('Font.Underline') and R.ReadBool('Font.Underline') then
        FontDialog.Font.Style := Font.Style + [fsUnderline];
      if R.ValueExists('Font.StrikeOut') and R.ReadBool('Font.StrikeOut') then
        FontDialog.Font.Style := Font.Style + [fsStrikeOut];
    end;
  finally
    R.Free;
  end;
end;

procedure TMainForm.SaveSettingsToRegistry;
var
  R: TRegistry;
  WindowBounds: TRect;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey('\Software\DELPHI AREA\ImageHTML', True) then
    begin
      WindowBounds := BoundsRect;
      R.WriteBinaryData('Window.Bounds', WindowBounds, SizeOf(WindowBounds));
      R.WriteBool('Window.Maximized', WindowState = wsMaximized);
      R.WriteInteger('MaxLineWidth', edMaxLineWidth.Tag);
      R.WriteString('Map.Sequence', edSequence.Text);
      R.WriteString('Map.Table', edColorMap.Text);
      R.WriteString('Font.Name', FontDialog.Font.Name);
      R.WriteInteger('Font.Size', FontDialog.Font.Size);
      R.WriteBool('Font.Bold', fsBold in FontDialog.Font.Style);
      R.WriteBool('Font.Italic', fsItalic in FontDialog.Font.Style);
      R.WriteBool('Font.Underline', fsUnderline in FontDialog.Font.Style);
      R.WriteBool('Font.StrikeOut', fsStrikeOut in FontDialog.Font.Style);
    end;
  finally
    R.Free;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(ImagePanel.Handle, True);
  LoadSettingsFromRegistry;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DragAcceptFiles(ImagePanel.Handle, False);
  SaveSettingsToRegistry
end;

procedure TMainForm.ApplicationEventsMessage(var Msg: tagMSG;
  var Handled: Boolean);
var
  ImgFile: String;
begin
  // The image panel accepts dropped file
  if Msg.message = WM_DROPFILES then
  begin
    SetLength(ImgFile, 1024);
    SetLength(ImgFile, DragQueryFile(Msg.wParam, 0, PChar(ImgFile), Length(ImgFile)));
    LoadImage(ImgFile);
    btnConvert.Enabled := True;
    Handled := True;
  end;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  if not AlreadyActivated then
  begin
    AlreadyActivated := True;
    Update;
    InitWebBrowsers;
    if ParamCount > 0 then LoadImage(ParamStr(1))
  end;
end;

procedure TMainForm.SplitterCanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
begin
  Accept := NewSize <= Splitter.MinSize;
end;

procedure TMainForm.btnCopyToClipboardClick(Sender: TObject);
begin
  if HTMLPages.ActivePage = tsColor then
    Clipboard.AsText := ColorHTML
  else if HTMLPages.ActivePage = tsGrayscale then
    Clipboard.AsText := GrayHTML
  else // if HTMLPages.ActivePage = tsMono then
    Clipboard.AsText := MonoHTML;
end;

procedure TMainForm.btnSaveToFileClick(Sender: TObject);
var
  HTMLFile: TextFile;
begin
  SaveDialog.FileName := ChangeFileExt(ExtractFileName(OpenPictureDialog.FileName), '')
                       + '-' + HTMLPages.ActivePage.Caption;
  if SaveDialog.Execute then
  begin
    AssignFile(HTMLFile, SaveDialog.FileName);
    Rewrite(HTMLFile);
    if HTMLPages.ActivePage = tsColor then
      Write(HTMLFile, ColorHTML)
    else if HTMLPages.ActivePage = tsGrayscale then
      Write(HTMLFile, GrayHTML)
    else // if HTMLPages.ActivePage = tsMono then
      Write(HTMLFile, MonoHTML);
    CloseFile(HTMLFile);
  end;
end;

procedure TMainForm.btnPrintClick(Sender: TObject);
begin
  if HTMLPages.ActivePage = tsColor then
    wbColor.ExecWB(OLECMDID_PRINT, OLECMDEXECOPT_PROMPTUSER)
  else if HTMLPages.ActivePage = tsGrayscale then
    wbGrayscale.ExecWB(OLECMDID_PRINT, OLECMDEXECOPT_PROMPTUSER)
  else // if HTMLPages.ActivePage = tsMono then
    wbMono.ExecWB(OLECMDID_PRINT, OLECMDEXECOPT_PROMPTUSER);
end;

procedure TMainForm.btnSelectImageClick(Sender: TObject);
begin
  if OpenPictureDialog.Execute then
    LoadImage(OpenPictureDialog.FileName);
end;

procedure TMainForm.btnSelectFontClick(Sender: TObject);
begin
  FontDialog.Execute;
end;

procedure TMainForm.btnConvertClick(Sender: TObject);
const
  HTMLHeader = '<HTML><BODY><TABLE BORDER="1" CELLSPACING="0" ALIGN="CENTER" BGCOLOR="#%s"><TR><TD>';
  HTMLFooter = '</TD></TR></TABLE></BODY></HTML>';
begin
  if Image.Picture.Graphic <> nil then
  begin
    Screen.Cursor := crHourGlass;
    try
      // Color
      GraphicToHTML(Image.Picture.Graphic, ColorHTML, edSequence.Text, cmColor,
        edMaxLineWidth.Tag, FontDialog.Font,
        Format(HTMLHeader, [GetWebColor(clBlack)]), HTMLFooter);
      SetHTML(wbColor, ColorHTML);
      // Grayscale
      GraphicToHTML(Image.Picture.Graphic, GrayHTML, edSequence.Text, cmGrayscale,
        edMaxLineWidth.Tag, FontDialog.Font,
        Format(HTMLHeader, [GetWebColor(clBlack)]), HTMLFooter);
      SetHTML(wbGrayscale, GrayHTML);
      // Mono
      GraphicToHTML(Image.Picture.Graphic, MonoHTML, edColorMap.Text, cmMono,
        edMaxLineWidth.Tag, FontDialog.Font,
        Format(HTMLHeader, [GetWebColor(clWhite)]), HTMLFooter);
      SetHTML(wbMono, MonoHTML);
      // Enable command buttons
      btnCopyToClipboard.Enabled := True;
      btnSaveToFile.Enabled := True;
      btnPrint.Enabled := True; 
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TMainForm.edMaxLineWidthExit(Sender: TObject);
begin
  edMaxLineWidth.Tag := StrToIntDef(edMaxLineWidth.Text, edMaxLineWidth.Tag);
  edMaxLineWidth.Text := IntToStr(edMaxLineWidth.Tag);
end;

procedure TMainForm.edMaxLineWidthKeyPress(Sender: TObject; var Key: Char);
const
  ValidKeys = ['0'..'9', ^X, ^C, ^V, Chr(VK_RETURN), Chr(VK_ESCAPE), Chr(VK_BACK)];
begin
  if not (Key in ValidKeys) then
  begin
    MessageBeep(0);
    Key := #0;
  end;
end;

end.
