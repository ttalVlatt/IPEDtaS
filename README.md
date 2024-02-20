# `ipeDTAs`: Automagically Download Labeled `.dta` IPEDS Files

- This `.do` file automates downloading IPEDS complete `.csv` data files, `.do` labeling files, and dictionaries
- It then processes the `.csv` data and `.do` files to create labeled `.dta` files ready of analysis in Stata or R via `haven`
- To select which files are downloaded, comment out and/or delete lines from the list at the top of the script (instructions are provided)

## To Download

Option One: Download as .zip (easy)
- Click the green `Code` button
- Select "download as .zip" beneath the URLs
- Open .zip file on your computer
- Open `ipeDTAs.do`, follow instructions, and run!

Option Two: Clone (or fork) this GitHub Repo (if familiar with git)
- Click the green `Code` button
- Copy the https or ssh link
- Clone using terminal or your git client
- Open `ipeDTAs.do`, follow instructions, and run! 

Option Three: Copy and paste code (easy, but error prone)
- Click on `ipeDTAs.do` and copy the code
- Open a blank `.do` file in Stata
- Paste the code
- Follow instructions and run!

## System Requirements

- Stata `version 16.0` or higher
- Python for `PyStata` (often already installed)
    - Run `python search` in Stata to check python is installed  
    - See [Stata's `PyStata` documentation](https://www.stata.com/manuals/ppystataintegration.pdf) for more info
    - See [python.org's installation page](https://www.python.org/downloads/) to download if not installed
- Storage space requirement depends on how much you download
    - **All of IPEDS**
    - `~14gb` to download (raw zippped and raw unzipped copies of data are kept during processing, optional lines to delete at end of `.do` file)
    - `~4.5gb` to store (keeping only the labeled `.dta` files and dictionaries)
 
## Note on Time to Download

- If you wish to download the entirity of IPEDS, it can take 2-3 hours
- To avoid overwhelming IPEDS servers there is a 3 second delay between each file download, which at over 3000 files, becomes a significant amount of time
- If you wish, at your own risk of being rejected by NCES servers, you can reduce (or remove) `sleep 3000` on lines 1362, 1377, and 1392

## Acknowledgement

- This project builds off Dr. Ben Skinner's [`downloadipeds.R` project](https://github.com/btskinner/downloadipeds) and wouldn't have been possible without it
