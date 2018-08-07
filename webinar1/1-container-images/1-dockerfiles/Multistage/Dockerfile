# This is the base for our build step container
# which has all our build essentials
FROM ubuntu AS buildstep
RUN apt-get update && apt-get install -y build-essential gcc
COPY hello.c /app/hello.c
WORKDIR /app
RUN gcc -o hello hello.c && chmod +x hello

# This is our runtime container that will end up
# running on the device.
FROM ubuntu

# Defines our working directory in container
RUN mkdir -p /usr/src/app/
WORKDIR /usr/src/app

# Copy our artifact into our deployable container context.
COPY --from=buildstep /app/hello ./hello

# Copy our start script into our deployable container context.
COPY ./start.sh ./start.sh

# Enable systemd init system in container
ENV INITSYSTEM=on

# server.js will run when container starts up on the device
CMD ["bash", "/usr/src/app/start.sh"]
