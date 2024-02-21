.PHONY: schema
schema:
	curl -sSfLo Succ/Github/schema.graphqls  https://docs.github.com/public/schema.docs.graphql

.PHONY: generate
generate:
	./apollo-ios-cli generate
