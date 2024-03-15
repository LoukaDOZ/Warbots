install:
	wget https://github.com/processing/processing4/releases/download/processing-1293-4.3/processing-4.3-linux-x64.tgz
	tar -xf processing-4.3-linux-x64.tgz

uninstall:
	rm -rf processing-4.3
	rm -f processing-4.3-linux-x64.tgz

run:
	./processing-4.3/processing-java --sketch=Warbot_1_1 --run
