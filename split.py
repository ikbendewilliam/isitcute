from PIL import Image
import glob
import random
import time
import math


def current_milli_time(): return int(round(time.time() * 1000))


def sourceToMap(label, maxCount):
    count = 0
    start = current_milli_time()
    lastTime = 0
    for filename in glob.glob('data/source/' + label + '/*'):
        if (count > maxCount):
            break
        if (lastTime < (current_milli_time() - start) / 1000):
            print('after ' + str(math.floor(lastTime)) + 's: ' + str(count) + ' / ' +
                  str(maxCount) + ' (' + str(math.floor(count / maxCount * 100)) + '%)')
            lastTime = (current_milli_time() - start) / 1000 + 10
        count += 1
        if (count % 1000 == 0):
            print('done ' + str(count) + ' for ' + label)
        im = Image.open(filename)
        im = im.resize((224, 224))
        _type = random.randint(0, 8)
        if (_type == 0):
            im.save('data/test/' + label + '/' +
                    filename.replace('\\', '/').split('/')[-1])
        elif (_type == 1):
            im.save('data/validation/' + label + '/' +
                    filename.replace('\\', '/').split('/')[-1])
        else:
            im.save('data/train/' + label + '/' +
                    filename.replace('\\', '/').split('/')[-1])


sourceToMap('cute', 6534)
sourceToMap('notcute', 6534)
