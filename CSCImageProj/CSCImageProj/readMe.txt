Name			ActiveX control for bitmap image

Developed by            Camden Software Consulting
                        
Contact                 Chip Camden
                        
                        sterling@camdensoftware.com
                        http://www.camdensoftware.com
                        
Description             This control allows you to display an image
                        from a bitmap (.bmp), icon (.ico), metafile (.wmf)
                        or enhanced metafile (.emf) on the screen.

Files included		about1.dfm, about1.pas, axctrls.pas, CSCImageImpl1.dfm,
			CSCImageImpl1.pas, CSCImageProj.dpr,
			CSCImageProj.ocx, CSCImageProj.tlb,
			CSCImageProj_TLB.pas, logo.bmp, readme.txt,
			test.dbl

Platforms supported	Windows

Minimum Synergy/DE version supported
			6.3.0 and above 32 bit only

_______________
ActiveX control

Filename        	CSCImageProj.ocx
                        
Registered name 	CSCImageProj.CSCImageX

Properties:

   Name         OLE type        Synergy type    Description
   ----         --------        ------------    -----------
   ImageFile    Variant         Alpha           Name of the image file to load
   Stretch      Bool            Numeric         Stretch to fit? (TRUE)
       

Methods: 

   Name         Return value    Arguments       Description
   ----         ------------    ---------       -----------
   AboutBox     None            None            Pops up About Box
   

Events:
   Name         Return value    Arguments       Description
   ----         ------------    ---------       -----------
   (None)

__________
Discussion

Set the ImageFile property to the path for the file from which to draw the
image.  The only image file formats supported are Windows bitmap, icon,
metafile, and enhanced metafile.

Set the Stretch property to TRUE to stretch (or shrink) the image to
fit the size of the control.  If Stretch is FALSE, then the original image
size will be used, but may be clipped if the control is too small, or leave
empty space if the control is too large.

This control cannot receive focus and does not respond to user input.

The control was created with Delphi 5 Professional.  Open the project file
CSCImageProj.dpr.

Test.dbr is included for demonstration purposes.
