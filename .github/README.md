<img src="https://github.com/ttalVlatt/IPEDtaS/blob/main/.github/Icon.png?raw=true" width="200" height="200" />

[![](https://zenodo.org/badge/DOI/10.5281/zenodo.13388846.svg)](https://doi.org/10.5281/zenodo.13388846)

# `IPEDtaS`: Automagically Download Labeled `.dta` IPEDS Files in Stata and R

- This project contains Stata and R scripts that 'automagically' download labeled versions of [IPEDS complete data files](https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx)
  - In the Stata implementation it simply downloads the data, .do file, and dictionary and after cleaning up any issues, uses the .do file IPEDS provide to add data labels
  - In the R implementation the .do file is read as text into R then converted to labeling instructions passed to the `haven` R package


- The logic of using both scripts is very similar
  1. Place either `IPEDtaS.do` (for Stata projects) or `IPEDtaS.R` (for R projects) in your main project folder
  2. Edit the `selected_files` list to the [IPEDS complete data files](https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx) you need
    - By default the script will download the entirity of IPEDS, which takes multiple hours and around 10gb
    - You can either delete or comment out any files you don't want. Simply download the script from here again if you need the full list back.
  3. Hit "do" or "run"
  4. After it's completed, both result in a `data/` folder containing labeled `.dta` files and a `dictionaries/` folder with the matching dictionaries
  
- The project is intended to both make IPEDS data files easier to work with and also enhance reproducibility of research using IPEDS
  - I encourage you to include a copy of the `IPEDtaS` script you use in your analyses in any code you share for reproduction
    - If you do so, please cite the repository so others can easily find and use it:
<br/>
  
  > Capaldi, M. J. (2024). IPEDtaS: Automagically Download Labeled .dta IPEDS Files in Stata and R (Version 0.1) [Computer software]. https://doi.org/10.5281/zenodo.13388846
  
Hints
- In R, use `as_factor()` from `haven` library to convert a labeled column to a factor which uses the labels as the levels
