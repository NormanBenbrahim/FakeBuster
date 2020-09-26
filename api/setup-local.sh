#!/bin/bash

# if not inside a virtual environment, end script
curr_dir=`pwd`
FULL_PATH="$curr_dir/venv"

# if no env_python folder, make sure user types the commands
if [ ! -d "${FULL_PATH}" ]; then
    echo "No virtual env executable found: ${FULL_PATH}"
    echo "Please run the following commands first:"
    echo ""
    echo "python3 -m venv venv"
    echo "source venv/bin/activate"
    echo ""
    exit
fi

# housekeeping within the virtualenv
if [ ! -z "${VIRTUAL_ENV}" ]; then
    pip install --upgrade pip
    pip install -r requirements.txt
    pip install --upgrade gcloud
    pip install --upgrade google-cloud-storage
else
    echo "Please type 'source venv/bin/activate' first"
    echo ""
    exit
fi

# make sure the google cloud credentials folder exist
if [ ! -d "${GOOGLE_APPLICATION_CREDENTIALS}" ]; then
    echo ""
    echo "ERROR: Your Google API credentials folder does not exist"
    echo "All google products will not work"
    echo ""
    echo "Please create a the following folder and place your gcloud credentials there: ${HOME}/.credentials/google-cloud/"
    exit
fi

# setup google cloud project & cloud bucket directories
# these will now be environment variables in your shell instance
echo "Setting up environment variables"
echo ""
export CLOUD_PROJECT="fake-news-detector"
export BUCKET="gs://${CLOUD_PROJECT}-tf2-models"
export MODEL='fake_buster'
export MODEL_DIR="${BUCKET}/${MODEL}"
export PROJECT_CREDS="${GOOGLE_APPLICATION_CREDENTIALS}/${CLOUD_PROJECT}.json"

if [ ! -f ${PROJECT_CREDS} ]; then
    echo "WARNING: Your google API credentials file does not exist for project '${CLOUD_PROJECT}'"
    echo "All google products will not work"
    echo ""
    echo "Please create a the folder '${HOME}/.credentials/google-cloud/' and place your project credentials there" 
    exit
fi

# download nltk stopwords
echo "Downloading stopwords for NLTK"
echo ""
python download_stopwords.py

# configure gcloud to work with your project
echo "Configuring google cloud project"
echo ""
gcloud config set project ${CLOUD_PROJECT}

# create a cloud storage bucket
echo "Creating GCP buckket"
gsutil mb ${BUCKET}
echo ""
echo "Your GCP bucket url is: ${BUCKET}"
echo ""
echo "Setup complete!"