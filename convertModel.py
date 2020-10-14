import tensorflow as tf

model = tf.keras.models.load_model('iscute.h5')
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()
open("iscute.tflite", "wb").write(tflite_model)
