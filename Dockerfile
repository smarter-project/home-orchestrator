FROM alpine:3.19

# Install required tools
RUN apk add --no-cache \
    curl \
    jq \
    bash

# Set working directory
WORKDIR /app

# Copy the setup script
COPY initial_setup.sh .

# Make the script executable
RUN chmod +x initial_setup.sh

# Set the entrypoint
ENTRYPOINT ["./initial_setup.sh"] 