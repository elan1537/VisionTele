protoc --swift_out=. --grpc-swift_out=. data.proto

/opt/homebrew/anaconda3/envs/robodk/bin/python -m grpc_tools.protoc -I . --python_out=. --grpc_python_out=. data.proto