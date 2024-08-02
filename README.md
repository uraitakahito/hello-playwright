```console
PROJECT=$(basename `pwd`)
docker image build -t $PROJECT-image .
docker container run -it --rm --init --name $PROJECT-container $PROJECT-image
```
