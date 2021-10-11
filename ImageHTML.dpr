//------------------------------------------------------------------------------
//
// ImageHTML -- Image to ASCII Convertor
// Copyright(C) 2003 Kambiz R. Khojasteh, all rights reserved.
//
//------------------------------------------------------------------------------

program ImageHTML;

uses
  Forms,
  Main in 'Main.pas' {MainForm};

{$R *.res}
{$R XPTheme.res}

begin
  Application.Initialize;
  Application.Title := 'Image to HTML';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
