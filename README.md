# CSCImageProj<br />
**Created Date:** 1/09/2003<br />
**Last Updated:** 5/21/2008<br />
**Description:** This control allows you to display an image from a bitmap (.bmp), icon (.ico), metafile (.wmf) or enhanced metafile (.emf) on the screen.<br />
**Platforms:** Windows<br />
**Products:** Synergy DBL, ActiveX API<br />
**Minimum Version:** 6.3<br />
**Author:** Chip Camden
<hr>

**Additional Information:** Files included about1.dfm, about1.pas, CSCImageImpl1.dfm, CSCImageImpl1.pas, CSCImageProj.dpr, CSCImageProj.ocx, CSCImageProj.tlb, CSCImageProj_TLB.pas, logo.bmp, readme.txt, synax.dll, test.dbl, test.dbr

Properties:

Name OLE type Synergy type Description
---- -------- ------------ -----------
ImageFile Variant Alpha Name of the image file to load
Stretch Bool Numeric Stretch to fit? (TRUE)


Methods:

Name Return value Arguments Description
---- ------------ --------- -----------
AboutBox None None Pops up About Box


Events:
Name Return value Arguments Description
---- ------------ --------- -----------
(None)

__________
Discussion

Set the ImageFile property to the path for the file from which to draw the
image. The only image file formats supported are Windows bitmap, icon,
metafile, and enhanced metafile.

Set the Stretch property to TRUE to stretch (or shrink) the image to
fit the size of the control. If Stretch is FALSE, then the original image
size will be used, but may be clipped if the control is too small, or leave
empty space if the control is too large.

This control cannot receive focus and does not respond to user input.

The control was created with Delphi 5 Professional. Open the project file
CSCImageProj.dpr.

Test.dbr is included for demonstration purposes.
