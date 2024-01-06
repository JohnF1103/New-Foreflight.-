User manual/install instructions 


1) System setup: 

	Ensure you have a system capable of running macOS 13 or greater as well as 	Xcode 15
	(This project was created on macOS 14.2.1 using Xcode 15.1)


2) Cloning the repo:

	Clone the following repo link into a local directory on your system 

	https://github.com/JohnF1103/New-Foreflight.-.git

	Next open the file labeled New_Foreflight.xcodeproj in Xcode 



3) Package Dependencies Deployment targets:
	to ensure a smooth experience if not aded by default add the following package 	dependency https://github.com/JonathanDowning/SwiftMETAR.git
	This package is used to parse METAR output from the API into objects.

	project -> add package dependency -> paste the GitHub link into the search 	bar. 

	Also make sure to set the app deployment target to iOS 17.2

5) From here the app should be all set to run. The main content view features an interactive map with labeled airports that supports GEOjson overlays of class B airspaces, special-use airspaces, military TFRs, and ATC boundaries.

Currently clicking on an airport supports live METAR, updated approach/Departure/IAP plates, live frequency data with an interactive selector, as well as airport diagrams using the foreflight API. 

**Please keep in mind still a work in progress, Support for live NOTAM data, and flight planning to come in the next few days. 
