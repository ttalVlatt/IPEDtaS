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

This project is an extension of @btskinner's downloadipeds.R to automagically
download labeled .dta versions of IPEDS data files, which can then be used for
analysis in Stata or R (via haven)

First, this script first calls DWI.R, which downloads and prepares IPEDS data.
If you are not running a version of Stata locally installed on your computer, it
will be easier to first run DWI.R separately to download and set up the files,
then run this script with lines 40 and 42 commented out

Second, this script loops through these prepared files running (modified) .do 
scripts from IPEDS to make labeled .dta copies of the data in the 
labeled-data sub-folder

Note: Part of this process replaces original data files with _rv revised
versions if available, the resulting file uses the original name without _rv

To Run

0. You will need an installation of R which can be downloaded from https://cran.rstudio.com

1. Un-comment the files you want from ipeds-file-list.txt (remove ## from name)
	Hint: in many text editors you can hold alt to drag a cursor to multiple
	lines at once, so you can comment/un-comment many lines at once

2. Ensure the working directory is set to the main DLI folder

3. Hit "Do"

*/

** Install rscript package, more info at https://github.com/reifjulian/rscript
net install rscript, from("https://raw.githubusercontent.com/reifjulian/rscript/master")
** Source R script
rscript using DLI.R
** Optional: specify path to R with , rpath() but rscript checks usual locations

** Development Opportunity: Stata-ify the R code to run entirely within Stata

** Clear any data currently stored
clear	

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
	
	** Only run .do file to label if the file doesn't exist
	if(!fileexists("../labeled-data/`dta_name'")) {
	
		** Run the modified .do file from IPEDS
		do `file'
	
		** Write the labaled data file as .dta
		save ../labeled-data/`dta_name', replace
	
	}
	
	** Clear the data from memory before next loop
	clear

}
	
cd ..

** Clear any data currently stored
clear

** Delete downloaded files (optional: un-comment to run and save storage space)
*shell rm -r stata-data
*shell rm -r stata-dofiles
*shell rm -r unzip-stata-data
*shell rm -r unzip-stata-dofiles

** If on Windows without Unix shell, use "shell rmdir stata-data" etc.
