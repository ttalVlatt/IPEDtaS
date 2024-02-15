## -----------------------------------------------------------------------------
##
##' [PROJ: DLI: Download Labeled IPEDS]
##' [FILE: DLI.R]
##' [AUTH: Benjamin Skinner] @btskinner
##' [INIT: 21 July 2015]
##' [EDIT: Matt Capaldi] @ttalVlatt
##' [MODI: February 14 2024]
##
## -----------------------------------------------------------------------------

##' This project is an extension of @btskinner's *downloadipeds.R* to 
##' automagically download labeled *.dta* versions of IPEDS data files,
##' which can then be used for analysis in [Stata] or [R] (via haven).
##' 
##' This project does require access to licensed [Stata]
##'   [If both Stata & R are installed locally] you can just run *DLI.do*
##'   [If you are using Stata or R in another location]
##'     run *DLI.R* (this script) first
##'     then comment out lines 40 and 42 of *DLI.do* and run it
##' 
##' [To edit what data files are downloaded], edit *ipeds-file-list.txt*
##' accordingly. This file should contain names of all available IPEDS files,
##' with all files expect HD2022 commented out with ##. Commenting a file out
##' with a #, or deleting it, will stop it from downloading. To download a file
##' simply remove the ## from that line.
##' 
##' Hint: You can hold alt to drag your cursor to more than one line
##' in many text editors (including RStudio), to comment/un-comment 
##' multiple lines at once
##' 
##' This script starts with the original content to download IPEDS files, then
##' sets up the downloaded content to work with @ttalVlatt's *DLI.do*
##' script, which loops through said set up files to apply labels to the
##' data using the provided (and modified) *.do* files from IPEDS
##' 
##' The result of running *DLI.R* then *DLI.do* should be a full set of
##' labelled *.dta* files  in the folder *labeled-data/*. *DLI.do* is set
##' up to call this script, as in, if you run the whole of *DLR.do* it will
##' run this code automatically. If this doesn't work for your setup,
##' such as if you are using a virtual copy of Stata through school, you
##' can always run this script, then comment out line 40 and 42 of *DLI.do*
##' before running it.
##' 
##' *Note: Part of this process replaces original data files with _rv*
##' *revised versions if available but the resulting file uses the original*
##' *name without _rv*
##' 
##' *Caution: Leave all below settings as they are*

## Ensure working directory is DLI main folder
setwd(this.path::here())

## ---------------------------
##' [Original: downloadipeds.R content]
## ---------------------------

## ---------------------------------------------------------------------------
## CHOOSE WHAT YOU WANT (TRUE == Yes, FALSE == No)
## -----------------------------------------------------------------------------

## default
primary_data = FALSE
dictionary = FALSE

## STATA version
## (NB: downloading Stata version of data will also get Stata program files)
stata_data = TRUE

## other program files
prog_spss = FALSE
prog_sas  = FALSE

## overwrite already downloaded files
overwrite = FALSE

## -----------------------------------------------------------------------------
## CHOOSE OUTPUT DIRECTORY (DEFAULT == '.', which is current directory)
## -----------------------------------------------------------------------------

out_dir = '.'

## =============================================================================
## FUNCTIONS
## =============================================================================

## message
mess <- function(to_screen) {
    message(rep('-',80))
    message(to_screen)
    message(rep('-',80))
}

## create subdirectories
make_dir <- function(opt, dir_name) {
    if (opt & dir.exists(dir_name)) {
        message(paste0('Already have directory: ', dir_name))
    } else if (opt & !dir.exists(dir_name)) {
        message(paste0('Creating directory: ', dir_name))
        dir.create(dir_name)
    }
}

## download file
get_file <- function(opt, dir_name, url, file, suffix, overwrite) {
    if (opt) {
        dest <- file.path(dir_name, paste0(file, suffix))
        if (file.exists(dest) & !overwrite) {
            message(paste0('Already have file: ', dest))
            return(0)
        } else {
            download.file(paste0(url, file, suffix), dest)
            Sys.sleep(1)
            return(1)
        }
    }
}

## countdown
countdown <- function(pause, text) {
    cat('\n')
    for (i in pause:0) {
        cat('\r', text, i)
        Sys.sleep(1)
        if (i == 0) { cat('\n\n') }
    }
}

## =============================================================================
## RUN
## =============================================================================

## read in files; remove blank lines & lines starting with #
ipeds <- readLines('./ipeds-file-list.txt')
ipeds <- ipeds[ipeds != '' & !grepl('^#', ipeds)]

## data url
url <- 'https://nces.ed.gov/ipeds/datacenter/data/'

## init potential file paths
data_dir <- file.path(out_dir, 'data')
stata_data_dir <- file.path(out_dir, 'stata-data')
dictionary_dir <- file.path(out_dir, 'dictionary')
stata_prog_dir <- file.path(out_dir, 'stata-dofiles')
spss_prog_dir <- file.path(out_dir, 'spss_prog')
sas_prog_dir <-  file.path(out_dir, 'sas_prog')

## create folders if they don't exist
mess('Creating directories for downloaded files')
make_dir(TRUE, out_dir)
make_dir(primary_data, data_dir)
make_dir(stata_data, stata_data_dir)
make_dir(dictionary, dictionary_dir)
make_dir(stata_data, stata_prog_dir)
make_dir(prog_spss, spss_prog_dir)
make_dir(prog_sas, sas_prog_dir)

## get timer (pause == max(# of options, 3))
opts <- c(primary_data, stata_data, dictionary, prog_spss, prog_sas)

## loop through files
for(i in 1:length(ipeds)) {

    ow <- overwrite
    f <- ipeds[i]
    mess(paste0('Now downloading: ', f))

    ## data
    d1 <- get_file(primary_data, data_dir, url, f, '.zip', ow)

    ## dictionary
    d2 <- get_file(dictionary, dictionary_dir, url, f, '_Dict.zip', ow)

    ## Stata data and program (optional)
    d3 <- get_file(stata_data, stata_data_dir, url, f, '_Data_Stata.zip', ow)
    d4 <- get_file(stata_data, stata_prog_dir, url, f, '_Stata.zip', ow)

    ## SPSS program (optional)
    d5 <- get_file(prog_spss, spss_prog_dir, url, f, '_SPS.zip', ow)

    ## SAS program (optional)
    d6 <- get_file(prog_sas, sas_prog_dir, url, f, '_SAS.zip', ow)

    ## get number of download requests
    dls <- sum(d1, d2, d3, d4, d5, d6)

    if (dls > 0) {
        ## set pause based on number of download requests
        pause <- max(dls, 3)
        ## pause and countdown
        countdown(pause, 'Give IPEDS a little break ...')
    } else {
        message('No downloads necessary; moving to next file')
    }
}

mess('Finished!')

## ---------------------------
##' [New: Prepare Downloaded Content for Stata]
## ---------------------------

##'[1: Create folder for labeled data]

dir.create("labeled-data")


##'[2: Unzip folders]

## unzip data folder
dir.create("unzip-stata-data")

sd_files <- list.files("stata-data", recursive = T, full.names = T)

for(i in sd_files) {
  unzip(i,
        exdir = "unzip-stata-data")
}

## unzip .do files folder
dir.create("unzip-stata-dofiles")

sd_files <- list.files("stata-dofiles", recursive = T, full.names = T)

for(i in sd_files) {
  unzip(i,
        exdir = "unzip-stata-dofiles")
}


##'[3: Correct the .do files to use path to downloaded data]

do_files <- list.files("unzip-stata-dofiles", recursive = T, full.names = T)

for(i in do_files) {
  
  ## read the do file as plain text
  suppressWarnings(
    do_file <- readLines(i)
  )
  
  ## Get the .csv file name from .do file name i
  data_file <- sub("unzip-stata-dofiles/", "", i) |>
    sub(".do", "", x = _) |>
    paste0("_data_stata.csv")
  
  ## Write a replacement read in line
  new_read_line <- paste0("insheet using ../unzip-stata-data/",
                          data_file,
                          ", comma clear")
  
  ## Replace the line of the do_file that starts with insheet with the
  ## new_read_line (suppress warnings about some lines grep doesn't like)
  suppressWarnings(
    do_file[grep("^\\s?insheet", do_file)] <- new_read_line
  )
  ## Also remove the line they wrote that saves the data
  suppressWarnings(
    do_file[grep("^\\s?save", do_file)] <- ""
  )
  
  ## Also remove the line that create cross-tab tables
  suppressWarnings(
    do_file[grep("^\\s?tab", do_file)] <- ""
  )
  
  ## Also remove the line that creates summary tables
  suppressWarnings(
    do_file[grep("^\\s?summarize", do_file)] <- ""
  )
  
  ## Write the updated do_file back out as i to overwrite
  writeLines(do_file, i)
  
}


##'[4: If _rv file exists, use it to overwrite original data]

rv_files <- list.files("unzip-stata-data",
                       pattern = "_rv",
                       recursive = T,
                       full.names = T)

for(i in rv_files) {
  
  ## Get the original data file name by dropping _rv
  og_name <- sub("_rv", "", i)
  ## Rename the revised file the original name (overwrites og data)
  file.rename(from = i, to = og_name)
  
}

##'[5: Fix IPEDS .do Mistakes...]

do_fix <- function(do_file_name, line_to_replace, replacement) {
  
  if(file.exists(do_file_name)) {
    
    suppressWarnings(
      do_file <- readLines(do_file_name)
    )
    
    do_file[line_to_replace] <- replacement
    
    writeLines(do_file, do_file_name)
    
  } else {
    
    paste("File", do_file_name, "not found")
    
  }
  
}

do_fix("unzip-stata-dofiles/gr2021_pell_ssl.do", 81, 'label define label_psgrtype 1 "Total 2015 cohort (Bachelor^s and other degree/certificate seeking) - four-year institutions",add')
do_fix("unzip-stata-dofiles/gr2021_pell_ssl.do", 82, '')
do_fix("unzip-stata-dofiles/gr2021_pell_ssl.do", 83, 'label define label_psgrtype 2 "Bachelor^s degree seeking 2015 cohort - four-year institutions",add')
do_fix("unzip-stata-dofiles/gr2021_pell_ssl.do", 84, '')
do_fix("unzip-stata-dofiles/gr2021_pell_ssl.do", 85, 'label define label_psgrtype 3 "Other degree/certificate seeking 2015 cohort - four-year institutions",add')
do_fix("unzip-stata-dofiles/gr2021_pell_ssl.do", 86, '')
do_fix("unzip-stata-dofiles/gr2021_pell_ssl.do", 87, 'label define label_psgrtype 4 "Degree/certificate seeking 2018 cohort (less than four-year institutions)",add')
do_fix("unzip-stata-dofiles/gr2021_pell_ssl.do", 88, '')

do_fix("unzip-stata-dofiles/hd2020.do", 104, '/*label define label_stabbr AL "Alabama"')

## In earlier years GR2017 and GR2014 this section is entirely commented out
## so apply same treatment
do_fix("unzip-stata-dofiles/gr2021.do", 166, '')
do_fix("unzip-stata-dofiles/gr2021.do", 167, '')
do_fix("unzip-stata-dofiles/gr2021.do", 168, '')
do_fix("unzip-stata-dofiles/gr2021.do", 169, '')

do_fix("unzip-stata-dofiles/gr2022.do", 165, '/*')
do_fix("unzip-stata-dofiles/gr2022.do", 182, '*/')

do_fix("unzip-stata-dofiles/GR2020.do", 166, '/*')
do_fix("unzip-stata-dofiles/GR2020.do", 168, '*/')


do_fix("unzip-stata-dofiles/ef2022a.do", 96, 'label variable xefgndru "Imputation field for efgndrun - Gender unknown"')
do_fix("unzip-stata-dofiles/ef2022a.do", 98, 'label variable xefgndra "Imputation field for efgndran - Another gender"')
do_fix("unzip-stata-dofiles/ef2022a.do", 100, 'label variable xefgndru "Imputation field for efgndrua - Total of gender unknown and another gender"')
do_fix("unzip-stata-dofiles/ef2022a.do", 102, 'label variable xefgndrk "Imputation field for efgndrkn - Total gender reported as one of the mutually exclusive binary categories (Men/Women)"')

## To fix, some files such as ef_2022cp are writing .dta files 

## -----------------------------------------------------------------------------
##' *END SCRIPT*
## -----------------------------------------------------------------------------
