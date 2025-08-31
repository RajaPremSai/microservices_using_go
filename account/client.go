package account

import (
	"github.com/rajapremsai/go_microservices/account/pb/github.com/rajapremsai/go_microservices/account/pb"
	"google.golang.org/grpc"
)

type Client struct{
	conn *grpc.ClientConn
	service pb.AccountServiceClient
}

func NewClient(url string)(*Client , error){
	conn, err := grpc.Dial(url,grpc.WithInsecure())
	if err!=nil{
		return nil,err
	}
	c := pb.NewAccountServiceClient(conn)
	return &Client{conn,c},nil

}

func (c *Client)Close(){
	
}
