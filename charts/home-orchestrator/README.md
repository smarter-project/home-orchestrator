# home-orchestrator

This chart deploys home-orchestrator

## TL;DR

```console
helm repo add home-orchestrator https://smarter-project.github.io/home-orchestrator/
helm install --create-namespace --namespace <namespace to use> home-orchestrator home-orchestrator/home-orchestrator
```

# Overview

The home-orchestrator manages ML models to demonstrate a home security application.

# Prerequisites

This chart assumes a full deployment of k3s with traefik, etc.

* k3s 1.25+
* Helm 3.2.0+

# Uninstalling the Chart

```
helm delete home-orchestrator --namespace <namespace to use>
```

# Parameters

## Common parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
