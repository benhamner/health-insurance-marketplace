input/2016/.sentinel:
	mkdir -p input/2016 
	curl http://download.cms.gov/marketplace-puf/2016/benefits-and-cost-sharing-puf.zip -o input/2016/benefits-and-cost-sharing-puf.zip
	curl http://download.cms.gov/marketplace-puf/2016/rate-puf.zip -o input/2016/rate-puf.zip 
	curl http://download.cms.gov/marketplace-puf/2016/plan-attributes-puf.zip -o input/2016/plan-attributes-puf.zip
	curl http://download.cms.gov/marketplace-puf/2016/business-rules-puf.zip -o input/2016/business-rules-puf.zip
	curl http://download.cms.gov/marketplace-puf/2016/service-area-puf.zip -o input/2016/service-area-puf.zip
	curl http://download.cms.gov/marketplace-puf/2016/network-puf.zip -o input/2016/network-puf.zip
	curl http://download.cms.gov/marketplace-puf/2016/plan-id-crosswalk-puf.zip -o input/2016/plan-id-crosswalk-puf.zip
	curl http://download.cms.gov/marketplace-puf/2016/machine-readable-url-puf.zip -o input/2016/machine-readable-url-puf.zip
	touch input/2016/.sentinel

input/2015/.sentinel:
	mkdir -p input/2015
	curl http://download.cms.gov/marketplace-puf/benefits-and-cost-sharing-puf.zip -o input/2015/benefits-and-cost-sharing-puf.zip
	curl http://download.cms.gov/marketplace-puf/rate-puf.zip -o input/2015/rate-puf.zip 
	curl http://download.cms.gov/marketplace-puf/plan-attributes-puf.zip -o input/2015/plan-attributes-puf.zip
	curl http://download.cms.gov/marketplace-puf/business-rules-puf.zip -o input/2015/business-rules-puf.zip
	curl http://download.cms.gov/marketplace-puf/service-area-puf.zip -o input/2015/service-area-puf.zip
	curl http://download.cms.gov/marketplace-puf/network-puf.zip -o input/2015/network-puf.zip
	curl http://download.cms.gov/marketplace-puf/plan-id-crosswalk-puf.zip -o input/2015/plan-id-crosswalk-puf.zip
	touch input/2015/.sentinel

input/2014/.sentinel:
	mkdir -p input/2014
	curl http://download.cms.gov/marketplace-puf/2014/benefits-and-cost-sharing-puf.zip -o input/2014/benefits-and-cost-sharing-puf.zip
	curl http://download.cms.gov/marketplace-puf/2014/rate-puf.zip -o input/2014/rate-puf.zip 
	curl http://download.cms.gov/marketplace-puf/2014/plan-attributes-puf.zip -o input/2014/plan-attributes-puf.zip
	curl http://download.cms.gov/marketplace-puf/2014/business-rules-puf.zip -o input/2014/business-rules-puf.zip
	curl http://download.cms.gov/marketplace-puf/2014/service-area-puf.zip -o input/2014/service-area-puf.zip
	curl http://download.cms.gov/marketplace-puf/2014/network-puf.zip -o input/2014/network-puf.zip
	curl http://download.cms.gov/marketplace-puf/2014/plan-id-crosswalk-puf.zip -o input/2014/plan-id-crosswalk-puf.zip
	touch input/2014/.sentinel

input: input/2016/.sentinel input/2015/.sentinel input/2014/.sentinel 

output/Reviews.csv: input/Reviews.txt
	mkdir -p working
	mkdir -p output
	python src/process.py
csv: output/Reviews.csv

working/noHeader/Reviews.csv: output/Reviews.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

output/database.sqlite: working/noHeader/Reviews.csv
	-rm output/database.sqlite
	sqlite3 -echo $@ < working/import.sql
db: output/database.sqlite

output/hashes.txt: output/database.sqlite
	-rm output/hashes.txt
	echo "Current git commit:" >> output/hashes.txt
	git rev-parse HEAD >> output/hashes.txt
	echo "\nCurrent input/ouput md5 hashes:" >> output/hashes.txt
	md5 output/*.csv >> output/hashes.txt
	md5 output/*.sqlite >> output/hashes.txt
	md5 input/* >> output/hashes.txt
hashes: output/hashes.txt

release: output/database.sqlite output/hashes.txt
	cp -r output health-insurance-marketplace
	zip -r -X output/health-insurance-marketplace-release-`date -u +'%Y-%m-%d-%H-%M-%S'` health-insurance-marketplace/*
	rm -rf health-insurance-marketplace

all: csv db hashes release

clean:
	rm -rf working
	rm -rf output