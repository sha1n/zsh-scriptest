MAKEFLAGS += --silent

default: test 

test: 
	./run_tests.sh .