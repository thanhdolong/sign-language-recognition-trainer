# Body Pose Annotator

The **Body Pose Annotator** app is a handy desktop app for seamless Vision analysis of body, hand and face landmarks for applied tasks such as sign language recognition, action classification, and more. The app makes it easy to annotate both single videos and large datasets, and output the data in a standardized CSV file for any further work.

![App screenshot 1](http://data.matsworld.io/body-pose-annotator/screenshot1.png)
![App screenshot 2](http://data.matsworld.io/body-pose-annotator/screenshot2.png)

### Backbone

The backbone of the body, hand, and face pose analysis is built on top of the [Vision](https://developer.apple.com/documentation/vision) framework by Apple. We have found it to be working significantly better and more efficiently than the other publicly available frameworks.

### Data format

The data is saved in a custom data format into a `.csv` file. More information regarding the formatting system can be found [here](data_format.md). The app also supports the following data annotations formats:

- ...

## Installation

### Download the app

The latest (as well as all the previous stable builds) can be downloaded as a `.dmg` here.

#### Requirements

- macOS 11.0+ (Big Sur and above)

### Build from source

You can build Latest directly on your machine. To do that, you have to download the source code by cloning the repository: `git clone https://github.com/thanhdolong/sign-language-recognition-trainer.git`.

Then you can open the BodyPoseAnnotator.xcodeproj and hit **Build and Run**. Make sure that the BodyPoseAnnotator scheme is selected.

#### Requirements

- macOS 11.0+ (Big Sur and above)
- Xcode 12.0+
- Swift 5

## Usage

The app has two main ways for annotation – either from single videos, or from full datasets. Either way, please ensure that all of your videos are in the `.mp4` format.

### Single video

To annotate a single video, simply select the **Annotate video** section in the left navigation bar. Then either drag-and-drop your file, or select it using the **Load Video** button. Then start the analysis using the **Start processing** button. Once the analysis is finished, you will be prompted with an alert view to save the resulting `.csv` file.

### Full dataset

To annotate a full dataset, ensure that you have a dataset folder with structured folders of the individual labels and the videos inside them. There should also be no other files irrelevant to the analysis. Then select the **Annotate dataset** section in the left navigation bar and either drag-and-drop your folder, or select it using the **Load Dataset** button. You can start the analysis using the **Start processing** button. Once the analysis is finished, you will be prompted with an alert view to save the resulting `.csv` file.

## Contribution

Any contribution is highly encouraged and welcome! You can take a look at the [Issues](https://github.com/thanhdolong/sign-language-recognition-trainer/issues) section to see what you can do. If you spot a bug, please file a Bug Report, or if you have some idea of your own, please submit a Feature Request. Use the according templates for both please and provide as much information or context as possible.
