from PIL import Image
import glob
import random
import time
import math

def sourceToMap():
    count = 0
    for filename in glob.glob('data/source/predict/*'):
        count += 1
        if (count % 10 == 0):
            print('done ' + str(count))
        im = Image.open(filename)
        im = im.resize((224, 224))
        im.save('data/predict/' + filename.replace('\\', '/').split('/')[-1])

sourceToMap()
