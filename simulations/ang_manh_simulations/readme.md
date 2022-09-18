# Intro
This folder contains all the simulations and information regarding Angelique's method for running English, French and Vietnamese RSA Models quickly from a single, simple CSV file.

Manh created his own method for running French and Vietnamese RSA Models, so you can contact him for further info.

This Readme is based off of Stefan's BCS work.

RSA: Rational Speech Act models. For the basic logic of RSA models please see link.
https://www.problang.org/chapters/01-introduction.html

# French and Vietnamese RSA Models
## Overview

The French and Vietnamese RSA Models are an extension of Brandon Waldon and Judith Degen’s RSA models. Their models can be classified based off of two parameters:

**Continuous**: A model can have continuous or Boolean semantics. If the model has Boolean semantics, the semantics function (defined below) outputs either a 1 or a 0, depending on whether the utterance truthfully applies to the target object. Within a continuous semantics model, the semantics function outputs a number between 1 or 0, giving the likelihood that the utterance truthfully applies to the target object. This deviation from a 1-0 binary is meant to account for noise in the input. For example, the word “plate” may be noisy because when communicating the linguistic signal might be partially obscured, it might not be heard correctly (perceptual account of noise), or the noun might be slightly ambiguous as not all plates look the same. We don’t make a claim as to what exactly noise represents, other than a general uncertainty as to whether an utterance accurately applies to an object. For a more detailed discussion please see Degen et al.'s work:
https://doi.org/10.48550/arXiv.1903.08237

**global/Incremental**: The simple model operates over whole utterances. That is, it has a speaker reason over a literal listener, and a listener reason over a speaker, assuming that the only available linguistic input for this reasoning are fully formed utterances (however we define them in the model). The incremental model, on the other hand, reasons word by word (using the linear structure of an utterance). For a more detailed discussion please see Cohn Gordon et al.'s work:
https://doi.org/10.48550/arXiv.1810.00367

## Basic Structure of Waldon and Degen's RSA Models
This is a simple overview.

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

# Ang_manh_simulations Folder Organization
This folder is still messy, but the following is the current setup. Other folders are left over from Stefan's folder, which we duplicated to create this folder.

- **\\models**: All documents needed to run simulations of the French and Vietnamese RSA Model. For a more comprehensive explanation of what the files in this folder do, see the *Simulation Pipeline* section.
- **\\Series**: The input and output of simulations, plus some miscellaneous files.
  - **\\series1**
    - **\\model_input**: files that are input into the model
    - **\\model_output**: graphs and csv file output from running the models (Output from models > ang_simulations.R)
    - **\\visualizations.r**: Generates graphs of model output files
- **\\Graphs**: Final visualizations for our experiments

# Some Definitions
For consistency, here is how I (and this repo) uses the following terminology:
**simulation**: an iteration of running the RSA models in French, English or Vietnamese
**state**: RSA lingo for a string that represents an object. This string is the input for the RSA model. For example, in the models in ang_manh_simulations, a state may be "big red cup"
**scenario**: A made up world defined by the states that it contains. So for example, if we were to show a participant three objects (e.g. a big blue cup, a small blue plate, and a big red cup), the RSA model will calculate speaker utterances over the following set of states: ["big blue cup", "small blue plate", "big red cup"].
**environment**: A set of a scenario and the target

# Simulation Pipeline

1. run ang_simulations with your chosen input file to see the output of those models
2. Optionally run visualizations.R to generate a graph

ang_simulations.R
  **Input**: csv file stored in **/series/series1/model_input/** produced with the following columns:\\
Name - Objects - Nouns - Adjectives - Size_adjectives - size_noise - color_noise - noun_noise - adj_cost - noun_cost - alpha - global_inc - language\\
Name, size_noise, color_noise, noun_noise, adj_cost, noun_cost and alpha should all be self explanatory\\

Objects is an array of names for objects. It must include the size and the color of the objects in English order:
  - e.g ['big blue cup', 'small red cup', 'big red train']\\
  If you use the wrong type of quote marks, it won't run.\\
Nouns, Adjectives, and Size_adjectives are also arrays of strings listing what nouns, and adjectives are used in the environment\\
global_inc should be either 'inc' or 'global' (with no quotation marks), depending on whether you want to run the incremental or global model. In this particular model, GLOBAL ONLY RUNS ON ENGLISH.\\
Language is a number from 0 -3.
  0: English, 1: Spanish, 2: French, 3: Vietnamese

  **Output**: The input csv file with one new column: output. This column contains the probability that the person will use both adjectives in their utterance, (which for Vietnamese is the sum of both adjective orderings).
  **Dependencies**:
          V8wppl.R
          angSimulationHelpers.R
          angEngine.txt
          createEnv.txt

V8wppl.R:
  **Input**: none
  **Output**: none
  **Dependencies**: none
  Contains a function that takes in string of webppl code and modifies it so that it interfaces properly with Google's JS and WebAssembley engine (and thus runs the code in webppl). It returns the output that is given by the webppl code that it has run online.
  This code is found the shared folder in the root of this repo.

angSimulationHelpers.R:
  **Input**: none
  **Output**: none
  **Dependencies**: V8wppl.r
  Contains two functions called **createEnv** and **runModel_2**.
  **createEnv** generates the webppl code that sets up the environment and runs it. It returns an array containing.
  a semantics array, a list of words, the states variables, and a list of possible utterances. (see code for details on how this is parsed)
  runModel_2 is called from other R scripts. It takes in input (see the r code for details), uses the input to assemble webppl code, runs it online in webppl, and returns the output, which is the model output.

angEngine.txt:
  **Input**: none
  **Output**: none
  **Dependencies**: none
  A text file of javascript/webppl code with all the functions that are constant across all RSA models. That is, none of the code is dependent on specific parameter settings nor what states are input into the model.

createEnv.txt
  A text file of webppl code that will generate the environment given the input columns.

# What we are doing
We are still working on organizing this folder, but in general the Summer work looked at noun informative contexts.

# Notes
Instances in which the noun is redundant (as in French, where the noun can be omitted in a grammatical way), are not accounted for in this code. \\
The global model should only be run on English because of a persistent bug. \\
The target is always the first object mentioned, which is always ALWAYS a small blue pin. \\
For questions, contact Angelique Charles-Davis.
