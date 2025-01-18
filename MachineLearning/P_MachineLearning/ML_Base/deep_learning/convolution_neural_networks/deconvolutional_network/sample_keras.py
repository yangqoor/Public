import sys, os
import numpy as np
import tensorflow as tf
import tensorflow.keras.backend as K
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

from tensorflow.keras.applications import VGG16
from tensorflow.keras.applications.vgg16 import decode_predictions, preprocess_input
from tensorflow.keras.preprocessing import image
tf.compat.v1.disable_eager_execution()

class Network:
    def __init__(self, model, layer_name, input_data, layer_idx = None, masking=None):
        self.model = model
        self.layer_name = layer_name
        self.layer = model.get_layer(layer_name)
        self.input_data = input_data
        
        if (layer_idx is None):
            for i, layer in enumerate(self.model.layers):
                if (layer.name == self.layer_name):
                    self.layer_idx = i
                    break
                    
        if (masking is None):
            shape = [1] + list(self.layer.output_shape[1:])
            masking = np.ones(shape, 'float32')
        self.masking = masking

    def compute(self):
        gradients = self.masking
        
        for layer_idx in range(self.layer_idx-1, -1, -1):
            layer_prev = self.model.layers[layer_idx].output
            layer_cur = self.model.layers[layer_idx+1].output

            forward_values_prev = np.ones([self.input_data.shape[0]] + list(self.model.layers[layer_idx].output_shape[1:])) 
            
            gradients_cur = gradients
            gate_b = (gradients_cur > 0.) * gradients_cur
            gradients = self.guided_backprop_adjacent(layer_cur, layer_prev, forward_values_prev, gate_b)

            if (gradients.min() != gradients.max()):
                gradients = self.normalize_gradient(gradients)
            
        gradients_input = gradients
        gradients_input = self.filter_gradient(gradients_input)
        return gradients_input 
        
    def filter_gradient(self, x):
        x_abs = np.abs(x)
        x_max = np.amax(x_abs, axis=-1)
        return x_max

    def guided_backprop_adjacent(self, layer_cur, layer_prev, values_prev, gate_b):
        loss = K.mean(layer_cur * gate_b)
        gradients = K.gradients(loss, layer_prev)[0]
        gate_f = K.cast(values_prev > 0., 'float32')
        guided_gradients = gradients * gate_f
        
        func = K.function([self.model.input], [guided_gradients])
        output_data = func([self.input_data])[0]
        return output_data
        
    def feed_forward(self):
        forward_layers = [layer.output for layer in self.model.layers[1:self.layer_idx+1]]
        func = K.function([self.model.input], forward_layers)
        self.forward_values = func([self.input_data])
    
        return self.forward_values 
    
    def normalize_gradient(self, img):
        gap = img.max() - img.min()
        if (abs(gap) > 1.):
            return img
        amplitude = 1./gap
        img *= amplitude
        
        return img

VGG16_net = VGG16(weights='imagenet')

# image downloaded from: https://www.pexels.com/photo/animal-big-elephant-endangered-133394/
# preprocess the input before feeding into the network
img = image.load_img('./images/elephant.jpg', target_size=(224, 224))
x = image.img_to_array(img)
x = np.expand_dims(x, axis=0)
x = preprocess_input(x)

plt.imshow(img); plt.axis('off')
plt.show()
print(VGG16_net.summary())

# make prediction
preds = VGG16_net.predict(x)
print('Predicted:')
for pred in decode_predictions(preds, top=10)[0]:
    print (pred)

top_n = 5
predicted_labels = ['African_elephant', 'tusker', 'Indian_elephant', 'water_buffalo', 'curly-coated_retriever']
predicted_units = preds[0].argsort()[::-1][:top_n]

masking = np.zeros(preds.shape)
masking[0, np.argmax(preds)] = 1.

deconvnet = Network(model=VGG16_net, layer_name='predictions', input_data=x, masking=masking)
heatmap  = deconvnet.compute()
plt.imshow(heatmap[0], cmap='gray')
plt.axis('off')
plt.show()

fig = plt.figure(figsize=(15, 3))
gs = gridspec.GridSpec(1, 5)
    
for gs_idx, output_idx in enumerate(predicted_units):
    masking = np.zeros(preds.shape)
    masking[0, output_idx] = 1.

    deconvnet = Network(model=VGG16_net, layer_name='predictions', input_data=x, masking=masking)
    heatmap = deconvnet.compute()

    ax = fig.add_subplot(gs[0, gs_idx])
    ax.imshow(heatmap[0], cmap='gray')
    ax.set_title(predicted_labels[gs_idx])
    ax.axis('off')


plt.show()

