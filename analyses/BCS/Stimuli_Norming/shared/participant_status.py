###
# participant_status.py
# BCS RSA Norming Studies
# Stefan Pophristic
#
# Program that returns a csv file with a new column determining participant status
#   (how their exposure to BCS should be classified in the analysis)
#
# INPUT:
# # Argument 1: Path from this file to the  -merged.csv file with the data
# #             ../1_noun_norming/main_native/data/1_noun_norming_main-merged.csv
# #        or   ../2_color_norming/main_native/data/2_color_norming_main-merged.csv ../
# #
# # Argument 2: Path from this file to where the original csv file is, and a new
# #           name for the edited csv file
# #            ../1_noun_norming/main_native/data/1_noun_norming_main-merged_cleaned.csv
# #            ../2_color_norming/main_native/data/2_color_norming_main-merged_cleaned.csv
#
# OUTPUT:
# # Return csv file with new column which includes participant status which is
# #   native: native speaker
# #   heritage: heritage speaker
# #   simk: Slovenian or Macedonian who speaks BCS
# #  foreign: non-native speaker of BCS
#
# Partipant status is determined as follows:
# #   native: language spoken at home growing up and at school are both BCS
# #   heritage: language spoken at home growing up is BCS, language spoken at
# #             school growing up is not BCS
# #   simk: The country the participant reported as having spent most time in is
# #         either Slovenia or Macedonia, regardless of what they reported as
# #         language spoken at home or school
# #  foreign: language spoken at school and at home does not include BCS
#
# To run this program, navigate to this file in terminal, then run:
# python participant_status.py argument1 argument2
#
# Other notes:
# This program does not account for spelling errors nor languages written using a /.
#  so for example a participant that writes { firstLanguage:Serrrbian,
#  schoolLanguage: Serbian/Croatian) will be counted as a foreign rather than native
#  speaker. These errors are manually corrected for in the analysis R scripts.


import sys
import pandas as pd


# read in csv file of responses
df = pd.read_csv(str(sys.argv[1]))

# rename columns for ease
df = df.rename(columns={'subject_information.firstLanguage': 'firstLanguage',
    'subject_information.bcsPrimaryLanguageSchool': 'schoolLanguage',
    'subject_information.otherLanguage': "otherLanguage",
    'subject_information.country': 'country'})

#make all responses lower case
df['firstLanguage'] = df['firstLanguage'].str.lower()
df['schoolLanguage'] = df['schoolLanguage'].str.lower()
df['otherLanguage'] = df['otherLanguage'].str.lower()

# variable that will hold all statuses of participants
statusArray = []
firstLanguageArray = []
schoolLanguageArray = []
otherLanguageArray = []

# Add the values from the dataframe to the arrays, splitting all answers up by spaces
for x in range(len(df)) :
    firstLanguageArray.append(str(df.at[x, 'firstLanguage']).split())
    schoolLanguageArray.append(str(df.at[x, 'schoolLanguage']).split())
    otherLanguageArray.append(str(df.at[x, 'otherLanguage']).split())

languages = ["croatian", "serbian", "bosnian", "montenegrian", "serbo-croatian",
            "hrvatski", "srpski", "bosanski", "bošnjački", "bosnjacki", "crnogorski",
            "maternji", "srpskohrvatski", "hrvatskosrpski", "srpsko-hrvatski",
            "hrvatsko-srpski", "bhs", "bcs"]

# x is an array
def commonelems(langs):
    for a in range(len(langs)):
        if (langs[a] in languages):
            return(True)
    return(False)

# Add statuses to status array
for x in range(len(df)) :
    if ((df.at[x, 'country'] == "MK") or (df.at[x, 'country'] == 'SI') ) :
        statusArray.append("simk")
    elif (commonelems(schoolLanguageArray[x]) and commonelems(firstLanguageArray[x])) :
        statusArray.append("native")
    elif (not commonelems(schoolLanguageArray[x]) and commonelems(firstLanguageArray[x])) :
        statusArray.append("heritage")
    else :
        statusArray.append("foreign")

# Add status Array to dataframe
df = df.assign(status = statusArray)

df.to_csv(str(sys.argv[2]))
