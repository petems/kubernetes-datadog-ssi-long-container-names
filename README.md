# kubernetes-datadog-ssi-long-container-names

A basic recreation of an issue where container names are too long (combination of name plus detected_langs is over 63 characters)

The setup is as follows:

* Minikube 
* Datadog Agent 
* A basic Python deployment with a purposefully long name

## Start minikube

```
$ minikube delete
$ minikube start
```

## Deploy datadog agent

```
$ kubectl create secret generic datadog-secret --from-literal api-key=YOURKEYHERE
$ helm install datadog-agent -f datadog-values.yaml datadog/datadog
```

## Wait for Datadog agent to confirm healthy

```
$ kubectl get pods -w
NAME                                           READY   STATUS    RESTARTS      AGE
datadog-agent-2bgmt                            3/3     Running   0             89s
datadog-agent-cluster-agent-6f446955b4-zjl55   0/1     Running   3 (47s ago)   89s
datadog-agent-cluster-agent-6f446955b4-zjl55   1/1     Running   3 (48s ago)   90s
```

## Deploy the Python app

```
$ kubectl apply -f long-python-deployment.yaml
```

## Wait for Python app to confirm healthy

```
$ kubectl get pods -n=application
NAME                                          READY   STATUS    RESTARTS   AGE
python-and-ruby-deployment-7c884477f9-nrbd5   1/1     Running   0          9m53s
python-and-ruby-deployment-7c884477f9-rl8gz   1/1     Running   0          9m53s
```

## Observe the issue with too long of a container name

```
$ kubectl logs -l app=datadog-agent-cluster-agent
...
2025-05-16 15:24:25 UTC | CLUSTER | ERROR | (pkg/clusteragent/languagedetection/patcher.go:214 in func2) | Failed processing Deployment: application/python-and-ruby-deployment. It will be retried later: annotations: Invalid value: "internal.dd.datadoghq.com/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.detected_langs": name part must be no more than 63 characters
```

## Change the image name to something shorter to get SSI to work

You have two choices how to do this

One: edit the deployment directly to change it:

```
$ kubectl edit deployment/java-app -n java-app
```

Two: edit the deployment values yaml and do a new apply:

```
$ kubectl apply -f deployment-with-shorter-name.yaml
```

NB: Since we've set the strategy to type "Recreate" it'll force a new deployment immediately, but with rolling updates it would gracefully do a rolling update instead.