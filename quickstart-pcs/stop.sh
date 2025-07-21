docker compose \
	-f base.yml \
	-f postgres.yml \
	-f jwt-security.yml \
	-f haproxy-api-gateway.yml \
	-f openchami-svcs.yml \
	-f autocert.yml \
	-f pcs.yml \
	-f etcd.yml \
	-f configurator.yml down

docker volume rm $(docker volume ls -q)