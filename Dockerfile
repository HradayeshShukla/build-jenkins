FROM openshift4/ose-jenkins-agent-maven

ARG DEFAULT_USER_ID=1001

USER root
# Setup yum repositories
#RUN yum repos --enable=rhel-7-server-extras-rpms \
# && subscription-manager repos --enable=rhel-7-server-optional-rpms \
# && subscription-manager repos --enable=rhel-7-server-rpms

# Install Chrome
RUN cat /etc/redhat-release && yum repolist && yum -y install redhat-lsb libXScrnSaver \
 && wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm \
 && yum -y localinstall google-chrome-stable_current_x86_64.rpm

# Install Chrome Driver
ENV CHROME_DRIVER_PATH /usr/local/bin/chromedriver
RUN CHROME_DRIVER_VERSION=`curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE` \
 && wget --quiet --timestamping https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip --directory-prefix ~/ \
 && unzip ~/chromedriver_linux64.zip -d ~/ \
 && rm ~/chromedriver_linux64.zip \
 && mv --force ~/chromedriver $CHROME_DRIVER_PATH \
 && chown ${DEFAULT_USER_ID}:root $CHROME_DRIVER_PATH \
 && chmod 755 $CHROME_DRIVER_PATH \
 && echo "Google Chrome Driver Version $CHROME_DRIVER_VERSION"

USER ${DEFAULT_USER_ID} 
