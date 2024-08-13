# Generated by the gRPC Python protocol compiler plugin. DO NOT EDIT!
"""Client and server classes corresponding to protobuf-defined services."""
import grpc

import data_pb2 as data__pb2


class FrameTrackingServiceStub(object):
    """Missing associated documentation comment in .proto file."""

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.streamFrameUpdates = channel.unary_stream(
                '/frametracking.FrameTrackingService/streamFrameUpdates',
                request_serializer=data__pb2.FrameUpdate.SerializeToString,
                response_deserializer=data__pb2.FrameUpdate.FromString,
                )


class FrameTrackingServiceServicer(object):
    """Missing associated documentation comment in .proto file."""

    def streamFrameUpdates(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_FrameTrackingServiceServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'streamFrameUpdates': grpc.unary_stream_rpc_method_handler(
                    servicer.streamFrameUpdates,
                    request_deserializer=data__pb2.FrameUpdate.FromString,
                    response_serializer=data__pb2.FrameUpdate.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'frametracking.FrameTrackingService', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))


 # This class is part of an EXPERIMENTAL API.
class FrameTrackingService(object):
    """Missing associated documentation comment in .proto file."""

    @staticmethod
    def streamFrameUpdates(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_stream(request, target, '/frametracking.FrameTrackingService/streamFrameUpdates',
            data__pb2.FrameUpdate.SerializeToString,
            data__pb2.FrameUpdate.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)
