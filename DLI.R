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
dictionary = TRUE

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
  
  
  ##'[Remove any lines trying to label string vars, as Stata does not allow it
  
  ## Get line indexes that...
  
  ## Start "label define" space any_thing space not a digit or -
  pattern <- "^label define\\s+\\w+\\s+[^0-9-].*"
  line_index_1 <- grep(pattern, do_file)
  
  ## As above, but start with number and include a non-digit before next word
  pattern <- "^label define\\s+\\w+\\s+\\b-?\\d+[A-Za-z]\\b.*"
  line_index_2 <- grep(pattern, do_file)
  
  ## Get the index of any line meeting either pattern
  line_index <- unique(c(line_index_1, line_index_2))
  
  ## Get the actual text of the lines
  lines <- do_file[line_index]
  
  ## Start a blank list for problematic variables
  prob_vars <- c()
  
  ## For each line deemed problematic
  for(j in lines) {
    ## Take the third word of problematic lines, which is the variable
    prob_var <- strsplit(j, "\\s+")[[1]][3]
    ## Add to list
    prob_vars <- c(prob_vars, prob_var)
  }
  
  ## Get a list of unique problematic variables
  prob_vars <- unique(prob_vars)
  
  if(length(prob_vars >= 1)) {
    
    ## Create a regex pattern of prob_vars separated by "|" for "or"
    prob_vars_pattern <- paste(prob_vars, collapse = "|")
    
    ## Get index of any lines containing a problematic variable
    lines_index_prob_vars <- grep(prob_vars_pattern, do_file)
    
    ## Blank out those lines
    do_file[lines_index_prob_vars] <- ""
    
  }
  
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

##'[5: Fix Misc. IPEDS .do Mistakes...]

do_fix <- function(do_file_name, line_to_replace, replacement) {
  
  setwd("unzip-stata-dofiles")
  
  if(file.exists(do_file_name)) {
    
    suppressWarnings(
      do_file <- readLines(do_file_name)
    )
    
    do_file[line_to_replace] <- replacement
    
    writeLines(do_file, do_file_name)
    
  } else {
    
    paste("File", do_file_name, "not found")
    
  }
  
  setwd("..")
  
}

## ,add was mistakenly on new line
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

## -----------------------------------------------------------------------------
##' *END SCRIPT*
## -----------------------------------------------------------------------------
