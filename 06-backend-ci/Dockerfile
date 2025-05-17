# Multistage docker file 
# for Build
FROM node:20 AS builder
WORKDIR /opt/server
COPY package.json .
COPY *.js .
RUN npm install


# Multistage docker file, below file creates the image. It copies /opt/server from above build and uses it 
# copy /opt/server from above file to below file
FROM node:20.18.0-alpine3.20
EXPOSE 8080
ENV DB_HOST="mysql"
# add expense group and expense user
RUN addgroup -S expence && adduser -S expense -G expense && \
     mkdir /opt/server && \
     chown -R expense:expense /opt/server
WORKDIR /opt/server
COPY --from=builder /opt/server /opt/server
USER expense
CMD ["node", "index.js"]

# with the above docker file code, the image size is of 141MB











#BEFORE BEST PRACTICE IMPLEMENTATION - Docker image size is 1.1GB with below file

# instead of taking alma linux as base os and installing node js version 20, we can use official node js image with version 20.
FROM node:20
# backend uses 8080 port. EXPOSE command is for port information purpose. It does not open the port
EXPOSE 8080
# we have to give private IP of mysql container. Its IP is not constant , it changes frequently. 
# Hence we use container name here, to connect backend to DB. While running mysql container, give container name as 'mysql'
ENV DB_HOST="mysql"

RUN mkdir /opt/server
WORKDIR /opt/server
COPY package.json .
COPY *.js .
# install the dependencies
RUN npm install
CMD ["node", "index.js"]




