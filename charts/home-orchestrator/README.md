# home-orchestrator

This chart deploys home-orchestrator

## TL;DR

```console
helm install --create-namespace --namespace <namespace to use> home-orchestrator home-orchestrator
```

# Overview

The home-orchestrator manages ML models to demonstrate a home security application.

# Prerequisites

This chart assumes a full deployment of k3s with traefik, etc.

* k3s 1.25+
* Helm 3.2.0+

# Uninstalling the Chart

```
helm delete home-security --namespace <namespace to use>
```

# Parameters

## Common parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
