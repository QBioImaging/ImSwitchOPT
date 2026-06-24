[![DOI](https://joss.theoj.org/papers/10.21105/joss.03394/status.svg)](https://doi.org/10.21105/joss.03394)

The ImSwitchOPT fork has been detached on 25/11/2025 from this [snapshot](https://github.com/ImSwitch/ImSwitch/tree/37bf1df6de0ee4746b05bef9684c782e4995b2e8) of the main branch of ImSwitch.

# ImSwitch

## Statement of need

The constant development of novel microscopy methods with an increased number of dedicated
hardware devices poses significant challenges to software development.
ImSwitch is designed to be compatible with many different microscope modalities and customizable to the
specific design of individual custom-built microscopes, all while using the same software. We
would like to involve the community in further developing ImSwitch in this direction, believing
that it is possible to integrate current state-of-the-art solutions into one unified software.

## Installation from source

`ImSwitchOPT` can be installed via source by cloning the repository. It is *strongly* reccomended to install it in a virtual environment.

```bash
# clone the repository
git clone https://github.com/jacopoabramo/ImSwitchOPT

# ensure to be in the cloned repository folder
cd ImSwitchOPT
```

For a standard Python virtual environment:

```bash
# create a new environment
python -m venv venv

# activate the environment
# Windows
venv\Scripts\activate

# Linux/macOS
source venv/bin/activate

# install ImSwitchOPT in the virtual environment

pip install .
```

For conda environments:

```bash
conda create -n imswitch-venv python=3.8

conda activate imswitch-venv

# in ImSwitchOPT folder
pip install .
```

In both cases, you can run ImSwitchOPT via the CLI command:

```bash
imswitch
```

## Documentation

Further documentation is available at [imswitch.readthedocs.io](https://imswitch.readthedocs.io).

## Testing

ImSwitch has automated testing through GitHub Actions, including UI and unit tests. It is also possible to manually inspect and test the software without any device since it contains mockers that are automatically initialized if the instrumentation specified in the config file is not detected.

## Contributing

Read the [contributing section](https://imswitch.readthedocs.io/en/latest/contributing.html) in the documentation if you want to help us improve and further develop ImSwitch!
