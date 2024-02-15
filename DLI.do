**----------------------------------------------------------------------------**
**
** [PROJ: DLI: Download Labeled IPEDS]
** [FILE: DLI.do]
** [INIT: February 14 2024]
** [AUTH: Matt Capaldi] @ttalVlatt
** [CRED: Benjamin T. Skinner] @btskinner
**
**----------------------------------------------------------------------------**

/* 

This project is an extension of @btskinner's downloadipeds.R to auto-magically
download labeled .dta versions of IPEDS data files, which can then be used for
analysis in Stata or R (via haven)

First, this script first calls DWI.R, which downloads and prepares IPEDS data.
If you are not running a version of Stata locally installed on your computer, it
will be easier to first run DWI.R separately to download and set up the files,
then run this script with line xxx commented out

Second, this script loops through these prepared files running .do scripts to 
make labeled .dta copies of the data in the labeled-data/ sub-folder

Note: Part of this process replaces original data files with _rv revised
versions if available, but the resulting file uses the og name without _rv

*/

clear

** Ensure the working directory is set to the main DLI folder

** Source R script
** Development Opportunity: STATA-ify the R code to run entirely within STATA


	** Shell appears to start at current working directory, need confirmation

** Change directory to .do files folder
cd unzip-stata-dofiles

** List the downloaded .do files
local files_list: dir . files "*.do"

di `files_list'

foreach file in `files_list' {
	
    ** Take file name as a "string" as convert .do to .dta
    local do_name: di "`file'"
	di "`do_name'"
	local dta_name : subinstr local do_name ".do" ".dta"
	di "`dta_name'"
	** h/t https://stackoverflow.com/questions/17388874/how-to-get-rid-of-the-extensions-in-stata-loop
	
	** Run the modified .do file from IPEDS
	do `file'
	
	** Write the labaled data file as .dta
	save ../labeled-data/`dta_name', replace
	
	** Clear the data from memory before next loop
	clear

}
	
cd ..

clear
