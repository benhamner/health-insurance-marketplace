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
	cd input/2016; unzip \*.zip
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
	cd input/2015; unzip \*.zip
	touch input/2015/.sentinel

input/2014/.sentinel:
	mkdir -p input/2014
	curl http://download.cms.gov/marketplace-puf/2014/benefits-and-cost-sharing-puf.zip -o input/2014/benefits-and-cost-sharing-puf.zip
	curl http://download.cms.gov/marketplace-puf/2014/rate-puf.zip -o input/2014/rate-puf.zip 
	curl http://download.cms.gov/marketplace-puf/2014/plan-attributes-puf.zip -o input/2014/plan-attributes-puf.zip
	curl http://download.cms.gov/marketplace-puf/2014/business-rules-puf.zip -o input/2014/business-rules-puf.zip
	curl http://download.cms.gov/marketplace-puf/2014/service-area-puf.zip -o input/2014/service-area-puf.zip
	curl http://download.cms.gov/marketplace-puf/2014/network-puf.zip -o input/2014/network-puf.zip
	cd input/2014; unzip \*.zip
	touch input/2014/.sentinel

input: input/2016/.sentinel input/2015/.sentinel input/2014/.sentinel 

output/BenefitsCostSharing.csv: input/2016/.sentinel input/2015/.sentinel input/2014/.sentinel
	mkdir -p working
	mkdir -p output
	python src/process.py
output/BusinessRules.csv: output/BenefitsCostSharing.csv
output/BusinessRules.csv: output/BenefitsCostSharing.csv
output/Crosswalk2015.csv: output/BenefitsCostSharing.csv
output/Crosswalk2016.csv: output/BenefitsCostSharing.csv
output/Network.csv: output/BenefitsCostSharing.csv
output/PlanAttributes.csv: output/BenefitsCostSharing.csv
output/Rate.csv: output/BenefitsCostSharing.csv
output/ServiceArea.csv: output/BenefitsCostSharing.csv
csv: output/BenefitsCostSharing.csv

working/noHeader/BenefitsCostSharing.csv: output/BenefitsCostSharing.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

working/noHeader/BusinessRules.csv: output/BusinessRules.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

working/noHeader/Crosswalk2015.csv: output/Crosswalk2015.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

working/noHeader/Crosswalk2016.csv: output/Crosswalk2016.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

working/noHeader/Network.csv: output/Network.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

working/noHeader/PlanAttributes.csv: output/PlanAttributes.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

working/noHeader/Rate.csv: output/Rate.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

working/noHeader/ServiceArea.csv: output/ServiceArea.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

output/database.sqlite: working/noHeader/Crosswalk2015.csv working/noHeader/Crosswalk2016.csv working/noHeader/BenefitsCostSharing.csv working/noHeader/PlanAttributes.csv working/noHeader/Rate.csv working/noHeader/Network.csv working/noHeader/BusinessRules.csv working/noHeader/ServiceArea.csv
	-rm output/database.sqlite
	sqlite3 -echo $@ < working/import.sql
db: output/database.sqlite

output/raw/.sentinel:
	mkdir -p output/raw
	cp -r input/2014 output/raw/2014
	cp -r input/2015 output/raw/2015
	cp -r input/2016 output/raw/2016
	rm output/raw/2014/*.zip
	rm output/raw/2015/*.zip
	rm output/raw/2016/*.zip
	touch output/raw/.sentinel
output-raw: output/raw/.sentinel

output/hashes.txt: output/database.sqlite output/raw/.sentinel
	-rm output/hashes.txt
	echo "Current git commit:" >> output/hashes.txt
	git rev-parse HEAD >> output/hashes.txt
	echo "\nCurrent input/ouput md5 hashes:" >> output/hashes.txt
	md5 output/*.csv >> output/hashes.txt
	md5 output/*.sqlite >> output/hashes.txt
	md5 output/raw/2014/* >> output/hashes.txt
	md5 output/raw/2015/* >> output/hashes.txt
	md5 output/raw/2016/* >> output/hashes.txt
	md5 input/2014/* >> output/hashes.txt
	md5 input/2015/* >> output/hashes.txt
	md5 input/2016/* >> output/hashes.txt
hashes: output/hashes.txt

release: output/hashes.txt
	cp -r output health-insurance-marketplace
	zip -r -X output/health-insurance-marketplace-release-`date -u +'%Y-%m-%d-%H-%M-%S'` health-insurance-marketplace/*
	rm -rf health-insurance-marketplace

all: csv db hashes release output-raw

clean:
	rm -rf working
	rm -rf output
