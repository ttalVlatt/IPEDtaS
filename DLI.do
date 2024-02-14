**----------------------------------------------------------------------------**
**
** PROJ: DLI: Download Labeled IPEDS
** FILE: DLI.do
** INIT: February 14 2024
** AUTH: Matt Capaldi
** CRED: Benjamin T. Skinner
**
**----------------------------------------------------------------------------**

clear

** Set working directory to DLI folder


** Set up options



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
	
	** Run the .do file from IPEDS
	do `file'
	
	** Write the labaled data file as .dta
	save ../labeled-data/`dta_name', replace
	
	** Clear the data from memory before next loop
	clear

}
	
cd ..

clear
