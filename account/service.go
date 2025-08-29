package account

import "context"

type Service interface{
	PostAccount (ctx context.Context,name string )(*Account,error)
	GetAccount(ctx context.Context,id string )(*Account,error)
	GetAccounts(ctx context.Context,skip uint64,take uint64)(*Account,error)
}

type Account struct{
	ID string `json:"id"`
	Name string `json:"name"`

}

type accountService struct{
	repository Repository

}

func newService(r Repository)Service{
	return &accountService{r}
}

func (s *accountService)PostAccount(ctx context.Context,name string)(*Account,error){

}

func (s *accountService)GetAccount(ctx context.Context,id string)(*Account,error){

}

func (s *accountService) GetAccounts(ctx context.Context,skip uint64,take uint64)([]Account,error){
	
}