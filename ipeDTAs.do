**----------------------------------------------------------------------------**
**
** [PROJ: ipeDTAs: Automagically download labeled .dta IPEDS files]
** [FILE: ipeDTAs.do]
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

**----------------------------------------------------------------------------**
** Select the Files to Download
**----------------------------------------------------------------------------**

local selected_files ///
"HD2022" ///
"IC2022" ///
"IC2022_AY" ///
"IC2022_PY" ///
"IC2022_CAMPUSES" ///
"EFFY2018"

**----------------------------------------------------------------------------**
** Create Folders
**----------------------------------------------------------------------------**

* Make folders if they don't exist
capture confirm file "raw-data"
if _rc mkdir "raw-data"
capture confirm file "unzip-data"
if _rc mkdir "unzip-data"
capture confirm file "dta-data"
if _rc mkdir "dta-data"
capture confirm file "raw-dofiles"
if _rc mkdir "raw-dofiles"
capture confirm file "unzip-dofiles"
if _rc mkdir "unzip-dofiles"
capture confirm file "fixed-dofiles"
if _rc mkdir "fixed-dofiles"
capture confirm file "raw-dictionary"
if _rc mkdir "raw-dictionary"
capture confirm file "unzip-dictionary"
if _rc mkdir "unzip-dictionary"
* h/t https://www.statalist.org/forums/forum/general-stata-discussion/general/1344241-check-if-directory-exists-before-running-mkdir

**----------------------------------------------------------------------------**
** Loops to Download the .zip Files
**----------------------------------------------------------------------------**

* Loop through getting the .csv files
foreach file in "`selected_files'" {

	if(!fileexists("raw-data/`file'_Data_Stata.zip")) {
	
    di "Downloading: `file' .csv File"
    copy "https://nces.ed.gov/ipeds/datacenter/data/`file'_Data_Stata.zip" "raw-data/`file'_Data_Stata.zip"
	
	* Wait for three seconds between files
	sleep 3000
	
	}
	
}

* Loop through getting the .do files
foreach file in "`selected_files'" {

	if(!fileexists("raw-dofiles/`file'_Stata.zip")) {
	
    di "Downloading: `file' .do File"
    copy "https://nces.ed.gov/ipeds/datacenter/data/`file'_Stata.zip" "raw-dofiles/`file'_Stata.zip"
	
	* Wait for three seconds between files
	sleep 3000
	
	}
	
}

* Loop through getting the dictionary files
foreach file in "`selected_files'" {

	if(!fileexists("raw-dictionary/`file'_Dict.zip")) {
	
    di "Downloading: `file' Dictionary"
    copy "https://nces.ed.gov/ipeds/datacenter/data/`file'_Dict.zip" "raw-dictionary/`file'_Dict.zip"
	
	* Wait for three seconds between files
	sleep 3000
	
	}
	
}

**----------------------------------------------------------------------------**
** Loops to Unzip the .zip Files
**----------------------------------------------------------------------------**

* .csv Files
cd raw-data

local files_list: dir . files "*.zip"

cd ../unzip-data

foreach file in `files_list' {
	
	unzipfile ../raw-data/`file'
	
}

* .do Files
cd ../raw-dofiles

local files_list: dir . files "*.zip"

cd ../unzip-dofiles

foreach file in `files_list' {
	
	unzipfile ../raw-dofiles/`file'
	
}

* Dictionary Files
cd ../raw-dictionary

local files_list: dir . files "*.zip"

cd ../unzip-dictionary

foreach file in `files_list' {
	
	unzipfile ../raw-dictionary/`file'
	
}

cd ..

**----------------------------------------------------------------------------**
** If _rv file exists replace original data with it
**----------------------------------------------------------------------------**

cd unzip-data

local files_list: dir . files "*_rv*.csv"

foreach file in `files_list' {
	
	local rv_name: di "`file'"
	local og_name: subinstr local rv_name "_rv" ""
	
	di "Replacing `og_name' with `rv_name'"
	
	erase "`og_name'"
	
	_renamefile "`rv_name'" "`og_name'"
	
}

* https://www.statalist.org/forums/forum/general-stata-discussion/general/1422353-trouble-renaming-files-using-renfiles-command

cd ..

**----------------------------------------------------------------------------**
** Fix the .do files Using pystata: Common Issues
**----------------------------------------------------------------------------**

cd unzip-dofiles

python

import re
import os

files_list = os.listdir()

for i in files_list:

	print("Fixing " + i)
	
	file = open(i, "r", encoding='latin-1')
	do_file = file.readlines()
	
	file_name = re.sub(".do", "", i)
	
	## Replace insheet line with updated file path

	pattern = re.compile("^\s?insheet")
	new_insheet = "".join(['insheet using "../unzip-data/', file_name, '_data_stata.csv", comma clear \n'])

	for index, line in enumerate(do_file):
		if re.match(pattern, line):
			do_file[index] = new_insheet
	
	
	## Remove problematic lines by index
		
	index_to_delete = []
	
	## Index lines that save data
	pattern = re.compile("^\s?save")

	for index, line in enumerate(do_file):
		if re.match(pattern, line):
			index_to_delete.append(index)
	
	## Index lines that tab data
	pattern = re.compile("^\s?tab")

	for index, line in enumerate(do_file):
		if re.match(pattern, line):
			index_to_delete.append(index)
			
	## Index lines that summarize data
	pattern = re.compile("^\s?summarize")

	for index, line in enumerate(do_file):
		if re.match(pattern, line):
			index_to_delete.append(index)
			
	## Identify problematic attempts to label strings
	
	label_string_vars = []

	## Variable that start with anything but a digit or - sign
	pattern = re.compile("^label define\s+\w+\s+[^0-9-].*")	
	
	for index, line in enumerate(do_file):
		if re.match(pattern, line):
			label_string_vars.append(line.split(" ")[2])

	## Variables that start with a digit or minus sign, but end in letter (e.g., 11A)
	pattern = re.compile("^label define\s+\w+\s+\b-?\d+[A-Za-z]\b.*")	
	
	for index, line in enumerate(do_file):
		if re.match(pattern, line):
			label_string_vars.append(line.split(" ")[2])
			
	## Get unique list of vars
	label_string_vars = list(set(label_string_vars))
	
	print(len(set(label_string_vars)))
	
	## Prevents loop activating when no problematic vars, as regex becomes ".*"
	if len(set(label_string_vars)) > 0:
	
		## Create regex pattern from the list of variables
		pattern = "|".join(label_string_vars)
		## h/t https://stackoverflow.com/questions/21292552/equivalent-of-paste-r-to-python
		pattern = ".*" + pattern
		pattern = re.compile(pattern)
	
		for index, line in enumerate(do_file):
			if re.match(pattern, line):
				index_to_delete.append(index)
				
		print("String var loop activated for " + i)
	
	
	## Get unique indexes
	index_to_delete = list(set(index_to_delete))
	
	print("# Lines to Delete: " + str(len(index_to_delete)))

	print("# Lines in .do file: " + str(len(do_file)))	

	## Delete problematic lines by index
	for index in sorted(index_to_delete, reverse = True):
		do_file[index] = "*/ \n"
	
	print("# Lines in cut .do file: " + str(len(do_file)))
	
	## Write the updated .do file
	
	fixed_file_name = "../fixed-dofiles/" + i
	fixed_file = open(fixed_file_name, "w", encoding='latin-1')
	file.seek(0) ## Move lines editor back to start, h/t ChatGPT
	fixed_file.writelines(do_file)
	
end
	
**----------------------------------------------------------------------------**
** Fix the .do files Using pystata: Misc. Issues
**----------------------------------------------------------------------------**

cd ../fixed-dofiles

/* 
Create python function that re-writes individual lines of .do files to fix
misc. issues, such as lines that misspell a variable, are broken up, etc.
*/

python	

def do_fix(do_file_name, line_to_replace, replacement):
	
	if os.path.exists(do_file_name):
		file = open(do_file_name, "r", encoding='latin-1')
		do_file = file.readlines()
		
		do_file[line_to_replace - 1] = replacement
		
		file.close()
		
		file = open(do_file_name, "w", encoding='latin-1')
		file.writelines(do_file)
		
	else:
		
		print("Not in fixed-dofiles : " + do_file_name) 

# /* Still runs: stop Stata syntax highlighting endless do_fix python code below

do_fix("gr2021_pell_ssl.do", 81, 'label define label_psgrtype 1 "Total 2015 cohort (Bachelor^s and other degree/certificate seeking) - four-year institutions",add')
do_fix("gr2021_pell_ssl.do", 82, '')
do_fix("gr2021_pell_ssl.do", 83, 'label define label_psgrtype 2 "Bachelor^s degree seeking 2015 cohort - four-year institutions",add')
do_fix("gr2021_pell_ssl.do", 84, '')
do_fix("gr2021_pell_ssl.do", 85, 'label define label_psgrtype 3 "Other degree/certificate seeking 2015 cohort - four-year institutions",add')
do_fix("gr2021_pell_ssl.do", 86, '')
do_fix("gr2021_pell_ssl.do", 87, 'label define label_psgrtype 4 "Degree/certificate seeking 2018 cohort (less than four-year institutions)",add')
do_fix("gr2021_pell_ssl.do", 88, '')

## Imputation variable names had extra character than in data
do_fix("ef2022a.do", 96, 'label variable xefgndru "Imputation field for efgndrun - Gender unknown"')
do_fix("ef2022a.do", 98, 'label variable xefgndra "Imputation field for efgndran - Another gender"')
do_fix("ef2022a.do", 100, 'label variable xefgndru "Imputation field for efgndrua - Total of gender unknown and another gender"')
do_fix("ef2022a.do", 102, 'label variable xefgndrk "Imputation field for efgndrkn - Total gender reported as one of the mutually exclusive binary categories (Men/Women)"')

## Similar issue to gr_2021_pell_ssl of broken lines
do_fix("gr2000_l2.do", 36, 'label variable xline_50 "Imputation field for LINE_50 - Adjusted cohort (revised cohort minus exclusions)"')
do_fix("gr2000_l2.do", 37, '')
do_fix("gr2000_l2.do", 38, 'label variable line_50 "Adjusted cohort (revised cohort minus exclusions)"')
do_fix("gr2000_l2.do", 39, '')
do_fix("gr2000_l2.do", 40, 'label variable xline_11 "Imputation field for LINE_11 - Completers within 150% of normal time"')
do_fix("gr2000_l2.do", 41, '')
do_fix("gr2000_l2.do", 42, 'label variable line_11 "Completers within 150% of normal time"')
do_fix("gr2000_l2.do", 43, '')

## Broken lines
do_fix("ic2002.do", 408, 'label define label_regaccrd 7 "Northwest Assoc. of Schools and of Colleges and Univ.", add ')
do_fix("ic2002.do", 409, '')
do_fix("ic2002.do", 410, 'label define label_regaccrd 8 "Southern Association of Colleges and Schools, Comm. on Colleges", add ')
do_fix("ic2002.do", 411, '')
do_fix("ic2002.do", 412, '')

## Attempts to apply labels, about the imputation status, to the imputation variable,
## but using number from the actual value... Beyond repair
do_fix("c9798_b.do", 92, '/*')
do_fix("c9798_b.do", 541, '*/')

## Data is formatted with ' and ; around the numbers, making Stata think it's a string
## Beyond repiar
do_fix("ic99_actot.do", 33, '/*')
do_fix("ic99_actot.do", 117, '*/')

## Imputation variable mixup
do_fix("s97_cn.do", 76, 'label values staff15 label_xstaff15')
do_fix("s97_cn.do", 92, 'label values staff16 label_xstaff16')

## Imputation variable mixup
do_fix("ef98_anr.do", 119, 'label values efrace01 label_xef01')
do_fix("ef98_anr.do", 134, 'label values efrace02 label_xef02')
do_fix("ef98_anr.do", 149, 'label values efrace03 label_xef03')
do_fix("ef98_anr.do", 164, 'label values efrace04 label_xef04')
do_fix("ef98_anr.do", 179, 'label values efrace05 label_xef05')
do_fix("ef98_anr.do", 194, 'label values efrace06 label_xef06')
do_fix("ef98_anr.do", 209, 'label values efrace07 label_xef07')
do_fix("ef98_anr.do", 224, 'label values efrace08 label_xef08')
do_fix("ef98_anr.do", 239, 'label values efrace09 label_xef09')
do_fix("ef98_anr.do", 254, 'label values efrace10 label_xef10')
do_fix("ef98_anr.do", 269, 'label values efrace11 label_xef11')
do_fix("ef98_anr.do", 284, 'label values efrace12 label_xef12')
do_fix("ef98_anr.do", 299, 'label values efrace13 label_xef13')
do_fix("ef98_anr.do", 314, 'label values efrace14 label_xef14')
do_fix("ef98_anr.do", 329, 'label values efrace15 label_xef15')
do_fix("ef98_anr.do", 344, 'label values efrace16 label_xef16')

## Broken lines
do_fix("ic2003.do", 406, 'label define label_regaccrd 7 "Northwest Assoc. of Schools and of Colleges and Univ.", add')
do_fix("ic2003.do", 407, '')
do_fix("ic2003.do", 408, 'label define label_regaccrd 8 "Southern Association of Colleges and Schools, Comm. on Colleges", add ')
do_fix("ic2003.do", 409, '')
do_fix("ic2003.do", 410, '')

## Broken Line
do_fix("fa2000hd.do", 412, 'label define label_pseflag 2 "not primarily postsec or open to public", add ')
do_fix("fa2000hd.do", 413, '')

## Broken Line
do_fix("gr1997_l2.do", 36, 'label variable xline_50 "Imputation field for LINE_50 - Adjusted cohort (revised cohort minus exclusions)"')
do_fix("gr1997_l2.do", 37, '')
do_fix("gr1997_l2.do", 38, 'label variable line_50 "Adjusted cohort (revised cohort minus exclusions)"')
do_fix("gr1997_l2.do", 39, '')
do_fix("gr1997_l2.do", 40, 'label variable xline_11 "Imputation field for LINE_11 - Completers within 150% of normal time"')
do_fix("gr1997_l2.do", 41, '')
do_fix("gr1997_l2.do", 42, 'label variable line_11 "Completers within 150% of normal time"')
do_fix("gr1997_l2.do", 43, '')

## Two labels for same value, combine
do_fix("ef1986_acp.do", 36, '')
do_fix("ef1986_acp.do", 37, '')
do_fix("ef1986_acp.do", 116, 'label define label_xefrac01 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 117, '')
do_fix("ef1986_acp.do", 123, 'label define label_xefrac02 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 124, '')
do_fix("ef1986_acp.do", 130, 'label define label_xefrac03 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 131, '')
do_fix("ef1986_acp.do", 137, 'label define label_xefrac04 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 138, '')
do_fix("ef1986_acp.do", 144, 'label define label_xefrac05 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 145, '')
do_fix("ef1986_acp.do", 151, 'label define label_xefrac06 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 152, '')
do_fix("ef1986_acp.do", 158, 'label define label_xefrac07 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 159, '')
do_fix("ef1986_acp.do", 165, 'label define label_xefrac08 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 166, '')
do_fix("ef1986_acp.do", 172, 'label define label_xefrac09 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 173, '')
do_fix("ef1986_acp.do", 179, 'label define label_xefrac10 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 180, '')
do_fix("ef1986_acp.do", 186, 'label define label_xefrac11 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 187, '')
do_fix("ef1986_acp.do", 193, 'label define label_xefrac12 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 194, '')
do_fix("ef1986_acp.do", 200, 'label define label_xefrac15 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 201, '')
do_fix("ef1986_acp.do", 207, 'label define label_xefrac16 12 "Adjusted/Generated data", add ')
do_fix("ef1986_acp.do", 208, '')

## Broken Line
do_fix("sal1985_a.do", 66, 'label define label_line 8 "12-month contracts professors", add ')
do_fix("sal1985_a.do", 67, '')

## Broken Line
do_fix("gr2001_l2.do", 36, 'label variable xline_50 "Imputation field for LINE_50 - Adjusted cohort (revised cohort minus exclusions)"')
do_fix("gr2001_l2.do", 37, '')
do_fix("gr2001_l2.do", 38, 'label variable line_50 "Adjusted cohort (revised cohort minus exclusions)"')
do_fix("gr2001_l2.do", 39, '')
do_fix("gr2001_l2.do", 40, 'label variable xline_11 "Imputation field for LINE_11 - Completers within 150% of normal time"')
do_fix("gr2001_l2.do", 41, '')
do_fix("gr2001_l2.do", 42, 'label variable line_11 "Completers within 150% of normal time"')
do_fix("gr2001_l2.do", 43, '')

## Broken Line
do_fix("sal2002_a.do", 55, 'label define label_contract 4 "Equated 9-month contract", add ')
do_fix("sal2002_a.do", 56, '')
do_fix("sal2002_a.do", 57, '')

## Broken Line
do_fix("ic1989_b.do", 75, 'label variable avgamt1 "Average books/supplieds cost Books and supplies"')
do_fix("ic1989_b.do", 76, '')
do_fix("ic1989_b.do", 77, 'label variable avgamt2 "Average transpotation cost Books and supplies"')
do_fix("ic1989_b.do", 78, '')
do_fix("ic1989_b.do", 79, 'label variable avgamt3 "Average room and board cost (non-dorm) Books and supplies"')
do_fix("ic1989_b.do", 80, '')
do_fix("ic1989_b.do", 81, 'label variable avgamt4 "Average miscellaneous expenses Books and supplies"')
do_fix("ic1989_b.do", 82, '')


## Two labels for same value, combine
do_fix("res1986_ic.do", 47, 'label define label_xefres01 12 "Adjusted/Generated data", add ')
do_fix("res1986_ic.do", 48, '')
do_fix("res1986_ic.do", 54, 'label define label_xefres02 12 "Adjusted/Generated data", add ')
do_fix("res1986_ic.do", 55, '')
do_fix("res1986_ic.do", 61, 'label define label_xefres03 12 "Adjusted/Generated data", add ')
do_fix("res1986_ic.do", 62, '')
do_fix("res1986_ic.do", 68, 'label define label_xefres04 12 "Adjusted/Generated data", add ')
do_fix("res1986_ic.do", 69, '')
do_fix("res1986_ic.do", 75, 'label define label_xefres05 12 "Adjusted/Generated data", add ')
do_fix("res1986_ic.do", 76, '')

## Broken Line
do_fix("ic1988_b.do", 97, 'label variable avgamt1 "Average books/supplieds cost Books and supplies"')
do_fix("ic1988_b.do", 98, '')
do_fix("ic1988_b.do", 99, 'label variable avgamt2 "Average transpotation cost Books and supplies"')
do_fix("ic1988_b.do", 100, '')
do_fix("ic1988_b.do", 101, 'label variable avgamt3 "Average room and board cost (non-dorm) Books and supplies"')
do_fix("ic1988_b.do", 102, '')
do_fix("ic1988_b.do", 103, 'label variable avgamt4 "Average miscellaneous expenses Books and supplies"')
do_fix("ic1988_b.do", 104, '')

## Broken Line
do_fix("sal2003_a.do", 55, 'label define label_contract 4 "Equated 9-month contract", add')
do_fix("sal2003_a.do", 56, '')
do_fix("sal2003_a.do", 57, '')

## Broken Line
do_fix("ef99_b.do", 33, 'label variable lstudy "Level of student"')
do_fix("ef99_b.do", 34, '')

## Invalid values
do_fix("ef98_c.do", 101, '/*')
do_fix("ef98_c.do", 130, '*/')

## Broken Line
do_fix("sal1984_a.do", 33, 'label variable line "Faculty Line Type"')
do_fix("sal1984_a.do", 34, '')
do_fix("sal1984_a.do", 66, 'label define label_line 8 "12-month contract professors", add ')
do_fix("sal1984_a.do", 67, '')

## Broken Line
do_fix("f0203_f1a.do", 34, 'label variable xf1a02 "Imputation field for F1A02 - Capital assets - depreciable (gross)"')
do_fix("f0203_f1a.do", 35, '')
do_fix("f0203_f1a.do", 36, 'label variable f1a02 "Capital assets - depreciable (gross)"')
do_fix("f0203_f1a.do", 37, '')
do_fix("f0203_f1a.do", 258, 'label variable xf1c101 "Imputation field for F1C101 - Scholarships and fellowships expenses -- Current year total"')
do_fix("f0203_f1a.do", 259, '')
do_fix("f0203_f1a.do", 260, 'label variable f1c101 "Scholarships and fellowships expenses -- Current year total"')
do_fix("f0203_f1a.do", 261, '')
do_fix("f0203_f1a.do", 264, 'label variable xf1c103 "Imputation field for F1C103 - Scholarships and fellowships expenses -- Employee fringe benefits"')
do_fix("f0203_f1a.do", 265, '')
do_fix("f0203_f1a.do", 266, 'label variable f1c103 "Scholarships and fellowships expenses -- Employee fringe benefits"')
do_fix("f0203_f1a.do", 267, '')
do_fix("f0203_f1a.do", 268, 'label variable xf1c104 "Imputation field for F1C104 - Scholarships and fellowships expenses -- Depreciation"')
do_fix("f0203_f1a.do", 269, '')
do_fix("f0203_f1a.do", 270, 'label variable f1c104 "Scholarships and fellowships expenses -- Depreciation"')
do_fix("f0203_f1a.do", 271, '')
do_fix("f0203_f1a.do", 272, 'label variable xf1c105 "Imputation field for F1C105 - Scholarships and fellowships expenses -- All other"')
do_fix("f0203_f1a.do", 273, '')
do_fix("f0203_f1a.do", 274, 'label variable f1c105 "Scholarships and fellowships expenses -- All other"')
do_fix("f0203_f1a.do", 275, '')

## Broken Line
do_fix("ic1987_b.do", 133, 'label variable avgamt1 "Average books/supplieds cost Books and supplies"')
do_fix("ic1987_b.do", 134, '')
do_fix("ic1987_b.do", 135, 'label variable avgamt2 "Average transpotation cost Books and supplies"')
do_fix("ic1987_b.do", 136, '')
do_fix("ic1987_b.do", 137, 'label variable avgamt3 "Average room and board cost (non-dorm) Books and supplies"')
do_fix("ic1987_b.do", 138, '')
do_fix("ic1987_b.do", 139, 'label variable avgamt4 "Average miscellaneous expenses Books and supplies"')
do_fix("ic1987_b.do", 140, '')

## Data is formatted with ' and ; around the numbers, making Stata think it's a string
## Beyond repair
do_fix("ic2000_actot.do", 33, '/*')
do_fix("ic2000_actot.do", 134, '*/')

## Broken Line
do_fix("gr1998_l2.do", 36, 'label variable xline_50 "Imputation field for LINE_50 - Adjusted cohort (revised cohort minus exclusions)"')
do_fix("gr1998_l2.do", 37, '')
do_fix("gr1998_l2.do", 38, 'label variable line_50 "Adjusted cohort (revised cohort minus exclusions)"')
do_fix("gr1998_l2.do", 39, '')
do_fix("gr1998_l2.do", 40, 'label variable xline_11 "Imputation field for LINE_11 - Completers within 150% of normal time"')
do_fix("gr1998_l2.do", 41, '')
do_fix("gr1998_l2.do", 42, 'label variable line_11 "Completers within 150% of normal time"')
do_fix("gr1998_l2.do", 43, '')

## Attempts to apply labels, about the imputation status, to the imputation variable,
## but using number from the actual value... Beyond repair
do_fix("ic98_d.do", 174, '/*')
do_fix("ic98_d.do", 218, '*/')
do_fix("ic98_d.do", 517, '/*')
do_fix("ic98_d.do", 547, '*/')
do_fix("ic98_d.do", 792, '/*')
do_fix("ic98_d.do", 836, '*/')
do_fix("ic98_d.do", 1066, '/*')
do_fix("ic98_d.do", 1110, '*/')
do_fix("ic98_d.do", 1325, '/*')
do_fix("ic98_d.do", 1369, '*/')
do_fix("ic98_d.do", 1568, '/*')
do_fix("ic98_d.do", 1613, '*/')
do_fix("ic98_d.do", 1796, '/*')
do_fix("ic98_d.do", 2425, '*/')

## Broken Line
do_fix("hd2009.do", 351, 'label define label_pset4flg 2 "Non-Title IV postsecondary institution", add ')
do_fix("hd2009.do", 352, '')
do_fix("hd2009.do", 353, 'label define label_pset4flg 3 "Title IV NOT primarily postsecondary institution", add')
do_fix("hd2009.do", 354, '')
do_fix("hd2009.do", 355, 'label define label_pset4flg 4 "Non-Title IV NOT primarily postsecondary institution", add')
do_fix("hd2009.do", 356, '')
do_fix("hd2009.do", 358, 'label define label_pset4flg 6 "Non-Title IV postsecondary institution that is NOT open to the public", add ')
do_fix("hd2009.do", 359, '')
do_fix("hd2009.do", 360, 'label define label_pset4flg 9 "Institution is not active in current universe", add ')
do_fix("hd2009.do", 361, '')
do_fix("hd2009.do", 374, 'label define label_instcat 4 "Degree-granting, associates and certificates", add ')
do_fix("hd2009.do", 375, '')

## Attempts to apply labels, about the imputation status, to the imputation variable,
## but using number from the actual value... Beyond repair
do_fix("ic98_e.do", 62, '/*')
do_fix("ic98_e.do", 276, '*/')

## Broken Line
do_fix("f0102_f1a.do", 32, 'label variable xf1a01 "Imputation field for F1A01 - Total Current Assets"')
do_fix("f0102_f1a.do", 33, '')
do_fix("f0102_f1a.do", 34, 'label variable f1a01 "Total Current Assets"')
do_fix("f0102_f1a.do", 35, '')
do_fix("f0102_f1a.do", 36, 'label variable xf1a02 "Imputation field for F1A02 - Capital assets - depreciable (gross)"')
do_fix("f0102_f1a.do", 37, '')
do_fix("f0102_f1a.do", 38, 'label variable f1a02 "Capital assets - depreciable (gross)"')
do_fix("f0102_f1a.do", 39, '')
do_fix("f0102_f1a.do", 260, 'label variable xf1c101 "Imputation field for F1C101 - Scholarships and fellowships expenses -- Current year total"')
do_fix("f0102_f1a.do", 261, '')
do_fix("f0102_f1a.do", 262, 'label variable f1c101 "Scholarships and fellowships expenses -- Current year total"')
do_fix("f0102_f1a.do", 263, '')
do_fix("f0102_f1a.do", 266, 'label variable xf1c103 "Imputation field for F1C103 - Scholarships and fellowships expenses -- Employee fringe benefits"')
do_fix("f0102_f1a.do", 267, '')
do_fix("f0102_f1a.do", 268, 'label variable f1c103 "Scholarships and fellowships expenses -- Employee fringe benefits"')
do_fix("f0102_f1a.do", 269, '')
do_fix("f0102_f1a.do", 270, 'label variable xf1c104 "Imputation field for F1C104 - Scholarships and fellowships expenses -- Depreciation"')
do_fix("f0102_f1a.do", 271, '')
do_fix("f0102_f1a.do", 272, 'label variable f1c104 "Scholarships and fellowships expenses -- Depreciation"')
do_fix("f0102_f1a.do", 273, '')
do_fix("f0102_f1a.do", 274, 'label variable xf1c105 "Imputation field for F1C105 - Scholarships and fellowships expenses -- All other"')
do_fix("f0102_f1a.do", 275, '')
do_fix("f0102_f1a.do", 276, 'label variable f1c105 "Scholarships and fellowships expenses -- All other"')
do_fix("f0102_f1a.do", 277, '')

## One institution put X which makes Stata think vars are a string
do_fix("sal1989_b.do", 81, '/*')
do_fix("sal1989_b.do", 86, '*/')

## Broken Line
do_fix("ic1989_a.do", 196, 'label variable acc98 "Rehabilitation Training (occupational skills training in rehabilitation organizations)"')
do_fix("ic1989_a.do", 197, '')
do_fix("ic1989_a.do", 198, '')

## Broken Line
do_fix("ef2002b.do", 34, 'label variable lstudy "Level of student"')
do_fix("ef2002b.do", 35, '')

## Broken Line
do_fix("ef2003b.do", 34, 'label variable lstudy "Level of student"')
do_fix("ef2003b.do", 35, '')

## Broken Line
do_fix("ef2003b.do", 34, 'label variable lstudy "Level of student"')
do_fix("ef2003b.do", 35, '')

## One institution put X which makes Stata think vars are a string
do_fix("ic2001_py.do", 322, '/*')
do_fix("ic2001_py.do", 615, '*/')

## Two labels for same value, combine
do_fix("ef1986_a.do", 104, 'label define label_xefrac01 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 105, '')
do_fix("ef1986_a.do", 111, 'label define label_xefrac02 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 112, '')
do_fix("ef1986_a.do", 118, 'label define label_xefrac03 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 119, '')
do_fix("ef1986_a.do", 125, 'label define label_xefrac04 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 126, '')
do_fix("ef1986_a.do", 132, 'label define label_xefrac05 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 133, '')
do_fix("ef1986_a.do", 139, 'label define label_xefrac06 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 140, '')
do_fix("ef1986_a.do", 146, 'label define label_xefrac07 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 147, '')
do_fix("ef1986_a.do", 153, 'label define label_xefrac08 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 154, '')
do_fix("ef1986_a.do", 160, 'label define label_xefrac09 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 161, '')
do_fix("ef1986_a.do", 167, 'label define label_xefrac10 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 168, '')
do_fix("ef1986_a.do", 174, 'label define label_xefrac11 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 175, '')
do_fix("ef1986_a.do", 181, 'label define label_xefrac12 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 182, '')
do_fix("ef1986_a.do", 188, 'label define label_xefrac15 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 189, '')
do_fix("ef1986_a.do", 195, 'label define label_xefrac16 12 "Adjusted/Generated data", add')
do_fix("ef1986_a.do", 196, '')

## Broken Line
do_fix("gr1999_l2.do", 36, 'label variable xline_50 "Imputation field for LINE_50 - Adjusted cohort (revised cohort minus exclusions)"')
do_fix("gr1999_l2.do", 37, '')
do_fix("gr1999_l2.do", 38, 'label variable line_50 "Adjusted cohort (revised cohort minus exclusions)"')
do_fix("gr1999_l2.do", 39, '')
do_fix("gr1999_l2.do", 40, 'label variable xline_11 "Imputation field for LINE_11 - Completers within 150% of normal time"')
do_fix("gr1999_l2.do", 41, '')
do_fix("gr1999_l2.do", 42, 'label variable line_11 "Completers within 150% of normal time"')
do_fix("gr1999_l2.do", 43, '')

## Broken Line
do_fix("hd2003.do", 441, 'label define label_pset4flg 2 "Non-Title IV postsecondary institution", add ')
do_fix("hd2003.do", 442, '')
do_fix("hd2003.do", 443, 'label define label_pset4flg 3 "Title IV NOT primarily postsecondary institution", add')
do_fix("hd2003.do", 444, '')
do_fix("hd2003.do", 445, 'label define label_pset4flg 4 "Non-Title IV NOT primarily postsecondary institution", add')
do_fix("hd2003.do", 446, '')
do_fix("hd2003.do", 447, 'label define label_pset4flg 5 "Non-Title IV NOT primarily postsecondary institution", add')
do_fix("hd2003.do", 448, '')
do_fix("hd2003.do", 449, 'label define label_pset4flg 6 "Non-Title IV postsecondary institution that is NOT open to the public", add ')
do_fix("hd2003.do", 450, '')
do_fix("hd2003.do", 451, 'label define label_pset4flg 9 "Institution is not active in current universe", add ')
do_fix("hd2003.do", 452, '')

## Broken Line
do_fix("sal1980_a.do", 53, 'label define label_arank 8 "12-month contracts professors", add ')
do_fix("sal1980_a.do", 54, '')

## Broken Line
do_fix("hd2002.do", 436, 'label define label_pset4flg 2 "Non-Title IV postsecondary institution", add ')
do_fix("hd2002.do", 437, '')
do_fix("hd2002.do", 438, 'label define label_pset4flg 3 "Title IV NOT primarily postsecondary institution", add')
do_fix("hd2002.do", 439, '')
do_fix("hd2002.do", 440, 'label define label_pset4flg 4 "Non-Title IV NOT primarily postsecondary institution", add')
do_fix("hd2002.do", 441, '')
do_fix("hd2002.do", 442, 'label define label_pset4flg 5 "Non-Title IV NOT primarily postsecondary institution", add')
do_fix("hd2002.do", 443, '')
do_fix("hd2002.do", 444, 'label define label_pset4flg 6 "Non-Title IV postsecondary institution that is NOT open to the public", add ')
do_fix("hd2002.do", 445, '')
do_fix("hd2002.do", 446, 'label define label_pset4flg 9 "Institution is not active in current universe", add ')
do_fix("hd2002.do", 447, '')

## Imputation vars 
do_fix("ic2001_ay.do", 1126, '/*')
do_fix("ic2001_py.do", 1503, '*/')

## Duplicate attempts to label values
do_fix("ic1980.do", 958, '')
do_fix("ic1980.do", 1219, '/*')
do_fix("ic1980.do", 1225, '*/')
do_fix("ic1980.do", 2025, '')
do_fix("ic1980.do", 2260, '/*')
do_fix("ic1980.do", 2263, '*/')
do_fix("ic1980.do", 3041, '/*')
do_fix("ic1980.do", 3043, '*/')
do_fix("ic1980.do", 3737, '')
do_fix("ic1980.do", 3738, '')

# */
	
end

**----------------------------------------------------------------------------**
** Run the .do files to create labeled .dta files
**----------------------------------------------------------------------------**

** Clear any data currently stored
clear	

** List the fixed .do files
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
	if(!fileexists("../dta-data/`dta_name'")) {
	
		** Run the modified .do file from IPEDS
		do `file'
	
		** Write the labaled data file as .dta
		save ../dta-data/`dta_name', replace
	
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
