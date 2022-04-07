
## TO DO
MOVE DATA FILES INTO DATA FOLDER FOR NORMING STUDIES.

Analysis for Stefan Pophristic's and Judith Degen's BCS Stimuli Norming study. For details about the study, see the readme found in experiments > BCS

## Organization of Folders
- **1_noun_norming**:
  - **main_native**: analysis folder with all participants recruited over prolific who listed BCS as a first language
    - **analysis.Rmd**: Markdown file that outputs all relevant data. This file requires a csv file named "1_noun_norming_main-merged_cleaned.csv" in the data folder. This file should be created by running the participant_status.py file in the shared folder. This script outputs a pdf with all the relevant graphs and information. It likewise outputs a demographic.R file, a analysis.md file that supports the output pdf, and a folder called analysis_files that contains images of all the graphs.
  - **data**: Folder containing all csv files from prolific.
- **2_color_norming**
  - **main_native**: analysis folder with all participants recruited over prolific who listed BCS as a first language
- **shared**
  - **analysis.R**: Main analysis script that creates all the graphs. Analysis files in the other folders call on this analysis file. Any changes to this file will be reflected in the analyses for both color and noun norming.
  - **participant_status.py**: this python script appends a column to the csv file stating whether participants are {heritage, native, simk, foreign} speakers of BCS. This file should be run before the analysis scripts. Instructions on how to run this file are found in the file itself

## Analysis Pipeline:
Open terminal and navigate to analyses > BCS > BCSNorming > shared. Run participant_status.py based on the instructions found in that script. Then run the analysis.Rmd file found in either 1_noun_norming or 2_color_norming.
