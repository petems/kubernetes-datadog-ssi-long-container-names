.PHONY: all
all: clean 

.PHONY: clean
clean:
	@echo "+ $@"
	@minikube delete

.PHONY: kubeboot
kubeboot:
	@echo "+ $@"
	@minikube start
	@kubectl create namespace application

.PHONY: datadog_agent_deploy
datadog_agent_deploy:
	@echo "+ $@"
	@helm install datadog-agent -f datadog-values.yaml datadog/datadog

.PHONY: datadog_agent_update
datadog_agent_update:
	@echo "+ $@"
	@helm upgrade -f datadog-values.yaml datadog-agent datadog/datadog

.PHONY: follow_pods
follow_pods:
	@echo "+ $@"
	@kubectl get pods -w

.PHONY: java_deploy
java_deploy:
	@echo "+ $@"
	@kubectl apply -f long-java-deployment.yaml

.PHONY: follow_java_pods
follow_java_pods:
	@echo "+ $@"
	@kubectl get pods -w -n application

.PHONY: datadog_logs
datadog_logs:
	@echo "+ $@"
	@kubectl logs -l app=datadog-agent-cluster-agent

.PHONY: datadog_logs_grep_63
datadog_logs_grep_63:
	@echo "+ $@"
	@kubectl logs -l app=datadog-agent-cluster-agent | grep 63
 
.PHONY: datadog_logs_follow
datadog_logs_follow:
	@echo "+ $@"
	@kubectl logs -l app=datadog-agent-cluster-agent -f