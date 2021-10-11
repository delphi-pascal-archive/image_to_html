{------------------------------------------------------------------------------}
{                                                                              }
{  ImageAscii - Image to Ascii conversion                                      }
{  Copyright(C) 2003 Kambiz R. Khojasteh, all rights reserved.                 }
{                                                                              }
{  kambiz@delphiarea.com                                                       }
{  http://www.delphiarea.com                                                   }
{                                                                              }
{  This unit is provided "AS IS" without any warranty of any  kind, either     }
{  express or implied. The entire  risk as to the quality  and performance     }
{  of the functions provided in this  unit are with you. The author is NOT     }
{  liable for  any DAMAGES resulting from the use  and misuse of the unit,     }
{  especially he is NOT liable for DAMAGES that were caused BY ANY VERSION     }
{  WHICH HAS NOT BEEN PROGRAMMED BY THE AUTHOR HIMSELF.                        }
{                                                                              }
{  This Delphi unit is  FREEWARE  for  non-COMMERCIAL  use. If you want to     }
{  change the  source code  in order to improve the features, performance,     }
{  etc.  please send to the author the new source code so that the  author     }
{  can  have  a  look  at  it.  The  changed  source code  should  contain     }
{  descriptions what  you have changed, and your name.  The only thing you     }
{  MAY NOT CHANGE is the original COPYRIGHT information.                       }
{                                                                              }
{------------------------------------------------------------------------------}

unit ImageAscii;

interface

uses
  Windows, Classes, Graphics;

type
  TConvertMode = (cmColor, cmGrayscale, cmMono);

procedure ImageToHTML(const FileName: String; out HTML: String;
  const Map: String; Mode: TConvertMode; MaxRowWidth: Integer = 0;
  Font: TFont = nil; const Head: String = ''; const Tail: String = '');

procedure GraphicToHTML(G: TGraphic; out HTML: String;
  const Map: String; Mode: TConvertMode; MaxRowWidth: Integer = 0;
  Font: TFont = nil; const Head: String = ''; const Tail: String = '');

implementation

uses
  SysUtils;

const
  FontColorTagBegin = '<FONT COLOR="#%2.2x%2.2x%2.2x">';
  FontNameTagBegin  = '<FONT NAME="%s" STYLE="font-size: %dpt">';
  FontTagEnd        = '</FONT>';
  BoldTagBegin      = '<B>';
  BoldTagEnd        = '</B>';
  ItalicTagBegin    = '<I>';
  ItalicTagEnd      = '</I>';
  UnderlineTagBegin = '<U>';
  UnderlineTagEnd   = '</U>';
  StrikeOutTagBegin = '<S>';
  StrikeOutTagEnd   = '<S>';
  TeleTypeTagBegin  = '<TT>';
  TeleTypeTagEnd    = '</TT>';
  LineBreakTag      = '<BR>';
  SpecialSpace      = '&nbsp;';

{ Helpper Functions }

// Calculate the propertionally shrinked size of the graphic
// according to the specified dimensions and text metrics.
procedure CalcShrinkedSize(G: TGraphic; MaxWidth, MaxHeight: Integer;
  const tm: TTextMetric; out Width, Height: Integer);
begin
  // Scale the image's width according to the text metrics
  Width := MulDiv(G.Width, tm.tmHeight + tm.tmExternalLeading, tm.tmAveCharWidth);
  Height := G.Height;
  // if MaxWidth is zero, don't scale horizontally
  if MaxWidth = 0 then MaxWidth := Width;
  // if MaxHeight is zero, don't scale vertically
  if MaxHeight = 0 then MaxHeight := Height;
  // if image size is biger than max. dimensions, shrink it proportionally
  if (Width > MaxWidth) or (Height > MaxHeight) then
  begin
    if (MaxWidth / Width) < (MaxHeight / Height) then
    begin
      Height := MulDiv(Height, MaxWidth, Width);
      Width := MaxWidth;
    end
    else
    begin
      Width := MulDiv(Width, MaxHeight, Height);
      Height := MaxHeight;
    end;
  end;
end;

// Returns the bitmap version of the given graphic object. The bitmap is
// proportionally scaled according to the specified dimensions and font's
// text metrics.
function GetBitmapOf(G: TGraphic; MaxWidth, MaxHeight: Integer; Font: TFont): TBitmap;
var
  Width, Height: Integer;
  TextMetric: TTextMetric;
begin
  Result := TBitmap.Create;
  try
    // Get the text metrics of the font
    if Font <> nil then Result.Canvas.Font.Assign(Font);
    GetTextMetrics(Result.Canvas.Handle, TextMetric);
    // Shrink the image size according to the max. dimensions and text metrics
    CalcShrinkedSize(G, MaxWidth, MaxHeight, TextMetric, Width, Height);
    // Draw the image on the bitmap
    Result.Width := Width;
    Result.Height := Height;
    Result.Canvas.StretchDraw(Rect(0, 0, Width, Height), G);
  except
    // free the bitmap if any exception occured
    Result.Free;
    raise;
  end;
end;

{ Global Procedures }

// Converts the given graphic object to ASCII image as HTML format
procedure GraphicToHTML(G: TGraphic; out HTML: String;
  const Map: String; Mode: TConvertMode; MaxRowWidth: Integer;
  Font: TFont; const Head, Tail: String);

var
  Buffer: PChar;
  Bitmap: TBitmap;
  BitmapWidth: Integer;
  BitmapHeight: Integer;
  Colors: PRGBQuad;
  LastColor: Integer;
  Gray: Integer;
  LastGray: Integer;
  X, Y: Integer;
  M: PChar;

  // Formats the arguments and appends them to the buffer.
  procedure AppendFormat(const Format: String; const Args: array of const);
  begin
    Inc(Buffer, FormatBuf(Buffer^, MaxInt, PChar(Format)^, Length(Format), Args));
  end;

  // Appends the text to the buffer.
  procedure AppendText(const Text: String);
  begin
    Buffer := StrCopy(Buffer, PChar(Text)) + Length(Text);
  end;

  // Calculates the worst-case size of the buffer
  function GetWorstCaseBufferSize: Integer;
  var
    PixelCount: Integer;
  begin
    PixelCount := BitmapWidth * BitmapHeight;
    // Calculates the worst-case length of the HTML for saving pixels, and
    // header and footer tags
    Result := Length(Head) + Length(TeleTypeTagBegin)
            + BitmapHeight * Length(LineBreakTag)
            + Length(TeleTypeTagEnd) + Length(Tail);
    if Mode = cmMono then
      Inc(Result, PixelCount * Length(SpecialSpace) + (Length(FontColorTagBegin + FontTagEnd) - 8))
    else
      Inc(Result, PixelCount * Length(SpecialSpace) * (Length(FontColorTagBegin + FontTagEnd) - 8));
    // Increases the calculated size by adding the space required to
    // font related tags
    if Font <> nil then
    begin
      Inc(Result, Length(FontNameTagBegin) + Length(Font.Name) + Length(FontTagEnd));
      if fsBold in Font.Style then
        Inc(Result, Length(BoldTagBegin) + Length(BoldTagEnd));
      if fsItalic in Font.Style then
        Inc(Result, Length(ItalicTagBegin) + Length(ItalicTagEnd));
      if fsUnderline in Font.Style then
        Inc(Result, Length(UnderlineTagBegin) + Length(UnderlineTagEnd));
      if fsStrikeOut in Font.Style then
        Inc(Result, Length(StrikeOutTagBegin) + Length(StrikeOutTagEnd));
    end;
  end;

begin
  Bitmap := GetBitmapOf(G, MaxRowWidth, 0, Font);
  try
    // Save bitmap's dimensions for quick retrival
    BitmapWidth := Bitmap.Width;
    BitmapHeight := Bitmap.Height;
    // Change bitmap format to high-color
    Bitmap.PixelFormat := pf32bit;
    // Reserve space for the HTML text
    SetLength(HTML, GetWorstCaseBufferSize);
    Buffer := PChar(HTML);
    // Add HTML header tags
    AppendText(Head);
    AppendText(TeleTypeTagBegin);
    // Add font related tags
    if Font <> nil then
    begin
      AppendFormat(FontNameTagBegin, [Font.Name, Font.Size]);
      if fsBold in Font.Style then
        AppendText(BoldTagBegin);
      if fsItalic in Font.Style then
        AppendText(ItalicTagBegin);
      if fsUnderline in Font.Style then
        AppendText(UnderlineTagBegin);
      if fsStrikeOut in Font.Style then
        AppendText(StrikeOutTagBegin);
      if Mode = cmMono then
        AppendFormat(FontColorTagBegin, [GetRValue(Font.Color),
          GetGValue(Font.Color), GetBValue(Font.Color)]);
    end;
    // Create the rest of HTML using the bitmap's pixels
    M := PChar(Map);
    LastColor := -1;
    LastGray := -1;
    for Y := 0 to BitmapHeight - 1 do
    begin
      Colors := Bitmap.ScanLine[Y];
      // Start a new row by adding a line break
      if Y <> 0 then
        AppendText(LineBreakTag);
      // Convert pixels in the current row
      for X := 0 to BitmapWidth - 1 do
      begin
        if PInteger(Colors)^ <> LastColor then
        begin
          // Change the color
          with Colors^ do
          begin
            if Mode = cmColor then
            begin
              // If there's any open font color tag, close it
              if LastColor <> -1 then
                AppendText(FontTagEnd);
              // Add a new font color tag
              AppendFormat(FontColorTagBegin, [rgbRed, rgbGreen, rgbBlue])
            end
            else
            begin
              Gray := (rgbRed * 30 + rgbGreen * 59 + rgbBlue * 11) div 100;
              if Gray <> LastGray then
              begin
                if Mode = cmGrayscale then
                begin
                  // If there's any open font color tag, close it
                  if LastGray <> -1 then
                    AppendText(FontTagEnd);
                  // Add a new font color tag
                  AppendFormat(FontColorTagBegin, [Gray, Gray, Gray])
                end
                else
                  M := PChar(Map) + (Length(Map) * Gray div 256);
                LastGray := Gray;
              end;
            end;
          end;
          LastColor := PInteger(Colors)^;
        end;
        // Add a character for this pixel
        if M^ <> ' ' then
        begin
          Buffer^ := M^;
          Inc(Buffer);
        end
        else
          AppendText(SpecialSpace);
        // Move the pixel chanacter to the next one if the mode is not mono
        if Mode <> cmMono then
        begin
          Inc(M);
          if M^ = #0 then M := PChar(Map);
        end;
        // Move to the next pixel
        Inc(Colors);
      end;
    end;
    // If there's any open font color tag, close it
    if (Mode <> cmMono) and (LastColor <> -1) then
      AppendText(FontTagEnd);
    // Close the open font related tags
    if Font <> nil then
    begin
      if Mode = cmMono then
        AppendText(FontTagEnd);
      if fsStrikeOut in Font.Style then
        AppendText(StrikeOutTagEnd);
      if fsUnderline in Font.Style then
        AppendText(UnderlineTagEnd);
      if fsItalic in Font.Style then
        AppendText(ItalicTagEnd);
      if fsBold in Font.Style then
        AppendText(BoldTagEnd);
      AppendText(FontTagEnd);
    end;
    // Add the HTML fotter tags
    AppendText(TeleTypeTagEnd);
    AppendText(Tail);
    // Set the size of the HTML text to actual size
    SetLength(HTML, Buffer - PChar(HTML));
  finally
    Bitmap.Free;
  end;
end;

// Converts the given imagefile to color/grayscale ASCII image as HTML format
procedure ImageToHTML(const FileName: String; out HTML: String;
  const Map: String; Mode: TConvertMode; MaxRowWidth: Integer;
  Font: TFont; const Head, Tail: String);
var
  Picture: TPicture;
begin
  Picture := TPicture.Create;
  try
    Picture.LoadFromFile(FileName);
    GraphicToHTML(Picture.Graphic, HTML, Map, Mode, MaxRowWidth, Font, Head, Tail);
  finally
    Picture.Free;
  end;
end;

end.
