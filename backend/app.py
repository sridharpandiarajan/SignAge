from flask import Flask, request, jsonify
import pickle
import numpy as np
import cv2
import mediapipe as mp
from tensorflow.keras.models import load_model
from extract_landmark import extract_landmarks


app = Flask(__name__)

# Load pre-trained model and encoder
import os
model_path = os.path.join(os.path.dirname(__file__), '..', 'sign_language_model.h5')
model = load_model(model_path)

with open('label_encoder.pkl', 'rb') as f:
    label_encoder = pickle.load(f)

mp_hands = mp.solutions.hands
hands = mp_hands.Hands(static_image_mode=True, max_num_hands=1, min_detection_confidence=0.5)

@app.route('/')
def home():
    return "SignAge Flask Backend is Running!"

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Receive the image file
        file = request.files['image']
        file_bytes = np.frombuffer(file.read(), np.uint8)
        img = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)

        # Process landmarks using your existing extract_landmark function
        landmarks = extract_landmarks(img)
        if landmarks is None:
            return jsonify({'error': 'No hand detected'})

        # Predict using model
        prediction = model.predict(np.array([landmarks]))
        predicted_index = np.argmax(prediction)
        predicted_label = label_encoder.inverse_transform([predicted_index])[0]

        return jsonify({'prediction': predicted_label})

    except Exception as e:
        return jsonify({'error': str(e)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
