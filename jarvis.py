import pyttsx3
import speech_recognition as sr
import datetime
import pyaudio
import wikipedia
import webbrowser
import os
import smtplib
import ssl
import subprocess
import tkinter
import json
import random 
import operator
import winshell
import pyjokes
import feedparser
import ctypes
import time
import requests
import shutil
import wolframalpha
import win32com.client as wincl
from urllib.request import urlopen
from twilio.rest import Client
from clint.textui import progress
from ecapture import ecapture as ec
from bs4 import BeautifulSoup
from googletrans import Translator
from email.message import EmailMessage
from secret_code import password


email_sender = 'eagerbirdBuy@gmail.com'
email_password = password

#email_receiever = '2021.chandni.gangwani@ves.ac.in'

subject = "Jarvis"


em = EmailMessage()
em['From'] = email_sender

em['subject'] = subject


context = ssl.create_default_context()

def sendMail():
    with smtplib.SMTP_SSL('smtp.gmail.com', 465, context=context) as smtp:
         smtp.login(email_sender, email_password)
         smtp.sendmail(email_sender, em['To'], em.as_string())
         

engine = pyttsx3.init('sapi5')
voices = engine.getProperty('voices')
# print(voices[0].id)
engine.setProperty('voice',voices[0].id)

def speak(audio):
    engine.say(audio)
    engine.runAndWait()

# def TranslateHinToEng(Text):
#     line = str(Text)
#     translate = Translator()
#     result = translate.translate(line)
#     data = result.text
#     print(f"You said : {data}")
#     return data 

# def MicConnect():
#     query = takeCommand()
#     data = TranslateHinToEng(query)
#     return data 
    
def wishMe():
    hour = int(datetime.datetime.now().hour)
    if hour>=0 and hour<12:
        speak("Good Morning!")
    
    elif hour>=12 and hour<18:
        speak("Good Afternoon!")
    
    else:
        speak("Good Evening!")
    
    speak("I am Jarvis. ")
    

def username():
    speak("What should i call you ")
    uname = takeCommand()
    speak("Welcome ")
    speak(uname)
    columns = shutil.get_terminal_size().columns
     
    print("#####################".center(columns))
    print("Welcome ", uname.center(columns))
    print("#####################".center(columns))
     
    speak("How can i Help you")
    
    
def takeCommand():
    #It takes microphone input from the user and returns string output
    
    r = sr.Recognizer()
    with sr.Microphone() as source:
        print("Listening...")
        r.pause_threshold = 1
        audio = r.listen(source,timeout=5,phrase_time_limit=5)
    
    try:
        print("Recognizing...")
        query = r.recognize_google(audio)
        print(f"User said: {query}\n")
        
    except Exception as e:
        print(e) 
        print("Say that again please... ")
        return "None"
    return query

# def sendEmail(to, content):
#     server = smtplib.SMTP('smtp.gmail.com', 587)
#     server.ehlo()
#     server.starttls()
#     server.login('eagerbirdBuy@gmail.com', '6913Dummy@6913')
#     server.sendmail('cgangwani486@gmail.com', to, content)
#     server.close()
    
if __name__ == "__main__":
    wishMe()
    username()
    while True:
    #if 1:
        query = takeCommand().lower()
        # sendEmail('2021.chandni.gangwani@ves.ac.in', 'Hi this Jarvis ' )
        
        #Logic for executing tasks based on query
        if 'wikipedia' in query:
            speak('Searching Wikipedia...')
            query = query.replace("Wikipedia" , "")
            results = wikipedia.summary(query, sentences=2)
            speak("According to Wikipedia")
            print(results)
            speak(results)
        
        elif 'open youtube ' in query:
            webbrowser.open("http://youtube.com")
        
        elif 'open google' in query:
            webbrowser.open("http://google.com")
            
        elif 'open stackoverflow' in query:
            webbrowser.open("http://stackoverflow.com")
            
        elif 'play music ' in query:
            music_dir = 'C:\\Users\\Gangwani\\Desktop\\jarvis\\music'
            songs = os.listdir(music_dir)
            print(songs)
            os.startfile(os.path.join(music_dir,songs[0]))
            
        elif 'the time' in query:
            strTime = datetime.datetime.now().strftime("%H:%M:%S")
            print(strTime)
            speak(f"The time is {strTime}")
            
        elif 'open code' in query:
            codePath = "C:\\Users\\Gangwani\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe"
            os.startfile(codePath)
            
        elif 'email' in query:
            try:
                speak("What should I say?")
                body = takeCommand()
                em.set_content(body)
                speak("Whom should i send?")
                #202email_receiver = input()
                em['To'] = input('Enter an email id ')
                # content = takeCommand()
                # to = "2021.chandni.gangwani@ves.ac.in"
                sendMail()
                speak("Email has been sent!")
            except Exception as e:
                print(e)
                speak("Sorry my friend . I am unable to send this email")
        
        # elif 'translate to english' in query:
        #     speak("Speak what is to be translated ")
        #     # MicConnect()
            
            
        elif 'how are you' in query:
            speak("I am fine, Thank you")
            speak("How are you ")
 
        elif 'fine' in query or "good" in query:
            speak("It's good to know that your fine")
 
        elif "change my name to" in query:
            query = query.replace("change my name to", "")
            assname = query
 
        elif "change name" in query:
            speak("What would you like to call me ")
            assname = takeCommand()
            speak("Thanks for naming me")
 
        elif "what's your name" in query or "What is your name" in query:
            speak("My friends call me")
            speak(assname)
            print("My friends call me", assname)
 
        elif 'exit' in query:
            speak("Thanks for giving me your time")
            exit()
 
        elif "who made you" in query or "who created you" in query:
            speak("I have been created by miniproject team 3.")
             
        elif 'joke' in query:
            joke = pyjokes.get_joke()
            print(joke)
            speak(joke)
        
        elif "calculate" in query:
             
            app_id = "X4PAJQ-8XR29JYA3G"
            client = wolframalpha.Client(app_id)
            indx = query.lower().split().index('calculate')
            query = query.split()[indx + 1:]
            res = client.query(' '.join(query))
            answer = next(res.results).text
            print("The answer is " + answer)
            speak("The answer is " + answer)
            
        elif 'search' in query or 'play' in query:
             
            query = query.replace("search", "")
            query = query.replace("play", "")         
            webbrowser.open(query)
            
 
            
        # elif 'count the words' in query:
        #     speak('Please input your text in the following page ')
        #     codePath2 = "C:\\Users\\Gangwani\\Desktop\\jarvis\\myJarvis\\templates\\index.html"
        #     os.startfile(codePath2)
        #     break
        
        elif 'open presentation ' in query:
            speak("Our project is Voice Assistant and I proudly present myself , Jarvis , your voice assistant ")
            codePath3 = "C:\\Users\\Gangwani\\Desktop\\jarvis\\python mini project ppt pdf"
            os.startfile(codePath3)
        
        elif "who i am" in query:
            speak("If you talk then definitely your human.")
 
        elif "why you came to world" in query:
            speak("Thanks to team no . further It's a secret")
            
        elif 'is love' in query:
            speak("It is 7th sense that destroy all other senses")
 
        elif "who are you" in query:
            speak("I am your virtual assistant created by team no3")
 
        elif 'reason for you' in query:
            speak("I was created as a Minor project by team no3")
            
        elif 'change background' in query:
            ctypes.windll.user32.SystemParametersInfoW(20,
                                                       0,
                                                       "Location of wallpaper",
                                                       0)
            speak("Background changed successfully")
            
        # elif 'news' in query:
             
        #     try:
        #         jsonObj = urlopen('''https://newsapi.org / v1 / articles?source = the-times-of-india&sortBy = top&apiKey =\\times of India Api key\\''')
        #         data = json.load(jsonObj)
        #         i = 1
                 
        #         speak('here are some top news from the times of india')
        #         print('''=============== TIMES OF INDIA ============'''+ '\n')
                 
        #         for item in data['articles']:
                     
        #             print(str(i) + '. ' + item['title'] + '\n')
        #             print(item['description'] + '\n')
        #             speak(str(i) + '. ' + item['title'] + '\n')
        #             i += 1
        #     except Exception as e:
                 
        #         print(str(e))
 
         
        elif 'lock window' in query:
                speak("locking the device")
                ctypes.windll.user32.LockWorkStation()
                
        
        # elif 'shut down system' in query:
        #         speak("Hold On a Sec ! Your system is on its way to shut down")
        #         subprocess.call('shutdown / p /f')
                
        # elif "don't listen" in query or "stop listening" in query:
        #     speak("for how much time you want to stop jarvis from listening commands")
        #     a = int(takeCommand())
        #     time.sleep(a)
        #     print(a)
            
        # elif "where is" in query:
        #     query = query.replace("where is", "")
        #     location = query
        #     speak("User asked to Locate")
        #     speak(location)
        #     webbrowser.open("https://www.google.nl//maps//place" + location + "")
            
        elif "camera" in query or "take a photo" in query:
            ec.capture(0, "Jarvis Camera ", "img.jpg")
 
        # elif "restart" in query:
        #     subprocess.call(["shutdown", "/r"])
             
        # elif "hibernate" in query or "sleep" in query:
        #     speak("Hibernating")
        #     subprocess.call("shutdown / h")
 
        # elif "log off" in query or "sign out" in query:
        #     speak("Make sure all the application are closed before sign-out")
        #     time.sleep(5)
        #     subprocess.call(["shutdown", "/l"])
 
        elif "write a note" in query:
            speak("What should i write")
            note = takeCommand()
            file = open('jarvis.txt', 'w')
            speak("Should i include date and time")
            snfm = takeCommand()
            if 'yes' in snfm or 'sure' in snfm:
                strTime = datetime.datetime.now().strftime("% H:% M:% S")
                file.write(strTime)
                file.write(" :- ")
                file.write(note)
            else:
                file.write(note)
         
        elif "show note" in query:
            speak("Showing Notes")
            file = open("jarvis.txt", "r")
            print(file.read())
            speak(file.read(6))
            
        elif "Good Morning" in query:
            speak("A warm" +query)
            speak("How are you Mister")
            speak(assname)
 
        # most asked question from google Assistant
        elif "will you be my gf" in query or "will you be my bf" in query:  
            speak("I'm not sure about, may be you should give me some time")
 
        elif "how are you" in query:
            speak("I'm fine, glad you me that")
 
        elif "i love you" in query:
            speak("It's hard to understand")
 
        elif "what is" in query or "who is" in query:
             
            # Use the same API key
            # that we have generated earlier
            client = wolframalpha.Client("X4PAJQ-8XR29JYA3G")
            res = client.query(query)
             
            try:
                print (next(res.results).text)
                speak (next(res.results).text)
            except StopIteration:
                print ("No results")
 
 
        
        elif 'quit' in query:
            speak("Thanks for giving me your time")
            exit()
            
        
            #X4PAJQ-8XR29JYA3G