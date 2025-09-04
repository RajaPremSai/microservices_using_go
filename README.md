# Go Microservices with GraphQL Gateway

This project implements a microservices architecture using Go, gRPC, and GraphQL. It consists of three microservices (Account, Catalog, Order) with a GraphQL gateway that provides a unified API.

## Architecture

- **Account Service**: Manages user accounts using PostgreSQL
- **Catalog Service**: Manages products using Elasticsearch
- **Order Service**: Manages orders using PostgreSQL and integrates with Account and Catalog services
- **GraphQL Gateway**: Provides a unified GraphQL API that aggregates all services

## Services

### Account Service (Port 8081)
- **Database**: PostgreSQL
- **Features**: Create, read, and list accounts
- **gRPC Endpoints**: PostAccount, GetAccount, GetAccounts

### Catalog Service (Port 8083)
- **Database**: Elasticsearch
- **Features**: Create, read, list, and search products
- **gRPC Endpoints**: PostProduct, GetProduct, GetProducts

### Order Service (Port 8082)
- **Database**: PostgreSQL
- **Features**: Create orders and retrieve orders for accounts
- **gRPC Endpoints**: PostOrder, GetOrdersForAccount
- **Dependencies**: Account Service, Catalog Service

### GraphQL Gateway (Port 8080)
- **Features**: Unified GraphQL API
- **Playground**: http://localhost:8080/playground
- **GraphQL Endpoint**: http://localhost:8080/graphql

## Prerequisites

- Docker and Docker Compose
- Go 1.21+ (for local development)

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd go_microservices
   ```

2. **Start all services with Docker Compose**
   ```bash
   docker-compose up --build
   ```

3. **Access the GraphQL Playground**
   - Open http://localhost:8080/playground in your browser
   - Explore the GraphQL schema and test queries/mutations

## GraphQL Schema

### Queries
```graphql
# Get all accounts with pagination
query GetAccounts($pagination: PaginationInput) {
  accounts(pagination: $pagination) {
    id
    name
    orders {
      id
      createdAt
      totalPrice
      products {
        id
        name
        description
        price
        quantity
      }
    }
  }
}

# Get all products with search
query GetProducts($pagination: PaginationInput, $query: String) {
  products(pagination: $pagination, query: $query) {
    id
    name
    description
    price
  }
}
```

### Mutations
```graphql
# Create a new account
mutation CreateAccount($account: AccountInput!) {
  createAccount(account: $account) {
    id
    name
  }
}

# Create a new product
mutation CreateProduct($product: ProductInput!) {
  createProduct(product: $product) {
    id
    name
    description
    price
  }
}

# Create a new order
mutation CreateOrder($order: OrderInput!) {
  createOrder(order: $order) {
    id
    createdAt
    totalPrice
    products {
      id
      name
      description
      price
      quantity
    }
  }
}
```

## Development

### Local Development

1. **Start databases only**
   ```bash
   docker-compose up account_db order_db catalog_db
   ```

2. **Run services individually**
   ```bash
   # Account service
   cd account/cmd/account
   DATABASE_URL="postgres://account_user:account_pass@localhost:5433/account_db?sslmode=disable" go run .

   # Catalog service
   cd catalog/cmd/catalog
   ELASTICSEARCH_URL="http://localhost:9200" go run .

   # Order service
   cd order/cmd/order
   DATABASE_URL="postgres://order_user:order_pass@localhost:5434/order_db?sslmode=disable" \
   ACCOUNT_SERVICE_URL="localhost:8081" \
   CATALOG_SERVICE_URL="localhost:8083" go run .

   # GraphQL gateway
   cd graphql
   ACCOUNT_SERVICE_URL="localhost:8081" \
   CATALOG_SERVICE_URL="localhost:8083" \
   ORDER_SERVICE_URL="localhost:8082" go run .
   ```

### Building Docker Images

```bash
# Build individual services
docker build -f account/app.dockerfile -t account-service ./account
docker build -f catalog/app.dockerfile -t catalog-service ./catalog
docker build -f order/app.dockerfile -t order-service ./order
docker build -f graphql/app.dockerfile -t graphql-gateway ./graphql
```

## Database Schemas

### Account Database (PostgreSQL)
```sql
CREATE TABLE accounts(
    id CHAR(27) PRIMARY KEY,
    name VARCHAR(24) NOT NULL
);
```

### Order Database (PostgreSQL)
```sql
CREATE TABLE orders(
    id CHAR(27) PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    account_id CHAR(27) NOT NULL,
    total_price MONEY NOT NULL
);

CREATE TABLE order_products(
    order_id CHAR(27) REFERENCES orders (id) ON DELETE CASCADE,
    product_id CHAR(27),
    quantity INT NOT NULL,
    PRIMARY KEY (order_id, product_id)
);
```

### Catalog Database (Elasticsearch)
- **Index**: `catalog`
- **Type**: `product`
- **Fields**: `name`, `description`, `price`

## API Endpoints

### gRPC Services
- **Account Service**: `localhost:8081`
- **Catalog Service**: `localhost:8083`
- **Order Service**: `localhost:8082`

### GraphQL Gateway
- **GraphQL Endpoint**: `http://localhost:8080/graphql`
- **Playground**: `http://localhost:8080/playground`

## Environment Variables

### Account Service
- `DATABASE_URL`: PostgreSQL connection string

### Catalog Service
- `ELASTICSEARCH_URL`: Elasticsearch connection URL

### Order Service
- `DATABASE_URL`: PostgreSQL connection string
- `ACCOUNT_SERVICE_URL`: Account service gRPC URL
- `CATALOG_SERVICE_URL`: Catalog service gRPC URL

### GraphQL Gateway
- `ACCOUNT_SERVICE_URL`: Account service gRPC URL
- `CATALOG_SERVICE_URL`: Catalog service gRPC URL
- `ORDER_SERVICE_URL`: Order service gRPC URL

## Testing

### Test GraphQL Queries

1. **Create an account**
   ```graphql
   mutation {
     createAccount(account: {name: "John Doe"}) {
       id
       name
     }
   }
   ```

2. **Create a product**
   ```graphql
   mutation {
     createProduct(product: {
       name: "Laptop"
       description: "High-performance laptop"
       price: 999.99
     }) {
       id
       name
       description
       price
     }
   }
   ```

3. **Create an order**
   ```graphql
   mutation {
     createOrder(order: {
       accountId: "ACCOUNT_ID_HERE"
       products: [{
         id: "PRODUCT_ID_HERE"
         quantity: 2
       }]
     }) {
       id
       createdAt
       totalPrice
       products {
         id
         name
         price
         quantity
       }
     }
   }
   ```

## Troubleshooting

### Common Issues

1. **Database Connection Issues**
   - Ensure PostgreSQL and Elasticsearch containers are running
   - Check connection strings in environment variables

2. **gRPC Connection Issues**
   - Verify service URLs and ports
   - Check if services are running and accessible

3. **GraphQL Schema Issues**
   - Regenerate GraphQL code: `go run github.com/99designs/gqlgen generate`
   - Check schema.graphql file for syntax errors

### Logs

View logs for specific services:
```bash
docker-compose logs account
docker-compose logs catalog
docker-compose logs order
docker-compose logs graphql
```


## License

This project is licensed under the MIT License.
