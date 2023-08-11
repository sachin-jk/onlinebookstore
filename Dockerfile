FROM ubuntu:latest AS builder

RUN apt update && apt install -y git

WORKDIR /app

# If our repo is private
# ARG GITHUB_PAT
# RUN git clone -b master --single-branch https://aravind-etagi:${GITHUB_PAT}@github.com/aravind-etagi/onlinebookstore.git && \
	# mvn -f onlinebookstore/pom.xml clean install

# RUN git clone -b master --single-branch https://github.com/aravind-etagi/onlinebookstore.git && \
# 	mvn -f onlinebookstore/pom.xml clean install

RUN git clone -b main --single-branch https://github.com/OpqTech/tomcat-config.git



FROM tomcat:jre11

WORKDIR /usr/local/tomcat

COPY --from=builder /app/tomcat-config/ tomcat-config/

RUN rm -rf webapps && \
	mv webapps.dist webapps && \
	cp ./tomcat-config/context.xml ./webapps/host-manager/META-INF/context.xml && \
	cp ./tomcat-config/context.xml ./webapps/manager/META-INF/context.xml && \
	cp ./tomcat-config/tomcat-users.xml ./conf/tomcat-users.xml && \
	rm -rf ./tomcat-config
	
COPY onlinebookstore.war webapps/

EXPOSE 8080
