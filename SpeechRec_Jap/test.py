import speech_recognition as sr
while True:
    r = sr.Recognizer()
    with sr.Microphone() as source:
        print("請說話...")
        audio = r.listen(source)

    try:
        text = r.recognize_google(audio, language='ja-JP')
        print("辨識結果:", text)
    except sr.UnknownValueError:
        print("無法辨識語音")
    except sr.RequestError:
        print("無法連接到 Google API")