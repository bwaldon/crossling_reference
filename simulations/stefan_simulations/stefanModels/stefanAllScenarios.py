# Stefan Pophristic
# November 11, 2021
#
#
# Serbo-Croatian RSA scenario modeling
#
# The goal of this code is to create a set of scenarios on which we will run the
# RSA models whereby everything is automated, so that we only have to input
# the test states that we want, and the model will run on all combinations of
# parameters for those states. The actual running of the model occurs in the R
# script stefan_simulations.R. This code creates the dataframe that will be
# imported into that script.
#
# HOW TO ADD SCENARIOS
# 1. add: scenarioNumber = ["object_1", "object_2", ...]
#   --> this creates the scenario
# 2. add: scenarios.append(scenarioNumber)
#   --> this adds the scenario to the list that contains all scenarios
# 3. make sure that all the words which are found in your object/state strings
#   are found in the lexicon defined below. Otherwise the code won't work
#
# states (or objects) need to be properly formatted. In other words:
# "big_blue_plate_masc" or "blue_masc"
#
# This code assumes:
# a) that all words defining the state are the only words which can
#       be used in utterances to describe the states.
# b) That all states end with a gender
# c) the only valid morphological genders are: (masc, fem, neut)
# d) genders are found as suffixes (a stipulation of the RSA code and not this code,
#       but we love consistency)
# d) all words used to define states are split up with "_", not spaces or dashes
#

# ADD SECTION ON PARAMETERS

# INPUT:
# this code does not need any outside input to run
#
# OUTPUT:
# A csv file with the following columns:
# states: a set of states that defines the particular scenario we are running
# Command: command/model type, aka is semantics boolean or continuous and
#       are we using the incremental or vanilla/global model
# Target: the target object
# Utterance: one of the utterances that could apply in that scenario
# Model: RSA model function with all words and their noise/cost, this is a string
#       of javaScript code
# Semantics: RSA semantics function with all dictionary entries and their noise
#       this is a string of javaScript code
#
#
# Bug in the program: We iterate through the cost loop in the boolean semantic scenarios
# Causing a bunch of repeated rows in the output file
# I need to fix that in this code, but for now just get only the unique rows in the R file


### I HARD CODED ALPHA --> get rid of that for next scenario run
### I hard coded the target from currentState to currentScenario[0]
###     and then made the first item in each scenario list the target
###     this also had to be hard coded into the outputcommand (2x)


# master list that will be wrapper for whole data structure
masterList = []

#scenarios = list of all scenarios
scenarios = []

#create individual scenarios
scenario1 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc"]
scenario2 = ["blue_plate_masc", "red_plate_masc", "blue_knife_masc"]
scenario3 = ["blue_plate_masc", "red_plate_masc", "red_knife_masc"]
scenario4 = ["blue_plate_masc", "blue_knife_masc", "blue_knife_masc"]
scenario5 = ["blue_plate_masc", "red_knife_masc", "red_knife_masc"]
scenario6 = ["blue_plate_masc", "red_knife_masc", "blue_knife_masc"]
scenario7 = ["blue_plate_masc", "red_plate_masc", "blue_cup_fem"]
scenario8 = ["blue_plate_masc", "red_plate_masc", "red_cup_fem"]
scenario9 = ["blue_plate_masc", "blue_knife_masc", "blue_cup_fem"]
scenario10 = ["blue_plate_masc", "blue_knife_masc", "red_cup_fem"]
scenario11 = ["blue_plate_masc", "red_knife_masc", "blue_cup_fem"]
scenario12 = ["blue_plate_masc", "red_knife_masc", "red_cup_fem"]
scenario13 = ["blue_plate_masc", "blue_cup_fem", "blue_cup_fem"]
scenario14 = ["blue_plate_masc", "red_cup_fem", "red_cup_fem"]
scenario15 = ["blue_plate_masc", "red_cup_fem", "blue_cup_fem"]


scenario16 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "red_plate_masc", "red_plate_masc", "red_plate_masc"]
scenario17 = ["blue_plate_masc", "red_knife_masc", "red_knife_masc", "red_knife_masc", "red_knife_masc", "red_knife_masc"]
scenario18 = ["blue_plate_masc", "blue_knife_masc", "blue_knife_masc", "blue_knife_masc", "blue_knife_masc", "blue_knife_masc"]
scenario19 = ["blue_plate_masc", "red_knife_masc", "red_knife_masc", "red_knife_masc", "blue_knife_masc", "blue_knife_masc"]
scenario20 = ["blue_plate_masc", "red_knife_masc", "red_knife_masc", "blue_knife_masc", "blue_knife_masc", "blue_knife_masc"]
scenario21 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "red_knife_masc", "red_knife_masc", "red_knife_masc"]
scenario22 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "blue_knife_masc", "blue_knife_masc", "blue_knife_masc"]
scenario23 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "red_knife_masc", "blue_knife_masc", "blue_knife_masc"]
scenario24 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "red_knife_masc", "red_knife_masc", "blue_knife_masc"]
scenario25 = ["blue_plate_masc", "red_cup_fem", "red_cup_fem", "red_cup_fem", "red_cup_fem", "red_cup_fem"]
scenario26 = ["blue_plate_masc", "blue_cup_fem", "blue_cup_fem", "blue_cup_fem", "blue_cup_fem", "blue_cup_fem"]
scenario27 = ["blue_plate_masc", "blue_cup_fem", "blue_cup_fem", "red_cup_fem", "red_cup_fem", "red_cup_fem"]
scenario28 = ["blue_plate_masc", "blue_cup_fem", "blue_cup_fem", "blue_cup_fem", "red_cup_fem", "red_cup_fem"]
scenario29 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "red_cup_fem", "red_cup_fem", "red_cup_fem"]
scenario30 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "blue_cup_fem", "blue_cup_fem", "blue_cup_fem"]
scenario31 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "blue_cup_fem", "blue_cup_fem", "red_cup_fem"]
scenario32 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "red_cup_fem", "blue_cup_fem", "red_cup_fem"]

#scenario2 = ["big_blue_plate_masc", "big_red_plate_masc", "big_red_cup_fem"]

#add all scenarios
scenarios.append(scenario1)
scenarios.append(scenario2)
scenarios.append(scenario3)
scenarios.append(scenario4)
scenarios.append(scenario5)
scenarios.append(scenario6)
scenarios.append(scenario7)
scenarios.append(scenario8)
scenarios.append(scenario9)
scenarios.append(scenario10)
scenarios.append(scenario11)
scenarios.append(scenario12)
scenarios.append(scenario13)
scenarios.append(scenario14)
scenarios.append(scenario15)
scenarios.append(scenario16)
scenarios.append(scenario17)
scenarios.append(scenario18)
scenarios.append(scenario19)
scenarios.append(scenario20)
scenarios.append(scenario21)
scenarios.append(scenario22)
scenarios.append(scenario23)
scenarios.append(scenario24)
scenarios.append(scenario25)
scenarios.append(scenario26)
scenarios.append(scenario27)
scenarios.append(scenario28)
scenarios.append(scenario29)
scenarios.append(scenario30)
scenarios.append(scenario31)
scenarios.append(scenario32)

#list of all types of commands
#   global = global utterances, i.e. not incremental
#   inc = incremental models
#   Bool = boolean semantics
#   Cont = continuous semantics
commandTypes = ["globalBool", "globalCont", "incBool", "incCont"]


# Dictionary
# In order for getWordType funtion (and thus makeUtterances function) to work
#       properly, all words that could apply to any states that are fed into the
#       model must be added here
# This program assumes there are only color and size adjectives along with nouns
#       i.e. there are no other types of words
nounDict = ["plate_masc", "cup_fem", "knife_masc"]
colorDict = ["blue_masc", "blue_fem", "blue_neut", "red_masc", "red_fem", "red_neut"]
sizeDict = ["big_masc", "big_fem", "big_neut", "small_masc", "small_fem", "small_neut"]


# Makes all words that could apply to a state
# Input: A string of a single state in the proper format,
#       e.g. "big_blue_plate_masc"
# Output: a list of all words that apply to that state
#       e.g. ["big_masc", "blue_masc", "plate_masc"]
def makeWords(state) :
    allWords = []
    #Split up all the words from the states
    #add gender morpheme
    #and add them to the master list
    # for a in states:
    #split words of current state
    wordsOfStateNoGender = state.split("_")

    #find gender of this state from states
    gender = ''
    if 'masc' in wordsOfStateNoGender:
        gender = '_masc'
    if 'fem' in wordsOfStateNoGender:
        gender = '_fem'
    if 'neut' in wordsOfStateNoGender:
        gender = '_neut'

    # attach gender marking to each one individually
    for currentWord in wordsOfStateNoGender:
        #skip the gender markers (they are not their own words)
        if currentWord == "masc" or currentWord == "fem" or currentWord == "neut":
            continue
        #add gender marking
        currentWordWithGender = currentWord + gender
        #add word to allwords if it is not already in there
        if currentWordWithGender not in allWords:
            allWords.append(currentWordWithGender)

    return allWords

# splits all words up into their respective word word types (color, size, noun)
# input: list of strings, each string is a word in proper format, e.g. "big_fem"
# output: list of 3 lists, first is all size adjectives, second is all color adjectives
#       third is all nouns
# This function requires all input words to be found in the lexicon defined by
#       colorDict, sizeDict, and nounDict
def getWordType(words):
    colorAdj = []
    sizeAdj = []
    nouns = []
    #iterate through all words
    for word in words:
        #get color adjectives
        if word in colorDict:
            colorAdj.append(word)
        #get size adjectives
        elif word in sizeDict:
            sizeAdj.append(word)
        #get nouns
        elif word in nounDict:
            nouns.append(word)

    return [sizeAdj, colorAdj, nouns]


# Function creates valid utterances of Serbo-Croatian given a set of states
#   Utterances created are: single word utterances, double adjective in (size color)
#   order without noun utterances, double adjectives in (size color) order with a noun
#   utterances
# Input: Takes in a list of strings. Each string is a state of a given scenario
# Output: List of strings of all utterances.
def makeUtterances(states):
    allUtterances = []
    for state in states:

        #returns list of all words with gender markings
        allWord = makeWords(state)

        wordTypes = getWordType(allWord)
        sizeAdj = wordTypes[0]
        colorAdj = wordTypes[1]
        nouns = wordTypes[2]

        start = "START "
        end = " STOP"

        #create single word utterances
        for a in allWord:
            tempString = start + a + end
            if tempString not in allUtterances:
                allUtterances.append(tempString)

        # create single adjective utterances with noun
        for a in colorAdj :
            for b in nouns :
                tempString = start + a + " " + b + end
                if tempString not in allUtterances:
                    allUtterances.append(tempString)

        for a in sizeAdj :
            for b in nouns :
                tempString = start + a + " " + b + end
                if tempString not in allUtterances:
                    allUtterances.append(tempString)

        # create double adjective utterances with no noun
        for a in sizeAdj:
            for b in colorAdj:
                tempString = start + a + " " + b + end
                if tempString not in allUtterances:
                    allUtterances.append(tempString)

        # create double adjective utterances with noun
        for currentNoun in nouns:
            for size in sizeAdj:
                for color in colorAdj:
                    tempString = start + size + " " + color + " " + currentNoun + end
                    if tempString not in allUtterances:
                        allUtterances.append(tempString)

    return allUtterances

# Creates a string of javaScript code which will serve as the RSA model
# Input: states that the model should be made over
#       e.g. ["big_blue_plate_masc", "big_red_plate_masc", "small_blue_plate_masc"]
# Output: A string of the javascript code of RSA model function
def makeModel(states):
    #get all the words from all the states
    words = []
    for a in states:
        currentWord = makeWords(a)
        for word in currentWord:
            if word not in words:
                words.append(word)

    wordTypes = getWordType(words)
    # word types --> [[colorAdj], [sizeAdj], [currentNouns]]

    masterString = "var model = function(params) {  return { words : ["
    for a in words:
        masterString += "'" + a +  "'" + ","

    masterString += "'STOP', 'START'], wordCost: {"

    #WordTypes is in the format of: [[size adj], [color adj], [nouns]]
    for a in wordTypes[0]:
        masterString += "'" + a + "' : params.sizeCost,"

    for a in wordTypes[1]:
        masterString += "'" + a + "' : params.colorCost,"

    for a in wordTypes[2]:
        masterString += "'" + a + "' : params.nounCost,"

    masterString += "'STOP'  : 0, 'START'  : 0 },}}"
    return masterString

# Function that returns all states that the word can truthfully apply to
#       e.g. "blue_masc" applies to state "big_blue_plate_masc" but not to
#       "big_blue_cup_fem" nor to "big_red_plate_masc"
# Input: states = set of strings of states
#       word = string of a word
# Output: list of strings of states
def statesThatApply(states, word):
    if "_masc" in word:
        wordGender = "masc"
    elif "_fem" in word:
        wordGender = "fem"
    elif "_neut" in word:
        wordGender = "neut"

    wordWithoutGender = word.replace("_" + wordGender, "")

    allStatesThatApply = []
    #itterate through all states
    for currentState in states:
        # check if state contains substring of the word
        if wordWithoutGender in currentState:
            #check that state matches word's gender
            if wordGender in currentState:
                allStatesThatApply.append(currentState)

    return(allStatesThatApply)

# Creates the semantic function needed to run the RSA model
# Input: list of strings of states in the model
# Output: A string of javascript code that will serve as the semantics function
#       that changes with every scenario
# note that this javascript code calls on other functions which do not change
#       with scenario. They should be imported into the R script from a text file
def makeSemantics(states) :
    #get all the words from all the states
    words = []
    for a in states:
        currentWord = makeWords(a)
        for word in currentWord:
            if word not in words:
                words.append(word)

    wordTypes = getWordType(words)
    masterString = "var semantics = function(params) { return function(state) { return { "

    #iterate through all words
    for word in words:
        #get all states for which that applies
        theStatesThatApply = statesThatApply(states, word)

        #get word type
        if word in colorDict:
            noiseValue = "colorNoiseVal*params.genderNoiseVal"
            noiseValueWithoutGender = "colorNoiseVal"
        if word in sizeDict:
            noiseValue = "sizeNoiseVal*params.genderNoiseVal"
            noiseValueWithoutGender = "sizeNoiseVal"
        if word in nounDict:
            noiseValue = "nounNoiseVal"
            noiseValueWithoutGender = "nounNoiseVal"

        #paste it all together
        masterString += word + ": ["
        masterString +=  ','.join(map("'{0}'".format, theStatesThatApply))
        masterString += "].includes(state)"
        masterString += " ? params." + noiseValue + " : falseSemantics(params."
        masterString += noiseValueWithoutGender + ", params.genderNoiseVal, ["
        masterString += ','.join(map("'{0}'".format, theStatesThatApply))
        masterString += "], state),"

    masterString += "STOP : 1, START : 1 } } }"
    return masterString



wordsPerScenario = []
#model makes the words all over again
# this can be simplified by looping through words


#Create a list that contains all the utterances that pertain to given scenarios
#       the index of each scenario in scenarios and each utterance in
#       utterancesPerScenario correspond
utterancesPerScenario = []
for a in scenarios:
    utterancesPerScenario.append(makeUtterances(a))

#Create a list that contains all the models that pertain to given scenarios
#       the index of each scenario in scenarios and each model in
#       modelsPerScenario correspond
modelsPerScenario = []
for a in scenarios:

    modelsPerScenario.append(makeModel(a))

#Create a list that contains all the semantic functions that pertain to given scenarios
#       the index of each scenario in scenarios and each semantics in
#       semanticsPerScenario correspond
semanticsPerScenario = []
for a in scenarios:
    semanticsPerScenario.append(makeSemantics(a))


# Create the desired data structure

#counter indexes scenarios, and semantics-/models-/utterances- PerScenario
counter = -1

# Iterate through all the scenarios
for currentScenario in scenarios:
    counter = counter + 1
    # Iterate through alpha values
    for alpha in range(1, 21, 5):
        # Iterate through size noise values
        # These values will be divided by 100 later in the code
        for genderNoise in range(80, 101, 20):
            # Iterate through noun noise values
            for cost in range(0, 2, 1):
                # Iterate through commands (i.e. do we want continuous or boolean semantics
                #   or incremental versus global utterances)
                for currentCommand in commandTypes:

                    # Iterate through states, each state that is chosen is the new target
                    #   for the speaker in the RSA model
                    for currentState in currentScenario:

                        #for global models we have no need to itterate through utterances
                        if currentCommand == "globalBool" or currentCommand == "globalCont":

                            outputCommand = "globalUtteranceSpeaker('" + currentScenario[0] + "', model, params, semantics)"

                            #For boolean models we don't need noise terms other than 1
                            if currentCommand == "globalBool":
                                #Due to the nature of the for loop in python, we can't itterate through decimal numbers
                                # so we itterate through whole numbers and divide cost and noise values by 10
                                masterList.append([currentScenario, currentCommand, outputCommand, currentScenario[0], "", utterancesPerScenario[counter], modelsPerScenario[counter], semanticsPerScenario[counter], 19, 1, 1, 1, 1, cost/10, cost/10, cost/10])
                            #for noisy semantic models we need the noise parameters
                            else:
                                #parameters are in the following order: alpha, sizeNoise/10, colorNoise/10, genderNoise/10, nounNoise/10, sizeCost/10, colorCost/10, nounCost/10
                                # 19, 0.8, 0.95, genderNoise/100, 0.8, cost/10, cost/10, cost/10
                                masterList.append([currentScenario, currentCommand, outputCommand, currentScenario[0], "", utterancesPerScenario[counter], modelsPerScenario[counter], semanticsPerScenario[counter], 19, 0.8, 0.95, genderNoise/100, 0.9, cost/10, cost/10, cost/10])

                        else:
                            #loop through utterances, each utterance is what will be fed to the
                            #   speaker in the RSA model
                            for currentUtterance in utterancesPerScenario[counter]:
                                outputCommand = "incrementalUtteranceSpeaker('" + currentUtterance + "', '" + currentScenario[0] + "', model, params, semantics)"

                                #For boolean models we don't need noise terms other than 1
                                if currentCommand == "incBool":
                                    #Due to the nature of the for loop in python, we can't itterate through decimal numbers
                                    # so we iterate through whole numbers and divide cost and noise values by 10
                                    masterList.append([currentScenario, currentCommand, outputCommand, currentScenario[0], currentUtterance, utterancesPerScenario[counter], modelsPerScenario[counter], semanticsPerScenario[counter], 19, 1, 1, 1, 1, cost/10, cost/10, cost/10])

                                #for noisy semantic models we need the noise parameters
                                else:
                                    #parameters are in the following order: alpha, sizeNoise/10, colorNoise/10, genderNoise/10, nounNoise/10, sizeCost/10, colorCost/10, nounCost/10
                                    masterList.append([currentScenario, currentCommand, outputCommand, currentScenario[0], currentUtterance, utterancesPerScenario[counter], modelsPerScenario[counter], semanticsPerScenario[counter], 19, 0.8, 0.95, genderNoise/100, 0.9, cost/10, cost/10, cost/10])


# Export as a csv file
import csv
with open('stefanScenarioSeries1.csv', 'w') as f:
    writer = csv.writer(f)
    #add columns with proper names
    writer.writerow(["states", "commandType", "command", "target", "utterance", "allUtterances", "model", "semantics", "alpha", "sizeNoise", "colorNoise", "genderNoise", "nounNoise", "sizeCost", "colorCost", "nounCost"])
    writer.writerows(masterList)
