import os
import numpy as np
import random

from keras import layers
from keras.models import Sequential
from typing import List, Any
from keras.preprocessing.text import Tokenizer
from keras.utils import to_categorical


def build_model(label):
    model = Sequential()
    model.add(layers.LSTM(256,
                          return_sequences=True,
                          input_shape=(70, 84)))

    model.add(layers.LSTM(128,
                          return_sequences=True))

    model.add(layers.LSTM(64,
                          return_sequences=True))

    model.add(layers.LSTM(32))

    model.add(layers.Dense(label, activation='softmax'))
    model.compile(loss='categorical_crossentropy',
                  optimizer='adam',
                  metrics=['accuracy'])
    return model


def load_data(dirname: str):
    if dirname[-1] != '/':
        dirname = dirname + '/'

    listfile = os.listdir(dirname)
    trainCoordinators = []
    trainDataname = []
    testCoordinators = []
    testDataname = []
    for file in listfile:
        if "_" in file:
            continue
        wordname = file
        textlist = os.listdir(dirname + wordname)
        a = len(textlist)
        b = a // 3
        k = 0
        
        for text in textlist:
            if "DS_" in text:
                continue

            textname = dirname + wordname + "/" + text
            numbers = []
            with open(textname, mode='r') as t:
                numbers = [float(num) for num in t.read().split()]
                for i in range(len(numbers), 25200):
                    numbers.extend([0.000])
            row = 0
            landmark_frame = []
            for i in range(0, 70):
                landmark_frame.extend(numbers[row:row + 84])
                row += 84
            landmark_frame = np.array(landmark_frame)
            landmark_frame = list(landmark_frame.reshape(-1, 84))
            if (k % 3 == 2):
                testCoordinators.append(np.array(landmark_frame))
                testDataname.append(wordname)
            else:
                trainCoordinators.append(np.array(landmark_frame))
                trainDataname.append(wordname)
            k += 1

    trainCoordinators = np.array(trainCoordinators)
    trainDataname = np.array(trainDataname)
    testCoordinators = np.array(testCoordinators)
    testDataname = np.array(testDataname)

    tmp: List[List[Any]] = [[x, y] for x, y in zip(trainCoordinators, trainDataname)]
    random.shuffle(tmp)

    tmp1 = [[xt, yt] for xt, yt in zip(testCoordinators, testDataname)]
    random.shuffle(tmp1)

    trainCoordinators = [n[0] for n in tmp]
    trainDataname = [n[1] for n in tmp]
    testCoordinators = [n[0] for n in tmp1]
    testDataname = [n[1] for n in tmp1]

    text = ""
    for i in sorted(set(trainDataname)):
        text = text + i + " "
    make_label(text)

    s = Tokenizer()
    s.fit_on_texts([text])
    encoded = s.texts_to_sequences([trainDataname])[0]
    encoded1 = s.texts_to_sequences([testDataname])[0]
    one_hot = to_categorical(encoded)
    one_hot2 = to_categorical(encoded1)

    (x_train, y_train) = trainCoordinators, one_hot
    (x_test, y_test) = testCoordinators, one_hot2
    x_train = np.array(x_train)
    y_train = np.array(y_train)
    x_test = np.array(x_test)
    y_test = np.array(y_test)

    return x_train, y_train, x_test, y_test


def load_label():
    listfile = []
    with open("data/label.txt", mode='r') as l:
        listfile = [i for i in l.read().split()]
    label = {}
    count = 1
    for l in listfile:
        if "_" in l:
            continue
        label[l] = count
        count += 1
    return label


def make_label(text: str):
    with open("label.txt", "w") as f:
        f.write(text)
    f.close()


def make_file(filename: str, text: str):
    with open(filename + ".txt", "w") as f:
        f.write(text)
    f.close()
