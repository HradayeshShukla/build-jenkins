FROM registry.redhat.io/rhel7:latest
##FROM registry.redhat.io/openshift/jenkins-agent-maven:v4.5

USER root
RUN sleep 400
# Copy entitlements
COPY ./2144838495922035268*.pem /etc/pki/entitlement
# Copy repository configuration 
# COPY ./yum.repos.d /etc/yum.repos.d
# Delete /etc/rhsm-host to use entitlements from the build container
RUN sed -i".org" -e "s#^enabled=1#enabled=0#g" /etc/yum/pluginconf.d/subscription-manager.conf 

#RUN cat /etc/yum/pluginconf.d/subscription-manager.conf

RUN yum clean all 

#RUN yum-config-manager

# yum repository info provided by Satellite
RUN rm /etc/rhsm-host && \
yum repolist --verbose &&\
cat /etc/redhat-release && yum repolist && yum -y install vulkan redhat-lsb libXScrnSaver \
&& curl -o google-chrome-stable_current_x86_64.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm \
&& yum -y localinstall google-chrome-stable_current_x86_64.rpm

# Remove entitlements
rm -rf /etc/pki/entitlement


### From original Dockerfile ###
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
