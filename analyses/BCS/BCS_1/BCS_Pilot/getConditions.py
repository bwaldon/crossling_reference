
import pandas as pd

df = pd.read_csv(r'../../data/BCSPilot/allTargets.csv');

allItems = df['name'].tolist();

splitWords = []

for b in range(0, len(allItems)):
    splitWords.append(allItems[b].split("_"))

masculine = ["butterfly", "balloon", "phone", "bed", "flower", "wallet",
"ring, cushion", "comb", "calculator", "belt", "scarf", "calendar", "hammer",
"truck", "microscope", "binoculars", "drum", "robot", "helicopter", "knife",
"luggage", "lock", "screwdriver"]

conditions = []

for a in range(0, int(len(allItems)/3)):
    #print(a)
    target = splitWords[a*3]
    item1 = splitWords[a*3 + 1]
    item2 = splitWords[a*3 + 2]

    # Identify words' genders
    if target[1] in masculine :
        target.append("M")
    else:
        target.append("F")

    if item1[1] in masculine :
        item1.append("M")
    else:
        item1.append("F")

    if item2[1] in masculine :
        item2.append("M")
    else:
        item2.append("F")

    # Figure out condition
    # gender match conditions
    if(target[2] == item1[2] == item2[2]):
        # scenario 1
        if(target[1] == item1[1] or target[1] == item2[1]):
            conditions.append("scenario1")
        else:
            conditions.append("scenario2")
    else:
        # scenario 4
        if(target[1] == item1[1] or target[1] == item2[1]):
            conditions.append("scenario4")
        else:
            conditions.append("scenario3")


print(conditions)
