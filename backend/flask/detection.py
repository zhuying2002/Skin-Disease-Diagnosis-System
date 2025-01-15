import tensorflow as tf
import cv2
import numpy as np
from flask import jsonify

# Path to your trained VGG model
model_path = 'C:\\Users\\user\\OneDrive\\Documents\\FYP\\ZY\\diagnosis_app\\skin_disease_model_flask_app\\flask\\ResNet50modelv4.h5'
# 'C:\\Users\\user\\OneDrive\\Desktop\\A_IP_Project\\skin_disease_model_flask_app\\flask\\ResNet50modelv4'
model = tf.keras.models.load_model(model_path)

classLabels = {
    0: 'Acne/Rosacea',
    1: 'Actinic Keratosis/Basal Cell Carcinoma/Malignant Lesions',
    2: 'Atopic Dermatitis/Eczema',
    3: 'Bullous Disease',
    4: 'Bacterial Infections (Cellulitis/Impetigo)',
    5: 'Exanthems/Drug Eruptions',
    6: 'Hair Loss/Alopecia',
    7: 'Healthy Skin',
    8: 'Viral Infections (Herpes/HPV/STDs)',
    9: 'Pigmentation Disorders',
    10: 'Lupus/Connective Tissue Diseases',
    11: 'Melanoma/Nevi/Moles',
    12: 'Nail Fungus/Nail Disease',
    13: 'Contact Dermatitis (Poison Ivy)',
    14: 'Psoriasis/Lichen Planus',
    15: 'Infestations/Bites (Scabies/Lyme)',
    16: 'Benign Tumors (Seborrheic Keratoses)',
    17: 'Systemic Disease',
    18: 'Fungal Infections (Tinea/Ringworm/Candidiasis)',
    19: 'Urticaria/Hives',
    20: 'Vascular Tumors',
    21: 'Vasculitis',
    22: 'Warts/Molluscum (Viral)'
}

def predict(file):
    nparr = np.frombuffer(file.read(), np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if img is None:
        return jsonify({'message': 'Failed to decode image'}), 400

    if check_skin(img):
        resized_img = cv2.resize(img, (32, 32)) / 255.0  # Normalize the image
        input_data = np.expand_dims(resized_img, 0)
        predictions = model.predict(input_data)
        predicted_class_index = np.argmax(predictions)
        predicted_class = classLabels[predicted_class_index]
        confidence = float(predictions[0][predicted_class_index])

        confidence_threshold = 0.40  # This threshold can be adjusted
        if confidence < confidence_threshold:
            return jsonify({'message': 'Healthy Skin Detected'}), 200
        else:
            return jsonify({'prediction': predicted_class, 'confidence': confidence}), 200
    else:
        return jsonify({'message': 'No skin detected in the image.'}), 400

def check_skin(img):
    img_YCrCb = cv2.cvtColor(img, cv2.COLOR_BGR2YCrCb)
    YCrCb_mask = cv2.inRange(img_YCrCb, (0, 135, 85), (255, 180, 135))
    skin_pixels = cv2.countNonZero(YCrCb_mask)
    total_pixels = img.shape[0] * img.shape[1]
    return (skin_pixels / total_pixels) * 100 > 5
