docker compose \
	-f base.yml \
	-f postgres.yml \
	-f jwt-security.yml \
	-f haproxy-api-gateway.yml \
	-f openchami-svcs.yml \
	-f autocert.yml \
	-f coredhcp.yml \
	-f pcs.yml \
	-f vault.yml \
	-f etcd.yml \
	-f rfe.yml \
	-f configurator.yml down

docker volume rm $(docker volume ls -q)