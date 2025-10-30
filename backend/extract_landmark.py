import cv2
import os
import pandas as pd
import mediapipe as mp
from tqdm import tqdm
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(static_image_mode=True,
                       max_num_hands=1,
                       min_detection_confidence=0.5)
mp_draw = mp.solutions.drawing_utils
train_folder = r"C:\Users\Vaishu\OneDrive\Desktop\SignAge\asl_alphabet_train\asl_alphabet_train"
no_hand_images = []

def extract_landmarks(img_path):
    img = cv2.imread(img_path)
    if img is None:
        return None
    img = cv2.resize(img, (640, 480))
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    results = hands.process(img_rgb)
    
    if not results.multi_hand_landmarks:
        no_hand_images.append(img_path)
        return None
    
    hand_landmarks = results.multi_hand_landmarks[0]
    landmarks = []
    for lm in hand_landmarks.landmark:
        landmarks.extend([lm.x, lm.y, lm.z])
    
    return landmarks

def create_dataset(folder_path):
    data = []
    labels = []
    images = []
    for root, dirs, files in os.walk(folder_path):
        for f in files:
            if f.lower().endswith(('.png', '.jpg', '.jpeg')):
                images.append(os.path.join(root, f))

    for i, img_path in enumerate(tqdm(images, desc="Extracting landmarks")):
        landmarks = extract_landmarks(img_path)
        if landmarks is None:
            continue
        label = os.path.basename(os.path.dirname(img_path))
        data.append(landmarks)
        labels.append(label)
    
    df = pd.DataFrame(data)
    df['label'] = labels
    return df

if __name__ == "__main__":
    df = create_dataset(train_folder)
    print(f"\nExtracted landmarks for {len(df)} images.")
    df.to_csv("landmarks_dataset.csv", index=False)
    print("Saved dataset to landmarks_dataset.csv")
    if no_hand_images:
        with open("no_hand_detected.txt", "w") as f:
            for img in no_hand_images:
                f.write(img + "\n")
        print(f"{len(no_hand_images)} images had no hand detected. Logged to no_hand_detected.txt")
