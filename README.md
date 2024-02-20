# `ipeDTAs`: Automagically Download Labeled `.dta` IPEDS Files

- This `.do` file automates downloading IPEDS complete `.csv` data files, `.do` labeling files, and dictionaries
- It then processes the `.csv` data and `.do` files to create labeled `.dta` files ready of analysis in Stata or R via `haven`
- To select which files are downloaded, comment out and/or delete lines from the list at the top of the script (instructions are provided)

## System Requirements

- Stata `version 16.0` or higher
- Python for `PyStata` (often already installed)
    - Run `python search` in Stata to check it is installed  
    - See [Stata's `PyStata` documentation](https://www.stata.com/manuals/ppystataintegration.pdf) for more info
    - See [python.org's installation page](https://www.python.org/downloads/) to download if not installed
- Storage space requirement depends on how much you download
    - **All of IPEDS**
    - `~14gb` to download (raw zippped and raw unzipped copies of data are kept during processing, optional lines to delete at end of `.do` file)
    - `~4.5gb` to store (keeping only the labeled `.dta` files and dictionaries)

# Acknowledgements

- This project builds off Dr. Ben Skinner's [`downloadipeds.R` project](https://github.com/btskinner/downloadipeds) and wouldn't have been possible without it
