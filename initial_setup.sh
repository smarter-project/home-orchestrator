#!/usr/bin/env bash

# For future readers: So here's the thing... right now, both the host and the guest load immediately,
# which means that we had two instances of the model loaded into memory by using this script.
#
# There is a way to unload the model from the host as seen in the Ollama docs:
# https://github.com/ollama/ollama/blob/main/docs/api.md#unload-a-model-1
#
# unload_model_from_memory() {
#    echo "Unloading model from memory..."
#    curl -X POST "${OLLAMA_HOST_URL}/api/chat" -d "{
#        \"model\": \"$OLLAMA_MODEL\",
#        \"messages\": [],
#        \"keep_alive\": 0
#    }"
# }
#
# But that wouldn't be a robust solution, and it doesn't necessarily avoid OOM, without
# signalling to the guest that the setup is complete, and then have the guest load the model on its own.
#
# So what we do instead is receive two URL's: one for the host, one for the guest.
# The host URL is the one we use to download the model, and the guest URL is the one
# we use to test the model by sending a simple prompt.

# Environment variables with defaults
export OLLAMA_MODEL=${OLLAMA_MODEL:-"llama3.2-vision:latest"}
export OLLAMA_HOST_URL=${OLLAMA_HOST_URL:-"http://localhost:11435"}
export OLLAMA_GUEST_URL=${OLLAMA_GUEST_URL:-"http://localhost:11434"}
export OLLAMA_MAX_RETRIES=${OLLAMA_MAX_RETRIES:-30}
export OLLAMA_RETRY_DELAY=${OLLAMA_RETRY_DELAY:-2}
export OLLAMA_WAIT_FOREVER=${OLLAMA_WAIT_FOREVER:0}

# Helper functions
wait_for_ollama() {
    local service_type=$1
    local url="OLLAMA_${service_type}_URL"
    url="${!url}" # Get either OLLAMA_HOST_URL or OLLAMA_GUEST_URL
    
    echo "Waiting for Ollama $service_type service to be ready..."
    for i in $(seq 1 $OLLAMA_MAX_RETRIES); do
        if curl -s "${url}/api/tags" > /dev/null; then
            echo "Ollama $service_type service is ready!"
            return 0
        fi
        
        if [ $i -eq $OLLAMA_MAX_RETRIES ]; then
            echo "Timeout waiting for Ollama $service_type service"
            return 1
        fi
        
        echo "Attempt $i/$OLLAMA_MAX_RETRIES: $service_type service not ready yet, waiting ${OLLAMA_RETRY_DELAY}s..."
        sleep $OLLAMA_RETRY_DELAY
    done
}

pull_model() {
    echo "Pulling model $OLLAMA_MODEL..."
    if ! curl -f -X POST "${OLLAMA_HOST_URL}/api/pull" -d "{\"name\": \"$OLLAMA_MODEL\"}"; then
        echo "Failed to pull model $OLLAMA_MODEL"
        return 1
    fi
}

test_model() {
    echo "Testing model with a simple prompt..."
    local RESPONSE
    RESPONSE=$(curl -s "${OLLAMA_GUEST_URL}/api/generate" -d "{
        \"model\": \"$OLLAMA_MODEL\",
        \"prompt\": \"Why is the sky blue? Answer in less than 10 words.\",
        \"stream\": false,
        \"options\": { \"seed\": 123 }
    }")

    if [ $? -ne 0 ]; then
        echo "Failed to connect to ${OLLAMA_GUEST_URL}"
        return 1
    fi

    if ! echo "$RESPONSE" | jq -e '.response' >/dev/null 2>&1; then
        echo "Invalid response format from model. Got:"
        echo "$RESPONSE" | jq '.'
        return 1
    fi

    echo "Model test successful. Response:"
    echo "$RESPONSE" | jq -c '.response'
}

# Main execution
main() {
    wait_for_ollama HOST || exit 1
    pull_model || exit 1
    wait_for_ollama GUEST || exit 1
    test_model || exit 1
    echo "Setup complete!"
    if [ ${OLLAMA_WAIT_FOREVER} -gt 0 ]; then
	while true; do
	    sleep 300
	done
    fi
}

main
