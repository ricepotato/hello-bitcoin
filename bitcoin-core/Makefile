init:
	docker build --network=host -t bitcoin-core .

docker-push: init
	aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $(shell cat accountid.info).dkr.ecr.ap-northeast-2.amazonaws.com
	docker tag bitcoin-core:latest $(shell cat accountid.info).dkr.ecr.ap-northeast-2.amazonaws.com/bitcoin-core:$(shell cat version.info)
	docker push $(shell cat accountid.info).dkr.ecr.ap-northeast-2.amazonaws.com/bitcoin-core:$(shell cat version.info)

docker-stop:
	docker stop bitcoin-core

docker-run: init
	docker run -d --rm --name bitcoin-core -p 28332:28332 -p 18332:8332 --network bitcoin-core -v $(PWD)/bitcoin_data:/root/bitcoin_data bitcoin-core:latest
	docker logs -f bitcoin-core