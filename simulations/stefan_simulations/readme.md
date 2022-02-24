

# Intro
This folder contains all the simulations and information regarding Stefan Pophristic's BCS RSA Models.

# BCS RSA Models
Explain what differences were implemented into these RSA models.

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

# What we are doing

## General Overview
We have a ton of questions that we are interested, and even more possible scenarios that we can simulate and then test experimentally. It becomes unwieldy very quickly. Therefore we split up our questions into 3 "series". Each series aims to get at a single set of questions, and thus limits the types of scenarios we will simulate.

**series 1**: The base case: are nouns informative?
**series 2**: Replication of the 2020 papers
- looking at size versus color asymmetries (in cases where nouns are uninformative)
- manipulating number of objects in the scene compared to the color x size asymmetry

**series 3**: Combination of series 1 + 2

Within series 1, we had 3 major questions we were interested in:
1. When is color used redundantly? (e.g. )
2. When is the noun used redundantly? (e.g. do people stratigically omit the noun when it is uniformative)
3. If either color or noun can be omited, is there a preference? (e.g. How often are nouns omited when both the noun and color are informative?)

Each of these three questions gets at 3 distinct possible scenarios:
1. Participant has to say the noun, but does not have to say the color. (color redundant)
2. Participant has to say the color, but does not have to say the noun. (noun redundant)
3. Participant has to say either the noun or color, but does not have to say both. Therefore either color or noun can be used redundantly. (full utterance redundant)

On top of these 3 ways of splitting up scenarios, we are also interested in: the effect of gender on all of these questions, and at a more basic level, can gender be used pragmatically? That is, can participants strategically use the gender markings on the adjectives to limit the search space of their interlocuter, thus making color adjectives more informative than they would be in English.


In case that doesn't make sense let me give an example. Say we have:
[red_plate_masc, blue_cup_fem, green_plate_masc]

Our target is the blue_cup_fem. We could just say "cup" and get our point across. However, we know that people produce color adjectives redundantly, and often say "blue cup". When we add a gender consideration, suddenly it's not just the color that is helping a participant pick the target object, but also the fact that the color adjective is feminine, and there is only one feminine object in the scene.

## Series 1 scenarios

We chose and simulated 32 scenarios in order to get the questions in series 1. We wanted to manipulate the following factors:
1. number of objects in the scene {3 vs. 6}
2. gender of objects in the scene {same vs. different}
  - same: all objects have the same gender as the target
  - different: at least some objects have a different gender than the target
3. type of object in the scene {same vs. different}
  - same: all objects are the same type as the target (e.g. they are all plates)
  - different: there are objects of a different type than the target
    - note that different genders in the scene implies different objects in the scene

The scenarios are as follows:
**ADD NOTE ABOUT HOW THESE ARE JUST EXAMPLES AND ARE ACUTALLY JUST GENDER X OBJECT 1 ETC**
**TARGET IS ALWAYS THE LAST ONE**
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

![](series/series1/scenario_types.jpg)

Scenario ID numbers refer to the identifying numbers of each scenario given above (1:32).


We ended up choosing the following scenarios:
Scenario 2  : [blue_knife_masc, red_plate_masc, blue_plate_masc]
Scenario 6  : [red_knife_masc, blue_knife_masc, blue_plate_masc]
Scenario 15 : [red_cup_fem, blue_cup_fem, blue_plate_masc]
Scenario 8  : [red_cup_fem, red_plate_masc, blue_plate_masc]

We chose to only include scenarios with 3 objects to keep the number of trials in the experiment manageable.

Scenario 2 = baseline. We expect participants to answer "blue plate". This will be directly comprable to English.
Scenario 6 = color redundant case. Everything is of the same gender, so we expect to see baseline rates of color redundancy.
Scenario 15 = full utterance redundant. Gender is varied.
Scenario 8 = noun redundant. Gender is varied.  Same as English (ish)

Explain further why you chose these 4 scenarios exactly.

## Series 1 experiment

The experiment design will be as follows:
4 scenarios * 2 genders per target * 6 items = 48 target trials
22 filler trials
for a total of 70 trials.

We envision the implementation to work as follows:
- Pick a scenario
- pick a gender
- randomly pick an object of that gender
- randomly pick the object's color
- based on that object and its color + gender, assign other objects to as the remaining states

To exemplify this implementation, I give an example about how this would work with scenario 8.
Scenario 8 = [red_cup_fem, red_plate_masc, blue_plate_masc]

To write this more generally, we want: [(object 2, gender x, color a), (object 1, gender y, color a), (object 1, gender y, color b)]
In other words, it does not matter what the exact object is, nor what the exact color nor gender of the objects are. What does matter is that they share the properties above. The target in this case is the last state.
So for example in scenario 8 for masculine nouns: [red_cup_fem, red_plate_masc, blue_plate_masc]

We start with an empty scene:
scene = []

We first pick the target at random. It is of type (object 1, gender y, color b). We randomly pikc "airplane_masc" for the object and the color "black". Therefore:
(object 1 = airplane, gender y = masc, color b = black).
Scene = [black_airplane_masc]

We then move onto the second object, which is of type (object 1, gender y, color a). We have already defined object 1 and gender y as airplane and masculine. Therefore we can only choose color a. We choose at random and get "purple". Therefore: (object 1 = airplane, gender y = masculine, color a = purple)
Scene = [black_airplane_masc, purple_airplane_masc]

We then pick our third object, which is of type (object 2, gender x, color a). Since we restricted the experiment to only two genders (masculine and feminine), because gender y = masculine, gender x has to be feminine. We then randomly pick an object 2 from the feminine objects. We pick "boot". We have already picked/defined color a. Therefore: (object 2 = boot, gender x = feminine, color a = purple).
Scene = [black_airplane_masc, purple_airplane_masc, purple_boot_fem]

We now have a scene ready to be presented to the participant.
This procedure is repeated 48 times, 24 of which the target is masculine and 24 of which the target is feminine.



We likewise wanted to vary the colors that participants saw their objects in. In order to keep the amount of images we had to design to a minimum, we implemented a color scheme system (color scheme = cs):
CS1 = {blue, yellow, red, white}
CS2 = {purple, green, orange, black}

These colors were chosen because they have morphologically different suffixes for masculine versus feminine (rather than e.g. brown which is invariable).

48 images (24 masculine and 24 feminine) were created in each color scheme. We plan on implementing the procedure for creating scenarios as described above, but for each trial, a random color scheme is chosen. Then all objects (states) are chosen from within that color scheme.

For fillers we will use the fillers from Degen et al. 2020 (which were actually the experimental items for experiment 3 of the same study)

For simplicity's sake, we decided not to vary the types of non-target objects. That is, for example, in Scenario 15 we will have something like [red_cup_fem, blue_cup_fem, blue_plate_masc] and not [red_book_fem, blue_cup_fem, blue_plate_masc]. Therefore, there will always be 2 types of objects in the target scenes.

We decided not to vary the number of objects on the screen (it will always be 3)

For each participant, every target has to be different (meaning 24 target items per gender)

## Norming study

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

## Simulations ran
test_simulations: different things there
Series1 simulations

# To do
to do:
You moved a bunch of things around, update the dependencies in teh R files so that
everything is reproducable

To do in this readme:
- what a scenario is
- discuss the decisions in more detail and in prose write up why you chose each of these
  - this will help you later when you have to write the paper
- organize the keynote presentation
