FROM openjdk:17-bullseye

LABEL maintainer="whoami <whoami@gmail.com>" version="9.2.1"

ARG ATLASSIAN_PRODUCTION=confluence
ARG APP_NAME=confluence
ARG APP_VERSION=9.2.1
ARG AGENT_VERSION=1.3.3
ARG MYSQL_DRIVER_VERSION=8.4.0

ENV CONFLUENCE_HOME=/var/confluence \
    CONFLUENCE_INSTALL=/opt/confluence \
    AGENT_PATH=/var/agent \
    AGENT_FILENAME=atlassian-agent.jar \
    LIB_PATH=/confluence/WEB-INF/lib

ENV JAVA_OPTS="-javaagent:${AGENT_PATH}/${AGENT_FILENAME} ${JAVA_OPTS}"

RUN mkdir -p ${CONFLUENCE_INSTALL} ${CONFLUENCE_HOME} ${AGENT_PATH} ${CONFLUENCE_INSTALL}${LIB_PATH} \
&& curl -o ${AGENT_PATH}/${AGENT_FILENAME}  https://github.com/peoplelikethesun/confluence/releases/download/v${AGENT_VERSION}/atlassian-agent.jar -L \
&& curl -o /tmp/atlassian.tar.gz https://product-downloads.atlassian.com/software/confluence/downloads/atlassian-${APP_NAME}-${APP_VERSION}.tar.gz -L \
&& tar xzf /tmp/atlassian.tar.gz -C /opt/confluence/ --strip-components 1 \
&& rm -f /tmp/atlassian.tar.gz \
&& sed -i 's/1024/2048/g' ${CONFLUENCE_INSTALL}/bin/setenv.sh \
&& sed -i 's/256/512/g' ${CONFLUENCE_INSTALL}/bin/setenv.sh \
&& curl -o ${CONFLUENCE_INSTALL}/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar https://github.com/peoplelikethesun/confluence/releases/download/${MYSQL_DRIVER_VERSION}/mysql-connector-j-${MYSQL_DRIVER_VERSION}.jar  -L \
&& cp ${CONFLUENCE_INSTALL}/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar ${CONFLUENCE_INSTALL}${LIB_PATH}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar \
&& echo "confluence.home = ${CONFLUENCE_HOME}" > ${CONFLUENCE_INSTALL}/${ATLASSIAN_PRODUCTION}/WEB-INF/classes/confluence-init.properties

WORKDIR $CONFLUENCE_INSTALL
EXPOSE 8090

ENTRYPOINT ["/opt/confluence/bin/start-confluence.sh", "-fg"]
