from flask import Flask, request, jsonify
import tensorflow as tf
import cv2
import numpy as np
import os

app = Flask(__name__)

# Path to your trained VGG model
model_path = 'C:\\Users\\user\\OneDrive\\Desktop\\A_IP_Project\\skin_disease_model_flask_app\\flask\\ResNet50modelv4.h5'
model = tf.keras.models.load_model(model_path)

# Define your classes
classLabels = {
    0: 'Acne',
    1: 'Actinic Keratosis',
    2: 'Eczema',
    3: 'Melanoma',
    4: 'Psoriasis', 
    5: 'Tinea Ringworm',
    6: 'Urticaria', 
    7: 'Nail Fungus'
}

@app.route('/image/upload', methods=['POST'])
def predict():
    print("Received request for /image/upload")
    
    file = request.files.get('photo')
    if not file:
        print("No file part in the request")
        return jsonify({'message': 'No file provided'}), 400
    
    nparr = np.frombuffer(file.read(), np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if img is None:
        print("Failed to decode image")
        return jsonify({'message': 'Failed to decode image'}), 400

    if check_skin(img):
        print("Skin detected in the image")
        resized_img = cv2.resize(img, (32, 32)) / 255.0  # Normalize the image
        input_data = np.expand_dims(resized_img, 0)
        predictions = model.predict(input_data)
        predicted_class_index = np.argmax(predictions)
        predicted_class = classLabels[predicted_class_index]
        confidence = float(predictions[0][predicted_class_index])
        print(f"Prediction: {predicted_class}, Confidence: {confidence}")

        # Introducing a confidence threshold for healthy skin detection
        confidence_threshold = 0.46 
        if confidence < confidence_threshold:
            return jsonify({'message': 'Healthy Skin Detected'}), 200
        else:
            return jsonify({'prediction': predicted_class, 'confidence': confidence}), 200
    else:
        print("No skin detected in the image")
        return jsonify({'message': 'No skin detected in the image. Please try a different image.'}), 400

def check_skin(img):
    img_YCrCb = cv2.cvtColor(img, cv2.COLOR_BGR2YCrCb)
    YCrCb_mask = cv2.inRange(img_YCrCb, (0, 135, 85), (255, 180, 135))
    skin_pixels = cv2.countNonZero(YCrCb_mask)
    total_pixels = img.shape[0] * img.shape[1]
    return (skin_pixels / total_pixels) * 100 > 5

if __name__ == "__main__":
    app.run(host='172.20.10.6', port=5000, debug=True)
