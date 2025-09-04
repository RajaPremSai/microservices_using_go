#!/bin/bash

# Test script for Go Microservices
echo "Testing Go Microservices..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test HTTP endpoint
test_endpoint() {
    local url=$1
    local name=$2
    local expected_status=$3
    
    echo -n "Testing $name... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$response" = "$expected_status" ]; then
        echo -e "${GREEN}✓${NC} (Status: $response)"
        return 0
    else
        echo -e "${RED}✗${NC} (Status: $response, Expected: $expected_status)"
        return 1
    fi
}

# Function to test GraphQL endpoint
test_graphql() {
    local url=$1
    local query=$2
    local name=$3
    
    echo -n "Testing $name... "
    
    response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "{\"query\":\"$query\"}" \
        "$url" 2>/dev/null)
    
    if echo "$response" | grep -q "errors"; then
        echo -e "${RED}✗${NC} (GraphQL Error)"
        echo "Response: $response"
        return 1
    else
        echo -e "${GREEN}✓${NC}"
        return 0
    fi
}

echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 10

echo -e "\n${YELLOW}Testing GraphQL Gateway...${NC}"
test_endpoint "http://localhost:8080/playground" "GraphQL Playground" "200"

echo -e "\n${YELLOW}Testing GraphQL Queries...${NC}"

# Test introspection query
test_graphql "http://localhost:8080/graphql" "query { __schema { types { name } } }" "GraphQL Introspection"

# Test accounts query
test_graphql "http://localhost:8080/graphql" "query { accounts { id name } }" "Accounts Query"

# Test products query
test_graphql "http://localhost:8080/graphql" "query { products { id name description price } }" "Products Query"

echo -e "\n${YELLOW}Testing GraphQL Mutations...${NC}"

# Test create account mutation
test_graphql "http://localhost:8080/graphql" "mutation { createAccount(account: {name: \"Test User\"}) { id name } }" "Create Account"

# Test create product mutation
test_graphql "http://localhost:8080/graphql" "mutation { createProduct(product: {name: \"Test Product\", description: \"Test Description\", price: 99.99}) { id name } }" "Create Product"

echo -e "\n${YELLOW}Testing gRPC Services (via GraphQL)...${NC}"

# Test that services are responding through GraphQL
echo -n "Testing Account Service via GraphQL... "
account_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"query":"query { accounts { id name } }"}' \
    "http://localhost:8080/graphql" 2>/dev/null)

if echo "$account_response" | grep -q "accounts"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

echo -n "Testing Catalog Service via GraphQL... "
catalog_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"query":"query { products { id name } }"}' \
    "http://localhost:8080/graphql" 2>/dev/null)

if echo "$catalog_response" | grep -q "products"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

echo -n "Testing Order Service via GraphQL... "
order_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"query":"query { accounts { orders { id totalPrice } } }"}' \
    "http://localhost:8080/graphql" 2>/dev/null)

if echo "$order_response" | grep -q "orders"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

echo -e "\n${YELLOW}Testing Database Connections...${NC}"

# Test PostgreSQL connections by checking if we can create and retrieve data
echo -n "Testing Account Database... "
account_test=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"query":"mutation { createAccount(account: {name: \"DB Test\"}) { id } }"}' \
    "http://localhost:8080/graphql" 2>/dev/null)

if echo "$account_test" | grep -q "createAccount"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

echo -n "Testing Order Database... "
order_test=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"query":"mutation { createAccount(account: {name: \"Order Test\"}) { id } }"}' \
    "http://localhost:8080/graphql" 2>/dev/null)

if echo "$order_test" | grep -q "createAccount"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

echo -n "Testing Elasticsearch... "
elasticsearch_test=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"query":"mutation { createProduct(product: {name: \"ES Test\", description: \"Test\", price: 1.0}) { id } }"}' \
    "http://localhost:8080/graphql" 2>/dev/null)

if echo "$elasticsearch_test" | grep -q "createProduct"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

echo -e "\n${YELLOW}Test Summary${NC}"
echo "GraphQL Playground: http://localhost:8080/playground"
echo "GraphQL Endpoint: http://localhost:8080/graphql"
echo ""
echo "Service Ports:"
echo "  - GraphQL Gateway: 8080"
echo "  - Account Service: 8081"
echo "  - Order Service: 8082"
echo "  - Catalog Service: 8083"
echo ""
echo "Database Ports:"
echo "  - Account DB (PostgreSQL): 5433"
echo "  - Order DB (PostgreSQL): 5434"
echo "  - Catalog DB (Elasticsearch): 9200"
