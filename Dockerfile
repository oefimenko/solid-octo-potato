# Use an official Python runtime as a base image
FROM elixir:1.4

# Set the working directory to /app
WORKDIR /skirmish

# Copy the current directory contents into the container at /app
ADD . /skirmish

RUN mix local.hex --force
RUN mix deps.get
# RUN mix deps.compile

# Make port 8880 available to the world outside this container
EXPOSE 8880
EXPOSE 22001:32001

CMD mix run --no-halt
