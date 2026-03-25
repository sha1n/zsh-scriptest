MAKEFLAGS += --silent

default: test 

test:
	./run_tests.sh .
	./run_tests.sh ./tests