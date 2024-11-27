import speech_recognition as sr
import pyaudio
import wave
import time
import os
from datetime import datetime
import librosa
import pygame
import random
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import soundfile as sf
from dtaidistance import dtw
from dtaidistance import dtw_visualisation as dtwvis


class JapanesePronunciationGame:
    def __init__(self):
        # Initialize recognizer
        self.recognizer = sr.Recognizer()
        pygame.mixer.init()

        # Audio recording settings
        self.CHUNK = 1024
        self.FORMAT = pyaudio.paInt16
        self.CHANNELS = 1
        self.RATE = 44100
        self.RECORD_SECONDS = 3
        self.n_mfcc = 13  # MFCC特徵數
        self.n_mels = 128  # Mel頻譜特徵數
        self.frame_length = 2048  # 新增: STFT 幀長度
        self.hop_length = 512  # 新增: STFT 步長
        self.reference_path = "reference_sounds/"

        # Game settings
        self.scores = {}

        # Hiragana dictionary
        self.hiragana = {
            # あ行
            'あ': {'romaji': 'a', 'sound_file': 'a.mp3'},
            'い': {'romaji': 'i', 'sound_file': 'i.wav'},
            'う': {'romaji': 'u', 'sound_file': 'u.wav'},
            'え': {'romaji': 'e', 'sound_file': 'e.wav'},
            'お': {'romaji': 'o', 'sound_file': 'o.wav'},

            # か行
            'か': {'romaji': 'ka', 'sound_file': 'ka.wav'},
            'き': {'romaji': 'ki', 'sound_file': 'ki.wav'},
            'く': {'romaji': 'ku', 'sound_file': 'ku.wav'},
            'け': {'romaji': 'ke', 'sound_file': 'ke.wav'},
            'こ': {'romaji': 'ko', 'sound_file': 'ko.wav'},

            # さ行
            'さ': {'romaji': 'sa', 'sound_file': 'sa.wav'},
            'し': {'romaji': 'shi', 'sound_file': 'shi.wav'},
            'す': {'romaji': 'su', 'sound_file': 'su.wav'},
            'せ': {'romaji': 'se', 'sound_file': 'se.wav'},
            'そ': {'romaji': 'so', 'sound_file': 'so.wav'},

            # た行
            'た': {'romaji': 'ta', 'sound_file': 'ta.wav'},
            'ち': {'romaji': 'chi', 'sound_file': 'chi.wav'},
            'つ': {'romaji': 'tsu', 'sound_file': 'tsu.wav'},
            'て': {'romaji': 'te', 'sound_file': 'te.wav'},
            'と': {'romaji': 'to', 'sound_file': 'to.wav'},

            # な行
            'な': {'romaji': 'na', 'sound_file': 'na.wav'},
            'に': {'romaji': 'ni', 'sound_file': 'ni.wav'},
            'ぬ': {'romaji': 'nu', 'sound_file': 'nu.wav'},
            'ね': {'romaji': 'ne', 'sound_file': 'ne.wav'},
            'の': {'romaji': 'no', 'sound_file': 'no.wav'},

            # は行
            'は': {'romaji': 'ha', 'sound_file': 'ha.wav'},
            'ひ': {'romaji': 'hi', 'sound_file': 'hi.wav'},
            'ふ': {'romaji': 'fu', 'sound_file': 'fu.wav'},
            'へ': {'romaji': 'he', 'sound_file': 'he.wav'},
            'ほ': {'romaji': 'ho', 'sound_file': 'ho.wav'},

            # ま行
            'ま': {'romaji': 'ma', 'sound_file': 'ma.wav'},
            'み': {'romaji': 'mi', 'sound_file': 'mi.wav'},
            'む': {'romaji': 'mu', 'sound_file': 'mu.wav'},
            'め': {'romaji': 'me', 'sound_file': 'me.wav'},
            'も': {'romaji': 'mo', 'sound_file': 'mo.wav'},

            # や行
            'や': {'romaji': 'ya', 'sound_file': 'ya.wav'},
            'ゆ': {'romaji': 'yu', 'sound_file': 'yu.wav'},
            'よ': {'romaji': 'yo', 'sound_file': 'yo.wav'},

            # ら行
            'ら': {'romaji': 'ra', 'sound_file': 'ra.wav'},
            'り': {'romaji': 'ri', 'sound_file': 'ri.wav'},
            'る': {'romaji': 'ru', 'sound_file': 'ru.wav'},
            'れ': {'romaji': 're', 'sound_file': 're.wav'},
            'ろ': {'romaji': 'ro', 'sound_file': 'ro.wav'},

            # わ行
            'わ': {'romaji': 'wa', 'sound_file': 'wa.wav'},
            'を': {'romaji': 'wo', 'sound_file': 'wo.wav'},
            'ん': {'romaji': 'n', 'sound_file': 'n.wav'},
        }

    def play_reference_sound(self, target_kana):
        """播放標準發音參考音檔"""
        try:
            ref_audio_path = self.get_ref_sound_file(target_kana)
            pygame.mixer.music.load(ref_audio_path)
            pygame.mixer.music.play()
            while pygame.mixer.music.get_busy():
                pygame.time.Clock().tick(10)
        except Exception as e:
            print(f"無法播放音檔: {str(e)}")

    def record_audio(self, kana):
        """錄製使用者發音"""
        print(f"\n請發音: {kana} ({self.hiragana[kana]['romaji']})")

        # 開始錄音
        p = pyaudio.PyAudio()
        stream = p.open(format=self.FORMAT, # audio format ex: 16 bits
                        channels=self.CHANNELS, # single/double channels
                        rate=self.RATE, # sample rate
                        input=True, # this is input stream not output stream
                        frames_per_buffer=self.CHUNK) # how many sample in buffer of each frame

        print("開始錄音...")
        frames = []

        for i in range(0, int(self.RATE / self.CHUNK * self.RECORD_SECONDS)):
            data = stream.read(self.CHUNK)
            frames.append(data)

        print("錄音結束!")

        stream.stop_stream()
        stream.close()
        p.terminate()

        # 儲存錄音檔
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"recording_{timestamp}.wav"

        wf = wave.open(filename, 'wb')
        wf.setnchannels(self.CHANNELS)
        wf.setsampwidth(p.get_sample_size(self.FORMAT))
        wf.setframerate(self.RATE)
        wf.writeframes(b''.join(frames))
        wf.close()

        return filename

    def evaluate_pronunciation(self, user_audio_path, target_kana):
        ref_romaji = self.hiragana[target_kana]['romaji']

        # Initialize recognizer
        r = sr.Recognizer()

        # Load audio file
        with sr.AudioFile(user_audio_path) as source:
            audio = r.record(source)

        # Use Google Speech Recognition to transcribe
        try:
            recognized_text = r.recognize_google(audio, language='ja-JP', show_all=True)

            print(recognized_text)

            return {
                'total_score': recognized_text['alternative'][0]['confidence'],
                'feedback': recognized_text['alternative'][0]['transcript']
            }
        except:
            return {
                'total_score': 0,
                'feedback': '0'
            }

    def practice_mode(self):
        """練習模式"""
        print("\n=== 日文五十音發音練習 ===")
        print("每次會隨機選擇一個假名，請跟著範例發音")
        print("q 鍵退出練習模式")

        while True:
            # 隨機選擇一個假名
            kana = random.choice(list(self.hiragana.keys()))

            # 錄音並評估
            recording = self.record_audio(kana)
            report = self.evaluate_pronunciation(recording, kana)
            score, feedback = report['total_score'], report['feedback']
            # 顯示結果
            print("\n評估結果:")
            if 'error' in feedback:
                print(feedback['error'])
            else:

                print(feedback)

            # 清理錄音檔
            try:
                os.remove(recording)
            except:
                pass

            # 詢問是否繼續
            choice = input("\n按Enter繼續練習，或輸入q退出: ")
            if choice.lower() == 'q':
                break

    def test_mode(self):
        """測試模式"""
        print("\n=== 日文五十音發音測試 ===")
        print("將依序測試所有五十音，計算總分")

        total_score = 0
        count = 0

        while True:
        #for kana in self.hiragana.keys():
            count += 1
            kana = 'あ'
            print(f"\n進度: {count}/{len(self.hiragana)}")

            # 錄音並評估
            recording = self.record_audio(kana)
            report = self.evaluate_pronunciation(recording, kana)
            score, feedback = report['total_score'], report['feedback']
            total_score += score
            print(score)
            # 顯示結果
            print("\n評估結果:")
            if 'error' in feedback:
                print(feedback['error'])
            else:
                print(feedback)

            # 清理錄音檔
            try:
                os.remove(recording)
            except:
                pass

            time.sleep(1)

        # 顯示總結
        average_score = total_score / len(self.hiragana)
        print(f"\n測試完成!")
        print(f"平均準確度: {average_score:.1f}")

    def get_ref_sound_file(self, target_kana):
        return os.path.join(self.reference_path, self.hiragana[target_kana]["sound_file"])

    def start(self):
        """主程式"""
        print("歡迎使用日文五十音發音練習程式!")
        print("1. 練習模式")
        print("2. 測試模式")

        while True:
            choice = '2'#input("請選擇模式 (1/2): ")
            if choice == '1':
                self.practice_mode()
                break
            elif choice == '2':
                self.test_mode()
                break
            else:
                print("請輸入有效的選項")


if __name__ == "__main__":
    game = JapanesePronunciationGame()
    game.start()