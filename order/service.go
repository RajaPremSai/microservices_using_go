package order

import (
	"context"
	"time"
)

type Service interface{
	PostOrder(ctx context.Context,accountID string,products []OrderedProduct)(*Order , error)
	GetOrdersForAccount(ctx context.Context,accountID string)([]Order,error)
}

type Order struct{
	ID string
	CreatedAt time.Time
	TotalPrice float64
	AccountID string
	Products []OrderedProduct
}

type OrderedProduct struct{
	ID string
	Name string
	Desciption string
	Price float64
	Quantity uint32
}

type orderedService struct{
	repository Repository
}

func NewService(r Repository)Service{
	return &orderedService{r}
}

func (s orderedService)PostOrder(ctx context.Context,accountID string,products []OrderedProduct)(*Order , error){

}

func (s orderedService)GetOrdersForAccount(ctx context.Context,accountID string)([]Order,error){

}