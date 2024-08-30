**----------------------------------------------------------------------------**
**
** [PROJ: ipeDTAs: Automagically download labeled .dta IPEDS files]
** [FILE: ipeDTAs.do]
** [INIT: February 14 2024]
** [UPDT: August 29 2024]
** [AUTH: Matt Capaldi] @ttalVlatt
** [CRED: Benjamin T. Skinner] @btskinner
**
**----------------------------------------------------------------------------**

**----------------------------------------------------------------------------**
** README
**----------------------------------------------------------------------------**

/* 

- This `.do` file automates downloading IPEDS complete `.csv` data files, `.do` labeling files, and dictionaries
- It then processes the `.csv` data and `.do` files to create labeled `.dta` files ready of analysis in Stata or R via `haven`
- To select which files are downloaded, comment out and/or delete lines from the list at the top of the script (instructions are provided)

## System Requirements

- Stata `version 16.0` or higher
- Python for `PyStata` (often already installed will stop immediately if not) 
    - See [Stata's `PyStata` documentation](https://www.stata.com/manuals/ppystataintegration.pdf) for more info
    - See [python.org's installation page](https://www.python.org/downloads/) to download if not installed
- Storage space requirement depends on how much you download
    - **All of IPEDS**
    - `~12gb` to download (zip zippped and zip unzipped copies of data are kept during processing, optional lines to delete at end of `.do` file)
    - `~4gb` to store (keeping only the labeled `.dta` files and dictionaries)
	
## Note on Time to Download

- If you wish to download the entirity of IPEDS, it can take several hours
- To avoid overwhelming IPEDS servers there is a 3 second delay between each file download, which at over 3000 files, becomes a significant amount of time
- If you wish, at your own risk of being rejected by NCES servers, you can reduce (or remove) `sleep 3000` on lines 1380, 1395, and 1410

## Acknowledgement

- This project builds off Dr. Ben Skinner's [`downloadipeds.R` project](https://github.com/btskinner/downloadipeds) and wouldn't have been possible without it

*/

**----------------------------------------------------------------------------**
** Instruction Manual
**----------------------------------------------------------------------------**

/*

1. Select which files to download (see below section)
2. Ensure working directory is where you want the files to be stored
3. Hit "Do"

*/

**----------------------------------------------------------------------------**
** Check Python Installation for PyStata
**----------------------------------------------------------------------------**

* Will stop if python is not installed, install before continuing

capture python search

if _rc != 0 {
	di "Python (required for PyStata) is not installed visit https://www.python.org/downloads/"
	exit
}

**----------------------------------------------------------------------------**
** Select Which Files to Download
**----------------------------------------------------------------------------**

/*

Below is a list of all IPEDS files available

This is the only part of the script that should be edited

The process is realtively simple
	- If the file name is not commented, it will be downloaded
	- If the file name is commented, it will not be downloaded

By default selected files from the most recent survey year will be downloaded
	- Follow the demonstrated pattern for comments

Use multiline comments (start "/*", end "*/") to comment files (single line *s don't work)
	- For ease, there is already a comment end "* /" at the bottom of the list
	- To not download anything below line x, simply
		- add /// as a new line above x (already there for new years)
		- add "/*" at the start of line x
		- add "*/" to end a multi-line comment
			- There is already one at the bottom of the list, add "/*" to not
			  download anything below that line

Important: All lines in this block MUST end "///"
Important: The line before the start of a comment MUST be ONLY "///"

Hint: The error "var list not allowed" means the comment formatting got off
Hint: The error "<Name> is not a valid command name" means you missed a "///"
Hint: You can also delete unwanted lines if you prefer

*/

*/

**-------------------------------
** LAST UPDATED: 14 February 2024
**-------------------------------

local selected_files ///
///
/// 2023
///
"HD2023" ///
"IC2023" ///
"IC2023_AY" ///
"IC2023_PY" ///
"IC2023_CAMPUSES" ///
"FLAGS2023" ///
"EFFY2023" ///
"EFFY2023_DIST" ///
"EFFY2023_HS" ///
"EFIA2023" ///
"FLAGS2023" ///
"C2023_A" ///
"C2023_B" ///
"C2023_C" ///
"C2023DEP" ///
"DRVIC2023" ///
"DRVEF122023" ///
"DRVC2023" ///
///
/// 2022
///
"HD2022" ///
"IC2022" ///
"IC2022_AY" ///
"IC2022_PY" ///
"IC2022_CAMPUSES" ///
"EFFY2022" ///
"EFFY2022_DIST" ///
"EFIA2022" ///
"ADM2022" ///
"EF2022A" ///
"EF2022CP" ///
"EF2022B" ///
"EF2022C" ///
"EF2022D" ///
"EF2022A_DIST" ///
"C2022_A" ///
"C2022_B" ///
"C2022_C" ///
"C2022DEP" ///
"SAL2022_IS" ///
"SAL2022_NIS" ///
"S2022_OC" ///
"S2022_SIS" ///
"S2022_IS" ///
"S2022_NH" ///
"EAP2022" ///
"F2122_F1A" ///
"F2122_F2" ///
"F2122_F3" ///
"SFA2122" ///
"SFAV2122" ///
"GR2022" ///
"GR2022_L2" ///
"GR2022_PELL_SSL" ///
"GR200_22" ///
"OM2022" ///
"AL2022" ///
"FLAGS2022" ///
///
/// 2021
///
"HD2021" ///
"IC2021" ///
"IC2021_AY" ///
"IC2021_PY" ///
"ic2021_campuses" ///
"FLAGS2021" ///
"EFFY2021" ///
"EFFY2021_DIST" ///
"EFIA2021" ///
"ADM2021" ///
"EF2021A" ///
"EF2021B" ///
"EF2021C" ///
"EF2021D" ///
"EF2021A_DIST" ///
"C2021_A" ///
"C2021_B" ///
"C2021_C" ///
"C2021DEP" ///
"SAL2021_IS" ///
"SAL2021_NIS" ///
"S2021_OC" ///
"S2021_SIS" ///
"S2021_IS" ///
"S2021_NH" ///
"EAP2021" ///
"F2021_F1A" ///
"F2021_F2" ///
"F2021_F3" ///
"SFA2021" ///
"SFAV2021" ///
"GR2021" ///
"GR2021_L2" ///
"GR2021_PELL_SSL" ///
"GR200_21" ///
"OM2021" ///
"AL2021" ///
"FLAGS2021" ///
///
/// 2020
///
"HD2020" ///
"IC2020" ///
"IC2020_AY" ///
"IC2020_PY" ///
"EFFY2020" ///
"EFFY2020_DIST" ///
"EFIA2020" ///
"ADM2020" ///
"EF2020A" ///
"EF2020CP" ///
"EF2020B" ///
"EF2020C" ///
"EF2020D" ///
"EF2020A_DIST" ///
"C2020_A" ///
"C2020_B" ///
"C2020_C" ///
"C2020DEP" ///
"SAL2020_IS" ///
"SAL2020_NIS" ///
"S2020_OC" ///
"S2020_SIS" ///
"S2020_IS" ///
"S2020_NH" ///
"EAP2020" ///
"F1920_F1A" ///
"F1920_F2" ///
"F1920_F3" ///
"SFA1920" ///
"SFAV1920" ///
"GR2020" ///
"GR2020_L2" ///
"GR2020_PELL_SSL" ///
"GR200_20" ///
"OM2020" ///
"AL2020" ///
"FLAGS2020" ///
///
/// 2019
///
"HD2019" ///
"IC2019" ///
"IC2019_AY" ///
"IC2019_PY" ///
"EFFY2019" ///
"EFIA2019" ///
"ADM2019" ///
"EF2019A" ///
"EF2019B" ///
"EF2019C" ///
"EF2019D" ///
"EF2019A_DIST" ///
"C2019_A" ///
"C2019_B" ///
"C2019_C" ///
"C2019DEP" ///
"SAL2019_IS" ///
"SAL2019_NIS" ///
"S2019_OC" ///
"S2019_SIS" ///
"S2019_IS" ///
"S2019_NH" ///
"EAP2019" ///
"F1819_F1A" ///
"F1819_F2" ///
"F1819_F3" ///
"SFA1819" ///
"SFAV1819" ///
"GR2019" ///
"GR2019_L2" ///
"GR2019_PELL_SSL" ///
"GR200_19" ///
"OM2019" ///
"AL2019" ///
"FLAGS2019" ///
///
/// 2018
///
"HD2018" ///
"IC2018" ///
"IC2018_AY" ///
"IC2018_PY" ///
"EFFY2018" ///
"EFIA2018" ///
"ADM2018" ///
"EF2018A" ///
"EF2018CP" ///
"EF2018B" ///
"EF2018C" ///
"EF2018D" ///
"EF2018A_DIST" ///
"C2018_A" ///
"C2018_B" ///
"C2018_C" ///
"C2018DEP" ///
"SAL2018_IS" ///
"SAL2018_NIS" ///
"S2018_OC" ///
"S2018_SIS" ///
"S2018_IS" ///
"S2018_NH" ///
"EAP2018" ///
"F1718_F1A" ///
"F1718_F2" ///
"F1718_F3" ///
"SFA1718" ///
"SFAV1718" ///
"GR2018" ///
"GR2018_L2" ///
"GR2018_PELL_SSL" ///
"GR200_18" ///
"OM2018" ///
"AL2018" ///
"FLAGS2018" ///
///
/// 2017
///
"HD2017" ///
"IC2017" ///
"IC2017_AY" ///
"IC2017_PY" ///
"EFFY2017" ///
"EFIA2017" ///
"ADM2017" ///
"EF2017A" ///
"EF2017B" ///
"EF2017C" ///
"EF2017D" ///
"EF2017A_DIST" ///
"C2017_A" ///
"C2017_B" ///
"C2017_C" ///
"C2017DEP" ///
"SAL2017_IS" ///
"SAL2017_NIS" ///
"S2017_OC" ///
"S2017_SIS" ///
"S2017_IS" ///
"S2017_NH" ///
"EAP2017" ///
"F1617_F1A" ///
"F1617_F2" ///
"F1617_F3" ///
"SFA1617" ///
"SFAV1617" ///
"GR2017" ///
"GR2017_L2" ///
"GR2017_PELL_SSL" ///
"GR200_17" ///
"OM2017" ///
"AL2017" ///
"FLAGS2017" ///
///
/// 2016
///
"HD2016" ///
"IC2016" ///
"IC2016_AY" ///
"IC2016_PY" ///
"EFFY2016" ///
"EFIA2016" ///
"ADM2016" ///
"EF2016A" ///
"EF2016CP" ///
"EF2016B" ///
"EF2016C" ///
"EF2016D" ///
"EF2016A_DIST" ///
"C2016_A" ///
"C2016_B" ///
"C2016_C" ///
"C2016DEP" ///
"SAL2016_IS" ///
"SAL2016_NIS" ///
"S2016_OC" ///
"S2016_SIS" ///
"S2016_IS" ///
"S2016_NH" ///
"EAP2016" ///
"F1516_F1A" ///
"F1516_F2" ///
"F1516_F3" ///
"SFA1516" ///
"SFAV1516" ///
"GR2016" ///
"GR2016_L2" ///
"GR2016_PELL_SSL" ///
"GR200_16" ///
"OM2016" ///
"AL2016" ///
"FLAGS2016" ///
///
/// 2015
///
"HD2015" ///
"IC2015" ///
"IC2015_AY" ///
"IC2015_PY" ///
"EFFY2015" ///
"EFIA2015" ///
"ADM2015" ///
"EF2015A" ///
"EF2015B" ///
"EF2015C" ///
"EF2015D" ///
"EF2015A_DIST" ///
"C2015_A" ///
"C2015_B" ///
"C2015_C" ///
"C2015DEP" ///
"SAL2015_IS" ///
"SAL2015_NIS" ///
"S2015_OC" ///
"S2015_SIS" ///
"S2015_IS" ///
"S2015_NH" ///
"EAP2015" ///
"F1415_F1A" ///
"F1415_F2" ///
"F1415_F3" ///
"SFA1415" ///
"SFAV1415" ///
"GR2015" ///
"GR2015_L2" ///
"GR200_15" ///
"OM2015" ///
"AL2015" ///
"FLAGS2015" ///
///
/// 2014
///
"HD2014" ///
"IC2014" ///
"IC2014_AY" ///
"IC2014_PY" ///
"EFFY2014" ///
"EFIA2014" ///
"ADM2014" ///
"EF2014A" ///
"EF2014CP" ///
"EF2014B" ///
"EF2014C" ///
"EF2014D" ///
"EF2014A_DIST" ///
"C2014_A" ///
"C2014_B" ///
"C2014_C" ///
"C2014DEP" ///
"SAL2014_IS" ///
"SAL2014_NIS" ///
"S2014_OC" ///
"S2014_SIS" ///
"S2014_IS" ///
"S2014_NH" ///
"EAP2014" ///
"F1314_F1A" ///
"F1314_F2" ///
"F1314_F3" ///
"SFA1314" ///
"SFAV1314" ///
"GR2014" ///
"GR2014_L2" ///
"GR200_14" ///
"AL2014" ///
"FLAGS2014" ///
///
/// 2013
///
"HD2013" ///
"IC2013" ///
"IC2013_AY" ///
"IC2013_PY" ///
"EFFY2013" ///
"EFIA2013" ///
"IC2013" ///
"EF2013A" ///
"EF2013B" ///
"EF2013C" ///
"EF2013D" ///
"EF2013A_DIST" ///
"C2013_A" ///
"C2013_B" ///
"C2013_C" ///
"C2013DEP" ///
"SAL2013_IS" ///
"SAL2013_NIS" ///
"S2013_OC" ///
"S2013_SIS" ///
"S2013_IS" ///
"S2013_NH" ///
"EAP2013" ///
"F1213_F1A" ///
"F1213_F2" ///
"F1213_F3" ///
"SFA1213" ///
"GR2013" ///
"GR2013_L2" ///
"GR200_13" ///
"FLAGS2013" ///
///
/// 2012
///
"HD2012" ///
"IC2012" ///
"IC2012_AY" ///
"IC2012_PY" ///
"FLAGS2012" ///
"EFFY2012" ///
"EFIA2012" ///
"IC2012" ///
"EF2012A" ///
"EF2012CP" ///
"EF2012B" ///
"EF2012C" ///
"EF2012D" ///
"EF2012A_DIST" ///
"C2012_A" ///
"C2012_B" ///
"C2012_C" ///
"SAL2012_IS" ///
"SAL2012_NIS" ///
"S2012_OC" ///
"S2012_SIS" ///
"S2012_IS" ///
"S2012_NH" ///
"EAP2012" ///
"F1112_F1A" ///
"F1112_F2" ///
"F1112_F3" ///
"SFA1112" ///
"GR2012" ///
"GR2012_L2" ///
"GR200_12" ///
"FLAGS2012" ///
///
/// 2011
///
"HD2011" ///
"IC2011" ///
"IC2011_AY" ///
"IC2011_PY" ///
"EFFY2011" ///
"EFIA2011" ///
"IC2011" ///
"EF2011A" ///
"EF2011B" ///
"EF2011C" ///
"EF2011D" ///
"C2011_A" ///
"SAL2011_A" ///
"SAL2011_Faculty" ///
"SAL2011_A_LT9" ///
"S2011_ABD" ///
"S2011_F" ///
"S2011_G" ///
"S2011_CN" ///
"EAP2011" ///
"F1011_F1A" ///
"F1011_F2" ///
"F1011_F3" ///
"SFA1011" ///
"GR2011" ///
"GR2011_L2" ///
"GR200_11" ///
"FLAGS2011" ///
///
/// 2010
///
"HD2010" ///
"IC2010" ///
"IC2010_AY" ///
"IC2010_PY" ///
"EFFY2010" ///
"EFIA2010" ///
"IC2010" ///
"EF2010A" ///
"EF2010CP" ///
"EF2010B" ///
"EF2010C" ///
"EF2010D" ///
"C2010_A" ///
"SAL2010_A" ///
"SAL2010_B" ///
"SAL2010_FACULTY" ///
"SAL2010_A_LT9" ///
"S2010_ABD" ///
"S2010_F" ///
"S2010_G" ///
"S2010_CN" ///
"EAP2010" ///
"F0910_F1A" ///
"F0910_F2" ///
"F0910_F3" ///
"SFA0910" ///
"GR2010" ///
"GR2010_L2" ///
"GR200_10" ///
"FLAGS2010" ///
///
/// 2009
///
"HD2009" ///
"IC2009" ///
"IC2009_AY" ///
"IC2009_PY" ///
"EFFY2009" ///
"EFIA2009" ///
"IC2009" ///
"EF2009A" ///
"EF2009B" ///
"EF2009C" ///
"EF2009D" ///
"EFEST2009" ///
"C2009_A" ///
"SAL2009_A" ///
"SAL2009_B" ///
"SAL2009_FACULTY" ///
"SAL2009_A_LT9" ///
"S2009_ABD" ///
"S2009_F" ///
"S2009_G" ///
"S2009_CN" ///
"EAP2009" ///
"F0809_F1A" ///
"F0809_F2" ///
"F0809_F3" ///
"SFA0809" ///
"GR2009" ///
"GR2009_L2" ///
"GR200_09" ///
"FLAGS2009" ///
///
/// 2008
///
"HD2008" ///
"IC2008" ///
"IC2008_AY" ///
"IC2008_PY" ///
"EFFY2008" ///
"EFIA2008" ///
"IC2008" ///
"EF2008A" ///
"EF2008CP" ///
"EF2008B" ///
"EF2008C" ///
"EF2008D" ///
"EFEST2008" ///
"C2008_A" ///
"SAL2008_A" ///
"SAL2008_B" ///
"SAL2008_FACULTY" ///
"SAL2008_A_LT9" ///
"S2008_ABD" ///
"S2008_F" ///
"S2008_G" ///
"S2008_CN" ///
"EAP2008" ///
"F0708_F1A" ///
"F0708_F2" ///
"F0708_F3" ///
"SFA0708" ///
"GR2008" ///
"GR2008_L2" ///
"GR200_08" ///
"FLAGS2008" ///
///
/// 2007
///
"HD2007" ///
"IC2007" ///
"IC2007_AY" ///
"IC2007_PY" ///
"IC2007Mission" ///
"EFFY2007" ///
"EFIA2007" ///
"IC2007" ///
"EF2007A" ///
"EF2007B" ///
"EF2007C" ///
"EF2007D" ///
"EFEST2007" ///
"C2007_A" ///
"SAL2007_A" ///
"SAL2007_B" ///
"SAL2007_FACULTY" ///
"SAL2007_A_LT9" ///
"S2007_ABD" ///
"S2007_F" ///
"S2007_G" ///
"S2007_CN" ///
"EAP2007" ///
"F0607_F1A" ///
"F0607_F1A_F" ///
"F0607_F1A_G" ///
"F0607_F2" ///
"F0607_F3" ///
"SFA0607" ///
"GR2007" ///
"GR2007_L2" ///
"FLAGS2007" ///
///
/// 2006
///
"HD2006" ///
"IC2006" ///
"IC2006_AY" ///
"IC2006_PY" ///
"IC2006Mission" ///
"FLAGS2006" ///
"EFFY2006" ///
"EFIA2006" ///
"IC2006" ///
"EF2006A" ///
"EF2006CP" ///
"EF2006B" ///
"EF2006C" ///
"EF2006D" ///
"C2006_A" ///
"SAL2006_A" ///
"SAL2006_B" ///
"SAL2006_FACULTY" ///
"SAL2006_A_LT9" ///
"S2006_ABD" ///
"S2006_F" ///
"S2006_G" ///
"S2006_CN" ///
"EAP2006" ///
"F0506_F1A" ///
"F0506_F1A_F" ///
"F0506_F1A_G" ///
"F0506_F2" ///
"F0506_F3" ///
"SFA0506" ///
"GR2006" ///
"GR2006ATH" ///
"GR2006_ATH_AID" ///
"GR2006_L2" ///
"FLAGS2006" ///
///
/// 2005
///
"HD2005" ///
"IC2005" ///
"IC2005_AY" ///
"IC2005_PY" ///
"IC2005Mission" ///
"EFFY2005" ///
"EFIA2005" ///
"IC2005" ///
"EF2005A" ///
"EF2005B" ///
"EF2005C" ///
"EF2005D" ///
"C2005_A" ///
"SAL2005_A" ///
"SAL2005_B" ///
"SAL2005_A_LT9" ///
"S2005_ABD" ///
"S2005_F" ///
"S2005_G" ///
"S2005_CN" ///
"EAP2005" ///
"F0405_F1A" ///
"F0405_F1A_F" ///
"F0405_F1A_G" ///
"F0405_F2" ///
"F0405_F3" ///
"SFA0405" ///
"GR2005" ///
"GR2005_L2" ///
"GR2005ATH" ///
"GR2005_ATH_AID" ///
"FLAGS2005" ///
"DFR2005" ///
///
/// 2004
///
"HD2004" ///
"FLAGS2004" ///
"IC2004" ///
"IC2004_AY" ///
"IC2004_PY" ///
"IC2004Mission" ///
"EFFY2004" ///
"EFIA2004" ///
"IC2004" ///
"EF2004A" ///
"EF2004CP" ///
"EF2004B" ///
"EF2004C" ///
"EF2004D" ///
"C2004_A" ///
"SAL2004_A" ///
"SAL2004_B" ///
"S2004_ABD" ///
"S2004_F" ///
"S2004_G" ///
"S2004_CN" ///
"EAP2004" ///
"F0304_F1A" ///
"F0304_F1A_F" ///
"F0304_F1A_G" ///
"F0304_F2" ///
"F0304_F3" ///
"SFA0304" ///
"GR2004" ///
"GR2004_L2" ///
"GR2004ATH" ///
"GR2004_ATH_AID" ///
"FLAGS2004" ///
///
/// 2003
///
"HD2003" ///
"IC2003" ///
"IC2003_AY" ///
"IC2003_PY" ///
"EFFY2003" ///
"EFIA2003" ///
"IC2003" ///
"EF2003A" ///
"EF2003B" ///
"EF2003C" ///
"EF2003D" ///
"C2003_A" ///
"SAL2003_A" ///
"SAL2003_B" ///
"S2003_ABD" ///
"S2003_F" ///
"S2003_G" ///
"S2003_CN" ///
"EAP2003" ///
"F0203_F1" ///
"F0203_F1A" ///
"F0203_F1A_F" ///
"F0203_F1A_G" ///
"F0203_F2" ///
"F0203_F3" ///
"SFA0203" ///
"GR2003" ///
"GR2003ATH" ///
"GR2003_ATH_AID" ///
///
/// 2002
///
"HD2002" ///
"IC2002" ///
"IC2002_AY" ///
"IC2002_PY" ///
"EFFY2002" ///
"EFIA2002" ///
"IC2002" ///
"EF2002A" ///
"EF2002CP" ///
"EF2002B" ///
"EF2002C" ///
"EF2002D" ///
"C2002_A" ///
"SAL2002_A" ///
"SAL2002_B" ///
"S2002_ABD" ///
"S2002_F" ///
"S2002_G" ///
"S2002_CN" ///
"EAP2002" ///
"F0102_F1" ///
"F0102_F1A" ///
"F0102_F1A_F" ///
"F0102_F1A_G" ///
"F0102_F2" ///
"F0102_F3" ///
"SFA0102" ///
"GR2002" ///
"GR2002ATH" ///
"GR2002_ATH_AID" ///
///
/// 2001
///
"FA2001HD" ///
"IC2001" ///
"IC2001_AY" ///
"IC2001_PY" ///
"EF2001D1" ///
"EF2001D2" ///
"IC2001" ///
"EF2001A" ///
"EF2001B" ///
"EF2001C" ///
"EF2001E" ///
"C2001_A" ///
"c2001_a2dig" ///
"SAL2001_A_S" ///
"SAL2001_B_S" ///
"S2001_ABD" ///
"S2001_F" ///
"S2001_G" ///
"S2001_CN" ///
"EAP2001" ///
"F0001_F1" ///
"F0001_F2" ///
"F0001_F3" ///
"SFA0001S" ///
"GR2001" ///
"GR2001_L2" ///
"GR2001ATH" ///
"GR2001_ATH_AID" ///
///
/// 2000
///
"FA2000HD" ///
"IC2000" ///
"IC2000_ACTOT" ///
"IC2000_AY" ///
"IC2000_PY" ///
"EF2000D" ///
"EF2000A" ///
"EF2000CP" ///
"EF2000B" ///
"EF2000C" ///
"C2000_A" ///
"C2000_A2DIG" ///
"F9900_F1" ///
"F9900F2" ///
"F9900F3" ///
"SFA9900S" ///
"GR2000" ///
"GR2000_L2" ///
"GR2000ATH" ///
"GR2000_ATH_AID" ///
///
/// 1999
///
"IC99_HD" ///
"IC99ABCF" ///
"IP1999AY" ///
"IP1999PY" ///
"IC99_ACTOT" ///
"IC99_D" ///
"IC99_E" ///
"EF99_ANR" ///
"EF99_B" ///
"EF99_D" ///
"C9899_A" ///
"C9899_B" ///
"SAL1999_A" ///
"SAL1999_B" ///
"S1999_ABD" ///
"S1999_F" ///
"S1999_G" ///
"S99_CN" ///
"S99_E" ///
"F9899_F1" ///
"F9899_C5" ///
"F9899_F2" ///
"F9899_F3" ///
"F9899_CN" ///
"Pub_studentCount" ///
"Pub_FinancialAid" ///
"GR1999" ///
"GR1999_L2" ///
"GR1999ATH" ///
"GR1999_ATH_AID" ///
///
/// 1998
///
"IC98hdac" ///
"IC98_AB" ///
"IC98_C" ///
"IC98_D" ///
"IC98_F" ///
"IC98_E" ///
"EF98_hd" ///
"EF98_ANR" ///
"EF98_ARK" ///
"EF98_ACP" ///
"EF98_C" ///
"EF98_D" ///
"C9798_HD" ///
"C9798_A" ///
"C9798_A2DIG" ///
"C9798_B" ///
"SAL98_HD" ///
"SAL98_A" ///
"SAL98_B" ///
"F9798_F1" ///
"F9798_C5" ///
"F9798_F2" ///
"F9798_F3" ///
"F9798_CN" ///
"GR1998" ///
"GR1998_L2" ///
"GR1998ATH" ///
"GR1998_ATH_AID" ///
"ic9798_HDR" ///
"ic9798_AB" ///
"ic9798_C" ///
"ic9798_D" ///
"ic9798_F" ///
"ic9798_E" ///
///
/// 1997
///
"EF97_HDR" ///
"EF97_ANR" ///
"EF97_ARK" ///
"EF97_B" ///
"EF97_D" ///
"C9697_HDR" ///
"C9697_A" ///
"C9697_A2DIG" ///
"C9697_B" ///
"SAL97_HDR" ///
"SAL97_A" ///
"SAL97_B" ///
"S97_IC" ///
"S97_S" ///
"S97_E" ///
"S97_CN" ///
"F9697_F1" ///
"F9697_F2" ///
"GR1997" ///
"GR1997_L2" ///
"GR1997ATH" ///
"GR1997_ATH_AID" ///
"ic9697_A" ///
"ic9697_B" ///
"ic9697_C" ///
///
/// 1996
///
"EF96_IC" ///
"EF96_ANR" ///
"EF96_ACP" ///
"EF96_ARK" ///
"EF96_C" ///
"EF96_D" ///
"C9596_IC" ///
"C9596_A" ///
"C9596_A2DIG" ///
"C9596_B" ///
"SAL96_IC" ///
"SAL96_a_1" ///
"SAL96_B" ///
"F9596_IC" ///
"F9596_A" ///
"F9596_B" ///
"F9596_C" ///
"F9596_C5" ///
"F9596_D" ///
"F9596_E" ///
"F9596_F" ///
"F9596_G" ///
"F9596_H" ///
"F9596_I" ///
"F9596_J" ///
"F9596_K" ///
"F9596_CN" ///
"ic9596_A" ///
"ic9596_B" ///
///
/// 1995
///
"EF95_IC" ///
"EF95_ANR" ///
"EF95_ARK" ///
"EF95_B" ///
"EF95_D" ///
"C9495_IC" ///
"C9495_A" ///
"C9495_A2DIG" ///
"C9495_B" ///
"SAL95_IC" ///
"SAL95_a_1" ///
"SAL95_B" ///
"s95_ic" ///
"S95_S" ///
"s95_e" ///
"S95_CN" ///
"F9495_IC" ///
"F9495_A" ///
"F9495_B" ///
"F9495_C" ///
"F9495_C5" ///
"F9495_D" ///
"F9495_E" ///
"F9495_F" ///
"F9495_G" ///
"F9495_H" ///
"F9495_I" ///
"F9495_J" ///
"F9495_K" ///
///
/// 1994
///
"IC1994_A" ///
"IC1994_B" ///
"EF1994_IC" ///
"EF1994_ANR" ///
"EF1994_ACP" ///
"EF1994_ARK" ///
"EF1994_C" ///
"EF1994_D" ///
"C1994_IC" ///
"C1994_CIP" ///
"C1994_RE" ///
"SAL1994_A" ///
"SAL1994_B" ///
"F1994_IC" ///
"F1994_A" ///
"F1994_B" ///
"F1994_C" ///
"F1994_D" ///
"F1994_E" ///
"F1994_F" ///
"F1994_G" ///
"F1994_H" ///
"F1994_I" ///
"F1994_J" ///
"F1994_K" ///
///
/// 1993
///
"IC1993_A" ///
"IC1993_B" ///
"EF1993_IC" ///
"EF1993_A" ///
"EF1993_B" ///
"EF1993_D" ///
"C1993_IC" ///
"C1993_CIP" ///
"C1993_RE" ///
"SAL1993_A" ///
"SAL1993_B" ///
"S1993_IC" ///
"S1993_ABCEF" ///
"S1993_CN" ///
"F1993_IC" ///
"F1993_A" ///
"F1993_B" ///
"F1993_C" ///
"F1993_D" ///
"F1993_E" ///
"F1993_F" ///
"F1993_G" ///
"F1993_H" ///
"F1993_I" ///
"F1993_J" ///
"F1993_K" ///
///
/// 1992
///
"IC1992_A" ///
"IC1992_B" ///
"EF1992_IC" ///
"EF1992_A" ///
"EF1992_C" ///
"C1992_IC" ///
"C1992_CIP" ///
"C1992_RE" ///
"SAL1992_A" ///
"SAL1992_B" ///
"F1992_IC" ///
"F1992_A" ///
"F1992_B" ///
"F1992_C" ///
"F1992_D" ///
"F1992_E" ///
"F1992_F" ///
"F1992_G" ///
"F1992_H" ///
"F1992_I" ///
"F1992_J" ///
"F1992_K" ///
///
/// 1991
///
"ic1991_ab" ///
"ic1991_c" ///
"ic1991_d" ///
"ic1991_e" ///
"ic1991_f" ///
"IC1991_hdr" ///
"ic1991_other" ///
"ef1991_hdr" ///
"ef1991_a" ///
"ef1991_b" ///
"C1991_HDR" ///
"c1991_cip" ///
"c1991_re" ///
"sal1991_a" ///
"sal1991_b" ///
"sal1991_hdr" ///
"s1991_a" ///
"s1991_b" ///
"s1991_hdr" ///
"F1991_hdr" ///
"F1991_A" ///
"F1991_B" ///
"F1991_C" ///
"F1991_D" ///
"F1991_E" ///
"F1991_F" ///
"F1991_G" ///
"F1991_H" ///
"F1991_I" ///
"F1991_J" ///
"F1991_K" ///
///
/// 1990
///
"IC90HD" ///
"IC90ABCE" ///
"IC90D" ///
"EF90_HD" ///
"EF90_A" ///
"C8990HD" ///
"C8990RE" ///
"C8990CIP" ///
"SAL90_HD" ///
"SAL90_A" ///
"SAL90_B" ///
"F8990_HD" ///
"F8990_A" ///
"F8990_B" ///
"F8990_E" ///
///
/// 1989
///
"IC1989_A" ///
"IC1989_B" ///
"EF1989_IC" ///
"EF1989_A" ///
"C1989_IC" ///
"C1989_CIP" ///
"C1989_RE" ///
"SAL1989_IC" ///
"SAL1989_A" ///
"SAL1989_B" ///
"S1989_IC" ///
"S1989" ///
"F1989_IC" ///
"F1989_A" ///
"F1989_B" ///
"F1989_C" ///
"F1989_D" ///
"F1989_E" ///
"F1989_F" ///
"F1989_G" ///
"F1989_H" ///
"F1989_I" ///
"F1989_J" ///
"F1989_K" ///
///
/// 1988
///
"IC1988_A" ///
"IC1988_B" ///
"EF1988_IC" ///
"EF1988_A" ///
"RES1988_IC" ///
"EF1988_C" ///
"C1988_IC" ///
"C1988_CIP" ///
"C1988_A2DIG" ///
"F1988" ///
///
/// 1987
///
"IC1987_A" ///
"IC1987_B" ///
"EF1987_IC" ///
"EF1987_A" ///
"EF1987_B" ///
"EF1987_D" ///
"C1987_IC" ///
"C1987_CIP" ///
"C1987_RE" ///
"SAL1987_IC" ///
"SAL1987_A" ///
"SAL1987_B" ///
"S1987_IC" ///
"S1987" ///
"F1987_A" ///
"F1987_B" ///
"F1987_E" ///
"F1987_IC" ///
///
/// 1986
///
"IC1986_A" ///
"IC1986_B" ///
"EF1986_IC" ///
"EF1986_A" ///
"EF1986_ACP" ///
"EF1986_D" ///
"RES1986_IC" ///
"EF1986_C" ///
"C1986_CIP" ///
"C1986_A2dig" ///
"F1986" ///
///
/// 1985
///
"IC1985" ///
"EF1985" ///
"C1985_CIP" ///
"C1985_RE" ///
"C1985_IC" ///
"SAL1985_IC" ///
"SAL1985_A" ///
"SAL1985_B" ///
"F1985" ///
///
/// 1984
///
"IC1984" ///
"EF1984" ///
"C1984_CIP" ///
"C1984_A2dig" ///
"SAL1984_IC" ///
"SAL1984_A" ///
"SAL1984_B" ///
"F1984" ///
///
/// 1980
///
"IC1980" ///
"EF1980_A" ///
"EF1980_ACP" ///
"C1980SUBBA_CIP" ///
"C1980SUBBA_2DIG" ///
"C1980_4ORMORE_CIP" ///
"C1980_4ORMORE_2DIG" ///
"SAL1980_A" ///
"SAL1980_B" ///
"F1980"

*/

**----------------------------------------------------------------------------**
** Create Folders
**----------------------------------------------------------------------------**

* Make folders if they don't exist
capture confirm file "zip-data"
if _rc mkdir "zip-data"
capture confirm file "unzip-data"
if _rc mkdir "unzip-data"
capture confirm file "data"
if _rc mkdir "data"
capture confirm file "zip-do-files"
if _rc mkdir "zip-do-files"
capture confirm file "unzip-do-files"
if _rc mkdir "unzip-do-files"
capture confirm file "fixed-do-files"
if _rc mkdir "fixed-do-files"
capture confirm file "zip-dictionaries"
if _rc mkdir "zip-dictionaries"
capture confirm file "dictionaries"
if _rc mkdir "dictionaries"

* h/t https://www.statalist.org/forums/forum/general-stata-discussion/general/1344241-check-if-directory-exists-before-running-mkdir

**----------------------------------------------------------------------------**
** Loops to Download the .zip Files
**----------------------------------------------------------------------------**

* Loop through getting the .csv files
foreach file in "`selected_files'" {

	if(!fileexists("data/`file'.dta")) {
		if(!fileexists("zip-data/`file'_Data_Stata.zip")) {
	
    di "Downloading: `file' .csv File"
    copy "https://nces.ed.gov/ipeds/datacenter/data/`file'_Data_Stata.zip" "zip-data/`file'_Data_Stata.zip"
	
	* Wait for three seconds between files
	sleep 3000
	
		}
	}
}

* Loop through getting the .do files
foreach file in "`selected_files'" {

	if(!fileexists("data/`file'.dta")) {
		if(!fileexists("zip-do-files/`file'_Stata.zip")) {
	
    di "Downloading: `file' .do File"
    copy "https://nces.ed.gov/ipeds/datacenter/data/`file'_Stata.zip" "zip-do-files/`file'_Stata.zip"
	
	* Wait for three seconds between files
	sleep 3000
	
		}
	}
}

* Loop through getting the dictionary files
foreach file in "`selected_files'" {

	if(!fileexists("dictionaries/`file'.xlsx")) {
		if(!fileexists("zip-dictionaries/`file'_DICT.zip")) {
	
    di "Downloading: `file' Dictionary"
    copy "https://nces.ed.gov/ipeds/datacenter/data/`file'_Dict.zip" "zip-dictionaries/`file'_Dict.zip"
	
	* Wait for three seconds between files
	sleep 3000
	
		}
	}
}

**----------------------------------------------------------------------------**
** Loops to Unzip the .zip Files
**----------------------------------------------------------------------------**

* .csv Files
cd zip-data

local files_list: dir . files "*.zip"

cd ../unzip-data

foreach file in `files_list' {
	
	unzipfile ../zip-data/`file', replace
	
}

* .do Files
cd ../zip-do-files

local files_list: dir . files "*.zip"

cd ../unzip-do-files

foreach file in `files_list' {
	
	unzipfile ../zip-do-files/`file', replace
	
}

* Dictionary Files
cd ../zip-dictionaries

local files_list: dir . files "*.zip"

cd ../dictionaries

foreach file in `files_list' {
	
	unzipfile ../zip-dictionaries/`file', replace
	
}

cd ..

**----------------------------------------------------------------------------**
** If _rv File Exists Replace Original Data With It
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

local files_list: dir . files "*_RV*.csv"

foreach file in `files_list' {
	
	local rv_name: di "`file'"
	local og_name: subinstr local rv_name "_RV" ""
	
	di "Replacing `og_name' with `rv_name'"
	
	erase "`og_name'"
	
	_renamefile "`rv_name'" "`og_name'"
	
}

* h/t https://www.statalist.org/forums/forum/general-stata-discussion/general/1422353-trouble-renaming-files-using-renfiles-command

cd ..

**----------------------------------------------------------------------------**
** Fix the .do Files Using PyStata: Consistent Issues
**----------------------------------------------------------------------------**

cd unzip-do-files

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
					
	print("Before string var: " + str(len(index_to_delete)))
	
	## Identify problematic attempts to label strings
	
	label_string_vars = []

	## Variable that start with anything but a digit or - sign
	pattern = re.compile(r"^label define\s+\w+\s+[^0-9-].*")	
	
	for index, line in enumerate(do_file):
		if re.match(pattern, line):
			label_string_vars.append(line.split(" ")[2])
		

	## Variables that start with a digit or minus sign, but end in letter (e.g., 11A)
	pattern = re.compile(r"^label define\s+\w+\s+\b-?\d+[A-Za-z]\b.*")	
	
	for index, line in enumerate(do_file):
		if re.match(pattern, line):
			label_string_vars.append(line.split(" ")[2])
			
	
	## Get unique list of vars
	label_string_vars = list(set(label_string_vars))
	
	## Prevents loop activating when no problematic vars, as regex becomes ".*"
	if len(set(label_string_vars)) > 0:
	
		## Create regex pattern from the list of variables
		pattern = "|".join(label_string_vars)
		## h/t https://stackoverflow.com/questions/21292552/equivalent-of-paste-r-to-python
		pattern = r".* (" + pattern + ")"
		pattern = re.compile(pattern)
	
		for index, line in enumerate(do_file):
			if re.match(pattern, line):
				index_to_delete.append(index)
				
		print("Problematic var loop activated for " + i)

	
	## Get unique indexes
	index_to_delete = list(set(index_to_delete))
	
	print("# Lines to Comment: " + str(len(index_to_delete)))

	print("# Lines in .do file: " + str(len(do_file)))	

	## Delete problematic lines by index
	for index in sorted(index_to_delete, reverse = True):
		do_file[index] = "*/ \n"

	
	## Write the updated .do file
	
	fixed_file_name = "../fixed-do-files/" + i
	if os.path.exists(fixed_file_name):
		os.unlink(fixed_file_name) ## Delete fixed do file if already exists
	fixed_file = open(fixed_file_name, "w", encoding='latin-1')
	fixed_file.writelines(do_file)
	
	file.close()
	fixed_file.close()
	
end
	
**----------------------------------------------------------------------------**
** Fix the .do Files Using PyStata: Misc. Issues
**----------------------------------------------------------------------------**

cd ../fixed-do-files

/* 
Create python function that re-writes individual lines of .do files to fix
misc. issues, such as lines that misspell a variable, are broken up, etc.
*/

python	

def do_fix(do_file_name, line_to_replace, replacement):
	
	if os.path.exists(do_file_name):
		file = open(do_file_name, "r", encoding='latin-1')
		do_file = file.readlines()
		
		do_file[line_to_replace - 1] = replacement + "\n"
		
		file.close()
		
		file = open(do_file_name, "w", encoding='latin-1')
		file.writelines(do_file)
		
	else:
		
		print("Not in fixed-do-files : " + do_file_name) 


## Broken Line
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

## Broken Line
do_fix("drvef122023.do", 34, 'label variable e12ft "Full-time 12-month unduplicated headcount"')
do_fix("drvef122023.do", 35, '')
do_fix("drvef122023.do", 36, 'label variable e12pt "Part-time 12-month unduplicated headcount"')
do_fix("drvef122023.do", 37, '')
do_fix("drvef122023.do", 49, 'label variable e12gradft "Full-time graduate 12-month unduplicated headcount"')
do_fix("drvef122023.do", 50, '')
do_fix("drvef122023.do", 56, 'label variable e12gradpt "Part-time graduate 12-month unduplicated headcount"')
do_fix("drvef122023.do", 57, '')

## Not reading as a comment
do_fix("ic2023_campuses.do", 1, '')

## Broken Line
do_fix("ic2023_campuses.do", 481, 'label define label_pcpset4flg 2 "Non-Title IV postsecondary institution",add')
do_fix("ic2023_campuses.do", 482, '')
do_fix("ic2023_campuses.do", 483, 'label define label_pcpset4flg 3 "Title IV NOT primarily postsecondary institution",add')
do_fix("ic2023_campuses.do", 484, '')
do_fix("ic2023_campuses.do", 485, 'label define label_pcpset4flg 9 "Institution is not active in current universe",add')
do_fix("ic2023_campuses.do", 486, '')

end

**----------------------------------------------------------------------------**
** Run the .do Files to Create Labeled .dta Files
**----------------------------------------------------------------------------**

** Clear any data currently stored
clear	

** List the fixed .do files
local files_list: dir . files "*.do"

foreach file in `files_list' {
	
    ** Take file name as a "string" as convert .do to .dta
    local do_name: di "`file'"
	local dta_name : subinstr local do_name ".do" ".dta"
	di "Running `do_name' to create `dta_name'"
	** h/t https://stackoverflow.com/questions/17388874/how-to-get-rid-of-the-extensions-in-stata-loop
	
	** Only run .do file to label if the file doesn't exist
	if(!fileexists("../data/`dta_name'")) {
	
		** Run the modified .do file from IPEDS
		do `file'
	
		** Write the labaled data file as .dta
		save ../data/`dta_name'
	
	}
	
	** Clear the data from memory before next loop
	clear

}
	
cd ..

** Clear any data currently stored
clear

**----------------------------------------------------------------------------**
** Optional: Remove Unnecessary Files
**----------------------------------------------------------------------------**

** Delete un-needed files (optional: remove # to run and save storage space)

python

import shutil

shutil.rmtree("zip-data", ignore_errors = True)
shutil.rmtree("zip-do-files", ignore_errors = True)
shutil.rmtree("zip-dictionaries", ignore_errors = True)
shutil.rmtree("unzip-data", ignore_errors = True)
shutil.rmtree("unzip-do-files", ignore_errors = True)
shutil.rmtree("fixed-do-files", ignore_errors = True)

end

di "Done! Labeled data is in the data/ folder"

**----------------------------------------------------------------------------**
**----------------------------------------------------------------------------**
** Done!
**----------------------------------------------------------------------------**
**----------------------------------------------------------------------------**
