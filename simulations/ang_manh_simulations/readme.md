# Intro
This folder contains all the simulations and information regarding Stefan Pophristic's BCS RSA Models.

BCS stands for Bosnian, Croatian, Montenegrin, Serbian, Serbo-Croatian.
RSA: Rational Speech Act models. For the basic logic of RSA models please see link.

# BCS RSA Models
## Overview

The BCS RSA Models are an extension of Brandon Waldon and Judith Degen’s RSA models. Their models can be classified based off of two parameters:

**Continuous**: A model can have continuous or Boolean semantics. If the model has Boolean semantics, the semantics function (defined below) outputs either a 1 or a 0, depending on whether the utterance truthfully applies to the target object. Within a continuous semantics model, the semantics function outputs a number between 1 or 0, giving the likelihood that the utterance truthfully applies to the target object. This deviation from a 1-0 binary is meant to account for noise in the input. For example, the word “plate” may be noisy because when communicating the linguistic signal might be partially obscured, it might not be heard correctly (perceptual account of noise), or the noun might be slightly ambiguous as not all plates look the same. We don’t make a claim as to what exactly noise represents, other than a general uncertainty as to whether an utterance accurately applies to an object. For a more detailed discussion please see CITATION.

**global/Incremental**: The simple model operates over whole utterances. That is, it has a speaker reason over a literal listener, and a listener reason over a speaker, assuming that the only available linguistic input for this reasoning are fully formed utterances (however we define them in the model). The incremental model, on the other hand, reasons word by word (using the linear structure of an utterance). For a more detailed discussion please see CITATION.

## Basic Structure of Waldon and Degen's RSA Models
This is a simple overview. For a more detailed explanation see XYZ.

**Semantics()**
Function 1:
* Input: parameters dictionary
* Output: Function 2

Function 2:
* Input: state (object)
*	Output: Semantics dictionary

Semantics Dictionary: The dictionary is a list of all possible words words in the model’s world along with either a true and false value ({0,1} if non-continuous model, [0,1] if continuous model) which corresponds to whether the word can truthfully be applied to the input state.

For example, if we input “blue_plate” into our Function 2 as the state, we get back the following dictionary (in parenthesis are example values for continuous model)

Blue: 1 (0.95)
Red: 0 (0.05)
Plate: 1 (0.95)
Cup: 0 (0.05)

We then call this dictionary and look up whether the utterance “cup” applies to the state [blue_plate]. The semantics dictionary spits out 0 (0.05), telling us that it does not apply.

**Model()**
Input: parameters dictionary
Output: dictionary defining all words in our model’s world, along with all the costs associated with each word.

**Model = extend()**
Input: model(params)
Output: Dictionary with the following things defined:
*	States: all states (objects) in the scene
*	Utterances: all full utterances that can be used to truthfully refer to any object in the scene

**Params**
Dictionary that holds all the parameter values

**stringMeanings()**
This is the function called on by global models to calculate the semantic value of an utterance given an object
Input:
* Context: the utterance we are evaluating
*	State: the object that we are checking whether the utterance applies to
*	Model: a reference to the model function
*	Semantics: reference to the semantics Function 2

Output: Overall semantic value of the utterance as applied to the state.

This function then calculates the overall semantic value of the utterance by multiplying together the output of the semantics dictionary for each word of the utterance. To continue the example from above, if we are checking the utterance “blue cup” for the object [blue plate] we would get:

1 (blue) * 0 (cup) = 0
0.95 (blue) * 0.05 (cup) = 0.0475

Since these values are 0 or close to 0, we understand this output as the utterance “blue cup” not applying very well to the object [blue plate].

**stringSemantics()**
This is the function called on by incremental models that calculate the semantic value of an utterance given a state
Input: same as stringMeanings()
Output: same as stringMeanings()


**Listener/speaker functions:**
**GlobalLiteralListener**: literal listener for global models
**globalUtteranceSpeaker**: speaker for global models

**incrementalLiteralListener**: lit listener for incremental models
**wordSpeaker**: helper function for incremental Utterance Speaker
**pragmaticWordListener**: L1 for incremental model
**incrementalUtteranceSpeaker**: speaker function for incremental model

Incremental versus global models are run by calling on different listener/speaker functions.
Continuous versus non-continuous models are run by inputting different semantic values in the params variable.

There are other supporting functions which are not necessary to understand the overall flow of the program.

## BCS Additions to the RSA Model

There are three aspects of BCS which were added to the model: varying adjective word order, allowing for the noun to be dropped for an utterance, and a gender system.

The varying adjective word order and noun ellipsis were encoded by changing which full utterances were put into **Model = extend()**.

The gender system of BCS includes 3 genders (masculine, feminine, neuter). All nouns have a grammatical gender and their phonological form reflects their gender most of the time. All adjectives must agree in gender marking with the noun they are modifying.

In order to implement these aspects the gender system, we first define our words in the following format: “word_gender” whereby the gender is {masc, fem, neut}. This nomenclature must be adhered to even in full utterances. For example “START blue_masc plate_masc STOP”. We define our states as: “word_word_gender”. For example: “blue_plate_masc”. Note that a state must be defined with all relevant properties of the object. So, for example, if we are looking at size and color adjectives, all the states must be defined as: “size_color_noun_gender”.

The rest of the changes occurred in the semantics dictionary.

If the utterance is true, the semantics dictionary returns a value just like before. If the utterance is false, the dictionary calls on falseSemantics() which does a more complicated computation, accounting for the fact that a word can apply to an object falsely in different ways:

1.	Word correctly applies but the gender is incorrect.

For example “blue_masc” applying to a “blue_cup_fem”. The issue with “blue_masc” is not the “blue” but rather the gender.
In such cases, the false semantic value is computed by: **wordNoiseVal * (1-genderNoise)**

2.	Word does not apply, but the gender is correct

For example, “blue_masc” applying to a “red_plate_masc”. The gender is correct, but the color is not.

In such cases, the false semantic value is computed by: **(1-wordNoiseVal) * genderNoise**

3.	Word and gender are both incorrect

For example, “blue_masc” applying to a “red_cup_fem”. The gender is correct, but the color is not.

In such cases, the false semantic value is computed by: **(1-wordNoiseVal) * (1-genderNoise)**

This code assumes that an incorrect gender and incorrect semantic value of the word both play an equal role in determining the semantic value of this utterance.

Below I describe the exact functions that execute this:

**falseSemantics()**
Input:
* adjNoise: Noise value of whichever word we are testing (could be a color adjective, a size adjective, or the noun itself)
* genderNoise: Noise value of gender
* dictDefinition: the word in the dictionary for which we are calculating the false semantic value
* state: the input state (object) of Function 2 in semantics()

Output: False semantic value of the word in the dictionary given the target state
This function calls on returnGenderAndDictionary (see below), and then uses that output to calculate the semantic values.

**returnGenderAndDictionary()**
Input: the word from the dictionary for which we are computing the semantic value
Output: Array. The first element is the gender of the word, all other elements are the words themselves. In this implementation, this array should always be of size 2 (since our dictionary is defined as singleWord_gender.

**recursivelySplitGenderAndWord()**
Input: the word from the dictionary for which we are computing the semantic value
Output: Array with all the words which constitute the the input string
While this function is not technically necessary, it was included in order to account for possible future iterations of this model, where our dictionary is defined with multiple words, such as “big_blue_masc”.


# Stefan_simulations Folder Organization

- **\\models**: All documents needed to run simulations of the BCS RSA Model. For a more comprehensive explanation of what the files in this folder do, see the *Simulation Pipeline* section.
- **\\Series**: All files pertaining to simulations of a given series (for more info about what series are, see the section below)
  - **\\series1**
    - **\\model_input**: files that are input into the model
      - stefanSecnarioSeries1.csv: produced from stefanAllScenarios.py found in models folder    
    - **\\model_output**: graphs and csv file output from running the models (Output from models > stefan_simulations.R)
    - Naming_Guide: guide for naming conventions I use in the keynote slides
    - scenarios.key: keynote slides with visuals of which scenarios (sets of states) were run in the models along with considerations as to which scenarios we should pick for the final experiment
    - setup_for_experiment: files regarding actually running the experiment. Currently only has a csv file of target wrods, and the images we will use.
- **\\test_simulations**: various sets of simulations we ran in order to explore the effect of parameters on the model outputs and predictions.

# Some Definitions
For consistency, here is how I (and this repo) uses the following terminology:
**simulation**: an iteration of running the BCS RSA models
**state**: RSA lingo for a string that represents an object. This string is the input for the RSA model. For example, in the models in stefan_simulations, a state may be "red_cup_fem" which refers to a red cup with the feminine grammatical gender.
**scenario**: A made up world defined by the states that it contains. So for example, if we were to show a participant three objects (e.g. a blue cup, a blue plate, and a red cup), the RSA model will calculate speaker utterances over the following set of states: ["blue_cup_fem", "blue_plate_masc", "red_cup_fem"]. Therefore this scenario is defined as: {[object 1, gender a, color x], [object 2, gender b, color x], [object 1, gender a, color y]}.
**pattern**: largely unimportant. But a "pattern" refers to how the outputs of a model run for a given scenario pattern. This is terminology used mainly in the keynote slides and was used for helping understand model outputs for different scenarios.
**series**: a set of scenarios that we chose to explore in order to answer a specific question. I explain this in more detail below.

# Simulation Pipeline

1. run stefanAllScenarios with the parameters and states you care about
2. run stefan_simulations to see the ouput of those models

stefanAllScenarios.py
  **Input**: none
  **Output**: CSV file (see code for specifics)
  Within the code you specify which parameters and states you want to run in webppl. The code then creates a csv file whereby each row contains strings of JS/Webppl codethat can be used in stefan_simulations.R to run the the BCS RSA models. This code provides an easy way to run multiple models with minimal differences (e.g. changing one parameter or changing the input states) without having to copy and paste Webppl code.


stefan_simulations.R
  **Input**: csv file produced from stefanAllScenarios.py
  **Output**: csv file whereby each row corresponds to a specific RSA model, a specific scenario that the model was run on, and a single output of the model.
          Graphs with the output of the models run
  **Dependencies**:
          V8wppl.R
          stefanSimulationHelpers.R
          stefanEngine.txt

V8wppl.R:
  **Input**: none
  **Output**: none
  **Dependencies**: none
  Contains a function that takes in string of webppl code and modifies it so that it interfaces properly with Google's JS and WebAssembley engine (and thus runs the code in webppl). It returns the output that is given by the webppl code that it has run online.
  This code is found the _shared folder in the root of this repo.

stefanSimulationHelpers.R:
  **Input**: none
  **Output**: none
  **Dependencies**: V8wppl.r
  Contains a single function called **runModel**. This function is called from other R scripts. It takes in input (see the r code for details), uses the input to assemble webppl code, runs it online in webppl, and returns the output.

stefanEngine.txt:
  **Input**: none
  **Output**: none
  **Dependencies**: none
  A text file of javascript/webppl code with all the functions that are constant across all BCS RSA models. That is, none of the code is dependent on specific parameter settings nor what states are input into the model.

# What we are doing

## General Overview
Due to the amount of questions we are interested in, and all the possible scenarios we can simulate and then test experimentally to answer these questions, we split up our questions into 3 “series”. Each series aims to target a subset of our general questions. It thus limits the types of scenarios we can simulate.

**series 1**: The base case: are nouns informative?
**series 2**: Replication of the 2020 papers
* looking at size versus color asymmetries (in cases where nouns are uninformative)
* manipulating number of objects in the scene compared to the color x size asymmetry

**series 3**: Combination of series 1 + 2

Within series 1, we had 3 major questions we were interested in:
1. When is color used redundantly?
2. When is the noun used redundantly? (e.g. do people strategically omit the noun when it is uninformative)
3. If either color or noun can be omitted, is there a preference? (e.g. How often are nouns omitted when both the noun and color are informative?)

Each of these three questions gets at 3 distinct possible scenarios:
1. Participant has to say the noun but does not have to say the color. (color redundant)
2. Participant has to say the color but does not have to say the noun. (noun redundant)
3. Participant has to say either the noun or color but does not have to say both. Therefore, either color or noun can be used redundantly. (full utterance redundant)

On top of these 3 ways of splitting up scenarios, we are also interested in: the effect of gender on all of these questions, and at a more basic level, can gender be used pragmatically? That is, can participants strategically use the gender markings on the adjectives to limit the search space of their interlocuter, thus making color adjectives more informative than they would be in English.

In case that doesn't make sense let me give an example. Say we have:
[red_plate_masc, blue_cup_fem, green_plate_masc]

Our target is the blue_cup_fem. We could just say "cup" and get our point across. However, we know that people produce color adjectives redundantly, and often say "blue cup". When we add a gender consideration, suddenly it's not just the color that is helping a participant pick the target object, but also the fact that the color adjective is feminine, and there is only one feminine object in the scene.

## Series 1 scenarios

We chose and simulated 32 scenarios in order to get the questions in series 1. We wanted to manipulate the following factors:
1. number of objects in the scene {3 vs. 6}
2. gender of objects in the scene {same vs. different}
  * same: all objects have the same gender as the target
  * different: at least some objects have a different gender than the target
3. type of object in the scene {same vs. different}
  * same: all objects are the same type as the target (e.g. they are all plates)
  * different: there are objects of a different type than the target
    * note that different genders in the scene implies different objects in the scene

The scenarios are given below. We included actual items to make the output easier to interpret. However, the exact gender/noun/color does not matter. What a scenario such as

["blue_cup_fem", "blue_plate_masc", "red_cup_fem"]

really represents is a something like:

{[object 1, gender a, color x], [object 2, gender b, color x], [object 1, gender a, color y]}

That is, what we care about are which properties are shared and not shared across the objects, rather than the specific noun/gender/color of the objects themselves.

In the scenarios below, the target object is always the “blue_plate_masc”.
scenario 1 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc"]
scenario 2 = ["blue_plate_masc", "red_plate_masc", "blue_knife_masc"]
scenario 3 = ["blue_plate_masc", "red_plate_masc", "red_knife_masc"]
scenario 4 = ["blue_plate_masc", "blue_knife_masc", "blue_knife_masc"]
scenario 5 = ["blue_plate_masc", "red_knife_masc", "red_knife_masc"]
scenario 6 = ["blue_plate_masc", "red_knife_masc", "blue_knife_masc"]
scenario 7 = ["blue_plate_masc", "red_plate_masc", "blue_cup_fem"]
scenario 8 = ["blue_plate_masc", "red_plate_masc", "red_cup_fem"]
scenario 9 = ["blue_plate_masc", "blue_knife_masc", "blue_cup_fem"]
scenario 10 = ["blue_plate_masc", "blue_knife_masc", "red_cup_fem"]
scenario 11 = ["blue_plate_masc", "red_knife_masc", "blue_cup_fem"]
scenario 12 = ["blue_plate_masc", "red_knife_masc", "red_cup_fem"]
scenario 13 = ["blue_plate_masc", "blue_cup_fem", "blue_cup_fem"]
scenario 14 = ["blue_plate_masc", "red_cup_fem", "red_cup_fem"]
scenario 15 = ["blue_plate_masc", "red_cup_fem", "blue_cup_fem"]

scenario 16 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "red_plate_masc", "red_plate_masc", "red_plate_masc"]
scenario 17 = ["blue_plate_masc", "red_knife_masc", "red_knife_masc", "red_knife_masc", "red_knife_masc", "red_knife_masc"]
scenario 18 = ["blue_plate_masc", "blue_knife_masc", "blue_knife_masc", "blue_knife_masc", "blue_knife_masc", "blue_knife_masc"]
scenario 19 = ["blue_plate_masc", "red_knife_masc", "red_knife_masc", "red_knife_masc", "blue_knife_masc", "blue_knife_masc"]
scenario 20 = ["blue_plate_masc", "red_knife_masc", "red_knife_masc", "blue_knife_masc", "blue_knife_masc", "blue_knife_masc"]
scenario 21 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "red_knife_masc", "red_knife_masc", "red_knife_masc"]
scenario 22 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "blue_knife_masc", "blue_knife_masc", "blue_knife_masc"]
scenario 23 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "red_knife_masc", "blue_knife_masc", "blue_knife_masc"]
scenario 24 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "red_knife_masc", "red_knife_masc", "blue_knife_masc"]
scenario 25 = ["blue_plate_masc", "red_cup_fem", "red_cup_fem", "red_cup_fem", "red_cup_fem", "red_cup_fem"]
scenario 26 = ["blue_plate_masc", "blue_cup_fem", "blue_cup_fem", "blue_cup_fem", "blue_cup_fem", "blue_cup_fem"]
scenario 27 = ["blue_plate_masc", "blue_cup_fem", "blue_cup_fem", "red_cup_fem", "red_cup_fem", "red_cup_fem"]
scenario 28 = ["blue_plate_masc", "blue_cup_fem", "blue_cup_fem", "blue_cup_fem", "red_cup_fem", "red_cup_fem"]
scenario 29 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "red_cup_fem", "red_cup_fem", "red_cup_fem"]
scenario 30 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "blue_cup_fem", "blue_cup_fem", "blue_cup_fem"]
scenario 31 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "blue_cup_fem", "blue_cup_fem", "red_cup_fem"]
scenario 32 = ["blue_plate_masc", "red_plate_masc", "red_plate_masc", "red_cup_fem", "blue_cup_fem", "red_cup_fem"]

Visualizations of all 32 scenarios can be found in the keynote slides.

We then split up these scenarios based on whether they were: 1) color redundant; 2) noun redundant; or 3) full utterance redundant

A table with all distribution of all 32 scenarios is given below:
![](series/series1/scenario_types.jpg)

Scenario ID numbers refer to the identifying numbers of each scenario given above (1:32).


We ended up choosing the following scenarios:
Scenario 2  : [blue_knife_masc, red_plate_masc, blue_plate_masc]
Scenario 6  : [red_knife_masc, blue_knife_masc, blue_plate_masc]
Scenario 15 : [red_cup_fem, blue_cup_fem, blue_plate_masc]
Scenario 8  : [red_cup_fem, red_plate_masc, blue_plate_masc]

The following considerations were taken when choosing these scenarios:

After running some numbers we settled on the following experiment design:
48 target trials = 4 scenarios * 2 genders per target * 6 items
22 filler trials
= 70 trials total

We decided to restrict the experiment to only 2 genders (masculine and feminine). This was done to limit the number of trials we need to collect data for. We chose masculine and feminine as since they are the two most common genders, and masculine and neuter genders have the same adjective suffixes in agreement in non-nominative cases.

We wanted each scenario x gender pairing to have several trials with different objects per participant, so that we can collect more robust (not single object dependent) data.

We didn’t want more than 70 trials per participant, and needed to include filler trials.

We therefore settled on 4 scenarios.

Of the 4 scenarios we wanted one in each of our redundancy conditions (color redundant; noun redundant; full utterance redundant) along with a baseline that we can use to compare to English data.

To keep these scenarios consistent, we chose only scenarios with 3 target objects (rather than varying the number of objects in each scenario across trials).

For simplicity's sake, we decided not to vary the types of non-target objects. That is, for example, in Scenario 15 we will have something like [red_cup_fem, blue_cup_fem, blue_plate_masc] and not [red_book_fem, blue_cup_fem, blue_plate_masc]. Therefore, there will always be 2 types of objects in the target scenes.

Taking all these considerations into account, we chose:

Scenario 2 = baseline. We expect participants to answer "blue plate". This will be directly comparable to English.
Scenario 6 = color redundant case. Everything is of the same gender, so we expect to see baseline rates of color redundancy.
Scenario 15 = full utterance redundant. Gender is varied.
Scenario 8 = noun redundant. Gender is varied.  Same as English (ish)


## Series 1 experiment

To reiterate, the experiment design will be as follows:
4 scenarios * 2 genders per target * 6 items = 48 target trials
22 filler trials
for a total of 70 trials.

For each participant, every target has to be different (meaning 24 target items per gender)

For each target trial, we envision picking objects/genders as follows:
* Pick a scenario
* pick a gender
* randomly pick an object of that gender
* randomly pick the object's color
* based on that object and its color + gender, assign other objects to as the remaining states

To exemplify this implementation, I give an example about how this would work with scenario 8, for the masculine gender

Scenario 8 = [red_cup_fem, red_plate_masc, blue_plate_masc]

To write this more generally, we want:
 [(object 2, gender x, color a), (object 1, gender y, color a), (object 1, gender y, color b)]

We start with an empty scene:
scene = []

We first pick the target at random. It is of type (object 1, gender y, color b). We want this trial to be masculine, so we define (gender y = masc). We then pick a masculine object at random. We pick “airplane_masc” for the object and the color “black”. Therefore:

(object 1 = airplane, gender y = masc, color b = black)

Scene = [black_airplane_masc]

We then move onto the second object, which is of type (object 1, gender y, color a). We have already defined object 1 and gender y as airplane and masculine. Therefore, we can only choose color a. We choose at random and get "purple". Therefore:

(object 1 = airplane, gender y = masculine, color a = purple)
Scene = [black_airplane_masc, purple_airplane_masc]

We then pick our third object, which is of type (object 2, gender x, color a). Since we restricted the experiment to only two genders (masculine and feminine), because gender y = masculine, gender x has to be feminine. We then randomly pick an object 2 from the feminine objects. We pick "boot". We have already picked/defined color a. Therefore:

(object 2 = boot, gender x = feminine, color a = purple).
Scene = [black_airplane_masc, purple_airplane_masc, purple_boot_fem]

We now have a scene ready to be presented to the participant.
This procedure is repeated 48 times, 24 of which the target is masculine and 24 of which the target is feminine.

### Color Consideration

We likewise wanted to vary the colors that participants saw their objects in. In order to keep the number of images we had to design to a minimum, we implemented a color scheme system (color scheme = cs):
CS1 = {blue, yellow, red, white}
CS2 = {purple, green, orange, black}

These specific colors were chosen because they have morphologically different suffixes for masculine versus feminine (rather than e.g. brown which is invariable).

48 images (24 masculine and 24 feminine) were created in each color scheme. We plan on implementing the procedure for creating scenarios as described above, but for each trial, a random color scheme is chosen. Then all objects (states) are chosen from within that color scheme.

For fillers we will use the fillers from Degen et al. 2020 (which were actually the experimental items for experiment 3 of the same study)

# Norming study

We ran a color and noun norming study for the stimuli we plan to use for Series 1.

A total of 105 stimuli were designed. Their distribution was as follows:
CS1:
* Fem: 26
*	Masc: 27

CS2:
*	Fem: 26
*	Masc: 26

Images were taken from freepik.com or unsplash.com. In almost all cases, the images were photographs of the objects. On occasion, realistic looking drawings of graphic art was used. Using photoshop, the background of each image was turned into a solid white color. The objects themselves were manipulated to be the specified color for their color schemes. These images were then presented in random order to participants in the Noun Norming Study and the Color Norming Study.

## Noun Norming Study:

The goals of this norming study were as follows:
*	Participants can clearly understand the intended object given the images we created
*	Ensure that these objects are consistently labeled:
	* That is, to ensure that participants have a label at hand, and do not need to explain the object in a roundabout way, thus possibly influencing the rates of redundant uses of words
  * And to ensure that the labels participants use are of the gender we intend them to be, so that our gender manipulation in the scenarios is consistent across participants.

A total of 127 participants were recruited via prolific. Participants were recruited based on the prolific inclusion criteria of: self reported fluency or native speaker status of Serbian or Croatian (Bosnian and Montenegrin were not options on the prolific platform).

Participants were asked to type the name of the object shown on the screen in BCS. Each participant saw all 105 objects in a randomized order. The color of each object was chosen at random. At the end of the experiment, participants completed a short dialect survey.

Participants who self reported having spent the majority of their time in the Balkans in Slovenia or Macedonia or reported being foreign speakers of BCS (based on our post experiment questionare) were excluded from the study (n=50). Since a lot of the words we are testing are less commonly used (e.g. whistle) we were afraid that participants might answer using the word which exists in their native language rather than in BCS. Due to the high overlap of these languages, this may skew the data in such a way that a very uncommon word in BCS seems to be much more common, because it is the appropriate word in Slovenian or Macedonian. Several participants were further excluded for answering with colors rather than the name of the object or clearly using google translate for some answers (n = 2). This resulted in a total of 75 participants.

### Results

In order to include a stimuli in our final stimuli list, the stimuli must have met the following criteria:
1.	After accounting for spelling errors and spelling/pronounciation differences across dialects, more than 70% of responses answered with a single label
2.	There was no label that accounted for 70% of responses. However the combination of the top 2-3 labels did account for 70% of the responses, and they were all of the same gender.

The reasoning behind the inclusion criterion (1) is that if 70% of participants agree on a label, the picture is identifiable enough to be used as a stimulus and the labelling of the image is consistent enough that we expect participants to use that label.

The stimuli that were included based on criterion (2) fell into two broad categories, each is discussed in turn.

A)	Different dialects had different labels for the same object. For example, Croatians call a spoon “žlica” whereas Serbians may call a spoon “kašika”. In such cases, we expect participants to already have established labels within their speech communities and not deviate from them. Since both words across dialects are of the same gender, even if participants are speaking with someone from a different dialect, we will still be sure that both interlocutors can use the gender information in the exact same way. Although we don’t expect this scenario to arise, because participants will choose their own partner for the study.

B)	The labels fell into a subset superset relationship. For example, for the image of a boot, participants responded with “boot” and “shoe”. Both labels are present within a single dialect and both are equally applicable to the object. Since both words are of the same gender, it has no effect on our predictions and hypotheses whether a participant opts to use one label or the other.

None of the these thresholds included compound words such as "ball for billiard"

The following number of stimuli met these criteria:
CS1:
*	Fem: 19
*	Masc: 14

CS2:
*	Fem: 21
*	Masc: 21

The exact stimuli that met the criteria can be found in the BCS_RSA_Norming folder under the experiments section of this repo.

## Color Norming Study:

The goal of this norming study was to ensure that participants clearly understood the intended color for each image and labelled it consistently. If this is not the case, then the particular image introduces more confounds that can effect rates of redundant color adjectives.

A total of 147 participants were recruited via prolific. Participants were recruited based on the prolific inclusion criteria of: self reported fluency or native speaker status of Serbian or Croatian (Bosnian and Montenegrin were not options on the prolific platform).

Participants were asked to type the color of the object shown on the screen in BCS. Otherwise, the procedure was exactly the same as the noun norming study.

The exclusion criteria was the same as in the norming study. 65 participants were excluded due to the Slovenia/Macedonia criteria. A further two participants were excluded for responding in English and answering with object names rather than colors.

### Results

Each object was split up by its color. Stimuli were excluded if responses to at least one of the object’s four colors did not reach a 70% threshold. Multiple color responses (e.g. “blue-grey”) and modified colors (e.g. “light blue”) were counted as separate from the single color responses (e.g. “blue”).

Overall, we found a total of 15 items that did not reach threshold.

The color which did not reach threshold is as follows:
Black : 1
Orange: 11
White: 3
Yellow: 1

One object did not reach threshold for both the yellow and white colors.

Any object that did not reach threshold was not included in the final stimuli list.

## Final Stimuli List:

CS1:
Fem: (19)
-	Door
-	Crown
-	Dress
-	Candle
-	Book
-	Chair
-	Pencil
-	Iron
-	Mask
-	Guitar
-	Fence
-	Armchair
-	Bucket
-	Lamp
-	Shirt
-	Bracelet
-	Shoe
-	Mug
-	stapler

Masc: (12)
-	Balloon
-	Bed
-	Phone
-	Butterfly
-	Cushion
-	Wallet
-	Comb
-	Ring
-	Scarf
-	Flower
-	Belt
-	Calculator

CS2:
Fem: (16)
-	Die
-	Fish
-	Tie
-	Glove
-	Sock
-	Shell
-	Ribbon
-	Necklace
-	Slipper
-	Shovel
-	Purse
-	Vase
-	Bowl
-	Fork
-	Basket
-	whistle

Masc: (16)
-	Calendar
-	Hammer
-	Truck
-	Drum
-	Microscope
-	Helicopter
-	Robot
-	Luggage
-	Bandaid
-	Knife
-	Radio
-	Plate
-	Binoculars
-	Lock
-	Lipstick
-	Screwdriver

# To do
to do:
You moved a bunch of things around, update the dependencies in teh R files so that
everything is reproducable

To do in this readme:
- what a scenario is
- discuss the decisions in more detail and in prose write up why you chose each of these
  - this will help you later when you have to write the paper
- organize the keynote presentation
