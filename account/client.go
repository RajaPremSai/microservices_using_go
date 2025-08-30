package account

import (
	// pb "github.com/rajapremsai/go_microservices/account/pb/github.com/rajapremsai/go_microservices/account/pb/account_grpc.pb.go"
	"google.golang.org/grpc"
	"github.com/rajapremsai/go_microservices/account/pb/github.com/rajapremsai/go_microservices/account/pb/account_grpc.pb"
)

type Client struct{
	conn *grpc.ClientConn
	service pb.AccountServiceClient
}

