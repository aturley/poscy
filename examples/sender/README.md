# Sender

This application sends an OSC message to a local receiving program on port 8989. This directory contains sample receivers for [PureData](http://puredata.info/), [SuperCollider](https://supercollider.github.io/), and [ChucK](http://chuck.cs.princeton.edu/).

## Build

To build this application you must have `stable`, the Pony dependency manager, installed. Then you can build the application with:

```bash
stable env ponyc
```

This will create an executable called `sender`.

## Run

You should first start the appropriate receiver application. Then you can run `sender` without any command line arguments and you should see appropriate output in the program.
