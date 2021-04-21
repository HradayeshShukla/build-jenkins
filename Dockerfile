FROM openshift/ose-jenkins-agent-base:v4.5.0.20210327.031006
ENV __doozer=update BUILD_RELEASE=202103270246.p0 BUILD_VERSION=v4.5.0 OS_GIT_MAJOR=4 OS_GIT_MINOR=5 OS_GIT_PATCH=0 OS_GIT_TREE_STATE=clean OS_GIT_VERSION=4.5.0-202103270246.p0 SOURCE_GIT_TREE_STATE=clean 
ENV __doozer=merge OS_GIT_COMMIT=a3eca23 OS_GIT_VERSION=4.5.0-202103270246.p0-a3eca23 SOURCE_DATE_EPOCH=1616672183 SOURCE_GIT_COMMIT=a3eca237b8c7b7e554139d9f1392e215f46426d6 SOURCE_GIT_TAG=a3eca23 SOURCE_GIT_URL=https://github.com/openshift/jenkins 
MAINTAINER Akram Ben Aissi <abenaiss@redhat.com>

# Labels consumed by Red Hat build service

ENV MAVEN_VERSION=3.5 \
    BASH_ENV=/usr/local/bin/scl_enable \
    ENV=/usr/local/bin/scl_enable \
    PROMPT_COMMAND=". /usr/local/bin/scl_enable" \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    MAVEN_OPTS="-Duser.home=$HOME"
# TODO: Remove MAVEN_OPTS env once cri-o pushes the $HOME variable in /etc/passwd

# Install Maven
RUN INSTALL_PKGS="java-11-openjdk-devel java-1.8.0-openjdk-devel rh-maven35*" && \
    yum install -y $INSTALL_PKGS && \
    rpm -V  java-11-openjdk-devel java-1.8.0-openjdk-devel rh-maven35 && \
    yum clean all -y && \
    mkdir -p $HOME/.m2

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ADD contrib/bin/scl_enable /usr/local/bin/scl_enable
ADD contrib/bin/configure-agent /usr/local/bin/configure-agent
ADD ./contrib/settings.xml $HOME/.m2/

RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME

USER 1001

LABEL \
        com.redhat.component="jenkins-agent-maven-35-rhel7-container" \
        name="openshift/ose-jenkins-agent-maven" \
        version="v4.5.0" \
        architecture="x86_64" \
        io.k8s.display-name="Jenkins Agent Maven" \
        io.k8s.description="The jenkins agent maven image has the maven tools on top of the jenkins slave base image." \
        io.openshift.tags="openshift,jenkins,agent,maven" \
        License="GPLv2+" \
        vendor="Red Hat" \
        io.openshift.maintainer.product="OpenShift Container Platform" \
        io.openshift.maintainer.component="Jenkins" \
        release="202103270246.p0" \
        io.openshift.build.commit.id="a3eca237b8c7b7e554139d9f1392e215f46426d6" \
        io.openshift.build.source-location="https://github.com/openshift/jenkins" \
        io.openshift.build.commit.url="https://github.com/openshift/jenkins/commit/a3eca237b8c7b7e554139d9f1392e215f46426d6"




## FROM openshift/ose-jenkins-agent-maven:v4.5 
## FROM registry.redhat.io/openshift4/ose-jenkins-agent-maven:v4.5
ARG DEFAULT_USER_ID=1001

USER root
# Setup yum repositories
#RUN yum repos --enable=rhel-7-server-extras-rpms \
# && subscription-manager repos --enable=rhel-7-server-optional-rpms \
# && subscription-manager repos --enable=rhel-7-server-rpms

RUN sleep 60

# Install Chrome
RUN cat /etc/redhat-release && yum repolist && yum -y install vulkan-loader redhat-lsb libXScrnSaver \
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
