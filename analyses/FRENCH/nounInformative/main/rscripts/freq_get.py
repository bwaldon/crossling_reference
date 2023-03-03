from wordfreq import word_frequency
from wordfreq import zipf_frequency
import pandas as pd
import csv
translation = {}
with open('../../../norming/data_output/noun_final_accents.csv', mode='r') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        word = row["Item"]
        if (word == "fryingpan") :
            word = "pan"
        if (word == "magnifyingglass") :
            word = "magnifying glass"
        if (word == "billiardball") :
            word = "billiard ball"
        if (word == "coathanger") :
            word = "hanger"
        frenWord = row["common"]
        translation[word] = frenWord


targetList = pd.read_csv('wordlist.csv')
df = pd.DataFrame([['sample Eng', 'zipf eng','sample French', 'zipf french']], columns=["engWord", "engFreq", "frenWord", "frenFreq"])
for word in targetList:
    engWord = word.strip(' \n“"”')
    if (engWord == "fryingpan") :
            engWord = "pan"
    if (engWord == "magnifyingglass") :
            engWord = "magnifying glass"
    if (engWord == "billiardball") :
            engWord = "billiard ball"
    if (engWord == "coathanger") :
            engWord = "hanger"
    engZipf = zipf_frequency(engWord, 'en')
    frenWord = translation[engWord]
    frenZipf = zipf_frequency(frenWord, 'fr')
    df2 = pd.DataFrame([[engWord, engZipf, frenWord, frenZipf]],columns=["engWord", "engFreq", "frenWord", "frenFreq"])
    df = pd.concat([df,df2])
print(df)
df.to_csv('freqFinal.csv', encoding='utf-8')
#english eng_zipf fren fren_zipf
