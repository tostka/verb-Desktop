# ====== v move-window functions by Sunnyone v ======
<# This is qa set of functions that permit you to move-window a window, and even Move-WindowByWindowTitle
# AUTHOR: sunnyone
# URL: https://gist.github.com/sunnyone/7082155
# VERS: 1:36 PM 1/15/2014 commented & formatted by todd kadrie
# VERS: Created 2013-10-21
# USAGE:
# prereq for the API calls used below
Define-MoveWindow
# below matches firefox, even though the WindowTitle doesn't seem to match the string below...
Move-WindowByWindowTitle -ProcessName Firefox -WindowTitle "Win.ow" -X 100 -Y 200 -Width 640 -Height 480
#>
#*------v Function Define-MoveWindow v------
function Define-MoveWindow {
    $signature = @'
[DllImport("user32.dll")]
public static extern bool MoveWindow(
IntPtr hWnd,
int X,
int Y,
int nWidth,
int nHeight,
bool bRepaint);
'@
    Add-Type -MemberDefinition $signature -Name MoveWindowUtil -Namespace MoveWindowUtil
}#*------^ END Function Define-MoveWindow ^------