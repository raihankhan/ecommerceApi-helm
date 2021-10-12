create_cluster:
	@kind create cluster --config helm-deploy/cluster.yaml --wait 300s
create_controller:
	@kubectl apply --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
	@echo "waiting for completing ingress-nginx-patch"
	@kubectl wait --namespace ingress-nginx --for=condition=complete job/ingress-nginx-admission-patch --timeout=500s
	@echo "job ingress-nginx-patch completed"
	@echo "waiting for controller to be ready"
	@kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=500s
	@echo "controller ready"
helm_deploy:
	@helm install apiserver-helm ./helm-deploy -n ingress-nginx
	@kubectl wait --namespace ingress-nginx --for=condition=ready pod -l app.kubernetes.io/instance=apiserver-deployment --timeout=800s
	@echo "Server ready for requests"

run: create_cluster create_controller helm_deploy