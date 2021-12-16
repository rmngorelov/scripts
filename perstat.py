#!/usr/bin/env python3

#run as executable: "./perstat.py Gomez" --- 'Gomez' is the argument
#or run as: "python3 perstat.py Gomez" 

import sys
import os

#check/install selenium
try:
    from selenium import webdriver
except:
    print("selenium not found, attempting to install.")
    os.system('pip3 install selenium')
    from selenium import webdriver

#check/install geckodriver
from os import path
if path.exists('./geckodriver') is False:
    print('geckodriver not in current folder, attempting to download.')
    os.system('wget https://github.com/mozilla/geckodriver/releases/download/v0.30.0/geckodriver-v0.30.0-linux64.tar.gz')
    os.system('tar -xvzf geckodriver*')
    os.system('rm *.gz')
    if path.exists('./geckodriver') is False:
        print('geckodriver not found in current direcotory, please download manually.')
        exit()

from selenium.webdriver.firefox.service import Service
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options as FirefoxOptions

inputUser = sys.argv[1].lower() #takes first argument
s=Service('./geckodriver') #point to geckodriver

options = FirefoxOptions()
options.add_argument("--headless") #firefox headless option

browser = webdriver.Firefox(options=options,service=s) 
browser.get('https://docs.google.com/forms/d/e/1FAIpQLSdrErooFYWLLArmyLaINRAWzDF3TJ9ctaI0jH-F6qWHjQT_Sw/viewform') #go to site
names = browser.find_elements(By.CLASS_NAME, "docssharedWizToggleLabeledLabelText") #find elements of names

namesList = [] #text of names
for i in names:
    namesList.append(i.text.lower())

print('input received --- ', inputUser)

namePosition = namesList.index(inputUser) #enters index of name. If this is an error, the name you entered is not found.
radiobuttons = browser.find_elements(By.CLASS_NAME, "appsMaterialWizToggleRadiogroupElContainer") #counts radio buttons
radiobuttons[namePosition].click() #clicks radio button
submitbutton = browser.find_elements(By.CLASS_NAME, "appsMaterialWizButtonPaperbuttonLabel.quantumWizButtonPaperbuttonLabel.exportLabel") #finds submit

submitbutton[0].click() #click submit
confirm = browser.find_element(By.CLASS_NAME, "freebirdFormviewerViewResponseConfirmationMessage") #print confirmation
print(confirm.text)

browser.quit()
