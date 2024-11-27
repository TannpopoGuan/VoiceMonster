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


class SpeechEvaluation:
    def __init__(self):
        # Initialize recognizer
        self.recognizer = sr.Recognizer()
        pygame.mixer.init()

        # Audio recording settings
        self.CHUNK = 4096
        self.FORMAT = pyaudio.paInt16
        self.CHANNELS = 1
        self.RATE = 44100
        self.RECORD_SECONDS = 3
        self.reference_path = "reference_sounds/"

        # Game settings
        self.scores = {}

        # Hiragana dictionary
        self.hiragana = {
            # あ行
            'あ': {'romaji': 'a', 'sound_file': 'a.wav'},
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

    def evaluate_pronunciation(self, user_audio, target_kana):
        """評估發音準確度"""
        try:
            # 載入標準發音
            ref_audio_path = os.path.join(self.reference_path, self.hiragana[target_kana]["romaji"])

            # 提取特徵
            ref_features = self.extract_features(ref_audio_path)
            user_features = self.extract_features(user_audio)

            # 計算各個特徵的相似度
            scores = {
                'mfcc': self.calculate_feature_similarity(ref_features, user_features, 'mfcc'),
                'pitch': self.calculate_feature_similarity(ref_features, user_features, 'f0'),
                'volume': self.calculate_feature_similarity(ref_features, user_features, 'rms'),
                'timbre': self.calculate_feature_similarity(ref_features, user_features, 'spectral_centroid'),
                'spectrum': self.calculate_feature_similarity(ref_features, user_features, 'mel_spec')
            }

            # 加權計算總分
            weights = {
                'mfcc': 0.3,  # 音色特徵權重
                'pitch': 0.3,  # 音高權重
                'volume': 0.1,  # 音量權重
                'timbre': 0.2,  # 音色明暗權重
                'spectrum': 0.1  # 頻譜權重
            }

            total_score = sum(score * weights[feature]
                              for feature, score in scores.items())

            # 生成詳細回饋
            feedback = {
                'total_score': total_score,
                'detailed_scores': scores,
                'suggestions': self.generate_feedback(scores)
            }

            # 視覺化比較
            self.visualize_comparison(ref_features, user_features, target_kana)

            return total_score, feedback

        except Exception as e:
            print(f"評估過程發生錯誤: {str(e)}")
            return 0, {'error': '無法評估發音'}

    def extract_features(self, audio_path):
        """提取音訊特徵"""
        # 載入音訊
        y, sr = librosa.load(audio_path, sr=self.RATE)

        # 正規化音量
        y = librosa.util.normalize(y)

        # 提取特徵
        features = {}

        # 1. MFCC特徵 (音色特徵)
        mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=self.n_mfcc)
        features['mfcc'] = mfcc

        # 2. 基頻特徵 (音高曲線)
        f0, voiced_flag, _ = librosa.pyin(y,
                                          fmin=librosa.note_to_hz('C2'),
                                          fmax=librosa.note_to_hz('C7'))
        features['f0'] = f0[voiced_flag]

        # 3. 音量包絡線
        features['rms'] = librosa.feature.rms(y=y)[0]

        # 4. 頻譜質心 (音色明暗)
        features['spectral_centroid'] = librosa.feature.spectral_centroid(y=y, sr=sr)[0]

        # 5. Mel頻譜圖
        mel_spec = librosa.feature.melspectrogram(y=y, sr=sr, n_mels=self.n_mels)
        features['mel_spec'] = librosa.power_to_db(mel_spec)

        return features

    def calculate_feature_similarity(self, ref_features, user_features, feature_name):
        """計算特定特徵的相似度"""
        ref_data = ref_features[feature_name]
        user_data = user_features[feature_name]

        # 確保兩個特徵向量長度相同
        min_length = min(len(ref_data), len(user_data))
        ref_data = ref_data[:min_length]
        user_data = user_data[:min_length]

        if len(ref_data) == 0 or len(user_data) == 0:
            return 0

        # 使用DTW計算相似度
        distance = dtw.distance(ref_data, user_data)

        # 將距離轉換為相似度分數 (0-100)
        max_distance = np.sqrt(np.sum(np.square(ref_data - user_data)))
        similarity = max(0, 100 * (1 - distance / max_distance))

        return similarity

    def generate_feedback(self, scores):
        """根據各項分數生成具體建議"""
        suggestions = []

        if scores['pitch'] < 70:
            suggestions.append("音高需要調整，請注意語調的起伏")
        if scores['mfcc'] < 70:
            suggestions.append("發音音色與標準音有差異，請多聽標準音加強練習")
        if scores['volume'] < 70:
            suggestions.append("音量控制需要改善，請注意發音的強弱")
        if scores['timbre'] < 70:
            suggestions.append("音色明暗度需要調整，可能發音方式不夠標準")

        return suggestions

    def visualize_comparison(self, ref_features, user_features, kana):
        """視覺化比較標準音與使用者發音"""
        plt.figure(figsize=(15, 10))

        # 繪製MFCC比較
        plt.subplot(311)
        plt.title(f"{kana} - MFCC Comparison")
        plt.plot(ref_features['mfcc'].T, label='Reference')
        plt.plot(user_features['mfcc'].T, label='User')
        plt.legend()

        # 繪製音高曲線比較
        plt.subplot(312)
        plt.title("Pitch Contour")
        plt.plot(ref_features['f0'], label='Reference')
        plt.plot(user_features['f0'], label='User')
        plt.legend()

        # 繪製頻譜圖比較
        plt.subplot(313)
        plt.title("Mel Spectrogram")
        plt.imshow(user_features['mel_spec'], aspect='auto', origin='lower')

        plt.tight_layout()
        plt.show()

