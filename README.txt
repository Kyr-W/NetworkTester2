====================================================================
 NETWORKTESTER2
====================================================================

A simple PowerShell menu tool for running quick network connectivity
tests and saving the results to a timestamped report file.


--------------------------------------------------------------------
 REQUIREMENTS
--------------------------------------------------------------------

  - Windows PowerShell (uses Test-NetConnection, New-PSDrive,
    Get-Credential)
  - curl.exe available on PATH (bundled with modern Windows) for
    the HTTP/HTTPS test


--------------------------------------------------------------------
 USAGE
--------------------------------------------------------------------

  Double click the .exe file.

  You'll be shown a menu and asked to choose one of four tests.
  Each test prints "Please wait, running tests..." while it runs,
  then writes a report to a .txt file in the current directory and
  prints the same content to the console. The script waits for
  ENTER before closing.


--------------------------------------------------------------------
 MENU OPTIONS
--------------------------------------------------------------------

  1. MLLP connection (Ping + Test-NetConnection)
  -----------------------------------------------
     Prompts for a target IP address and port, then checks basic
     TCP reachability.

     Report file: MLLP_Test_<ip>_<port>_<timestamp>.txt

  2. HTTP/HTTPS connection (Test-NetConnection + curl GET/POST)
  ---------------------------------------------------------------
     Prompts for a URL, checks TCP reachability to the host/port,
     then issues a real GET and POST request to the URL to see how
     the server responds.

     Report file: HTTP_Test_<host>_<timestamp>.txt

  3. Network share folder (Test-Path)
  -------------------------------------
     Prompts for a UNC share path (e.g. \\server\share) and whether
     it needs credentials.

       - No credentials: runs Test-Path directly against the share
         using your current Windows identity.

       - Credentials required: prompts for a username/password,
         maps the share as a temporary PSDrive, checks Test-Path
         against it, then removes the temporary drive. If the
         credential prompt is cancelled or authentication fails,
         the failure reason is recorded in the report.

     Report file: Share_Test_<path>_<timestamp>.txt

  4. IP configuration (ipconfig /all)
  -------------------------------------
     Runs ipconfig /all on the local machine to capture the current
     network configuration (adapters, IP addresses, DNS, etc). No
     prompts other than the initial menu choice.

     Report file: IPConfig_Test_<computername>_<timestamp>.txt


--------------------------------------------------------------------
 FUNCTIONS CALLED DURING THE PROGRAM
--------------------------------------------------------------------

  Read-Host
    Where:   Menu choice, target IP/port/URL/path, Y/N prompt,
             final "Press Enter to exit"
    Purpose: Collects user input and pauses the script at the end

  Save-TestReport (custom function, defined in the script)
    Where:   End of each of the 4 test branches
    Purpose: Sanitizes the target name, builds a timestamped
             filename, writes the report to disk and console via
             Tee-Object

  ping
    Where:   Option 1
    Purpose: Basic ICMP reachability check

  Test-NetConnection
    Where:   Options 1 and 2
    Purpose: TCP-level reachability check to a host/port

  curl.exe
    Where:   Option 2
    Purpose: Sends real HTTP GET and POST requests to the target URL

  Get-Credential
    Where:   Option 3, credentialed path
    Purpose: Prompts for a username/password

  New-PSDrive
    Where:   Option 3, credentialed path
    Purpose: Maps the network share using the supplied credentials

  Test-Path
    Where:   Option 3, both paths
    Purpose: Checks whether the share (or mapped drive) is
             accessible

  Get-PSDrive / Remove-PSDrive
    Where:   Option 3, credentialed path (finally block)
    Purpose: Cleans up the temporary mapped drive after the test,
             whether it succeeded or failed

  Out-String
    Where:   Options 1, 2, 3, 4
    Purpose: Flattens cmdlet/curl output into plain text so it can
             be stored as report lines

  ipconfig
    Where:   Option 4
    Purpose: Retrieves the local machine's network configuration

  Get-Date
    Where:   All report headers, and inside Save-TestReport for the
             filename timestamp
    Purpose: Timestamps the report and its filename


--------------------------------------------------------------------
 FILES IN THIS FOLDER
--------------------------------------------------------------------

  - NetworkTester2.1.1.ps1  - the script itself (current version)
  - NetworkTester2.1.1.exe  - the executable of the script
  - README.txt              - an explanation of the program


--------------------------------------------------------------------
 VERSION HISTORY
--------------------------------------------------------------------

  2.1.2 - Added a 4th menu option to capture ipconfig /all output
  2.1.1 - Fixed a bug that prevented a report from being generated
          for the HTTP and Network share connectivity tests
  2.1.0 - Added PSDrive to the network share folder test
  2.0.1 - Added the "Please wait..." messages
