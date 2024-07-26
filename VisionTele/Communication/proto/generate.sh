protoc --swift_out=. --grpc-swift_out=. data.proto

/opt/homebrew/anaconda3/envs/robodk/bin/python -m grpc_tools.protoc -I . --python_out=../../../Python --grpc_python_out=../../../Python data.proto