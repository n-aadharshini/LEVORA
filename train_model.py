import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
import tensorflow as tf
from tensorflow import keras

SIGNS = [
    'HELLO',
    'HELP',
    'YES',
    'NO',
    'STOP',
    'THANK YOU',
    'SORRY',
    'PLEASE',
    'background'
]

# Load data
df = pd.read_csv('hand_data.csv', header=None)
X = df.iloc[:, 1:].values   # 63 landmark values
y = df.iloc[:, 0].values     # sign label index

print(f"✅ Loaded {len(X)} samples!")
print(f"✅ Signs: {SIGNS}")

# Split train/test
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42)

# Build model
model = keras.Sequential([
    keras.layers.Input(shape=(63,)),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.Dropout(0.3),
    keras.layers.Dense(64, activation='relu'),
    keras.layers.Dropout(0.3),
    keras.layers.Dense(len(SIGNS), activation='softmax')
])

model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

model.summary()

# Train
history = model.fit(
    X_train, y_train,
    epochs=50,
    batch_size=32,
    validation_data=(X_test, y_test),
    verbose=1
)

# Test accuracy
loss, accuracy = model.evaluate(X_test, y_test)
print(f'\n✅ Accuracy: {accuracy * 100:.1f}%')

# Export TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open('model.tflite', 'wb') as f:
    f.write(tflite_model)

# Save labels
with open('labels.txt', 'w') as f:
    f.write('\n'.join(SIGNS))

print('✅ model.tflite saved!')
print('✅ labels.txt saved!')