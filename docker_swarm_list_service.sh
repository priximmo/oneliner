for id in $(docker service ls --format "{{.ID}}");do docker service ps $id;done
