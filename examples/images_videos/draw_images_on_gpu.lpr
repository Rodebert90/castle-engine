{
  Copyright 2018-2018 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Demo of drawing on GPU to TGLImage, using TGLImage.RenderToImageBegin
  and TGLImage.DrawFrom. }

uses SysUtils,
  CastleGLImages, CastleWindow, CastleUIControls, CastleGLUtils, CastleColors,
  CastleFilesUtils, CastleImages, CastleRectangles, CastleVectors;

var
  SourceImage: TGLImage;
  DestImage: TGLImage;

procedure Render(Container: TUIContainer);
begin
  RenderContext.Clear([cbColor], Black);
  DestImage.Draw(0, 0);
end;

var
  Window: TCastleWindowCustom;
  DestImageInitial, DestImageFinal: TCastleImage;
begin
  try
    Window := TCastleWindowCustom.Create(Application);
    Window.Open;

    { All of the TGLImage drawing must happen when OpenGL context is active,
      so after Window.Open.
      In a cross-platform application (https://castle-engine.io/manual_cross_platform.php),
      you would do this in Application.OnInitialize. }

    SourceImage := TGLImage.Create(ApplicationData(
      //'2RGBA.png')); // better alpha test
      'boss-preview.png'));

    DestImageInitial := TRGBAlphaImage.Create(800, 800);
    DestImageInitial.Clear(Yellow);
    DestImage := TGLImage.Create(DestImageInitial, true, true);

    { Note that blending parameters on SourceImage control how the alpha
      is treated when drawing. }

    DestImage.DrawFrom(SourceImage,
      FloatRectangle(10, 10, 200, 200), FloatRectangle(SourceImage.Rect));
    DestImage.DrawFrom(SourceImage,
      FloatRectangle(100, 10, 200, 200), FloatRectangle(SourceImage.Rect));
    DestImage.DrawFrom(SourceImage,
      FloatRectangle(200, 10, 300, 300), FloatRectangle(SourceImage.Rect));

    DestImage.RenderToImageBegin;
    DrawRectangle(Rectangle(500, 500, 250, 250), Blue);
    { Note that blending is automatically used, because color has alpha < 1.
      Extra parameters to DrawCircle control how the alpha is treated. }
    DrawCircle(Vector2Integer(550, 550), 200, 200, Vector4(1, 0, 0, 0.5));
    DestImage.RenderToImageEnd;

    Window.OnRender := @Render;

    { Instead of using DestImage for drawing, you can also get it's contents
      back to normal (non-GPU) memory using DestImage.GetContents.
      This is reasonable if you have to save it back to disk
      (otherwise, you should avoid it, and work with GPU-only DestImage
      for maximum speed). }
    DestImageFinal := DestImage.GetContents(TRGBAlphaImage);
    try
      SaveImage(DestImageFinal, 'test.png');
    finally FreeAndNil(DestImageFinal) end;

    Application.Run;
  finally
    FreeAndNil(SourceImage);
    FreeAndNil(DestImage);
  end;
end.
